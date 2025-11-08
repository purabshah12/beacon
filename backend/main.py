from flask import Flask, request, jsonify, send_from_directory
from flask_cors import CORS, cross_origin
import os
os.environ["TF_ENABLE_ONEDNN_OPTS"] = "0"
import tensorflow as tf
tf.get_logger().setLevel("ERROR")
import glob
from transformers import CLIPProcessor, CLIPModel
from PIL import Image
import math

app = Flask(__name__)
CORS(app)

NGROK_BASE_URL = 'https://subtransparently-unnoting-malaysia.ngrok-free.dev'
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
UPLOAD_FOLDER = os.path.join(BASE_DIR, 'uploads')
os.makedirs(UPLOAD_FOLDER, exist_ok=True)
print(f"Upload folder: {os.path.abspath(UPLOAD_FOLDER)}")

model = CLIPModel.from_pretrained("openai/clip-vit-base-patch32")
processor = CLIPProcessor.from_pretrained("openai/clip-vit-base-patch32")

def parse_filename_metadata(filename):
    """
    Parse metadata from filename
    Format: originalname__foundLat_foundLon__pickupLocation.ext
    Returns: (found_lat, found_lon, pickup_location)
    """
    try:
        parts = filename.split('__')
        if len(parts) >= 3:
            # Extract location coordinates
            location_part = parts[1]
            if location_part != "NoGPS":
                coords = location_part.split('_')
                if len(coords) >= 2:
                    found_lat = float(coords[0])
                    found_lon = float(coords[1])
                else:
                    found_lat, found_lon = None, None
            else:
                found_lat, found_lon = None, None

            # Extract pickup location (remove file extension)
            pickup_location = parts[2].rsplit('.', 1)[0].replace('_', ' ')

            return found_lat, found_lon, pickup_location
        else:
            # Old format fallback
            if '__' in filename:
                pickup_location = filename.split('__')[1].rsplit('.', 1)[0].replace('_', ' ')
                return None, None, pickup_location
            return None, None, 'Unknown'
    except Exception as e:
        print(f"Error parsing filename {filename}: {e}")
        return None, None, 'Unknown'

def calculate_distance(lat1, lon1, lat2, lon2):
    """
    Calculate distance between two GPS coordinates in kilometers using Haversine formula
    """
    if lat1 is None or lon1 is None or lat2 is None or lon2 is None:
        return float('inf')

    # Earth's radius in kilometers
    R = 6371.0

    # Convert to radians
    lat1_rad = math.radians(lat1)
    lon1_rad = math.radians(lon1)
    lat2_rad = math.radians(lat2)
    lon2_rad = math.radians(lon2)

    # Haversine formula
    dlat = lat2_rad - lat1_rad
    dlon = lon2_rad - lon1_rad
    a = math.sin(dlat / 2)**2 + math.cos(lat1_rad) * math.cos(lat2_rad) * math.sin(dlon / 2)**2
    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
    distance = R * c

    return distance

@app.route('/upload', methods=['POST'])
def upload_file():
    if 'file' not in request.files:
        print("No file part in request")
        return jsonify({'success': False, 'error': 'No file part'}), 400

    file = request.files['file']
    if file.filename == '':
        print("No selected file")
        return jsonify({'success': False, 'error': 'No selected file'}), 400

    # Get found location (from EXIF or live GPS) - used for matching
    found_latitude = request.form.get('foundLatitude')
    found_longitude = request.form.get('foundLongitude')

    # Get pickup location (where item can be retrieved) - used for display
    pickup_location = request.form.get('pickupLocation', 'Unknown')

    print(f"Received file: {file.filename}")
    print(f"Found Location (for matching): Lat={found_latitude}, Lon={found_longitude}")
    print(f"Pickup Location (for display): {pickup_location}")

    # Create filename with embedded metadata
    # Format: originalname__foundLat_foundLon__pickupLocation.ext
    filename_parts = file.filename.rsplit('.', 1)
    base_name = filename_parts[0]
    extension = filename_parts[1] if len(filename_parts) > 1 else 'jpg'

    # Build filename with location data
    location_part = f"{found_latitude}_{found_longitude}" if found_latitude and found_longitude else "NoGPS"
    pickup_part = pickup_location.replace(' ', '_')

    filename = f"{base_name}__{location_part}__{pickup_part}.{extension}"
    file_path = os.path.join(UPLOAD_FOLDER, filename)

    try:
        file.save(file_path)
        if os.path.exists(file_path):
            print(f"File saved successfully: {file_path}")
        else:
            print(f"File save failed: {file_path}")
            return jsonify({'success': False, 'error': 'File not saved to disk'}), 500
    except Exception as e:
        print(f"Error saving file: {e}")
        return jsonify({'success': False, 'error': f"Failed to save file: {e}"}), 500

    file_url = f"{NGROK_BASE_URL}/uploads/{filename}"
    print(f"Uploaded file URL: {file_url}")
    return jsonify({
        'success': True,
        'filename': filename,
        'url': file_url,
        'foundLocation': f"{found_latitude},{found_longitude}" if found_latitude and found_longitude else None,
        'pickupLocation': pickup_location
    }), 200

@app.route('/match', methods=['POST'])
@cross_origin()
def find_match():
    data = request.get_json()
    user_prompt = data.get('description', '')
    lost_location_text = data.get('lostLocation', 'Unknown')  # Text location (building name)
    lost_latitude = data.get('lostLatitude')  # GPS coordinates if provided
    lost_longitude = data.get('lostLongitude')

    if not user_prompt:
        return jsonify({'error': 'No description provided'}), 400

    print(f"Searching for: '{user_prompt}'")
    print(f"Lost location text: {lost_location_text}")
    print(f"Lost GPS coords: {lost_latitude}, {lost_longitude}")

    image_paths = glob.glob(f"{UPLOAD_FOLDER}/*.jpg") + \
                   glob.glob(f"{UPLOAD_FOLDER}/*.jpeg") + \
                   glob.glob(f"{UPLOAD_FOLDER}/*.png")
    if not image_paths:
        return jsonify({'error': 'No images found'}), 404

    images = []
    valid_paths = []
    metadata_list = []

    for path in image_paths:
        try:
            img = Image.open(path).convert("RGB")
            images.append(img)
            valid_paths.append(path)

            # Parse filename metadata
            filename = os.path.basename(path)
            found_lat, found_lon, pickup_loc = parse_filename_metadata(filename)
            metadata_list.append({
                'found_lat': found_lat,
                'found_lon': found_lon,
                'pickup_location': pickup_loc
            })
        except Exception as e:
            print(f"Skipping {path}: {e}")

    if not images:
        return jsonify({'error': 'No valid images loaded'}), 500

    # Step 1: Get description-based confidence scores using CLIP
    text_prompts = [user_prompt]
    inputs = processor(text=text_prompts, images=images, return_tensors="pt", padding=True)
    outputs = model(**inputs)
    logits = outputs.logits_per_image
    probs = logits.softmax(dim=0)

    # Create a list of candidates with scores and metadata
    candidates = []
    for i in range(len(probs)):
        confidence = probs[i, 0].item()
        path = valid_paths[i]
        metadata = metadata_list[i]

        # Calculate distance if both locations are available
        distance = float('inf')
        if lost_latitude and lost_longitude and metadata['found_lat'] and metadata['found_lon']:
            distance = calculate_distance(
                float(lost_latitude), float(lost_longitude),
                metadata['found_lat'], metadata['found_lon']
            )

        candidates.append({
            'path': path,
            'confidence': confidence,
            'distance': distance,
            'metadata': metadata
        })

        print(f"Candidate: {os.path.basename(path)} - Confidence: {confidence:.4f}, Distance: {distance:.2f}km")

    # Step 2: Sort by confidence first (descending)
    candidates.sort(key=lambda x: x['confidence'], reverse=True)

    # Step 3: Check for ties (candidates within 10% of the best confidence)
    best_confidence = candidates[0]['confidence']
    tie_threshold = best_confidence * 0.9  # 10% threshold

    tied_candidates = [c for c in candidates if c['confidence'] >= tie_threshold]

    if len(tied_candidates) > 1 and lost_latitude and lost_longitude:
        # Step 4: Use location as tiebreaker - sort tied candidates by distance
        print(f"Found {len(tied_candidates)} candidates with similar confidence, using location as tiebreaker")
        tied_candidates.sort(key=lambda x: x['distance'])
        best_match = tied_candidates[0]
        print(f"Best match after location tiebreaker: {os.path.basename(best_match['path'])} (distance: {best_match['distance']:.2f}km)")
    else:
        # No ties or no location provided, use the highest confidence
        best_match = candidates[0]
        print(f"Best match by confidence: {os.path.basename(best_match['path'])}")

    # Prepare response
    best_filename = os.path.basename(best_match['path'])
    best_image_url = f"{NGROK_BASE_URL}/uploads/{best_filename}"
    found_lat = best_match['metadata']['found_lat']
    found_lon = best_match['metadata']['found_lon']
    pickup_location = best_match['metadata']['pickup_location']

    found_location_str = f"{found_lat},{found_lon}" if found_lat and found_lon else None

    print(f"Returning best match:")
    print(f"  URL: {best_image_url}")
    print(f"  Confidence: {best_match['confidence']:.4f}")
    print(f"  Found at: {found_location_str}")
    print(f"  Pickup at: {pickup_location}")

    return jsonify({
        'best_match': best_image_url,
        'confidence': best_match['confidence'],
        'foundLocation': found_location_str,
        'pickupLocation': pickup_location
    }), 200

@app.route('/uploads/<path:filename>')
@cross_origin()
def serve_uploaded_file(filename):
    file_path = os.path.join(UPLOAD_FOLDER, filename)
    if os.path.exists(file_path):
        print(f"File found, serving: {filename}")
        return send_from_directory(UPLOAD_FOLDER, filename)
    else:
        print(f"File not found: {filename}")
        return jsonify({'error': 'File not found'}), 404

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)

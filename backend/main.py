from flask import Flask, request, jsonify, send_from_directory
from flask_cors import CORS, cross_origin
import os
os.environ["TF_ENABLE_ONEDNN_OPTS"] = "0"
import tensorflow as tf
tf.get_logger().setLevel("ERROR")
import json
import glob
from datetime import datetime
from typing import List, Optional
from PIL import Image
import math

app = Flask(__name__)
CORS(app)

NGROK_BASE_URL = ''
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
UPLOAD_FOLDER = os.path.join(BASE_DIR, 'uploads')
DATA_FILE = os.path.join(BASE_DIR, "items.json")
ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg', 'gif', 'heic'}

os.makedirs(UPLOAD_FOLDER, exist_ok=True)
print(f"Upload directory: {os.path.abspath(UPLOAD_FOLDER)}")

def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

def extract_metadata_from_filename(filename):
    """
    Extract metadata embedded in filename
    Format: originalname__foundLat_foundLon__pickupLocation.ext
    Returns: (found_lat, found_lon, pickup_location)
    """
    try:
        segments = filename.split('__')
        if len(segments) >= 3:
            # Parse location coordinates
            coord_segment = segments[1]
            if coord_segment != "NoGPS":
                coordinate_parts = coord_segment.split('_')
                if len(coordinate_parts) >= 2:
                    latitude = float(coordinate_parts[0])
                    longitude = float(coordinate_parts[1])
                else:
                    latitude, longitude = None, None
            else:
                latitude, longitude = None, None

            # Parse pickup location (strip file extension)
            location_name = segments[2].rsplit('.', 1)[0].replace('_', ' ')

            return latitude, longitude, location_name
        else:
            # Fallback for older format
            if '__' in filename:
                location_name = filename.split('__')[1].rsplit('.', 1)[0].replace('_', ' ')
                return None, None, location_name
            return None, None, 'Unknown'
    except Exception as err:
        print(f"Error extracting metadata from {filename}: {err}")
        return None, None, 'Unknown'

def compute_haversine_distance(lat1, lon1, lat2, lon2):
    """
    Compute distance between two GPS coordinates in kilometers using Haversine formula
    """
    if lat1 is None or lon1 is None or lat2 is None or lon2 is None:
        return float('inf')

    # Radius of Earth in kilometers
    EARTH_RADIUS_KM = 6371.0

    # Convert degrees to radians
    lat1_radians = math.radians(lat1)
    lon1_radians = math.radians(lon1)
    lat2_radians = math.radians(lat2)
    lon2_radians = math.radians(lon2)

    # Calculate differences
    delta_lat = lat2_radians - lat1_radians
    delta_lon = lon2_radians - lon1_radians

    # Haversine formula
    a_value = math.sin(delta_lat / 2)**2 + math.cos(lat1_radians) * math.cos(lat2_radians) * math.sin(delta_lon / 2)**2
    c_value = 2 * math.atan2(math.sqrt(a_value), math.sqrt(1 - a_value))
    distance_km = EARTH_RADIUS_KM * c_value

    return distance_km

def load_items() -> List[dict]:
    if not os.path.exists(DATA_FILE):
        return []
    
    with open(DATA_FILE, 'r') as f:
        return json.load(f)

def save_items(items: List[dict]):
    with open(DATA_FILE, 'w') as f:
        json.dump(items, f, indent=2)

def get_next_id() -> int:
    items = load_items()
    if not items:
        return 1
    return max(item['id'] for item in items) + 1

@app.route("/")
def read_root():
    return jsonify({"message": "Beacon Lost and Found API"})

@app.route("/upload", methods=["POST"])
def upload_file():
    if 'file' not in request.files:
        print("Missing file in request")
        return jsonify({'success': False, 'error': 'No file part'}), 400

    uploaded_file = request.files['file']
    if uploaded_file.filename == '':
        print("Empty filename received")
        return jsonify({'success': False, 'error': 'No selected file'}), 400

    # Extract found location (EXIF or GPS data) - for matching purposes
    found_lat = request.form.get('foundLatitude')
    found_lon = request.form.get('foundLongitude')

    # Extract pickup location (where to retrieve item) - for display purposes
    retrieval_location = request.form.get('pickupLocation', 'Unknown')

    print(f"Processing upload: {uploaded_file.filename}")
    print(f"Found coords (matching): Lat={found_lat}, Lon={found_lon}")
    print(f"Retrieval location (display): {retrieval_location}")

    # Build filename with embedded metadata
    # Format: originalname__foundLat_foundLon__pickupLocation.ext
    name_parts = uploaded_file.filename.rsplit('.', 1)
    original_name = name_parts[0]
    file_extension = name_parts[1] if len(name_parts) > 1 else 'jpg'

    # Construct location segment
    coord_segment = f"{found_lat}_{found_lon}" if found_lat and found_lon else "NoGPS"
    location_segment = retrieval_location.replace(' ', '_')

    new_filename = f"{original_name}__{coord_segment}__{location_segment}.{file_extension}"
    destination_path = os.path.join(UPLOAD_FOLDER, new_filename)

    try:
        uploaded_file.save(destination_path)
        if os.path.exists(destination_path):
            print(f"Upload successful: {destination_path}")
        else:
            print(f"Upload verification failed: {destination_path}")
            return jsonify({'success': False, 'error': 'File not saved to disk'}), 500
    except Exception as save_error:
        print(f"Upload error: {save_error}")
        return jsonify({'success': False, 'error': f"Failed to save file: {save_error}"}), 500

    image_url = f"{NGROK_BASE_URL}/uploads/{new_filename}"
    print(f"File accessible at: {image_url}")
    return jsonify({
        'success': True,
        'filename': new_filename,
        'url': image_url,
        'foundLocation': f"{found_lat},{found_lon}" if found_lat and found_lon else None,
        'pickupLocation': retrieval_location
    }), 200

@app.route('/match', methods=['POST'])
@cross_origin()
def find_match():
    payload = request.get_json()
    search_description = payload.get('description', '')
    lost_place_name = payload.get('lostLocation', 'Unknown')
    lost_lat = payload.get('lostLatitude')
    lost_lon = payload.get('lostLongitude')

    if not search_description:
        return jsonify({'error': 'No description provided'}), 400

    print(f"Searching for item: '{search_description}'")
    print(f"Lost at location: {lost_place_name}")
    print(f"Lost coordinates: {lost_lat}, {lost_lon}")

    # Collect all image files
    image_files = glob.glob(f"{UPLOAD_FOLDER}/*.jpg") + \
                  glob.glob(f"{UPLOAD_FOLDER}/*.jpeg") + \
                  glob.glob(f"{UPLOAD_FOLDER}/*.png")

    if not image_files:
        return jsonify({'error': 'No images found'}), 404

    # Build candidate list
    match_candidates = []

    for img_path in image_files:
        try:
            # Extract metadata from filename
            img_filename = os.path.basename(img_path)
            found_latitude, found_longitude, pickup_spot = extract_metadata_from_filename(img_filename)

            # Compute distance if coordinates available
            proximity = float('inf')
            if lost_lat and lost_lon and found_latitude and found_longitude:
                proximity = compute_haversine_distance(
                    float(lost_lat), float(lost_lon),
                    found_latitude, found_longitude
                )

            # Simple text matching score (placeholder for CLIP)
            description_score = 0.5  # Default neutral score
            if search_description.lower() in img_filename.lower():
                description_score = 0.9  # Higher score for filename match

            match_candidates.append({
                'path': img_path,
                'filename': img_filename,
                'description_score': description_score,
                'proximity': proximity,
                'found_latitude': found_latitude,
                'found_longitude': found_longitude,
                'pickup_spot': pickup_spot
            })

            print(f"Candidate: {img_filename} - Score: {description_score:.4f}, Distance: {proximity:.2f}km")

        except Exception as err:
            print(f"Skipping file {img_path}: {err}")

    if not match_candidates:
        return jsonify({'error': 'No valid images loaded'}), 500

    # Sort by proximity first if coordinates available, otherwise by description score
    if lost_lat and lost_lon:
        match_candidates.sort(key=lambda x: (x['proximity'], -x['description_score']))
        print("Sorted by proximity (distance)")
    else:
        match_candidates.sort(key=lambda x: -x['description_score'])
        print("Sorted by description score")

    # Select best match
    top_match = match_candidates[0]
    top_filename = top_match['filename']
    top_url = f"{NGROK_BASE_URL}/uploads/{top_filename}"
    found_coords_str = f"{top_match['found_latitude']},{top_match['found_longitude']}" if top_match['found_latitude'] and top_match['found_longitude'] else None

    print(f"Best match result:")
    print(f"  URL: {top_url}")
    print(f"  Score: {top_match['description_score']:.4f}")
    print(f"  Found coordinates: {found_coords_str}")
    print(f"  Pickup location: {top_match['pickup_spot']}")

    return jsonify({
        'best_match': top_url,
        'confidence': top_match['description_score'],
        'foundLocation': found_coords_str,
        'pickupLocation': top_match['pickup_spot']
    }), 200

@app.route("/items", methods=["POST"])
def create_item():
    data = request.json
    items = load_items()
    
    new_item = {
        'id': get_next_id(),
        'title': data["title"],
        'description': data["description"],
        'category': data["category"],
        'location': data["location"],
        'status': data["status"],
        'contact_info': data["contact_info"],
        'image_filename': data.get("image_filename"),
        'created_at': datetime.utcnow().isoformat()
    }
    
    items.append(new_item)
    save_items(items)
    
    return jsonify(new_item), 201

@app.route("/items", methods=["GET"])
def get_items():
    status = request.args.get("status")
    items = load_items()
    
    if status:
        items = [item for item in items if item['status'] == status]
    
    items = sorted(items, key=lambda x: x['created_at'], reverse=True)
    return jsonify(items)

@app.route("/items/<int:item_id>", methods=["GET"])
def get_item(item_id):
    items = load_items()
    
    for item in items:
        if item['id'] == item_id:
            return jsonify(item)
    
    return jsonify({"detail": "Item not found"}), 404

@app.route("/items/<int:item_id>", methods=["PUT"])
def update_item(item_id):
    data = request.json
    items = load_items()
    
    for i, item in enumerate(items):
        if item['id'] == item_id:
            for key, value in data.items():
                if key in item:
                    item[key] = value
            items[i] = item
            save_items(items)
            return jsonify(item)
    
    return jsonify({"detail": "Item not found"}), 404

@app.route("/items/<int:item_id>", methods=["DELETE"])
def delete_item(item_id):
    items = load_items()
    
    for i, item in enumerate(items):
        if item['id'] == item_id:
            items.pop(i)
            save_items(items)
            return jsonify({"message": "Item deleted successfully"})
    
    return jsonify({"detail": "Item not found"}), 404

@app.route('/uploads/<path:filename>')
@cross_origin()
def serve_uploaded_file(filename):
    target_path = os.path.join(UPLOAD_FOLDER, filename)
    if os.path.exists(target_path):
        print(f"Serving file: {filename}")
        return send_from_directory(UPLOAD_FOLDER, filename)
    else:
        print(f"File not found: {filename}")
        return jsonify({'error': 'File not found'}), 404

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)

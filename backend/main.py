from flask import Flask, request, jsonify
from flask_cors import CORS
import json
import os
from datetime import datetime
from typing import List, Optional
from werkzeug.utils import secure_filename

app = Flask(__name__)
CORS(app)

DATA_FILE = "items.json"
UPLOAD_FOLDER = "uploads"
ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg', 'gif', 'heic'}

os.makedirs(UPLOAD_FOLDER, exist_ok=True)

def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

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
        return jsonify({"error": "No file part"}), 400
    
    file = request.files['file']
    
    if file.filename == '':
        return jsonify({"error": "No selected file"}), 400
    
    if file and allowed_file(file.filename):
        filename = secure_filename(file.filename)
        timestamp = datetime.utcnow().strftime('%Y%m%d_%H%M%S')
        filename = f"{timestamp}_{filename}"
        filepath = os.path.join(UPLOAD_FOLDER, filename)
        file.save(filepath)
        
        return jsonify({
            "message": "File uploaded successfully",
            "filename": filename,
            "filepath": filepath
        }), 201
    
    return jsonify({"error": "File type not allowed"}), 400

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

if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", port=8000)

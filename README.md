# Beacon - UMD Lost and Found App

A lost and found application for UMD students with a Flask backend and SwiftUI frontend.

## Backend (Python/Flask)

### Setup
```bash
cd backend
pip install -r requirements.txt
```

### Run
```bash
python main.py
```

Server runs on `http://localhost:8000`

Data is stored locally in `items.json` in the backend directory.
Uploaded images are stored in the `uploads/` folder.

## Frontend (Swift/iOS)

### Requirements
- Xcode 15+
- iOS 17+

### Setup
1. Open Xcode
2. Create a new iOS App project
3. Copy all `.swift` files from the `frontend` folder into your Xcode project
4. Ensure the backend server is running on `http://localhost:8000`

### Run
Build and run the app in Xcode simulator or on a device.

## Features

- **Post Lost Items**: Report items you've lost with optional photo
- **Post Found Items**: Report items you've found with optional photo
- **Upload Photos**: Attach photos to items when posting
- **Browse Items**: View all lost and found items
- **Filter**: Filter by lost or found status
- **Contact**: Access contact information to coordinate returns
- **Delete**: Remove items once they're resolved

## API Endpoints

- `GET /` - Health check
- `POST /upload` - Upload image file (returns filename)
- `POST /items` - Create new item (with optional image_filename)
- `GET /items` - Get all items (optional `?status=lost` or `?status=found`)
- `GET /items/{id}` - Get specific item
- `PUT /items/{id}` - Update item
- `DELETE /items/{id}` - Delete item

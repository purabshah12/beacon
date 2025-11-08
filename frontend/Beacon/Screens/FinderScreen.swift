//
//  FinderScreen.swift
//  Beacon
//
//  Created by Eswar Karavadi on 11/7/25.
//

import SwiftUI
import PhotosUI
import CoreLocation

struct FinderScreen: View {
    let onBack: () -> Void
    @State private var selectedImage: UIImage?
    @State private var isImagePickerPresented = false
    @State private var isCamera = false
    @State private var selectedBuilding = "Select Building"
    @State private var isUploading = false
    @State private var uploadSuccess = false
    @State private var locationManager = CLLocationManager()
    @State private var currentLocation: CLLocation?
    @State private var locationStatus: CLAuthorizationStatus = .notDetermined

    var body: some View {
        ZStack {
            // Gradient background
            AppColors.backgroundGradient
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Custom header
                HStack {
                    Button(action: onBack) {
                        ZStack {
                            Circle()
                                .fill(AppColors.glassEffect)
                                .frame(width: 44, height: 44)
                            
                            Image(systemName: "arrow.left")
                                .foregroundColor(.white)
                                .font(.system(size: 18, weight: .semibold))
                        }
                    }
                    
                    Spacer()
                    
                    Text("Report Found Item")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Placeholder for symmetry
                    Circle()
                        .fill(Color.clear)
                        .frame(width: 44, height: 44)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 24)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Image Selection Card
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "camera.fill")
                                    .foregroundColor(AppColors.primary)
                                Text("Photo")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                            }

                            if let image = selectedImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: 220)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(AppColors.primaryGradient, lineWidth: 2)
                                    )
                            } else {
                                Button(action: { isImagePickerPresented = true }) {
                                    VStack(spacing: 16) {
                                        ZStack {
                                            Circle()
                                                .fill(AppColors.primaryGradient)
                                                .frame(width: 70, height: 70)
                                            
                                            Image(systemName: "camera.fill")
                                                .font(.system(size: 30))
                                                .foregroundColor(.white)
                                        }
                                        
                                        Text("Tap to add photo")
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(AppColors.textSecondary)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 220)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(AppColors.surface.opacity(0.5))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 16)
                                                    .stroke(style: StrokeStyle(lineWidth: 2, dash: [8]))
                                                    .foregroundStyle(AppColors.primaryGradient)
                                            )
                                    )
                                }
                            }

                            // Camera/Gallery buttons
                            HStack(spacing: 12) {
                                Button(action: {
                                    isCamera = true
                                    isImagePickerPresented = true
                                }) {
                                    HStack {
                                        Image(systemName: "camera")
                                        Text("Camera")
                                    }
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(AppColors.surfaceLight)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                }

                                Button(action: {
                                    isCamera = false
                                    isImagePickerPresented = true
                                }) {
                                    HStack {
                                        Image(systemName: "photo.on.rectangle")
                                        Text("Gallery")
                                    }
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(AppColors.surfaceLight)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                            }
                        }
                        .padding(20)
                        .glassCard()

                        // Building Selection Card
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "mappin.circle.fill")
                                    .foregroundColor(AppColors.accent)
                                Text("Location")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                            }

                            Menu {
                                ForEach(Config.umdBuildings, id: \.self) { building in
                                    Button(action: {
                                        selectedBuilding = building
                                    }) {
                                        Text(building)
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(selectedBuilding)
                                        .foregroundColor(selectedBuilding == "Select Building" ? AppColors.textTertiary : .white)
                                        .font(.system(size: 16))
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                        .foregroundColor(AppColors.textSecondary)
                                        .font(.system(size: 14))
                                }
                                .padding(16)
                                .background(AppColors.surfaceLight)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                        .padding(20)
                        .glassCard()

                        // Upload Button
                        Button(action: uploadItem) {
                            Group {
                                if isUploading {
                                    HStack(spacing: 12) {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        Text("Uploading...")
                                            .font(.system(size: 18, weight: .semibold))
                                    }
                                } else {
                                    HStack(spacing: 12) {
                                        Image(systemName: "arrow.up.circle.fill")
                                            .font(.system(size: 22))
                                        Text("Upload Found Item")
                                            .font(.system(size: 18, weight: .semibold))
                                    }
                                }
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(
                                Group {
                                    if selectedImage != nil && selectedBuilding != "Select Building" && !isUploading {
                                        AppColors.primaryGradient
                                    } else {
                                        LinearGradient(
                                            colors: [AppColors.surfaceLight, AppColors.surfaceLight],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    }
                                }
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(
                                color: selectedImage != nil && selectedBuilding != "Select Building" && !isUploading
                                    ? AppColors.primary.opacity(0.5)
                                    : Color.clear,
                                radius: 20,
                                x: 0,
                                y: 10
                            )
                        }
                        .disabled(selectedImage == nil || selectedBuilding == "Select Building" || isUploading)
                        .padding(.horizontal, 20)

                        if uploadSuccess {
                            HStack(spacing: 12) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(AppColors.success)
                                    .font(.system(size: 20))
                                Text("Item uploaded successfully!")
                                    .foregroundColor(.white)
                                    .font(.system(size: 15, weight: .medium))
                            }
                            .padding(16)
                            .frame(maxWidth: .infinity)
                            .background(AppColors.success.opacity(0.2))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .padding(.horizontal, 20)
                        }
                    }
                    .padding(.bottom, 32)
                }
            }
        }
        .sheet(isPresented: $isImagePickerPresented) {
            ImagePicker(isCamera: isCamera, selectedImage: $selectedImage)
        }
        .onAppear {
            setupLocationManager()
        }
    }

    private func setupLocationManager() {
        locationManager.delegate = LocationDelegate.shared
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    private func uploadItem() {
        guard let image = selectedImage else { return }

        isUploading = true
        uploadSuccess = false

        LocationDelegate.shared.getCurrentLocation { location in
            guard let imageData = image.jpegData(compressionQuality: 0.8) else {
                isUploading = false
                return
            }

            let boundary = "Boundary-\(UUID().uuidString)"
            var request = URLRequest(url: URL(string: Config.uploadEndpoint)!)
            request.httpMethod = "POST"
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

            var body = Data()

            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"file\"; filename=\"upload.jpg\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            body.append(imageData)
            body.append("\r\n".data(using: .utf8)!)

            if let location = location {
                body.append("--\(boundary)\r\n".data(using: .utf8)!)
                body.append("Content-Disposition: form-data; name=\"latitude\"\r\n\r\n".data(using: .utf8)!)
                body.append("\(location.coordinate.latitude)\r\n".data(using: .utf8)!)

                body.append("--\(boundary)\r\n".data(using: .utf8)!)
                body.append("Content-Disposition: form-data; name=\"longitude\"\r\n\r\n".data(using: .utf8)!)
                body.append("\(location.coordinate.longitude)\r\n".data(using: .utf8)!)
            }

            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"lostLocation\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(selectedBuilding)\r\n".data(using: .utf8)!)

            body.append("--\(boundary)--\r\n".data(using: .utf8)!)

            request.httpBody = body

            URLSession.shared.dataTask(with: request) { data, response, error in
                DispatchQueue.main.async {
                    isUploading = false
                    if let error = error {
                        print("Upload error: \(error)")
                        return
                    }

                    if let data = data,
                       let response = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                       response["success"] as? Bool == true {
                        uploadSuccess = true
                        selectedImage = nil
                        selectedBuilding = "Select Building"
                    }
                }
            }.resume()
        }
    }
}

class LocationDelegate: NSObject, CLLocationManagerDelegate {
    static let shared = LocationDelegate()

    private var locationManager = CLLocationManager()
    private var completion: ((CLLocation?) -> Void)?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func getCurrentLocation(completion: @escaping (CLLocation?) -> Void) {
        self.completion = completion
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            completion?(location)
            completion = nil
            manager.stopUpdatingLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error)")
        completion?(nil)
        completion = nil
    }
}

#Preview {
    FinderScreen(onBack: {})
}

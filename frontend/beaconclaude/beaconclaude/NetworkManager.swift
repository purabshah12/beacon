//
//  NetworkManager.swift
//  beaconclaude
//
//  Network manager for API communication
//

import Foundation
import UIKit

class NetworkManager {
    static let shared = NetworkManager()
    
    private init() {}
    
    // MARK: - Upload Item
    func uploadItem(image: UIImage, location: String, latitude: Double, longitude: Double, completion: @escaping (Result<UploadResponse, Error>) -> Void) {
        
        guard let url = URL(string: AppConstants.apiBaseURL + AppConstants.uploadEndpoint) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        // Convert image to base64
        guard let imageData = image.jpegData(compressionQuality: 0.7) else {
            completion(.failure(NetworkError.imageConversionFailed))
            return
        }
        let base64Image = imageData.base64EncodedString()
        
        // Create timestamp
        let timestamp = ISO8601DateFormatter().string(from: Date())
        
        // Create request body
        let uploadRequest = UploadRequest(
            image: base64Image,
            location: location,
            latitude: latitude,
            longitude: longitude,
            timestamp: timestamp
        )
        
        // Create URL request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONEncoder().encode(uploadRequest)
        } catch {
            completion(.failure(error))
            return
        }
        
        // Execute request
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NetworkError.noData))
                return
            }
            
            do {
                let uploadResponse = try JSONDecoder().decode(UploadResponse.self, from: data)
                completion(.success(uploadResponse))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    // MARK: - Search Items
    func searchItems(description: String, location: String?, completion: @escaping (Result<SearchResponse, Error>) -> Void) {
        
        guard let url = URL(string: AppConstants.apiBaseURL + AppConstants.matchEndpoint) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        // Create request body
        let searchRequest = SearchRequest(description: description, location: location)
        
        // Create URL request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONEncoder().encode(searchRequest)
        } catch {
            completion(.failure(error))
            return
        }
        
        // Execute request
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NetworkError.noData))
                return
            }
            
            do {
                let searchResponse = try JSONDecoder().decode(SearchResponse.self, from: data)
                completion(.success(searchResponse))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    // MARK: - Download Image
    func downloadImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            
            let image = UIImage(data: data)
            completion(image)
        }.resume()
    }
}

// MARK: - Network Errors
enum NetworkError: LocalizedError {
    case invalidURL
    case noData
    case imageConversionFailed
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received from server"
        case .imageConversionFailed:
            return "Failed to convert image"
        }
    }
}


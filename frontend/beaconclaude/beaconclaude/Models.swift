//
//  Models.swift
//  beaconclaude
//
//  Data models for Lost & Found app
//

import Foundation
import CoreLocation

// MARK: - Upload Request
struct UploadRequest: Codable {
    let image: String // Base64 encoded image
    let location: String
    let latitude: Double
    let longitude: Double
    let timestamp: String
}

// MARK: - Upload Response
struct UploadResponse: Codable {
    let success: Bool
    let message: String?
    let itemId: String?
    
    enum CodingKeys: String, CodingKey {
        case success
        case message
        case itemId = "item_id"
    }
}

// MARK: - Search Request
struct SearchRequest: Codable {
    let description: String
    let location: String?
}

// MARK: - Search Response
struct SearchResponse: Codable {
    let matches: [MatchResult]
}

// MARK: - Match Result
struct MatchResult: Codable {
    let imageUrl: String
    let confidence: Double
    let location: String
    let latitude: Double
    let longitude: Double
    let timestamp: String
    let itemId: String
    
    enum CodingKeys: String, CodingKey {
        case imageUrl = "image_url"
        case confidence
        case location
        case latitude
        case longitude
        case timestamp
        case itemId = "item_id"
    }
}

// MARK: - App Constants
struct AppConstants {
    static let apiBaseURL = "http://localhost:8000" // Change to your backend URL
    static let uploadEndpoint = "/upload"
    static let matchEndpoint = "/match"
    
    // UI Colors
    static let backgroundColor = UIColor(red: 0x11/255.0, green: 0x18/255.0, blue: 0x1C/255.0, alpha: 1.0)
    static let accentColor = UIColor(red: 0x0a/255.0, green: 0x7e/255.0, blue: 0xa4/255.0, alpha: 1.0)
    static let cardBackgroundColor = UIColor(red: 0x1c/255.0, green: 0x23/255.0, blue: 0x28/255.0, alpha: 1.0)
    static let textColor = UIColor.white
    static let secondaryTextColor = UIColor(white: 0.7, alpha: 1.0)
}

// MARK: - Location Data
struct LocationData {
    let buildingName: String
    let coordinate: CLLocationCoordinate2D?
}


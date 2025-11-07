//
//  ResultsViewController.swift
//  beaconclaude
//
//  Screen for displaying search results
//

import UIKit
import MapKit

class ResultsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Properties
    var matches: [MatchResult] = []
    
    // MARK: - UI Components
    private let tableView: UITableView = {
        let tv = UITableView()
        tv.backgroundColor = AppConstants.backgroundColor
        tv.separatorStyle = .none
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    private let noResultsLabel: UILabel = {
        let label = UILabel()
        label.text = "No matches found\n\nTry describing your item differently or check back later"
        label.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        label.textColor = AppConstants.secondaryTextColor
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = AppConstants.backgroundColor
        title = "Search Results"
        
        view.addSubview(tableView)
        view.addSubview(noResultsLabel)
        
        NSLayoutConstraint.activate([
            // Table View
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // No Results Label
            noResultsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noResultsLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            noResultsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            noResultsLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
        
        noResultsLabel.isHidden = !matches.isEmpty
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ResultCell.self, forCellReuseIdentifier: "ResultCell")
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matches.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ResultCell", for: indexPath) as! ResultCell
        let match = matches[indexPath.row]
        cell.configure(with: match)
        cell.onMapTapped = { [weak self] in
            self?.openMap(for: match)
        }
        return cell
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 400
    }
    
    // MARK: - Helper Methods
    private func openMap(for match: MatchResult) {
        let coordinate = CLLocationCoordinate2D(latitude: match.latitude, longitude: match.longitude)
        
        // Check if location is "I have it"
        if match.location == "I have it" {
            showAlert(message: "The finder currently has this item. Please contact them directly.")
            return
        }
        
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate))
        mapItem.name = match.location
        
        let alert = UIAlertController(title: "Open in Maps", message: "Open \(match.location) in Maps app?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Open", style: .default) { _ in
            mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking])
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - Result Cell
class ResultCell: UITableViewCell {
    
    var onMapTapped: (() -> Void)?
    
    // MARK: - UI Components
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = AppConstants.cardBackgroundColor
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let itemImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 8
        iv.backgroundColor = AppConstants.backgroundColor
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let confidenceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.textColor = AppConstants.accentColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let locationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textColor = AppConstants.textColor
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = AppConstants.secondaryTextColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let coordinatesLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = AppConstants.secondaryTextColor
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let mapButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Open in Maps", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = AppConstants.accentColor
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.color = AppConstants.accentColor
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(containerView)
        containerView.addSubview(itemImageView)
        containerView.addSubview(loadingIndicator)
        containerView.addSubview(confidenceLabel)
        containerView.addSubview(locationLabel)
        containerView.addSubview(dateLabel)
        containerView.addSubview(coordinatesLabel)
        containerView.addSubview(mapButton)
        
        NSLayoutConstraint.activate([
            // Container View
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            
            // Item Image View
            itemImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            itemImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            itemImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            itemImageView.heightAnchor.constraint(equalToConstant: 250),
            
            // Loading Indicator
            loadingIndicator.centerXAnchor.constraint(equalTo: itemImageView.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: itemImageView.centerYAnchor),
            
            // Confidence Label
            confidenceLabel.topAnchor.constraint(equalTo: itemImageView.bottomAnchor, constant: 16),
            confidenceLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            confidenceLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            // Location Label
            locationLabel.topAnchor.constraint(equalTo: confidenceLabel.bottomAnchor, constant: 8),
            locationLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            locationLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            // Date Label
            dateLabel.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 6),
            dateLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            dateLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            // Coordinates Label
            coordinatesLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 6),
            coordinatesLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            coordinatesLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            // Map Button
            mapButton.topAnchor.constraint(equalTo: coordinatesLabel.bottomAnchor, constant: 16),
            mapButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            mapButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            mapButton.heightAnchor.constraint(equalToConstant: 44),
            mapButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16)
        ])
        
        mapButton.addTarget(self, action: #selector(mapButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Configuration
    func configure(with match: MatchResult) {
        // Confidence
        let confidencePercent = Int(match.confidence * 100)
        confidenceLabel.text = "Match: \(confidencePercent)%"
        
        // Location
        locationLabel.text = "Location: \(match.location)"
        
        // Date
        dateLabel.text = "Found: \(formatDate(match.timestamp))"
        
        // Coordinates
        coordinatesLabel.text = String(format: "Coordinates: %.4f, %.4f", match.latitude, match.longitude)
        
        // Hide map button if location is "I have it"
        mapButton.isHidden = match.location == "I have it"
        
        // Load image
        loadingIndicator.startAnimating()
        itemImageView.image = nil
        
        // Construct full image URL
        let imageUrl = match.imageUrl.hasPrefix("http") ? match.imageUrl : AppConstants.apiBaseURL + match.imageUrl
        
        NetworkManager.shared.downloadImage(from: imageUrl) { [weak self] image in
            DispatchQueue.main.async {
                self?.loadingIndicator.stopAnimating()
                self?.itemImageView.image = image ?? UIImage(systemName: "photo")
            }
        }
    }
    
    // MARK: - Actions
    @objc private func mapButtonTapped() {
        onMapTapped?()
    }
    
    // MARK: - Helper Methods
    private func formatDate(_ timestamp: String) -> String {
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: timestamp) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .medium
            displayFormatter.timeStyle = .short
            return displayFormatter.string(from: date)
        }
        return timestamp
    }
}


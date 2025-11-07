//
//  ViewController.swift
//  beaconclaude
//
//  Home screen - Lost & Found App
//

import UIKit

class ViewController: UIViewController {
    
    // MARK: - UI Components
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "UMD Lost & Found"
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.textColor = AppConstants.textColor
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Connecting Terrapins with their belongings"
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = AppConstants.secondaryTextColor
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let foundButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("I Found Something", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = AppConstants.accentColor
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let lostButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("I Lost Something", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = AppConstants.accentColor
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = AppConstants.backgroundColor
        
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(foundButton)
        view.addSubview(lostButton)
        
        NSLayoutConstraint.activate([
            // Title
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Subtitle
            subtitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            
            // Found Button
            foundButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            foundButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
            foundButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            foundButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            foundButton.heightAnchor.constraint(equalToConstant: 60),
            
            // Lost Button
            lostButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            lostButton.topAnchor.constraint(equalTo: foundButton.bottomAnchor, constant: 24),
            lostButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            lostButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            lostButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func setupActions() {
        foundButton.addTarget(self, action: #selector(foundButtonTapped), for: .touchUpInside)
        lostButton.addTarget(self, action: #selector(lostButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Actions
    @objc private func foundButtonTapped() {
        let finderVC = FinderViewController()
        navigationController?.pushViewController(finderVC, animated: true)
    }
    
    @objc private func lostButtonTapped() {
        let searcherVC = SearcherViewController()
        navigationController?.pushViewController(searcherVC, animated: true)
    }
}


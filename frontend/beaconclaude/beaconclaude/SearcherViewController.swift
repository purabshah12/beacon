//
//  SearcherViewController.swift
//  beaconclaude
//
//  Screen for searching lost items
//

import UIKit

class SearcherViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // MARK: - Properties
    private let buildings = ["Any location"] + UMDBuildings.buildings
    private var selectedLocation: String? = nil
    
    // MARK: - UI Components
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Find Your Lost Item"
        label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        label.textColor = AppConstants.textColor
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Describe what you lost"
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.textColor = AppConstants.textColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionTextView: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.textColor = AppConstants.textColor
        tv.backgroundColor = AppConstants.cardBackgroundColor
        tv.layer.cornerRadius = 10
        tv.textContainerInset = UIEdgeInsets(top: 15, left: 12, bottom: 15, right: 12)
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "e.g., red backpack with laptop inside"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = AppConstants.secondaryTextColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let locationLabel: UILabel = {
        let label = UILabel()
        label.text = "Where did you lose it? (Optional)"
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.textColor = AppConstants.textColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let locationTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Select location (optional)"
        tf.font = UIFont.systemFont(ofSize: 16)
        tf.textColor = AppConstants.textColor
        tf.backgroundColor = AppConstants.cardBackgroundColor
        tf.layer.cornerRadius = 10
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 0))
        tf.leftViewMode = .always
        tf.translatesAutoresizingMaskIntoConstraints = false
        
        tf.attributedPlaceholder = NSAttributedString(
            string: "Select location (optional)",
            attributes: [NSAttributedString.Key.foregroundColor: AppConstants.secondaryTextColor]
        )
        
        return tf
    }()
    
    private let locationPicker: UIPickerView = {
        let picker = UIPickerView()
        return picker
    }()
    
    private let searchButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Search", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = AppConstants.accentColor
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = AppConstants.accentColor
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
        setupPickerView()
        setupKeyboardDismissal()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = AppConstants.backgroundColor
        title = "Lost Item"
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(descriptionTextView)
        descriptionTextView.addSubview(placeholderLabel)
        contentView.addSubview(locationLabel)
        contentView.addSubview(locationTextField)
        contentView.addSubview(searchButton)
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            // Scroll View
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Content View
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Title
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Description Label
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 40),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40),
            
            // Description TextView
            descriptionTextView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 12),
            descriptionTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40),
            descriptionTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40),
            descriptionTextView.heightAnchor.constraint(equalToConstant: 120),
            
            // Placeholder Label
            placeholderLabel.topAnchor.constraint(equalTo: descriptionTextView.topAnchor, constant: 15),
            placeholderLabel.leadingAnchor.constraint(equalTo: descriptionTextView.leadingAnchor, constant: 17),
            placeholderLabel.trailingAnchor.constraint(equalTo: descriptionTextView.trailingAnchor, constant: -17),
            
            // Location Label
            locationLabel.topAnchor.constraint(equalTo: descriptionTextView.bottomAnchor, constant: 30),
            locationLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40),
            locationLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40),
            
            // Location TextField
            locationTextField.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 12),
            locationTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40),
            locationTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40),
            locationTextField.heightAnchor.constraint(equalToConstant: 50),
            
            // Search Button
            searchButton.topAnchor.constraint(equalTo: locationTextField.bottomAnchor, constant: 40),
            searchButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40),
            searchButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40),
            searchButton.heightAnchor.constraint(equalToConstant: 60),
            searchButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40),
            
            // Activity Indicator
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        // TextView delegate
        descriptionTextView.delegate = self
    }
    
    private func setupActions() {
        searchButton.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)
    }
    
    private func setupPickerView() {
        locationPicker.delegate = self
        locationPicker.dataSource = self
        locationTextField.inputView = locationPicker
        
        // Add toolbar with done button
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(dismissPicker))
        let flexSpace = UIBarButtonItem(barButtonItem: .flexibleSpace)
        toolbar.setItems([flexSpace, doneButton], animated: false)
        locationTextField.inputAccessoryView = toolbar
    }
    
    private func setupKeyboardDismissal() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Actions
    @objc private func searchButtonTapped() {
        guard let description = descriptionTextView.text, !description.isEmpty else {
            showAlert(message: "Please describe the item you lost")
            return
        }
        
        activityIndicator.startAnimating()
        searchButton.isEnabled = false
        
        NetworkManager.shared.searchItems(
            description: description,
            location: selectedLocation
        ) { [weak self] result in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                self?.searchButton.isEnabled = true
                
                switch result {
                case .success(let response):
                    let resultsVC = ResultsViewController()
                    resultsVC.matches = response.matches
                    self?.navigationController?.pushViewController(resultsVC, animated: true)
                    
                case .failure(let error):
                    self?.showAlert(message: "Error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    @objc private func dismissPicker() {
        view.endEditing(true)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - UIPickerViewDataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return buildings.count
    }
    
    // MARK: - UIPickerViewDelegate
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return buildings[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let building = buildings[row]
        if building == "Any location" {
            selectedLocation = nil
            locationTextField.text = "Any location"
        } else {
            selectedLocation = building
            locationTextField.text = building
        }
    }
    
    // MARK: - Helper Methods
    private func showAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITextViewDelegate
extension SearcherViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
}


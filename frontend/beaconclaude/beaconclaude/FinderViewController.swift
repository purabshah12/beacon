//
//  FinderViewController.swift
//  beaconclaude
//
//  Screen for uploading found items
//

import UIKit
import CoreLocation

class FinderViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // MARK: - Properties
    private var selectedImage: UIImage?
    private var currentLocation: CLLocationCoordinate2D?
    private let buildings = UMDBuildings.buildings
    private var selectedBuilding: String = "I have it"
    
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
        label.text = "Upload Found Item"
        label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        label.textColor = AppConstants.textColor
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let imagePreview: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = AppConstants.cardBackgroundColor
        iv.contentMode = .scaleAspectFit
        iv.layer.cornerRadius = 12
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let cameraButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Take Photo", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = AppConstants.accentColor
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let galleryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Choose from Gallery", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = AppConstants.accentColor
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let locationLabel: UILabel = {
        let label = UILabel()
        label.text = "Where did you find it?"
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.textColor = AppConstants.textColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let locationTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Select building"
        tf.font = UIFont.systemFont(ofSize: 16)
        tf.textColor = AppConstants.textColor
        tf.backgroundColor = AppConstants.cardBackgroundColor
        tf.layer.cornerRadius = 10
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 0))
        tf.leftViewMode = .always
        tf.translatesAutoresizingMaskIntoConstraints = false
        
        // Set placeholder color
        tf.attributedPlaceholder = NSAttributedString(
            string: "Select building",
            attributes: [NSAttributedString.Key.foregroundColor: AppConstants.secondaryTextColor]
        )
        
        return tf
    }()
    
    private let locationPicker: UIPickerView = {
        let picker = UIPickerView()
        return picker
    }()
    
    private let uploadButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Upload Item", for: .normal)
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
        requestLocation()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = AppConstants.backgroundColor
        title = "Found Item"
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(imagePreview)
        contentView.addSubview(cameraButton)
        contentView.addSubview(galleryButton)
        contentView.addSubview(locationLabel)
        contentView.addSubview(locationTextField)
        contentView.addSubview(uploadButton)
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
            
            // Image Preview
            imagePreview.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            imagePreview.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            imagePreview.widthAnchor.constraint(equalToConstant: 300),
            imagePreview.heightAnchor.constraint(equalToConstant: 300),
            
            // Camera Button
            cameraButton.topAnchor.constraint(equalTo: imagePreview.bottomAnchor, constant: 20),
            cameraButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40),
            cameraButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40),
            cameraButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Gallery Button
            galleryButton.topAnchor.constraint(equalTo: cameraButton.bottomAnchor, constant: 12),
            galleryButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40),
            galleryButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40),
            galleryButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Location Label
            locationLabel.topAnchor.constraint(equalTo: galleryButton.bottomAnchor, constant: 30),
            locationLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40),
            locationLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40),
            
            // Location TextField
            locationTextField.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 12),
            locationTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40),
            locationTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40),
            locationTextField.heightAnchor.constraint(equalToConstant: 50),
            
            // Upload Button
            uploadButton.topAnchor.constraint(equalTo: locationTextField.bottomAnchor, constant: 30),
            uploadButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40),
            uploadButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40),
            uploadButton.heightAnchor.constraint(equalToConstant: 60),
            uploadButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40),
            
            // Activity Indicator
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupActions() {
        cameraButton.addTarget(self, action: #selector(cameraButtonTapped), for: .touchUpInside)
        galleryButton.addTarget(self, action: #selector(galleryButtonTapped), for: .touchUpInside)
        uploadButton.addTarget(self, action: #selector(uploadButtonTapped), for: .touchUpInside)
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
        
        // Set default value
        locationTextField.text = selectedBuilding
    }
    
    private func requestLocation() {
        LocationManager.shared.requestLocation { [weak self] coordinate in
            self?.currentLocation = coordinate
        }
    }
    
    // MARK: - Actions
    @objc private func cameraButtonTapped() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            showAlert(message: "Camera is not available on this device")
            return
        }
        
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = self
        present(picker, animated: true)
    }
    
    @objc private func galleryButtonTapped() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        present(picker, animated: true)
    }
    
    @objc private func uploadButtonTapped() {
        guard let image = selectedImage else {
            showAlert(message: "Please select an image first")
            return
        }
        
        let latitude = currentLocation?.latitude ?? 0.0
        let longitude = currentLocation?.longitude ?? 0.0
        
        activityIndicator.startAnimating()
        uploadButton.isEnabled = false
        
        NetworkManager.shared.uploadItem(
            image: image,
            location: selectedBuilding,
            latitude: latitude,
            longitude: longitude
        ) { [weak self] result in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                self?.uploadButton.isEnabled = true
                
                switch result {
                case .success(let response):
                    if response.success {
                        self?.showAlert(message: "Item uploaded successfully!", completion: {
                            self?.navigationController?.popViewController(animated: true)
                        })
                    } else {
                        self?.showAlert(message: response.message ?? "Upload failed")
                    }
                case .failure(let error):
                    self?.showAlert(message: "Error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    @objc private func dismissPicker() {
        view.endEditing(true)
    }
    
    // MARK: - UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            selectedImage = image
            imagePreview.image = image
        }
        picker.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
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
        selectedBuilding = buildings[row]
        locationTextField.text = selectedBuilding
    }
    
    // MARK: - Helper Methods
    private func showAlert(message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
        })
        present(alert, animated: true)
    }
}

// MARK: - UIBarButtonItem Extension
extension UIBarButtonItem {
    static var flexibleSpace: UIBarButtonItem {
        return UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    }
}


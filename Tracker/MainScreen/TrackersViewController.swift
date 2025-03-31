//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Ilya Grishanov on 31.03.2025.
//

import UIKit

final class TrackersViewController: UIViewController {
    
    private let addTrackerButton = UIButton()
    private let datePicker = UIDatePicker()
    private let headerLabel = UILabel()
    private let searchBar = UISearchBar()
    private let starImage = UIImageView()
    private let questionLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        setupUI()
        
    }
    
    private func setupUI() {
        setupAddTrackerButton()
        setupDatePicker()
        setupHeaderLabel()
        setupSearchBar()
        setupStarImage()
        setupQuestionLabel()
    }
    
    private func setupAddTrackerButton() {
        addTrackerButton.setImage(UIImage(named: "AddTracker"), for: .normal)
        addTrackerButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(addTrackerButton)
        
        NSLayoutConstraint.activate([
            addTrackerButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 45),
            addTrackerButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 6),
            
            addTrackerButton.widthAnchor.constraint(equalToConstant: 42),
            addTrackerButton.heightAnchor.constraint(equalToConstant: 42)
        ])
    }
    
    private func setupDatePicker() {
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        datePicker.locale = Locale(identifier: "ru_RU")
        
        datePicker.backgroundColor = .lightGray.withAlphaComponent(0.3)
        
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(datePicker)
        
        NSLayoutConstraint.activate([
            datePicker.centerYAnchor.constraint(equalTo: addTrackerButton.centerYAnchor),
            datePicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "dd.MM.yy"
    }
    
    private func setupHeaderLabel() {
        headerLabel.text = "Трекеры"
        headerLabel.textColor = UIColor(named: "CustomBlack")
        headerLabel.font = UIFont(name: "YS Display Bold", size: 34)
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerLabel)
        
        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: addTrackerButton.bottomAnchor, constant: 1),
            headerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16)
        ])
    }
    
    private func setupSearchBar() {
        searchBar.placeholder = "Поиск"
        searchBar.searchBarStyle = .minimal
        searchBar.tintColor = .gray
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchBar)
        
        if let textField = searchBar.value(forKey: "searchField") as? UITextField {
            textField.layer.cornerRadius = 10
            textField.layer.masksToBounds = true
            textField.backgroundColor = .white
            textField.font = UIFont(name: "YS Display Medium", size: 17)
            
            textField.attributedPlaceholder = NSAttributedString(
                string: "Поиск",
                attributes: [
                    .foregroundColor: UIColor(named: "CustomGray") ?? .gray,
                    .font: UIFont(name: "YS Display Medium", size: 17) ?? UIFont.systemFont(ofSize: 17)
                ]
            )
            
            textField.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                textField.heightAnchor.constraint(equalToConstant: 36),
                textField.leadingAnchor.constraint(equalTo: searchBar.leadingAnchor),
                textField.trailingAnchor.constraint(equalTo: searchBar.trailingAnchor),
                textField.centerYAnchor.constraint(equalTo: searchBar.centerYAnchor)
            ])
            
            if let glassIconView = textField.leftView as? UIImageView {
                glassIconView.image = glassIconView.image?.withRenderingMode(.alwaysTemplate)
                glassIconView.tintColor = .gray
            }
        }
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 7),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            searchBar.heightAnchor.constraint(equalToConstant: 36)
        ])
    }
    
    private func setupStarImage() {
        starImage.image = UIImage(named: "Star")
        starImage.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(starImage)
        
        NSLayoutConstraint.activate([
            starImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            starImage.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            starImage.widthAnchor.constraint(equalToConstant: 80),
            starImage.heightAnchor.constraint(equalToConstant: 80)
        ])
    }
    
    private func setupQuestionLabel() {
        questionLabel.text = "Что будем отслеживать?"
        questionLabel.font = UIFont(name:"YS Display Medium", size: 12)
        questionLabel.textColor = UIColor (named: "CustomBlack")
        view.addSubview(questionLabel)
        
        questionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            questionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            questionLabel.topAnchor.constraint(equalTo: starImage.bottomAnchor, constant: 8)
            ])
    }
    
    @objc func addTrackerButtonTapped() {
        
    }
    
}

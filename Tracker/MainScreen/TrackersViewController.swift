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
    
    
    private var categories: [TrackerCategory] = []
    private var completedTrackers: [TrackerRecord] = []
    
    
    
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
        datePicker.calendar = Calendar.current
        datePicker.timeZone = TimeZone.current
        
        datePicker.backgroundColor = .lightGray.withAlphaComponent(0.3)
        datePicker.tintColor = UIColor(named: "CustomBlack")
        
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(datePicker)
        
        NSLayoutConstraint.activate([
            datePicker.centerYAnchor.constraint(equalTo: addTrackerButton.centerYAnchor),
            datePicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
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
    
    private func completeTracker(with id: UUID, on date: Date) {
          let record = TrackerRecord(trackerId: id, date: date)
          completedTrackers.append(record)
      }
      
      private func undoCompleteTracker(with id: UUID, on date: Date) {
          completedTrackers.removeAll { $0.trackerId == id && Calendar.current.isDate($0.date, inSameDayAs: date) }
      }
      
      private func addNewTracker(_ tracker: Tracker, to categoryTitle: String) {
          var newCategories = categories
          
          if let index = newCategories.firstIndex(where: { $0.title == categoryTitle }) {

              let existingCategory = newCategories[index]
              let updatedTrackers = existingCategory.trackers + [tracker]
              newCategories[index] = TrackerCategory(title: existingCategory.title, trackers: updatedTrackers)
          } else {
 
              let newCategory = TrackerCategory(title: categoryTitle, trackers: [tracker])
              newCategories.append(newCategory)
          }
          
          categories = newCategories
      }
    
}

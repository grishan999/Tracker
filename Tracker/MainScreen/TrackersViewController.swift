//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Ilya Grishanov on 31.03.2025.
//
protocol CreateDelegateProtocol: AnyObject {
    func didCreateHabit(title: String, category: TrackerCategory, emoji: Character, color: UIColor, schedule: Set<Day>)
    func didCreateEvent(title: String, category: TrackerCategory, emoji: Character, color: UIColor)
}

import UIKit

final class TrackersViewController: UIViewController {
    
    private let datePicker = UIDatePicker()
    private let headerLabel = UILabel()
    private let searchBar = UISearchBar()
    private let starImage = UIImageView()
    private let questionLabel = UILabel()
    
    
    private lazy var cellWidth = ceil((UIScreen.main.bounds.width - sideInset * 2 - 10)/2)
    private let cellHeight: CGFloat = 148
    private let sideInset: CGFloat = 16
    private let minimumCellSpacing: CGFloat = 9
    
    
    private var categories: [TrackerCategory] = []
    private var completedTrackers: [TrackerRecord] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        categories = DataManager.shared.categories
        setupUI()
        
        
    }
    
    
    
    private lazy var placeholderView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(TrackersCell.self, forCellWithReuseIdentifier: TrackersCell.cellIdentifier)
        collectionView.register(HeaderCategoryView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: HeaderCategoryView.headerIdentifier)
        return collectionView
    }()
    
    private func setupUI() {
        setupNavBarItems()
        setupHeaderLabel()
        setupSearchBar()
        setupStarImage()
        setupQuestionLabel()
        setupCollectionView()
        
        view.addSubview(placeholderView)
        NSLayoutConstraint.activate([
            placeholderView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        updatePlaceholderVisibility()
    }
    
    private func setupCollectionView() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 10),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    
    private func setupNavBarItems() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(named: "AddTracker"),
            style: .plain,
            target: self,
            action: #selector(addTrackerButtonTapped)
        )
        navigationItem.leftBarButtonItem?.tintColor = UIColor(named: "CustomBlack")

        let datePicker = UIDatePicker()
        datePicker.tintColor = UIColor(named: "CustomBlack")
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
    }
    
    
    private func setupHeaderLabel() {
        headerLabel.text = "Трекеры"
        headerLabel.textColor = UIColor(named: "CustomBlack")
        headerLabel.font = UIFont(name: "YS Display Bold", size: 34)
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerLabel)
        
        NSLayoutConstraint.activate([
            headerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            headerLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,constant: 1),
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
        placeholderView.addSubview(starImage)
        
        NSLayoutConstraint.activate([
            starImage.topAnchor.constraint(equalTo: placeholderView.topAnchor),
            starImage.centerXAnchor.constraint(equalTo: placeholderView.centerXAnchor),
            starImage.widthAnchor.constraint(equalToConstant: 80),
            starImage.heightAnchor.constraint(equalToConstant: 80)
        ])
    }
    
    private func setupQuestionLabel() {
        questionLabel.text = "Что будем отслеживать?"
        questionLabel.font = UIFont(name:"YS Display Medium", size: 12)
        questionLabel.textColor = UIColor(named: "CustomBlack")
        questionLabel.translatesAutoresizingMaskIntoConstraints = false
        placeholderView.addSubview(questionLabel)
        
        NSLayoutConstraint.activate([
            questionLabel.topAnchor.constraint(equalTo: starImage.bottomAnchor, constant: 8),
            questionLabel.centerXAnchor.constraint(equalTo: placeholderView.centerXAnchor),
            questionLabel.bottomAnchor.constraint(equalTo: placeholderView.bottomAnchor)
        ])
    }
    
    private func updatePlaceholderVisibility () {
        let hasTrackers = !categories.isEmpty
        placeholderView.isHidden = hasTrackers
        collectionView.isHidden = !hasTrackers
    }
    
    @objc func addTrackerButtonTapped() {
            let typeCreationVC = TypeCreationViewController()
            let navController = UINavigationController(rootViewController: typeCreationVC)
            present(navController, animated: true)
    }
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        let selectedDate = sender.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        let formattedDate = dateFormatter.string(from: selectedDate)
        print("Выбранная дата: \(formattedDate)")
        
        updatePlaceholderVisibility()
        collectionView.reloadData()
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

extension TrackersViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories[section].trackers.count
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TrackersCell.cellIdentifier,
            for: indexPath
        ) as? TrackersCell else {
            fatalError("Unable to dequeue TrackersCell")
        }
        
        let tracker = categories[indexPath.section].trackers[indexPath.item]
        let isCompletedToday = completedTrackers.contains { record in
            record.trackerId == tracker.id && Calendar.current.isDate(record.date, inSameDayAs: datePicker.date)
        }
        
        cell.setupCell( name: tracker.title,
                        color: UIColor(named: tracker.color) ?? .systemBlue,
                        emoji: Character(tracker.emoji),
                        days: completedTrackers.filter { $0.trackerId == tracker.id }.count,
                        trackerID: tracker.id,
                        isCompletedToday: isCompletedToday)
        
//        cell.delegate = self
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            guard let headerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: HeaderCategoryView.headerIdentifier,
                for: indexPath
            ) as? HeaderCategoryView else {
                return UICollectionReusableView()
            }
            
            headerView.titleLabel.text = categories[indexPath.section].title
            return headerView
            
        default:
            fatalError("Unexpected supplementary view kind: \(kind)")
        }
    }
}

extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if DataManager.shared.categories.isEmpty {
            return .zero
        }
        
        return CGSize(width: collectionView.frame.width, height: 46)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 0, left: sideInset, bottom: 0, right: sideInset)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        minimumCellSpacing
    }
}


extension TrackersViewController: CreateDelegateProtocol {
    func didCreateEvent(title: String, category: TrackerCategory, emoji: Character, color: UIColor) {
        let colorName = "CustomBlue"
        let newEvent = Tracker(
            id: UUID(),
            title: title,
            color: colorName,
            emoji: String(emoji),
            schedule: []
        )
        DataManager.shared.addTracker(newEvent, toCategoryWithTitle: category.title)
        updateUIAfterTrackerCreation()
    }
    func didCreateHabit(title: String, category: TrackerCategory, emoji: Character, color: UIColor, schedule: Set<Day>) {
           let colorName = "CustomGreen" 
           let newTracker = Tracker(
               id: UUID(),
               title: title,
               color: colorName,
               emoji: String(emoji),
               schedule: schedule
           )
           DataManager.shared.addTracker(newTracker, toCategoryWithTitle: category.title)
           updateUIAfterTrackerCreation()
       }
    
    private func updateUIAfterTrackerCreation() {
        categories = DataManager.shared.categories
        updatePlaceholderVisibility()
        collectionView.reloadData()
    
        
        print("Обновление интерфейса. Количество категорий: \(categories.count)")
    }
    
}

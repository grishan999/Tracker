//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Ilya Grishanov on 31.03.2025.
//

import UIKit

protocol CreateDelegateProtocol: AnyObject {
    func didCreateHabit(
        title: String, category: TrackerCategory, emoji: Character,
        color: UIColor, schedule: Set<Day>)
    func didCreateEvent(
        title: String, category: TrackerCategory, emoji: Character,
        color: UIColor)
}

final class TrackersViewController: UIViewController {
    let trackerStore = TrackerStore()
    
    private let datePicker = UIDatePicker()
    private let headerLabel = UILabel()
    private let searchBar = UISearchBar()
    private let starImage = UIImageView()
    private let questionLabel = UILabel()
    
    private var hiddenCategories: [TrackerCategory] = []
    private var completedTrackers: [TrackerRecord] = []
    
    var currentDate: Date = Calendar.current.startOfDay(for: Date())
    
    lazy var cellWidth = ceil(
        (UIScreen.main.bounds.width - sideInset * 2 - 10) / 2)
    let cellHeight: CGFloat = 148
    let sideInset: CGFloat = 16
    let minimumCellSpacing: CGFloat = 9
    
    let trackerRecordStore = TrackerRecordStore()
    let trackerCategoryStore = TrackerCategoryStore()
    
    var categories: [TrackerCategory] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        categories = trackerCategoryStore.fetchCategories()
        filterTrackers(for: currentDate)
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
        let collectionView = UICollectionView(
            frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(
            TrackersCell.self,
            forCellWithReuseIdentifier: TrackersCell.cellIdentifier)
        collectionView.register(
            HeaderCategoryView.self,
            forSupplementaryViewOfKind: UICollectionView
                .elementKindSectionHeader,
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
            placeholderView.centerXAnchor.constraint(
                equalTo: view.centerXAnchor),
            placeholderView.centerYAnchor.constraint(
                equalTo: view.centerYAnchor),
        ])
        
        updatePlaceholderVisibility()
    }
    
    private func setupCollectionView() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(
                equalTo: searchBar.bottomAnchor, constant: 10),
            collectionView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    private func setupNavBarItems() {
        
        let addButton = UIBarButtonItem(
            image: UIImage(named: "AddTracker"),
            style: .plain,
            target: self,
            action: #selector(addTrackerButtonTapped))
        addButton.tintColor = UIColor(named: "CustomBlack")
        navigationItem.leftBarButtonItem = addButton
        
        let datePicker = UIDatePicker()
        datePicker.tintColor = UIColor(named: "CustomBlack")
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.addTarget(
            self, action: #selector(datePickerValueChanged(_:)),
            for: .valueChanged)
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            customView: datePicker)
    }
    
    private func setupHeaderLabel() {
        headerLabel.text = "Трекеры"
        headerLabel.textColor = UIColor(named: "CustomBlack")
        headerLabel.font = UIFont(name: "YS Display Bold", size: 34)
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerLabel)
        
        NSLayoutConstraint.activate([
            headerLabel.leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: 16),
            headerLabel.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 1),
        ])
    }
    
    private func setupSearchBar() {
        searchBar.placeholder = "Поиск"
        searchBar.searchBarStyle = .minimal
        searchBar.tintColor = .gray
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchBar)
        
        if let textField = searchBar.value(forKey: "searchField")
            as? UITextField
        {
            textField.layer.cornerRadius = 10
            textField.layer.masksToBounds = true
            textField.backgroundColor = .white
            textField.font = UIFont(name: "YS Display Medium", size: 17)
            
            textField.attributedPlaceholder = NSAttributedString(
                string: "Поиск",
                attributes: [
                    .foregroundColor: UIColor(named: "CustomGray") ?? .gray,
                    .font: UIFont(name: "YS Display Medium", size: 17)
                    ?? UIFont.systemFont(ofSize: 17),
                ]
            )
            
            textField.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                textField.heightAnchor.constraint(equalToConstant: 36),
                textField.leadingAnchor.constraint(
                    equalTo: searchBar.leadingAnchor),
                textField.trailingAnchor.constraint(
                    equalTo: searchBar.trailingAnchor),
                textField.centerYAnchor.constraint(
                    equalTo: searchBar.centerYAnchor),
            ])
            
            textField.delegate = self
            
            if let glassIconView = textField.leftView as? UIImageView {
                glassIconView.image = glassIconView.image?.withRenderingMode(
                    .alwaysTemplate)
                glassIconView.tintColor = .gray
            }
        }
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(
                equalTo: headerLabel.bottomAnchor, constant: 7),
            searchBar.leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: 16),
            searchBar.trailingAnchor.constraint(
                equalTo: view.trailingAnchor, constant: -16),
            searchBar.heightAnchor.constraint(equalToConstant: 36),
        ])
    }
    
    private func setupStarImage() {
        starImage.image = UIImage(named: "Star")
        starImage.translatesAutoresizingMaskIntoConstraints = false
        placeholderView.addSubview(starImage)
        
        NSLayoutConstraint.activate([
            starImage.topAnchor.constraint(equalTo: placeholderView.topAnchor),
            starImage.centerXAnchor.constraint(
                equalTo: placeholderView.centerXAnchor),
            starImage.widthAnchor.constraint(equalToConstant: 80),
            starImage.heightAnchor.constraint(equalToConstant: 80),
        ])
    }
    
    private func setupQuestionLabel() {
        questionLabel.text = "Что будем отслеживать?"
        questionLabel.font = UIFont(name: "YS Display Medium", size: 12)
        questionLabel.textColor = UIColor(named: "CustomBlack")
        questionLabel.translatesAutoresizingMaskIntoConstraints = false
        placeholderView.addSubview(questionLabel)
        
        NSLayoutConstraint.activate([
            questionLabel.topAnchor.constraint(
                equalTo: starImage.bottomAnchor, constant: 8),
            questionLabel.centerXAnchor.constraint(
                equalTo: placeholderView.centerXAnchor),
            questionLabel.bottomAnchor.constraint(
                equalTo: placeholderView.bottomAnchor),
        ])
    }
    
    
    @objc func addTrackerButtonTapped() {
        let typeCreationVC = TypeCreationViewController()
        typeCreationVC.delegate = self
        let navController = UINavigationController(
            rootViewController: typeCreationVC)
        present(navController, animated: true)
    }
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        let selectedDate = sender.date
        currentDate = selectedDate
        datePicker.date = selectedDate
        filterTrackers(for: selectedDate)
        
        updatePlaceholderVisibility()
        collectionView.reloadData()
    }
    
    private func filterTrackers(for date: Date) {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)
        let isToday = calendar.isDate(date, inSameDayAs: Date())
        
        try? trackerCategoryStore.fetchedResultsController?.performFetch()
        try? trackerRecordStore.fetchedResultsController?.performFetch()
        
        let allTrackers = trackerStore.fetchTrackers()
        var categorizedTrackers: [String: [Tracker]] = [:]
        
        for tracker in allTrackers {
            let shouldShow: Bool
            
            if tracker.schedule.isEmpty {
                shouldShow = isToday
            } else {
                shouldShow = tracker.schedule.contains { $0.calendarDayNumber == weekday }
            }
            if shouldShow {
                categorizedTrackers[tracker.category.title, default: []].append(tracker)
            }
        }
        
        categories = categorizedTrackers.map {
            TrackerCategory(title: $0.key, trackers: $0.value)
        }.sorted { $0.title < $1.title }
        
        updatePlaceholderVisibility()
        collectionView.reloadData()
    }
    
    private func completeTracker(with id: UUID, on date: Date) {
        let record = TrackerRecord(trackerId: id, date: date)
        completedTrackers.append(record)
    }
    
    private func undoCompleteTracker(with id: UUID, on date: Date) {
        completedTrackers.removeAll {
            $0.trackerId == id
            && Calendar.current.isDate($0.date, inSameDayAs: date)
        }
    }
    
    private func addNewTracker(_ tracker: Tracker, to categoryTitle: String) {
        var newCategories = categories
        
        if let index = newCategories.firstIndex(where: {
            $0.title == categoryTitle
        }) {
            
            let existingCategory = newCategories[index]
            let updatedTrackers = existingCategory.trackers + [tracker]
            newCategories[index] = TrackerCategory(
                title: existingCategory.title, trackers: updatedTrackers)
        } else {
            
            let newCategory = TrackerCategory(
                title: categoryTitle, trackers: [tracker])
            newCategories.append(newCategory)
        }
        
        categories = newCategories
    }
    
    func updatePlaceholderVisibility() {
        let hasVisibleTrackers = categories.contains { !$0.trackers.isEmpty }
        placeholderView.isHidden = hasVisibleTrackers
        collectionView.isHidden = !hasVisibleTrackers
        
    }
    
}

extension TrackersViewController: TrackersCellDelegate {
    func didToggleCompletion(for trackerID: UUID, on date: Date, isCompleted: Bool) {
        guard Calendar.current.startOfDay(for: date) <= Calendar.current.startOfDay(for: Date()) else { return }
        
        do {
            if isCompleted {
                let records = trackerRecordStore.fetchRecords(for: trackerID)
                if !records.contains(where: {
                    Calendar.current.isDate($0.date, inSameDayAs: date)
                }) {
                    try trackerRecordStore.addRecord(trackerId: trackerID, date: date)
                }
            } else {
                let records = trackerRecordStore.fetchRecords(for: trackerID)
                if let recordToRemove = records.first(where: {
                    Calendar.current.isDate($0.date, inSameDayAs: date)
                }) {
                    guard let fetchedObjects = trackerRecordStore.fetchedResultsController?.fetchedObjects else { return }
                    
                    if let index = fetchedObjects.firstIndex(where: {
                        $0.trackerId == recordToRemove.trackerId &&
                        Calendar.current.isDate($0.date!, inSameDayAs: recordToRemove.date)
                    }) {
                        let object = trackerRecordStore.fetchedResultsController?.object(at: IndexPath(row: index, section: 0))
                        if let object = object {
                            trackerRecordStore.context.delete(object)
                            try trackerRecordStore.context.save()
                        }
                    }
                }
            }
            
            categories = trackerCategoryStore.fetchCategories()
            filterTrackers(for: currentDate)
            collectionView.reloadData()
        } catch {
            if let indexPath = findIndexPath(for: trackerID) {
                collectionView.reloadItems(at: [indexPath])
            }
        }
    }
    
    private func findIndexPath(for trackerID: UUID) -> IndexPath? {
        for (section, category) in categories.enumerated() {
            if let row = category.trackers.firstIndex(where: { $0.id == trackerID }) {
                return IndexPath(row: row, section: section)
            }
        }
        return nil
    }
}

extension TrackersViewController: CreateDelegateProtocol {
    func didCreateEvent(
        title: String,
        category: TrackerCategory,
        emoji: Character,
        color: UIColor
    ) {
        let newEvent = Tracker(
            id: UUID(),
            title: title,
            color: color,
            emoji: String(emoji),
            schedule: [],
            category: category
        )
        
        do {
            try trackerStore.addTracker(newEvent, categoryTitle: category.title)
            updateUIAfterTrackerCreation()
        } catch {
            print("Failed to add event: \(error)")
        }
    }
    
    func didCreateHabit(
        title: String,
        category: TrackerCategory,
        emoji: Character,
        color: UIColor,
        schedule: Set<Day>
    ) {
        let newTracker = Tracker(
            id: UUID(),
            title: title,
            color: color,
            emoji: String(emoji),
            schedule: schedule,
            category: category
        )
        
        do {
            try trackerStore.addTracker(newTracker, categoryTitle: category.title)
            updateUIAfterTrackerCreation()
        } catch {
            print("Failed to add habit: \(error)")
        }
    }
    
    private func updateUIAfterTrackerCreation() {
        DispatchQueue.main.async {
            self.categories = self.trackerCategoryStore.fetchCategories()
            self.filterTrackers(for: self.currentDate)
            self.collectionView.reloadData()
            self.updatePlaceholderVisibility()
        }
    }
}

extension TrackersViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        filterTrackers(for: currentDate, with: updatedText)
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        filterTrackers(for: currentDate)
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    private func filterTrackers(for date: Date, with searchText: String = "") {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)
        let isToday = calendar.isDate(date, inSameDayAs: Date())
        
        try? trackerCategoryStore.fetchedResultsController?.performFetch()
        try? trackerRecordStore.fetchedResultsController?.performFetch()
        
        let allTrackers = trackerStore.fetchTrackers()
        var categorizedTrackers: [String: [Tracker]] = [:]
        
        for tracker in allTrackers {
            let shouldShowByDate: Bool
            if tracker.schedule.isEmpty {
                shouldShowByDate = isToday
            } else {
                shouldShowByDate = tracker.schedule.contains { $0.calendarDayNumber == weekday }
            }
            
            let shouldShowBySearch = searchText.isEmpty ||
            tracker.title.lowercased().contains(searchText.lowercased())
            
            if shouldShowByDate && shouldShowBySearch {
                categorizedTrackers[tracker.category.title, default: []].append(tracker)
            }
        }
        
        categories = categorizedTrackers.map {
            TrackerCategory(title: $0.key, trackers: $0.value)
        }.sorted { $0.title < $1.title }
        
        updatePlaceholderVisibility()
        collectionView.reloadData()
    }
}

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
    
    var currentFilter: FilterType = .all
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(named: "ViewBackgroundColor")
        
        categories = trackerCategoryStore.fetchCategories()
        filterTrackers(for: currentDate)
        setupUI()
    }
    
    lazy var trackersCollectionView: UICollectionView = {
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
    
    private lazy var placeholderView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    
    private func setupUI() {
        setupNavBarItems()
        setupHeaderLabel()
        setupSearchBar()
        setupStarImage()
        setupQuestionLabel()
        setupCollectionView()
        setupFilterButton()
        
        view.addSubview(placeholderView)
        NSLayoutConstraint.activate([
            placeholderView.centerXAnchor.constraint(
                equalTo: view.centerXAnchor),
            placeholderView.centerYAnchor.constraint(
                equalTo: view.centerYAnchor),
        ])
        
        updatePlaceholderVisibility()
        setupKeyboard()
    }
    
    
    private func setupCollectionView() {
        trackersCollectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(trackersCollectionView)
        
        NSLayoutConstraint.activate([
            trackersCollectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 10),
            trackersCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            trackersCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            trackersCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        trackersCollectionView.alwaysBounceVertical = true
        trackersCollectionView.contentInset.bottom = 66
        
        trackersCollectionView.verticalScrollIndicatorInsets.bottom = 66
        trackersCollectionView.horizontalScrollIndicatorInsets.bottom = 0
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
        headerLabel.text = NSLocalizedString("trackers.header",
                                             comment: "Заголовок Трекеры на главном экране")
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
        searchBar.searchBarStyle = .minimal
        
        searchBar.tintColor = UIColor(named: "SearchColor")
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchBar)
        
        if let textField = searchBar.value(forKey: "searchField")
            as? UITextField
        {
            textField.layer.cornerRadius = 10
            textField.layer.masksToBounds = true
            textField.backgroundColor = UIColor(named: "SearchColor")
            textField.font = UIFont(name: "YS Display Medium", size: 17)
            
            textField.attributedPlaceholder = NSAttributedString(
                string: NSLocalizedString("searchBar.placeholder",
                                          comment: "Плейсхолдер Поиск"),
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
        questionLabel.text = NSLocalizedString("emptyState.trackers.title",
                                               comment: "Заглушка на пустом экране Трекеров")
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
    
    private lazy var filterButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("filters.button",
                                          comment: "Кнопка Фильтры"),
                        for: .normal)
        button.titleLabel?.font = UIFont(name: "YS Display Medium", size: 17)
        button.setTitleColor(UIColor(named: "AlwaysWhiteColor"), for: .normal)
        button.backgroundColor = UIColor(named: "CustomBlue")
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private func setupFilterButton() {
        view.addSubview(filterButton)
        NSLayoutConstraint.activate([
            filterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filterButton.widthAnchor.constraint(equalToConstant: 114),
            filterButton.heightAnchor.constraint(equalToConstant: 50),
            filterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
        filterButton.layer.zPosition = 15
    }
    
    private func setupKeyboard() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        if let textField = searchBar.value(forKey: "searchField") as? UITextField {
            textField.delegate = self
        }
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func filterButtonTapped() {
        let filterVC = FiltersViewController(selectedFilter: currentFilter)
        filterVC.delegate = self
        let navController = UINavigationController(rootViewController: filterVC)
        navController.modalPresentationStyle = .automatic
        present(navController, animated: true)
        
        AnalyticsService.shared.report(event: "click", screen: "Main", item: "filter")
    }
    
    @objc func addTrackerButtonTapped() {
        let typeCreationVC = TypeCreationViewController()
        typeCreationVC.delegate = self
        let navController = UINavigationController(
            rootViewController: typeCreationVC)
        present(navController, animated: true)
        
        AnalyticsService.shared.report(event: "click", screen: "Main", item: "add_track")
    }
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        let selectedDate = sender.date
        currentDate = selectedDate
        filterTrackers(for: selectedDate)
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
        trackersCollectionView.isHidden = !hasVisibleTrackers
    }
    
    func togglePin(for trackerID: UUID) {
        try? trackerStore.togglePin(for: trackerID)
        categories = trackerCategoryStore.fetchCategories()
        filterTrackers(for: currentDate)
        trackersCollectionView.reloadData()
    }
    
    func filterTrackers(for date: Date, with searchText: String = "") {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)
        let isToday = calendar.isDate(date, inSameDayAs: Date())
        
        try? trackerCategoryStore.fetchedResultsController?.performFetch()
        try? trackerRecordStore.fetchedResultsController?.performFetch()
        
        let allTrackers = trackerStore.fetchTrackers()
        let completedTrackerIDs = trackerRecordStore.fetchCompletedTrackerIDs(for: date)
        var categorizedTrackers: [String: [Tracker]] = [:]
        
        var filteredTrackers: [Tracker] = allTrackers.filter { tracker in
            let matchesSchedule = tracker.schedule.isEmpty ||
            tracker.schedule.contains { $0.calendarDayNumber == weekday }
            
            switch currentFilter {
            case .all:
                return matchesSchedule
            case .today:
                return matchesSchedule && isToday
            case .completed:
                return matchesSchedule && completedTrackerIDs.contains(tracker.id)
            case .notCompleted:
                return matchesSchedule && !completedTrackerIDs.contains(tracker.id)
            }
        }
        
        let pinnedTrackers = filteredTrackers.filter { $0.isPinned }
        if !pinnedTrackers.isEmpty {
            categorizedTrackers[NSLocalizedString("pinned",
                                                  comment: "Заголовок Закрепленные")]
            = pinnedTrackers
        }
        
        for tracker in filteredTrackers where !tracker.isPinned {
            let shouldShowBySearch = searchText.isEmpty ||
            tracker.title.localizedCaseInsensitiveContains(searchText)
            
            if shouldShowBySearch {
                categorizedTrackers[tracker.category.title, default: []].append(tracker)
            }
        }
        
        categories = categorizedTrackers.map {
            TrackerCategory(title: $0.key, trackers: $0.value)
        }.sorted {
            if $0.title == NSLocalizedString("pinned",
                                             comment: "Заголовок Закрепленные")
            { return true }
            if $1.title == NSLocalizedString("pinned",
                                             comment: "Заголовок Закрепленные")
            { return false }
            return $0.title < $1.title
        }
        
        updatePlaceholderVisibility()
        trackersCollectionView.reloadData()
    }
    
    func applyFilter(_ filter: FilterType) {
        currentFilter = filter
        
        if filter == .today {
            let today = Date()
            currentDate = Calendar.current.startOfDay(for: today)
            datePicker.date = today
        }
        
        filterTrackers(for: currentDate)
        updatePlaceholderVisibility()
        trackersCollectionView.reloadData()
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
            self.trackersCollectionView.reloadData()
            self.updatePlaceholderVisibility()
        }
    }
}

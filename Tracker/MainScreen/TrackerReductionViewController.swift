//
//  TrackerReductionViewController.swift
//  Tracker
//
//  Created by Ilya Grishanov on 29.04.2025.
//

import UIKit

protocol TrackerUpdateDelegate: AnyObject {
    func didUpdateTracker(_ tracker: Tracker, with newData: Tracker)
}

final class TrackerReductionViewController: UIViewController {
    
    weak var delegate: TrackerUpdateDelegate?
    private var trackerToEdit: Tracker
    private var selectedCategory: TrackerCategory?
    private var schedule: Set<Day> = []
    private var selectedEmoji: String?
    private var selectedColor: UIColor?
    private var daysCount: Int = 0
    
    private let emojies = [
        "🙂", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶", "🤔", "🙌", "🍔", "🥦", "🏓",
        "🥇", "🎸", "🏝️", "😪",
    ]
    
    private let colors: [UIColor] = [
        UIColor(named: "Selection 1"),
        UIColor(named: "Selection 2"),
        UIColor(named: "Selection 3"),
        UIColor(named: "Selection 4"),
        UIColor(named: "Selection 5"),
        UIColor(named: "Selection 6"),
        UIColor(named: "Selection 7"),
        UIColor(named: "Selection 8"),
        UIColor(named: "Selection 9"),
        UIColor(named: "Selection 10"),
        UIColor(named: "Selection 11"),
        UIColor(named: "Selection 12"),
        UIColor(named: "Selection 13"),
        UIColor(named: "Selection 14"),
        UIColor(named: "Selection 15"),
        UIColor(named: "Selection 16"),
        UIColor(named: "Selection 17"),
        UIColor(named: "Selection 18"),
    ].compactMap { $0 }
    
    private lazy var daysCountLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textAlignment = .center
        label.font = UIFont(name: "YS Display Bold", size: 32)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var trackerNameTextField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = UIColor(named: "CustomBackgroundDay")
        textField.placeholder = "Введите название трекера"
        textField.layer.cornerRadius = 16
        textField.clearButtonMode = .whileEditing
        textField.leftView = UIView(
            frame: CGRect(x: 0, y: 0, width: 16, height: textField.frame.height)
        )
        textField.leftViewMode = .always
        textField.addTarget(
            self, action: #selector(textFieldDidChange), for: .editingChanged)
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let tableViewCells: [String] = ["Категория", "Расписание"]
    
    private lazy var settingsTableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.layer.cornerRadius = 16
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = false
        tableView.separatorInset = UIEdgeInsets(
            top: 0, left: 16, bottom: 0, right: 16)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Отменить", for: .normal)
        button.setTitleColor(UIColor(named: "CancelButtonRed"), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 16
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(named: "CancelButtonRed")?.cgColor
        button.addTarget(
            self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var saveButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("Сохранить", for: .normal)
        button.setTitleColor(UIColor(named: "CustomWhite"), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 16
        button.layer.borderWidth = 1
        button.backgroundColor = UIColor(named: "CustomBlack")
        button.layer.borderColor = UIColor(named: "CustomBlack")?.cgColor
        button.addTarget(
            self, action: #selector(saveButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var buttonsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            cancelButton, saveButton,
        ])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var emojiHeaderLabel: UILabel = {
        let label = UILabel()
        label.text = "Emoji"
        label.font = UIFont(name: "YS Display Bold", size: 19)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var emojiCollectionView: HabitEmojiCollection = {
        let collectionView = HabitEmojiCollection(emojies: emojies)
        collectionView.selectionDelegate = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private lazy var colorCollectionView: HabitColorCollection = {
        let collectionView = HabitColorCollection(colors: colors)
        collectionView.selectionDelegate = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private lazy var colorHeaderLabel: UILabel = {
        let label = UILabel()
        label.text = "Цвет"
        label.font = UIFont(name: "YS Display Bold", size: 19)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    init(trackerToEdit: Tracker, category: TrackerCategory?, daysCount: Int) {
        self.trackerToEdit = trackerToEdit
        self.selectedCategory = category
        self.daysCount = daysCount
        super.init(nibName: nil, bundle: nil)
        
        trackerNameTextField.text = trackerToEdit.title
        selectedEmoji = String(trackerToEdit.emoji)
        selectedColor = trackerToEdit.color
        schedule = trackerToEdit.schedule ?? []
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        navigationController?.navigationBar.tintColor = UIColor(named: "CustomBlack")
        navigationItem.title = "Редактирование привычки"
        
        setupUI()
        updateSaveButtonState()
        daysCountLabel.text = daysCount.days()
    }
    
    
    private func setupUI() {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        contentView.addSubview(trackerNameTextField)
        contentView.addSubview(settingsTableView)
        contentView.addSubview(emojiHeaderLabel)
        contentView.addSubview(emojiCollectionView)
        contentView.addSubview(colorHeaderLabel)
        contentView.addSubview(colorCollectionView)
        contentView.addSubview(buttonsStackView)
        contentView.addSubview(daysCountLabel)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            trackerNameTextField.topAnchor.constraint(equalTo: daysCountLabel.bottomAnchor, constant: 40),
            trackerNameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            trackerNameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            trackerNameTextField.heightAnchor.constraint(equalToConstant: 75),
            
            settingsTableView.topAnchor.constraint(equalTo: trackerNameTextField.bottomAnchor, constant: 24),
            settingsTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            settingsTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            settingsTableView.heightAnchor.constraint(equalToConstant: 150),
            
            emojiHeaderLabel.topAnchor.constraint(equalTo: settingsTableView.bottomAnchor, constant: 32),
            emojiHeaderLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),
            
            emojiCollectionView.topAnchor.constraint(equalTo: emojiHeaderLabel.bottomAnchor, constant: 8),
            emojiCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            emojiCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            emojiCollectionView.heightAnchor.constraint(equalToConstant: 204),
            
            colorHeaderLabel.topAnchor.constraint(equalTo: emojiCollectionView.bottomAnchor, constant: -26),
            colorHeaderLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),
            
            colorCollectionView.topAnchor.constraint(equalTo: colorHeaderLabel.bottomAnchor, constant: 15),
            colorCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            colorCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            colorCollectionView.heightAnchor.constraint(equalToConstant: 204),
            
            buttonsStackView.topAnchor.constraint(equalTo: colorCollectionView.bottomAnchor, constant: 8),
            buttonsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            buttonsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            buttonsStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            buttonsStackView.heightAnchor.constraint(equalToConstant: 60),
            
            daysCountLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            daysCountLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            daysCountLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
        ])
    }
    
    @objc private func textFieldDidChange() {
        updateSaveButtonState()
    }
    
    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc private func saveButtonTapped() {
        guard let trackerName = trackerNameTextField.text, !trackerName.isEmpty,
              let category = selectedCategory,
              let selectedEmoji = selectedEmoji,
              let selectedColor = selectedColor else { return }
        
        let updatedTracker = Tracker(
            id: trackerToEdit.id,
            title: trackerName,
            color: selectedColor,
            emoji: selectedEmoji,
            schedule: schedule,
            category: category,
            isPinned: trackerToEdit.isPinned
        )
        
        delegate?.didUpdateTracker(trackerToEdit, with: updatedTracker)
        dismiss(animated: true)
    }
    
    
    private func presentCategorySelection() {
        let categoryVC = CategoryCreationViewController { [weak self] category in
            self?.selectedCategory = category
            if let cell = self?.settingsTableView.cellForRow(at: IndexPath(row: 0, section: 0)) {
                cell.detailTextLabel?.text = category.title
            }
            self?.updateSaveButtonState()
        }
        let navController = UINavigationController(rootViewController: categoryVC)
        present(navController, animated: true)
    }
    
    private func updateSaveButtonState() {
        let isTextValid = !(trackerNameTextField.text?.isEmpty ?? true)
        let isScheduleSelected = !schedule.isEmpty
        let isEmojiSelected = selectedEmoji != nil
        let isColorSelected = selectedColor != nil
        
        saveButton.isEnabled = isTextValid && isScheduleSelected && isEmojiSelected && isColorSelected
        saveButton.backgroundColor = saveButton.isEnabled ? UIColor(named: "CustomBlack") : UIColor(named: "CustomGray")
    }
    
    private func formatScheduleText(days: Set<Day>) -> String {
        guard !days.isEmpty else { return "" }
        
        if days.count == Day.allCases.count {
            return "Каждый день"
        }
        
        let sortedDays = Day.allCases.filter { days.contains($0) }
        return sortedDays.map { $0.shortName }.joined(separator: ", ")
    }
}

extension TrackerReductionViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewCells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        cell.accessoryType = .disclosureIndicator
        
        cell.textLabel?.text = tableViewCells[indexPath.row]
        
        if indexPath.row == 0 {
            cell.detailTextLabel?.text = selectedCategory?.title ?? "Выберите категорию"
        } else if indexPath.row == 1 {
            cell.detailTextLabel?.text = schedule.isEmpty ? "" : formatScheduleText(days: schedule)
        }
        
        cell.detailTextLabel?.textColor = UIColor(named: "CustomGray")
        cell.textLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        cell.textLabel?.textColor = UIColor(named: "CustomBlack")
        cell.detailTextLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        cell.backgroundColor = UIColor(named: "CustomBackgroundDay")
        
        let separator = UIView()
        separator.backgroundColor = UIColor(named: "CustomGray")?.withAlphaComponent(0.3)
        separator.tag = 100
        cell.contentView.addSubview(separator)
        separator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            separator.leadingAnchor.constraint(
                equalTo: cell.contentView.leadingAnchor, constant: 16),
            separator.trailingAnchor.constraint(
                equalTo: cell.contentView.trailingAnchor, constant: -16),
            separator.bottomAnchor.constraint(
                equalTo: cell.contentView.bottomAnchor),
            separator.heightAnchor.constraint(equalToConstant: 0.5),
        ])
        
        let isLastCell = indexPath.row == tableViewCells.count - 1
        separator.isHidden = isLastCell
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == 0 {
            presentCategorySelection()
        } else if indexPath.row == 1 {
            let scheduleVC = ScheduleViewController()
            scheduleVC.delegate = self
            scheduleVC.selectedDays = schedule
            let navController = UINavigationController(rootViewController: scheduleVC)
            present(navController, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cornerRadius: CGFloat = 16
        let isFirstCell = indexPath.row == 0
        let isLastCell = indexPath.row == tableViewCells.count - 1
        
        if isFirstCell {
            cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            cell.layer.cornerRadius = cornerRadius
        } else if isLastCell {
            cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            cell.layer.cornerRadius = cornerRadius
        } else {
            cell.layer.cornerRadius = 0
        }
        cell.layer.masksToBounds = true
        tableView.separatorStyle = .none
    }
}

extension TrackerReductionViewController: ScheduleViewControllerDelegate {
    func didSelectSchedule(_ days: Set<Day>) {
        schedule = days
        if let cell = settingsTableView.cellForRow(at: IndexPath(row: 1, section: 0)) {
            cell.detailTextLabel?.text = formatScheduleText(days: days)
        }
        updateSaveButtonState()
    }
}

extension TrackerReductionViewController: HabitEmojiSelectionDelegate {
    func didSelectEmoji(_ emoji: String) {
        selectedEmoji = emoji
        updateSaveButtonState()
    }
}

extension TrackerReductionViewController: HabitColorSelectionDelegate {
    func didSelectColor(_ color: UIColor) {
        selectedColor = color
        updateSaveButtonState()
    }
}

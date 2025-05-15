//
//  EventCreationViewController.swift
//  Tracker
//
//  Created by Ilya Grishanov on 08.04.2025.
//
protocol EventEmojiSelectionDelegate: AnyObject {
    func didSelectEmoji(_ emoji: String)
}

protocol EventColorSelectionDelegate: AnyObject {
    func didSelectColor(_ color: UIColor)
}

import UIKit

final class EventCreationViewController: UIViewController {
    
    weak var delegate: CreateDelegateProtocol?
    private var selectedCategory: TrackerCategory?
    private var selectedEmoji: String?
    private var selectedColor: UIColor?
    private let keyboardManager: KeyboardManageable
    
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
    
    private lazy var eventNameTextField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = UIColor(named: "CustomBackgroundDay")
        textField.placeholder = NSLocalizedString("event.name.placeholder",
                                                  comment: "Плейсхолдер названия трекера")
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
    
    private let tableViewCells: [String] = [
        NSLocalizedString("category.tableview.button", comment: "Кнопка выбора категории")
    ]
    
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
        button.setTitle(NSLocalizedString("cancel.creation.tracker.button",
                                          comment: "Кнопка отмены создания трекера"),
                        for: .normal)
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
    
    private lazy var createButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle(NSLocalizedString("create.creation.tracker.button",
                                          comment: "Кнопка создания трекера Создать"),
                        for: .normal)
        button.setTitleColor(UIColor(named: "AlwaysWhiteColor"), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 16
        button.layer.borderWidth = 1
        button.backgroundColor = UIColor(named: "CustomGray")
        button.layer.borderColor = UIColor(named: "CustomGray")?.cgColor
        button.addTarget(
            self, action: #selector(createButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var emojiCollectionView: EventEmojiCollection = {
        let collectionView = EventEmojiCollection(emojies: emojies)
        collectionView.selectionDelegate = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private lazy var emojiHeaderLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("emoji.collection.title",
                                       comment: "Заголовок Emoji")
        label.font = UIFont(name: "YS Display Bold", size: 19)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var colorCollectionView: EventColorCollection = {
        let collectionView = EventColorCollection(colors: colors)
        collectionView.selectionDelegate = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private lazy var colorHeaderLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("color.collection.title",
                                       comment: "Заголовок Цвет")
        label.font = UIFont(name: "YS Display Bold", size: 19)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var buttonsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            cancelButton, createButton,
        ])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        navigationController?.navigationBar.tintColor = UIColor(
            named: "CustomBlack")
        navigationItem.title = NSLocalizedString("new.event.vc.title",
                                                 comment: "Название вьюшки Новое нерегулярное событие")
        
        setupUI()
        setupKeyboard()
    }
    
    private func setupKeyboard() {
        keyboardManager.setupKeyboardDismissal(for: view)
        keyboardManager.registerTextField(eventNameTextField)
    }
    
    private func setupUI() {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        contentView.addSubview(eventNameTextField)
        contentView.addSubview(settingsTableView)
        contentView.addSubview(emojiHeaderLabel)
        contentView.addSubview(emojiCollectionView)
        contentView.addSubview(colorHeaderLabel)
        contentView.addSubview(colorCollectionView)
        contentView.addSubview(buttonsStackView)
        
        createButton.backgroundColor = UIColor(named: "CustomGray")
        createButton.isEnabled = false
        
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
            
            eventNameTextField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            eventNameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            eventNameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            eventNameTextField.heightAnchor.constraint(equalToConstant: 75),
            
            settingsTableView.topAnchor.constraint(equalTo: eventNameTextField.bottomAnchor, constant: 24),
            settingsTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            settingsTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            settingsTableView.heightAnchor.constraint(equalToConstant: 75),
            
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
        ])
    }
    
    init(
            keyboardManager: KeyboardManageable = KeyboardManager()
        ) {
            self.keyboardManager = keyboardManager
            super.init(nibName: nil, bundle: nil)
        }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func textFieldDidChange() {
        updateCreateButtonState()
    }
    
    @objc private func cancelButtonTapped() {
        self.dismiss(animated: true)
    }
    
    @objc private func createButtonTapped() {
        guard let eventName = eventNameTextField.text, !eventName.isEmpty,
              let category = selectedCategory,
              let selectedEmoji = selectedEmoji,
              let selectedColor = selectedColor else {
            return
        }
        
        delegate?.didCreateEvent(
            title: eventName,
            category: category,
            emoji: Character(selectedEmoji),
            color: selectedColor
        )
        presentingViewController?.presentingViewController?.dismiss(animated: true)
    }
    
    private func updateCreateButtonState() {
        let isTextValid = !(eventNameTextField.text?.isEmpty ?? true)
        let isCategorySelected = selectedCategory != nil
        let isEmojiSelected = selectedEmoji != nil
        let isColorSelected = selectedColor != nil
        
        let isFormValid = isTextValid && isCategorySelected && isEmojiSelected && isColorSelected
        
        createButton.backgroundColor = isFormValid ? .customBlack : .customGray
        createButton.isEnabled = isFormValid
        
        createButton.setTitleColor(UIColor(named: "CustomWhite"), for: .normal)
        createButton.setTitleColor(UIColor(named: "AlwaysWhiteColor"), for: .disabled)
    }
}

extension EventCreationViewController: UITableViewDelegate,
                                       UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int)
    -> Int
    {
        return tableViewCells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        cell.accessoryType = .disclosureIndicator
        
        cell.textLabel?.text = tableViewCells[indexPath.row]
        if indexPath.row == 0 {
            cell.detailTextLabel?.text = selectedCategory?.title
        }
        
        cell.detailTextLabel?.textColor = UIColor(named: "CustomGray")
        cell.textLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        cell.textLabel?.textColor = UIColor(named: "CustomBlack")
        cell.detailTextLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        
        cell.accessoryType = .disclosureIndicator
        cell.backgroundColor = UIColor(named: "CustomBackgroundDay")
        cell.backgroundView = UIView()
        cell.backgroundView?.backgroundColor = UIColor(
            named: "CustomBackgroundDay")
        
        return cell
    }
    
    func tableView(
        _ tableView: UITableView, willDisplay cell: UITableViewCell,
        forRowAt indexPath: IndexPath
    ) {
        let cornerRadius: CGFloat = 16
        let isLastCell = indexPath.row == tableViewCells.count - 1
        
        if isLastCell {
            cell.layer.maskedCorners = [
                .layerMinXMaxYCorner, .layerMaxXMaxYCorner,
            ]
            cell.layer.cornerRadius = cornerRadius
            cell.layer.masksToBounds = true
            
            cell.separatorInset = UIEdgeInsets(
                top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        } else {
            cell.layer.maskedCorners = []
            cell.layer.cornerRadius = 0
        }
        tableView.separatorColor = UIColor(named: "CustomGray")
    }
    
    func tableView(
        _ tableView: UITableView, heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == 0 {
            presentCategorySelection()
        }
    }
}

extension EventCreationViewController: EventEmojiSelectionDelegate, EventColorSelectionDelegate {
    func didSelectEmoji(_ emoji: String) {
        selectedEmoji = emoji
        updateCreateButtonState()
    }
    
    func didSelectColor(_ color: UIColor) {
        selectedColor = color
        updateCreateButtonState()
    }
    
}

extension EventCreationViewController {
    private func presentCategorySelection() {
        let categoryVC = CategoryCreationViewController { [weak self] category in
            self?.selectedCategory = category
            self?.settingsTableView.reloadData()
            self?.updateCreateButtonState()
            self?.dismiss(animated: true)
        }
        let navController = UINavigationController(rootViewController: categoryVC)
        present(navController, animated: true)
    }
}

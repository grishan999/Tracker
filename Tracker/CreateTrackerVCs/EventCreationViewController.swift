//
//  EventCreationViewController.swift
//  Tracker
//
//  Created by Ilya Grishanov on 08.04.2025.
//

import UIKit

final class EventCreationViewController: UIViewController {
    
    private var category: TrackerCategory = TrackerCategory(
        title: "Уборка", trackers: [])
    weak var delegate: CreateDelegateProtocol?
    
    private lazy var eventNameTextField: UITextField = {
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
    
    private let tableViewCells: [String] = ["Категория"]
    
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
        button.setTitle("Отмена", for: .normal)
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
        button.setTitle("Создать", for: .normal)
        button.setTitleColor(UIColor(named: "CustomWhite"), for: .normal)
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
        navigationItem.title = "Новое событие"
        
        setupUI()
    }
    
    private func setupUI() {
        view.addSubview(eventNameTextField)
        view.addSubview(settingsTableView)
        view.addSubview(buttonsStackView)
        
        // Начальное состояние кнопки "Создать"
        createButton.backgroundColor = UIColor(named: "CustomGray")
        createButton.isEnabled = false
        
        NSLayoutConstraint.activate([
            eventNameTextField.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            eventNameTextField.leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: 16),
            eventNameTextField.trailingAnchor.constraint(
                equalTo: view.trailingAnchor, constant: -16),
            eventNameTextField.heightAnchor.constraint(equalToConstant: 75),
            
            settingsTableView.topAnchor.constraint(
                equalTo: eventNameTextField.bottomAnchor, constant: 24),
            settingsTableView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: 16),
            settingsTableView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor, constant: -16),
            settingsTableView.heightAnchor.constraint(equalToConstant: 150),
            
            buttonsStackView.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            buttonsStackView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: 20),
            buttonsStackView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor, constant: -20),
            buttonsStackView.heightAnchor.constraint(equalToConstant: 60),
            
            cancelButton.widthAnchor.constraint(
                equalTo: createButton.widthAnchor),
        ])
    }
    
    @objc private func textFieldDidChange() {
        updateCreateButtonState()
    }
    
    @objc private func cancelButtonTapped() {
        self.dismiss(animated: true)
    }
    
    @objc private func createButtonTapped() {
        
        guard let eventName = eventNameTextField.text, !eventName.isEmpty else {
            print("Название события не может быть пустым")
            return
        }
        
        guard !category.title.isEmpty else {
            print("Категория не выбрана")
            return
        }
        
        delegate?.didCreateEvent(
            title: eventName, category: category, emoji: "🫡", color: .clear)
        presentingViewController?.presentingViewController?.dismiss(
            animated: true)
        
    }
    
    private func updateCreateButtonState() {
        let isTextValid = !(eventNameTextField.text?.isEmpty ?? true)
        
        if isTextValid {
            createButton.backgroundColor = UIColor(named: "CustomBlack")
            createButton.isEnabled = true
        } else {
            createButton.backgroundColor = UIColor(named: "CustomGray")
            createButton.isEnabled = false
        }
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
    -> UITableViewCell
    {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        cell.accessoryType = .disclosureIndicator
        
        cell.textLabel?.text = tableViewCells[indexPath.row]
        if indexPath.row == 0 {
            cell.detailTextLabel?.text = category.title  // Заголовок категории "Спорт"
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
        _ tableView: UITableView, heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        return 75
    }
}

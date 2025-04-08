//
//  HabitCreationViewController.swift
//  Tracker
//
//  Created by Ilya Grishanov on 07.04.2025.
//

import UIKit

final class HabitCreationViewController: UIViewController {
    
    private var category: TrackerCategory = TrackerCategory(title: "Уборка", trackers: [])
    private var schedule: Set<Day> = [] 
    
    weak var delegate: CreateDelegateProtocol?
   
    private lazy var habitNameTextField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = UIColor(named: "CustomBackgroundDay")
        textField.placeholder = "Введите название привычки"
        textField.layer.cornerRadius = 16
        textField.clearButtonMode = .whileEditing
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: textField.frame.height))
        textField.leftViewMode = .always
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
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
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
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
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
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
        button.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var buttonsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [cancelButton, createButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        navigationController?.navigationBar.tintColor = UIColor(named: "CustomBlack")
        navigationItem.title = "Новая привычка"
        
        setupUI()
    }
    
    private func setupUI() {
        view.addSubview(habitNameTextField)
        view.addSubview(settingsTableView)
        view.addSubview(buttonsStackView)
        
        // Начальное состояние кнопки "Создать"
        createButton.backgroundColor = UIColor(named: "CustomGray")
        createButton.isEnabled = false
        
        NSLayoutConstraint.activate([
            habitNameTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            habitNameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            habitNameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            habitNameTextField.heightAnchor.constraint(equalToConstant: 75),
            
            settingsTableView.topAnchor.constraint(equalTo: habitNameTextField.bottomAnchor, constant: 24),
            settingsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            settingsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            settingsTableView.heightAnchor.constraint(equalToConstant: 150),
            
            buttonsStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            buttonsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            buttonsStackView.heightAnchor.constraint(equalToConstant: 60),
            
            cancelButton.widthAnchor.constraint(equalTo: createButton.widthAnchor)
        ])
    }
    
    @objc private func textFieldDidChange() {
        updateCreateButtonState()
    }
    
    @objc private func cancelButtonTapped() {
        self.dismiss(animated: true)
    }
    
    @objc private func createButtonTapped() {
        guard let text = habitNameTextField.text, !text.isEmpty else { return }
        
        // Создаем новую привычку
        let newHabit = Tracker(
            id: UUID(),
            title: text,
            color: "CustomPink", // Моковый цвет (можно сделать рандомный выбор)
            emoji: "🏃‍♂️", // Моковый emoji
            schedule: schedule
        )
        
        // Сохраняем трекер в выбранную категорию (по умолчанию "Спорт")
        DataManager.shared.addTracker(newHabit, toCategoryWithTitle: category.title)
        delegate?.didCreateHabit(title: text, category: category, emoji: "📌", color: .blue,  schedule: schedule)
        presentingViewController?.presentingViewController?.dismiss(animated: true)
    }
    
    private func updateCreateButtonState() {
        let isTextValid = !(habitNameTextField.text?.isEmpty ?? true)
        let isScheduleSelected = !schedule.isEmpty
        
        if isTextValid && isScheduleSelected {
            createButton.backgroundColor = UIColor(named: "CustomBlack")
            createButton.isEnabled = true
        } else {
            createButton.backgroundColor = UIColor(named: "CustomGray")
            createButton.isEnabled = false
        }
    }
}

extension HabitCreationViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewCells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        cell.accessoryType = .disclosureIndicator
        
        cell.textLabel?.text = tableViewCells[indexPath.row]
        if indexPath.row == 0 {
            cell.detailTextLabel?.text = category.title
        } else if indexPath.row == 1 {
            cell.detailTextLabel?.text = formatScheduleText(days: schedule)
        }
        
        cell.detailTextLabel?.textColor = UIColor(named: "CustomGray")
        cell.textLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        cell.textLabel?.textColor = UIColor(named: "CustomBlack")
        cell.detailTextLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        
        cell.accessoryType = .disclosureIndicator
        cell.backgroundColor = UIColor(named: "CustomBackgroundDay")
        cell.backgroundView = UIView()
        cell.backgroundView?.backgroundColor = UIColor(named: "CustomBackgroundDay")
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cornerRadius: CGFloat = 16
        var corners: UIRectCorner = []
        
        if indexPath.row == 0 {
            corners.update(with: .topLeft)
            corners.update(with: .topRight)
        }
        
        if indexPath.row == tableViewCells.count - 1 {
            corners.update(with: .bottomLeft)
            corners.update(with: .bottomRight)
        }
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = UIBezierPath(
            roundedRect: cell.bounds,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)
        ).cgPath
        cell.layer.mask = maskLayer
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == 0 {
            // Показываем экран выбора категории (если нужно)
        } else if indexPath.row == 1 {
            // Показываем экран выбора расписания
            let scheduleVC = ScheduleViewController()
            scheduleVC.delegate = self
            scheduleVC.selectedDays = schedule
            let navController = UINavigationController(rootViewController: scheduleVC)
            present(navController, animated: true)
        }
    }
}

extension HabitCreationViewController: ScheduleViewControllerDelegate {
    func didSelectSchedule(_ days: Set<Day>) {
        schedule = days
        // Обновляем отображение выбранных дней
        if let cell = settingsTableView.cellForRow(at: IndexPath(row: 1, section: 0)) {
            cell.detailTextLabel?.text = formatScheduleText(days: days)
        }
        updateCreateButtonState()
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

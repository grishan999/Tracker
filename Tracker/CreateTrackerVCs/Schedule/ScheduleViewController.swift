//
//  ScheduleViewController.swift
//  Tracker
//
//  Created by Ilya Grishanov on 07.04.2025.
//

import UIKit

protocol ScheduleViewControllerDelegate: AnyObject {
    func didSelectSchedule(_ days: Set<Day>)
}

final class ScheduleViewController: UIViewController {
    
    weak var delegate: ScheduleViewControllerDelegate?
    var selectedDays: Set<Day> = []
    
    private lazy var scheduleTableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.layer.cornerRadius = 16
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = false
        tableView.separatorInset = UIEdgeInsets(
            top: 0, left: 16, bottom: 0, right: 16)
        tableView.register(
            ScheduleCell.self,
            forCellReuseIdentifier: ScheduleCell.reuseIdentifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Готово", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = UIColor(named: "CustomBlack")
        button.addTarget(
            self, action: #selector(doneButtonTapped), for: .touchUpInside)
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(
            named: "CustomWhite")
        
        navigationController?.navigationBar.tintColor = UIColor(
            named: "CustomBlack")
        navigationItem.title = "Расписание"
        
        setupUI()
    }
    
    private func setupUI() {
        view.addSubview(scheduleTableView)
        view.addSubview(doneButton)
        
        scheduleTableView.separatorStyle = .none
        scheduleTableView.allowsSelection = false
        scheduleTableView.tableFooterView = UIView()
        
        NSLayoutConstraint.activate([
            scheduleTableView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            scheduleTableView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: 16),
            scheduleTableView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor, constant: -16),
            scheduleTableView.bottomAnchor.constraint(
                equalTo: doneButton.topAnchor, constant: -16),
            scheduleTableView.heightAnchor.constraint(equalToConstant: 525),
            
            doneButton.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.heightAnchor.constraint(equalToConstant: 60),
            doneButton.leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(
                equalTo: view.trailingAnchor, constant: -20),
        ])
    }
    
    @objc private func doneButtonTapped() {
        delegate?.didSelectSchedule(selectedDays)
        dismiss(animated: true)
    }
}

extension ScheduleViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int)
    -> Int
    {
        return Day.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
    -> UITableViewCell
    {
        guard
            let cell = tableView.dequeueReusableCell(
                withIdentifier: ScheduleCell.reuseIdentifier, for: indexPath)
                as? ScheduleCell
        else {
            return UITableViewCell()
        }
        
        let day = Day.allCases[indexPath.row]
        let isLastCell = indexPath.row == Day.allCases.count - 1
        cell.configure(
            with: day.rawValue, isOn: selectedDays.contains(day),
            isLastCell: isLastCell)
        
        cell.toggleSwitch.onTintColor = .systemBlue
        cell.toggleSwitch.tag = indexPath.row
        cell.toggleSwitch.addTarget(
            self, action: #selector(switchValueChanged(_:)), for: .valueChanged)
        
        return cell
    }
    
    func tableView(
        _ tableView: UITableView, heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        return 75
    }
    
    @objc private func switchValueChanged(_ sender: UISwitch) {
        let day = Day.allCases[sender.tag]
        if sender.isOn {
            selectedDays.insert(day)
        } else {
            selectedDays.remove(day)
        }
    }
    
}

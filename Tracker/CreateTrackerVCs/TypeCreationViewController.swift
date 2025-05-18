//
//  TypeCreation.swift
//  Tracker
//
//  Created by Ilya Grishanov on 07.04.2025.
//

import UIKit

final class TypeCreationViewController: UIViewController {

    weak var delegate: CreateDelegateProtocol?
    private var buttonsView = UIView()

    private lazy var addHabitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("habit.button.title",
                                          comment: "Кнопка Привычка на создании типа трекера"),
                        for: .normal)
        button.titleLabel?.font = UIFont(name: "YS Display Medium", size: 16)
        button.setTitleColor(UIColor(named: "CustomWhite"), for: .normal)
        button.backgroundColor = UIColor(named: "CustomBlack")
        button.layer.cornerRadius = 16
        button.addTarget(
            self, action: #selector(addHabitButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var addEventButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("event.button.title",
                                           comment: "Кнопка Событие на создании типа трекера"),
                         for: .normal)
        button.titleLabel?.font = UIFont(name: "YS Display Medium", size: 16)
        button.setTitleColor(UIColor(named: "CustomWhite"), for: .normal)
        button.backgroundColor = UIColor(named: "CustomBlack")
        button.layer.cornerRadius = 16
        button.addTarget(
            self, action: #selector(addEventButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "ViewBackgroundColor")
        setupUI()

        navigationController?.navigationBar.tintColor = UIColor(
            named: "CustomBlack")
        navigationItem.title = NSLocalizedString("trackers.creation.type.title",
                                                 comment: "Заголовок экрана создания типа трекера")
    }

    private func setupUI() {
        buttonsView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonsView)
        buttonsView.addSubview(addHabitButton)
        buttonsView.addSubview(addEventButton)

        NSLayoutConstraint.activate([
            addHabitButton.topAnchor.constraint(equalTo: buttonsView.topAnchor),
            addHabitButton.leadingAnchor.constraint(
                equalTo: buttonsView.leadingAnchor),
            addHabitButton.trailingAnchor.constraint(
                equalTo: buttonsView.trailingAnchor),
            addHabitButton.heightAnchor.constraint(equalToConstant: 60),

            addEventButton.topAnchor.constraint(
                equalTo: addHabitButton.bottomAnchor, constant: 16),
            addEventButton.leadingAnchor.constraint(
                equalTo: buttonsView.leadingAnchor),
            addEventButton.trailingAnchor.constraint(
                equalTo: buttonsView.trailingAnchor),
            addEventButton.bottomAnchor.constraint(
                equalTo: buttonsView.bottomAnchor),
            addEventButton.heightAnchor.constraint(equalToConstant: 60),

            buttonsView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: 20),
            buttonsView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor, constant: -20),
            buttonsView.centerYAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.centerYAnchor),
        ])
    }

    @objc private func addHabitButtonTapped() {
        let habitCreationVC = HabitCreationViewController()
        habitCreationVC.delegate = delegate
        let navController = UINavigationController(
            rootViewController: habitCreationVC)
        present(navController, animated: true)
    }

    @objc private func addEventButtonTapped() {
        let eventCreationVC = EventCreationViewController()
        eventCreationVC.delegate = delegate
        let navController = UINavigationController(
            rootViewController: eventCreationVC)
        present(navController, animated: true)
    }
}

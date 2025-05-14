//
//  StatisticViewController.swift
//  Tracker
//
//  Created by Ilya Grishanov on 31.03.2025.
//

import UIKit

final class StatisticViewController: UIViewController {
    
    private let navigationContainer = UIView()
    private let statisticErrorImage = UIImageView()
    private let errorLabel = UILabel()
    
    private let periodCardView = UIView()
    private let periodNumberLabel = UILabel()
    private let periodTextLabel = UILabel()
    
    private let idealDaysCardView = UIView()
    private let idealDaysNumberLabel = UILabel()
    private let idealDaysTextLabel = UILabel()
    
    private let statsStackView = UIStackView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupCards()
        setupStatsStack()
        
        updateUI(hasData: true)
    }
    
    private func setupUI() {
        view.addSubview(placeholderView)
        view.addSubview(navigationContainer)
        view.addSubview(statsStackView)
        
        NSLayoutConstraint.activate([
            placeholderView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        setupStatisticErrorImage()
        setupErrorLabel()
        setupNavigationBar()
    }
    
    private func setupCards() {
        // Настройка карточки периода
        periodCardView.layer.borderWidth = 1
        periodCardView.layer.borderColor = UIColor.lightGray.cgColor
        periodCardView.layer.cornerRadius = 12
        periodCardView.translatesAutoresizingMaskIntoConstraints = false
        
        periodNumberLabel.text = "0"
        periodNumberLabel.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        periodNumberLabel.textAlignment = .center
        periodNumberLabel.textColor = UIColor(named: "CustomBlack")
        
        periodTextLabel.text = "Лучший период"
        periodTextLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        periodTextLabel.textAlignment = .center
        periodTextLabel.textColor = UIColor(named: "CustomBlack")
        
        let periodStack = UIStackView(arrangedSubviews: [periodNumberLabel, periodTextLabel])
        periodStack.axis = .vertical
        periodStack.spacing = 4
        periodStack.translatesAutoresizingMaskIntoConstraints = false
        
        periodCardView.addSubview(periodStack)
        
        NSLayoutConstraint.activate([
            periodStack.centerXAnchor.constraint(equalTo: periodCardView.centerXAnchor),
            periodStack.centerYAnchor.constraint(equalTo: periodCardView.centerYAnchor),
            periodStack.leadingAnchor.constraint(equalTo: periodCardView.leadingAnchor, constant: 16),
            periodStack.trailingAnchor.constraint(equalTo: periodCardView.trailingAnchor, constant: -16),
            periodCardView.heightAnchor.constraint(equalToConstant: 90)
        ])
        
        // Настройка карточки идеальных дней (аналогично)
        idealDaysCardView.layer.borderWidth = 1
        idealDaysCardView.layer.borderColor = UIColor.lightGray.cgColor
        idealDaysCardView.layer.cornerRadius = 12
        idealDaysCardView.translatesAutoresizingMaskIntoConstraints = false
        
        idealDaysNumberLabel.text = "0"
        idealDaysNumberLabel.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        idealDaysNumberLabel.textAlignment = .center
        idealDaysNumberLabel.textColor = UIColor(named: "CustomBlack")
        
        idealDaysTextLabel.text = "Идеальные дни"
        idealDaysTextLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        idealDaysTextLabel.textAlignment = .center
        idealDaysTextLabel.textColor = UIColor(named: "CustomBlack")
        
        let idealDaysStack = UIStackView(arrangedSubviews: [idealDaysNumberLabel, idealDaysTextLabel])
        idealDaysStack.axis = .vertical
        idealDaysStack.spacing = 4
        idealDaysStack.translatesAutoresizingMaskIntoConstraints = false
        
        idealDaysCardView.addSubview(idealDaysStack)
        
        NSLayoutConstraint.activate([
            idealDaysStack.centerXAnchor.constraint(equalTo: idealDaysCardView.centerXAnchor),
            idealDaysStack.centerYAnchor.constraint(equalTo: idealDaysCardView.centerYAnchor),
            idealDaysStack.leadingAnchor.constraint(equalTo: idealDaysCardView.leadingAnchor, constant: 16),
            idealDaysStack.trailingAnchor.constraint(equalTo: idealDaysCardView.trailingAnchor, constant: -16),
            idealDaysCardView.heightAnchor.constraint(equalToConstant: 90)
        ])
    }
    
    private func setupStatsStack() {
        statsStackView.axis = .vertical
        statsStackView.spacing = 12
        statsStackView.alignment = .fill
        statsStackView.distribution = .fillEqually
        statsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        statsStackView.addArrangedSubview(periodCardView)
        statsStackView.addArrangedSubview(idealDaysCardView)
        
        NSLayoutConstraint.activate([
            statsStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            statsStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            statsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            statsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    // Функция для показа/скрытия плейсхолдера
    func updateUI(hasData: Bool) {
        placeholderView.isHidden = hasData
        statsStackView.isHidden = !hasData
    }
    
    private func setupNavigationBar() {
        navigationContainer.backgroundColor = .clear
        navigationContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(navigationContainer)
        
        NSLayoutConstraint.activate([
            navigationContainer.topAnchor.constraint(equalTo: view.topAnchor),
            navigationContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navigationContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            navigationContainer.heightAnchor.constraint(equalToConstant: 182)
        ])
        
        let titleLabel = UILabel()
        titleLabel.text = NSLocalizedString("statistic.header",
                                          comment: "Заголовок Статистика на главном экране")
        titleLabel.font = UIFont(name: "YS Display Bold", size: 34)
        titleLabel.textColor = UIColor(named: "CustomBlack")
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        navigationContainer.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: navigationContainer.leadingAnchor, constant: 16),
            titleLabel.bottomAnchor.constraint(equalTo: navigationContainer.bottomAnchor, constant: -43)
        ])
    }
    
    private lazy var placeholderView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private func setupStatisticErrorImage() {
        statisticErrorImage.image = UIImage(named: "statisticError")
        statisticErrorImage.translatesAutoresizingMaskIntoConstraints = false
        placeholderView.addSubview(statisticErrorImage)
        
        NSLayoutConstraint.activate([
            statisticErrorImage.topAnchor.constraint(equalTo: placeholderView.topAnchor),
            statisticErrorImage.centerXAnchor.constraint(
                equalTo: placeholderView.centerXAnchor),
            statisticErrorImage.widthAnchor.constraint(equalToConstant: 80),
            statisticErrorImage.heightAnchor.constraint(equalToConstant: 80),
        ])
    }
    
    private func setupErrorLabel() {
        errorLabel.text = NSLocalizedString("emptyState.statistic.title",
                                          comment: "Заглушка на пустом экране Отслеживания")
        errorLabel.font = UIFont(name: "YS Display Medium", size: 12)
        errorLabel.textColor = UIColor(named: "CustomBlack")
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        placeholderView.addSubview(errorLabel)
        
        NSLayoutConstraint.activate([
            errorLabel.topAnchor.constraint(
                equalTo: statisticErrorImage.bottomAnchor, constant: 8),
            errorLabel.centerXAnchor.constraint(
                equalTo: placeholderView.centerXAnchor),
            errorLabel.bottomAnchor.constraint(
                equalTo: placeholderView.bottomAnchor),
        ])
    }
}

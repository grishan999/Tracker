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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    private func setupUI() {
        view.addSubview(placeholderView)
        view.addSubview(navigationContainer)
        
        NSLayoutConstraint.activate([
            placeholderView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        setupStatisticErrorImage()
        setupErrorLabel()
        setupNavigationBar()
        
        placeholderView.isHidden = false
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
        view.isHidden = true
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

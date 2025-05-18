//
//  StatisticViewController.swift
//  Tracker
//
//  Created by Ilya Grishanov on 31.03.2025.
//

import UIKit
import CoreData

enum Localization {
    static let bestPeriod = NSLocalizedString("best.period", comment: "Лучший период")
    static let idealDays = NSLocalizedString("ideal.days", comment: "Идеальные дни")
    static let completedTrackers = NSLocalizedString("completed.trackers", comment: "Трекеров завершено")
    static let statisticHeader = NSLocalizedString("statistic.header", comment: "Заголовок Статистика на главном экране")
    static let emptyStateTitle = NSLocalizedString("emptyState.statistic.title", comment: "Заглушка на пустом экране Отслеживания")
}

final class StatisticViewController: UIViewController, NSFetchedResultsControllerDelegate {
    
    private let navigationContainer = UIView()
    private let statisticErrorImage = UIImageView()
    private let errorLabel = UILabel()
    
    private let periodCardView = UIView()
    private let periodNumberLabel = UILabel()
    private let periodTextLabel = UILabel()
    
    private let idealDaysCardView = UIView()
    private let idealDaysNumberLabel = UILabel()
    private let idealDaysTextLabel = UILabel()
    
    private let completedTrackersCardView = UIView()
    private let completedTrackersNumberLabel = UILabel()
    private let completedTrackersTextLabel = UILabel()
    
    private let statsStackView = UIStackView()
    
    private let calendar = Calendar.current
    
    private let trackerRecordStore = TrackerRecordStore()
    private let trackerStore = TrackerStore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupCards()
        setupStatsStack()
        
        updateStatistics()
        trackerRecordStore.delegate = self
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        updateStatistics()
    }
    
    private func calculateStatistics() -> (idealDays: Int, bestPeriod: Int, completedTrackers: Int) {
        let calendar = Calendar.current
        let allTrackers = trackerStore.fetchTrackers()
        let completedDates = fetchAllCompletedDates().sorted()
        let allCompletedTrackers = trackerRecordStore.fetchedResultsController?.fetchedObjects?.count ?? 0
        
        var idealDays = 0
        var bestPeriod = 0
        var currentStreak = 0
        var previousDate: Date?
        
        for date in completedDates {
            guard areAllTrackersCompleted(on: date, trackers: allTrackers) else {
                currentStreak = 0
                previousDate = nil
                continue
            }
            
            idealDays += 1
            
            if let prev = previousDate,
               let nextDay = calendar.date(byAdding: .day, value: 1, to: prev),
               calendar.isDate(date, inSameDayAs: nextDay) {
                currentStreak += 1
            } else {
                currentStreak = 1
            }
            
            bestPeriod = max(bestPeriod, currentStreak)
            previousDate = date
        }
        
        return (idealDays, bestPeriod, allCompletedTrackers)
    }
    
    private func fetchAllCompletedDates() -> [Date] {
        guard let records = trackerRecordStore.fetchedResultsController?.fetchedObjects else { return [] }
        
        let dates = records.compactMap { $0.date }
        let uniqueDates = Set(dates.map { calendar.startOfDay(for: $0) })
        
        return Array(uniqueDates).sorted()
    }
    
    
    private func areAllTrackersCompleted(on date: Date, trackers: [Tracker]) -> Bool {
        let weekday = calendar.component(.weekday, from: date)
        let completedTrackerIDs = Set(trackerRecordStore.fetchCompletedTrackerIDs(for: date))
        
        let scheduledTrackers = trackers.filter { tracker in
            tracker.schedule.isEmpty || tracker.schedule.contains(where: { $0.calendarDayNumber == weekday })
        }
        
        return !scheduledTrackers.isEmpty && scheduledTrackers.allSatisfy { completedTrackerIDs.contains($0.id) }
    }
    
    private func updateStatistics() {
        let stats = calculateStatistics()
        
        DispatchQueue.main.async {
            self.periodNumberLabel.text = "\(stats.bestPeriod)"
            self.idealDaysNumberLabel.text = "\(stats.idealDays)"
            self.completedTrackersNumberLabel.text = "\(stats.completedTrackers)"
            
            let allValuesZero = stats.bestPeriod == 0 && stats.idealDays == 0 && stats.completedTrackers == 0
            self.updateUI(hasData: !allValuesZero)
        }
    }
    
    private func setupUI() {
        view.addSubview(placeholderView)
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
        setupCardView(periodCardView, numberLabel: periodNumberLabel, textLabel: periodTextLabel,
                      text: Localization.bestPeriod)
        
        setupCardView(idealDaysCardView, numberLabel: idealDaysNumberLabel, textLabel: idealDaysTextLabel,
                      text: Localization.idealDays)
        
        setupCardView(completedTrackersCardView, numberLabel: completedTrackersNumberLabel, textLabel: completedTrackersTextLabel,
                      text: Localization.completedTrackers)
    }
    
    private func applyGradientBorder(to view: UIView, colors: [CGColor], cornerRadius: CGFloat, borderWidth: CGFloat) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = colors
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0)
        gradientLayer.cornerRadius = cornerRadius
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.lineWidth = borderWidth
        shapeLayer.path = UIBezierPath(roundedRect: view.bounds.insetBy(dx: borderWidth / 2,
                                                                        dy: borderWidth / 2),
                                       cornerRadius: cornerRadius).cgPath
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor.black.cgColor
        gradientLayer.mask = shapeLayer
        
        view.layer.addSublayer(gradientLayer)
    }
    
    private func setupCardView(_ cardView: UIView, numberLabel: UILabel, textLabel: UILabel, text: String) {
        cardView.layer.cornerRadius = 16
        cardView.clipsToBounds = true
        cardView.translatesAutoresizingMaskIntoConstraints = false
        
        numberLabel.text = "0"
        numberLabel.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        numberLabel.textAlignment = .left
        numberLabel.textColor = UIColor(named: "CustomBlack")
        
        textLabel.text = text
        textLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        textLabel.textAlignment = .left
        textLabel.textColor = UIColor(named: "CustomBlack")
        
        let stack = UIStackView(arrangedSubviews: [numberLabel, textLabel])
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        cardView.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            stack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            cardView.heightAnchor.constraint(equalToConstant: 90)
        ])
        
        DispatchQueue.main.async {
            self.applyGradientBorder(
                to: cardView,
                colors: [
                    UIColor(named: "BlueGradient")?.cgColor,
                    UIColor(named: "GreenGradient")?.cgColor,
                    UIColor(named: "RedGradient")?.cgColor
                ].compactMap { $0 },
                cornerRadius: 16,
                borderWidth: 2
            )
        }
    }
    
    private func setupStatsStack() {
        statsStackView.axis = .vertical
        statsStackView.spacing = 12
        statsStackView.alignment = .fill
        statsStackView.distribution = .fillEqually
        statsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        statsStackView.addArrangedSubview(periodCardView)
        statsStackView.addArrangedSubview(idealDaysCardView)
        statsStackView.addArrangedSubview(completedTrackersCardView)
        
        NSLayoutConstraint.activate([
            statsStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            statsStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            statsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            statsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
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
        titleLabel.text = Localization.statisticHeader
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
        errorLabel.text = Localization.emptyStateTitle
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

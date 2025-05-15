//
//  MainViewController.swift
//  Tracker
//
//  Created by Ilya Grishanov on 31.03.2025.
//

import UIKit

final class MainTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
        customizeTabBar()
        
        view.backgroundColor = UIColor(named: "ViewBackgroundColor")
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AnalyticsService.shared.report(event: "open", screen: "Main")
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        AnalyticsService.shared.report(event: "close", screen: "Main")
    }
    
    private func setupTabs() {
        
        let trackersVC = TrackersViewController()
        let trackersNav = UINavigationController(rootViewController: trackersVC)
        trackersNav.tabBarItem = UITabBarItem(
            title: NSLocalizedString("trackers.button.title",
                                     comment: "Кнопка Трекеры на главном экране"),
            image: UIImage(named: "AimGrey")?.withRenderingMode(
                .alwaysOriginal),
            selectedImage: UIImage(named: "AimBlue")?.withRenderingMode(
                .alwaysOriginal)
        )
        
        let statisticVC = StatisticViewController()
        let statisticNav = UINavigationController(
            rootViewController: statisticVC)
        statisticNav.tabBarItem = UITabBarItem(
            title: NSLocalizedString("statistic.button.title",
                                     comment: "Кнопка Статистика на главном экране"),
            image: UIImage(named: "RabbitGrey")?.withRenderingMode(
                .alwaysOriginal),
            selectedImage: UIImage(named: "RabbitBlue")?.withRenderingMode(
                .alwaysOriginal)
        )
        
        viewControllers = [trackersNav, statisticNav]
        selectedIndex = 0
    }
    
    private func customizeTabBar() {
        tabBar.tintColor = UIColor(named: "CustomBlue")
        tabBar.unselectedItemTintColor = .gray
        tabBar.backgroundColor = UIColor(named: "ViewBackgroundColor")
        
        let topBorder = CALayer()
        topBorder.frame = CGRect(
            x: 0, y: 0, width: tabBar.frame.width, height: 0.5)
        topBorder.backgroundColor = UIColor(named: "TabBarSelectorColor")?.cgColor
        tabBar.layer.addSublayer(topBorder)
    }
}

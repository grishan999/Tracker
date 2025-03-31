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
    }
    
    private func setupTabs() {
        
        let trackersVC = TrackersViewController()
        let trackersNav = UINavigationController(rootViewController: trackersVC)
        trackersNav.tabBarItem = UITabBarItem(
            title: "Трекеры",
            image: UIImage(named: "AimGrey")?.withRenderingMode(.alwaysOriginal),
            selectedImage: UIImage(named: "AimBlue")?.withRenderingMode(.alwaysOriginal)
        )
        
        let statisticVC = StatisticViewController()
        let statisticNav = UINavigationController(rootViewController: statisticVC)
        statisticNav.tabBarItem = UITabBarItem(
            title: "Статистика",
            image: UIImage(named: "RabbitGrey")?.withRenderingMode(.alwaysOriginal),
            selectedImage: UIImage(named: "RabbitBlue")?.withRenderingMode(.alwaysOriginal)
        )
        
        viewControllers = [trackersNav, statisticNav]
        selectedIndex = 0
    }
    
    private func customizeTabBar() {
        tabBar.tintColor = UIColor (named: "CustomBlue")
        tabBar.unselectedItemTintColor = .gray
        tabBar.backgroundColor = .systemBackground
        
        let topBorder = CALayer()
            topBorder.frame = CGRect(x: 0, y: 0, width: tabBar.frame.width, height: 0.5)
            topBorder.backgroundColor = UIColor.lightGray.cgColor
            tabBar.layer.addSublayer(topBorder)
    }
}

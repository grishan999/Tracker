//
//  TrackerTests.swift
//  TrackerTests
//
//  Created by Ilya Grishanov on 11.05.2025.
//

import XCTest
import SnapshotTesting
@testable import Tracker

final class MainTabBarControllerSnapshotTests: XCTestCase {
    
    private var window: UIWindow!
    
    override func setUp() {
        super.setUp()
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window.makeKeyAndVisible()
    }
    
    override func tearDown() {
        window = nil
        super.tearDown()
    }
    
    func test_mainTabBarController_defaultState() {
        let tabBarVC = MainTabBarController()
        
        window.rootViewController = tabBarVC
        tabBarVC.loadViewIfNeeded()
        
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.1))
        
        assertSnapshot(
            matching: tabBarVC,
            as: .image,
            named: "default",
            record: false
        )
    }
    
    //тест статистики, меняем вкладку
    func test_mainTabBarController_secondTabSelected() {
        let tabBarVC = MainTabBarController()
        window.rootViewController = tabBarVC
        tabBarVC.loadViewIfNeeded()
        
        tabBarVC.selectedIndex = 1
        
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.1))
        
        assertSnapshot(
            matching: tabBarVC,
            as: .image,
            named: "second_tab_selected",
            record: false
        )
    }
}


















//    func test_mainTabBarController_darkMode() {
//        let tabBarVC = MainTabBarController()
//        
//        // Применяем темную тему
//        window.overrideUserInterfaceStyle = .dark
//        window.rootViewController = tabBarVC
//        tabBarVC.loadViewIfNeeded()
//        
//        RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.1))
//        
//        assertSnapshot(
//            matching: tabBarVC,
//            as: .image,
//            named: "dark_mode",
//            record: false
//        )
//    }


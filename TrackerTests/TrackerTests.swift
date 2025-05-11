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
    
    func test_mainTabBarController_defaultState_light() {
        window.overrideUserInterfaceStyle = .light
        
        let tabBarVC = MainTabBarController()
        window.rootViewController = tabBarVC
        tabBarVC.loadViewIfNeeded()
        
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.1))
        
        assertSnapshot(
            matching: tabBarVC,
            as: .image(traits: .init(userInterfaceStyle: .light)),
            named: "light_default",
            record: false
        )
    }
    
    func test_mainTabBarController_defaultState_dark() {
        window.overrideUserInterfaceStyle = .dark
        
        let tabBarVC = MainTabBarController()
        window.rootViewController = tabBarVC
        tabBarVC.loadViewIfNeeded()
        
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 1.5))
        
        assertSnapshot(
            matching: tabBarVC,
            as: .image(traits: .init(userInterfaceStyle: .dark)),
            named: "dark_default",
            record: false
        )
    }
    
    func test_mainTabBarController_secondTabSelected_light() {
        window.overrideUserInterfaceStyle = .light
        
        let tabBarVC = MainTabBarController()
        window.rootViewController = tabBarVC
        tabBarVC.loadViewIfNeeded()
        
        tabBarVC.selectedIndex = 1
        
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.1))
        
        assertSnapshot(
            matching: tabBarVC,
            as: .image(traits: .init(userInterfaceStyle: .light)),
            named: "light_second_tab_selected",
            record: false
        )
    }
    
    func test_mainTabBarController_secondTabSelected_dark() {
        window.overrideUserInterfaceStyle = .dark
        
        let tabBarVC = MainTabBarController()
        window.rootViewController = tabBarVC
        tabBarVC.loadViewIfNeeded()
        
        tabBarVC.selectedIndex = 1
        
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 1.5))
        
        assertSnapshot(
            matching: tabBarVC,
            as: .image(traits: .init(userInterfaceStyle: .dark)),
            named: "dark_second_tab_selected",
            record: false
        )
    }
}

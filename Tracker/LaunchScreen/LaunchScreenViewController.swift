//
//  LaunchScreenViewController.swift
//  Tracker
//
//  Created by Ilya Grishanov on 30.03.2025.
//

import UIKit

final class LaunchScreenViewController: UIViewController {

    private let launchScreenImage = UIImageView()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.switchToMainApp()
        }
    }

    private func setupUI() {
        view.backgroundColor = UIColor(named: "CustomBlue")

        launchScreenImage.image = UIImage(named: "TrackerLS")
        launchScreenImage.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(launchScreenImage)

        NSLayoutConstraint.activate([
            launchScreenImage.centerXAnchor.constraint(
                equalTo: view.centerXAnchor),
            launchScreenImage.centerYAnchor.constraint(
                equalTo: view.centerYAnchor),
        ])
    }

    private func switchToMainApp() {
        guard let window = view.window ?? UIApplication.shared.windows.first
        else { return }

        let tabBarController = MainTabBarController()

        UIView.transition(
            with: window,
            duration: 0.3,
            options: .transitionCrossDissolve,
            animations: {
                window.rootViewController = tabBarController
            },
            completion: nil)
    }

}

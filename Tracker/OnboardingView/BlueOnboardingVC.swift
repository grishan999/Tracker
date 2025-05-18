//
//  BlueOnboardingVC.swift
//  Tracker
//
//  Created by Ilya Grishanov on 27.04.2025.
//

import UIKit

final class BlueOnboardingVC: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backgroundImage = UIImageView(image: UIImage(named: "BlueBackground"))
        backgroundImage.contentMode = .scaleAspectFill
        backgroundImage.frame = view.bounds
        view.addSubview(backgroundImage)
        view.sendSubviewToBack(backgroundImage)
        
        let label = UILabel()
        label.text = NSLocalizedString("onboarding.blue.title",
                                     comment: "Заголовок синего экрана онбординга")
        label.textColor = UIColor(named: "OnboardingBlack")
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.numberOfLines = 2
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            label.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -304),
        ])
    }
}

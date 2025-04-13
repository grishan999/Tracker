//
//  TrackersCollectionViewCell.swift
//  Tracker
//
//  Created by Ilya Grishanov on 03.04.2025.
//

import UIKit

protocol TrackersCellDelegate: AnyObject {
    func updateCount(cell: TrackersCell)
}

final class TrackersCell: UICollectionViewCell {
    
    static let cellIdentifier = "cell"
    private(set) var trackerID: UUID?
    
    weak var delegate: TrackersCellDelegate?
    
    // MARK: - TrackerName
    private lazy var trackerNameView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "CustomGreen")
        view.layer.cornerRadius = 16
        contentView.addSubview(view)
        return view
    }()
    
    private lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "YS Display Medium", size: 16)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        trackerNameView.addSubview(label)
        return label
    }()
    
    private lazy var emojiCircle: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.backgroundColor = UIColor(named: "EmojiCircle")
        trackerNameView.addSubview(view)
        return view
    }()
    private lazy var trackerNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "YS Display Medium", size: 12)
        label.textColor = UIColor(named: "CustomWhite")
        label.numberOfLines = 2
        label.baselineAdjustment = .alignBaselines
        trackerNameView.addSubview(label)
        return label
    }()
    
    private lazy var countView: UIView = {
        var view = UIView()
        contentView.addSubview(view)
        return view
    }()
    
    // MARK: - Count
    private lazy var countLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "YS Display Medium", size: 12)
        label.textColor = UIColor(named: "CustomBlack")
        countView.addSubview(label)
        return label
    }()
    
    private lazy var plusButton: UIButton = {
        let plusImage = UIImage(named: "Plus") ?? UIImage()
        let button = UIButton.systemButton(
            with: plusImage, target: self, action: #selector(plusButtonTapped))
        button.tintColor = UIColor(named: "CustomWhite")
        button.layer.cornerRadius = 17
        countView.addSubview(button)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        [
            trackerNameView, emojiLabel, emojiCircle, trackerNameLabel,
            countView, countLabel, plusButton,
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            
            trackerNameView.topAnchor.constraint(equalTo: topAnchor),
            trackerNameView.leadingAnchor.constraint(equalTo: leadingAnchor),
            trackerNameView.trailingAnchor.constraint(equalTo: trailingAnchor),
            trackerNameView.heightAnchor.constraint(equalToConstant: 90),
            
            emojiCircle.topAnchor.constraint(
                equalTo: trackerNameView.topAnchor, constant: 12),
            emojiCircle.leadingAnchor.constraint(
                equalTo: trackerNameView.leadingAnchor, constant: 12),
            emojiCircle.widthAnchor.constraint(equalToConstant: 24),
            emojiCircle.heightAnchor.constraint(equalToConstant: 24),
            
            emojiLabel.centerXAnchor.constraint(
                equalTo: emojiCircle.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(
                equalTo: emojiCircle.centerYAnchor),
            
            trackerNameLabel.topAnchor.constraint(
                greaterThanOrEqualTo: emojiCircle.bottomAnchor, constant: 8),
            trackerNameLabel.leadingAnchor.constraint(
                equalTo: trackerNameView.leadingAnchor, constant: 12),
            trackerNameLabel.trailingAnchor.constraint(
                equalTo: trackerNameView.trailingAnchor, constant: -12),
            trackerNameLabel.bottomAnchor.constraint(
                equalTo: trackerNameView.bottomAnchor, constant: -12),
            
            countView.topAnchor.constraint(
                equalTo: trackerNameView.bottomAnchor),
            countView.leadingAnchor.constraint(equalTo: leadingAnchor),
            countView.trailingAnchor.constraint(equalTo: trailingAnchor),
            countView.bottomAnchor.constraint(equalTo: bottomAnchor),
            countView.heightAnchor.constraint(equalToConstant: 58),
            
            countLabel.centerYAnchor.constraint(
                equalTo: countView.centerYAnchor),
            countLabel.leadingAnchor.constraint(
                equalTo: countView.leadingAnchor, constant: 12),
            
            plusButton.centerYAnchor.constraint(
                equalTo: countView.centerYAnchor),
            plusButton.trailingAnchor.constraint(
                equalTo: countView.trailingAnchor, constant: -12),
            plusButton.widthAnchor.constraint(equalToConstant: 34),
            plusButton.heightAnchor.constraint(equalToConstant: 34),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupCell(
        name: String, color: UIColor, emoji: Character, days: Int,
        trackerID: UUID, isCompletedToday: Bool, isEnabled: Bool = true
    ) {
        plusButton.backgroundColor = color
        trackerNameView.backgroundColor = color
        emojiLabel.text = String(emoji)
        trackerNameLabel.text = name
        
        self.trackerID = trackerID
        countLabel.text = days.days()
        updateCompletionStatus(
            isCompletedToday: isCompletedToday, isEnabled: isEnabled)
    }
    
    func updateDays(days: Int, isAddition: Bool, isEnabled: Bool = true) {
        countLabel.text = days.days()
        updateCompletionStatus(
            isCompletedToday: isAddition, isEnabled: isEnabled)
    }
    
    func updateCompletionStatus(isCompletedToday: Bool, isEnabled: Bool = true)
    {
        let image =
        isCompletedToday ? UIImage(named: "Done") : UIImage(named: "Plus")
        plusButton.setImage(image, for: .normal)
        plusButton.alpha = isCompletedToday ? 0.3 : 1.0
        plusButton.isEnabled = isEnabled
    }
    
    @objc private func plusButtonTapped() {
        
        delegate?.updateCount(cell: self)
        
    }
    
}

extension Int {
    func days() -> String {
        let mod100 = self % 100
        let mod10 = self % 10
        
        if (11...14).contains(mod100) {
            return "\(self) дней"
        }
        
        switch mod10 {
        case 1: return "\(self) день"
        case 2...4: return "\(self) дня"
        default: return "\(self) дней"
        }
    }
}

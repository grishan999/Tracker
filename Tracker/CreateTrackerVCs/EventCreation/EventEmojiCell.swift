//
//  EventEmojiCell.swift
//  Tracker
//
//  Created by Ilya Grishanov on 13.04.2025.
//

import UIKit

final class EventEmojiCell: UICollectionViewCell {
    private let emojiLabel = UILabel()
    private let backgroundViewForSelection = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.addSubview(backgroundViewForSelection)
        backgroundViewForSelection.layer.cornerRadius = 16
        backgroundViewForSelection.layer.masksToBounds = true
        backgroundViewForSelection.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(emojiLabel)
        emojiLabel.font = UIFont.systemFont(ofSize: 32)
        emojiLabel.textAlignment = .center
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            backgroundViewForSelection.topAnchor.constraint(equalTo: contentView.topAnchor),
            backgroundViewForSelection.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            backgroundViewForSelection.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            backgroundViewForSelection.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            emojiLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    func configure(with emoji: String) {
        emojiLabel.text = emoji
    }
    
    func setSelectedBackground(color: UIColor) {
        backgroundViewForSelection.backgroundColor = color
    }
    
    func clearSelectedBackground() {
        backgroundViewForSelection.backgroundColor = .clear
    }
}

//
//  FiltersCell.swift
//  Tracker
//
//  Created by Ilya Grishanov on 05.05.2025.
//

import UIKit

final class FiltersCell: UITableViewCell {
    static let reuseIdentifier = "FiltersCell"
    
    private let titleLabel = UILabel()
    private let separatorView = UIView()
    private let checkmarkImageView = UIImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        backgroundColor = UIColor(named: "CustomBackgroundDay")
        selectionStyle = .none
        
        titleLabel.font = UIFont.systemFont(ofSize: 17)
        titleLabel.textColor = UIColor(named: "CustomBlack")
        contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        separatorView.backgroundColor = UIColor(named: "CustomGray")
        contentView.addSubview(separatorView)
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        
        checkmarkImageView.image = UIImage(systemName: "checkmark")
        checkmarkImageView.tintColor = UIColor(named: "CustomBlue")
        checkmarkImageView.contentMode = .scaleAspectFit
        checkmarkImageView.isHidden = true
        contentView.addSubview(checkmarkImageView)
        checkmarkImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            titleLabel.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(
                equalTo: contentView.centerYAnchor),
            
            checkmarkImageView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor, constant: -16),
            checkmarkImageView.centerYAnchor.constraint(
                equalTo: contentView.centerYAnchor),
            checkmarkImageView.widthAnchor.constraint(equalToConstant: 24),
            checkmarkImageView.heightAnchor.constraint(equalToConstant: 24),
            
            separatorView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor, constant: 16),
            separatorView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor, constant: -16),
            separatorView.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 0.5),
        ])
    }
    
    func configure(with title: String, isSelected: Bool, isLastCell: Bool) {
        titleLabel.text = title
        checkmarkImageView.isHidden = !isSelected
        separatorView.isHidden = isLastCell
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        checkmarkImageView.isHidden = true
        separatorView.isHidden = false
    }
}

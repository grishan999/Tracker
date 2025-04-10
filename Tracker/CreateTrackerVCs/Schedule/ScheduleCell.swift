//
//  ScheduleTableViewCell.swift
//  Tracker
//
//  Created by Ilya Grishanov on 07.04.2025.
//

import UIKit

final class ScheduleCell: UITableViewCell {
    static let reuseIdentifier = "ScheduleCell"

    let toggleSwitch = UISwitch()
    private let titleLabel = UILabel()
    private let separatorView = UIView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        backgroundColor = UIColor(named: "CustomBackgroundDay")

        titleLabel.font = UIFont.systemFont(ofSize: 17)
        contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(toggleSwitch)
        toggleSwitch.translatesAutoresizingMaskIntoConstraints = false

        separatorView.backgroundColor = UIColor(
            named: "CustomGray")
        contentView.addSubview(separatorView)
        separatorView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(
                equalTo: contentView.centerYAnchor),

            toggleSwitch.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor, constant: -16),
            toggleSwitch.centerYAnchor.constraint(
                equalTo: contentView.centerYAnchor),

            separatorView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor, constant: 16),
            separatorView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor, constant: -16),
            separatorView.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 0.5),
        ])
    }

    func configure(with title: String, isOn: Bool, isLastCell: Bool = false) {
        titleLabel.text = title
        toggleSwitch.isOn = isOn
        separatorView.isHidden = isLastCell

        layer.cornerRadius = 0
        layer.maskedCorners = []

        if isLastCell {
            layer.cornerRadius = 16
            layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            layer.masksToBounds = true
        }
    }
}

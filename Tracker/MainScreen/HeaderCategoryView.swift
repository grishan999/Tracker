//
//  HeaderCategoryView.swift
//  Tracker
//
//  Created by Ilya Grishanov on 03.04.2025.
//

import UIKit

final class HeaderCategoryView: UICollectionReusableView {
    static let headerIdentifier = "header"

    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "YS Display Bold", size: 19)
        label.textColor = UIColor(named: "CustomBlack")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        addSubview(titleLabel)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(
                equalTo: leadingAnchor, constant: 28),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            titleLabel.bottomAnchor.constraint(
                equalTo: bottomAnchor, constant: -12),
        ])

    }

}

//
//  CategoryCell.swift
//  Tracker
//
//  Created by Ilya Grishanov on 25.04.2025.
//

import UIKit

final class CategoryCell: UITableViewCell {
    static let reuseIdentifier = "CategoryCell"

    private var onEdit: (() -> Void)?
    private var onDelete: (() -> Void)?

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
        selectionStyle = .none

        titleLabel.font = UIFont.systemFont(ofSize: 17)
        titleLabel.textColor = UIColor(named: "CustomBlack")
        contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        separatorView.backgroundColor = UIColor(named: "CustomGray")
        contentView.addSubview(separatorView)
        separatorView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(
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

    func configure(
        with category: TrackerCategory, isSelected: Bool,
        isLastCell: Bool = false, onEdit: @escaping () -> Void,
        onDelete: @escaping () -> Void
    ) {
        titleLabel.text = category.title
        accessoryType = isSelected ? .checkmark : .none
        separatorView.isHidden = isLastCell
        self.onEdit = onEdit
        self.onDelete = onDelete
    }

    func makeContextMenu() -> UIContextMenuConfiguration {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil)
        { _ -> UIMenu? in
            let edit = UIAction(
                title: "Редактировать", image: UIImage(systemName: "pencil")
            ) { _ in
                self.onEdit?()
            }

            let delete = UIAction(
                title: "Удалить", image: UIImage(systemName: "trash"),
                attributes: .destructive
            ) { _ in
                self.onDelete?()
            }

            return UIMenu(title: "", children: [edit, delete])
        }
    }
}

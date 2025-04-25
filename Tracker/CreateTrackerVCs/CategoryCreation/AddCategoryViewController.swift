//
//  AddCategoryViewController.swift
//  Tracker
//
//  Created by Ilya Grishanov on 25.04.2025.
//


protocol AddCategoryDelegate: AnyObject {
    func didAddCategory(title: String)
}

import UIKit

final class AddCategoryViewController: UIViewController {
    
    weak var delegate: AddCategoryDelegate?
    
    private lazy var textField: UITextField = {
        let field = UITextField()
        field.placeholder = "Введите название категории"
        field.backgroundColor = UIColor(named: "CustomBackgroundDay")
        field.layer.cornerRadius = 16
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: field.frame.height))
        field.leftViewMode = .always
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private lazy var addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Готово", for: .normal)
        button.titleLabel?.font = UIFont(name: "YS Display Medium", size: 16)
        button.setTitleColor(UIColor(named: "CustomWhite"), for: .normal)
        button.backgroundColor = UIColor(named: "CustomBlack")
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.tintColor = UIColor(named: "CustomBlack")
        navigationItem.title = "Новая категория"
        setupUI()
    }
    
    private func setupUI() {
        view.addSubview(textField)
        view.addSubview(addButton)
        
        NSLayoutConstraint.activate([
            
            textField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textField.heightAnchor.constraint(equalToConstant: 75),
            
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addButton.heightAnchor.constraint(equalToConstant: 60),
        ])
    }
    
    @objc private func addButtonTapped() {
        guard let text = textField.text, !text.isEmpty else { return }
        delegate?.didAddCategory(title: text)
        dismiss(animated: true)
    }
}



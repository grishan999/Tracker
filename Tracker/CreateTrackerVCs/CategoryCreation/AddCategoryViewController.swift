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
    private enum Constants {
        static let placeholder = NSLocalizedString("new.category.name.placeholder",
                                                   comment: "Плейсхолдер Введите название категории")
        static let doneButtonTitle = NSLocalizedString("new.category.button.title",
                                                       comment: "Кнопка Новая категория")
        static let navigationTitle = NSLocalizedString("new.category.button.title",
                                                       comment: "Название Новая категория вьюшки")
        static let cornerRadius: CGFloat = 16
        static let textFieldHeight: CGFloat = 75
        static let buttonHeight: CGFloat = 60
        static let horizontalPadding: CGFloat = 16
        static let buttonHorizontalPadding: CGFloat = 20
        static let topPadding: CGFloat = 16
        static let bottomPadding: CGFloat = -16
    }
    
    private let keyboardManager: KeyboardManageable
    
    private let onAddCategory: (String) -> Void
    
    private lazy var textField: UITextField = {
        let field = UITextField()
        field.placeholder = Constants.placeholder
        field.backgroundColor = UIColor(named: "CustomBackgroundDay")
        field.layer.cornerRadius = Constants.cornerRadius
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: Constants.horizontalPadding, height: field.frame.height))
        field.leftViewMode = .always
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private lazy var addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Constants.doneButtonTitle, for: .normal)
        button.titleLabel?.font = UIFont(name: "YS Display Medium", size: 16)
        button.setTitleColor(UIColor(named: "AlwaysWhiteColor"), for: .normal)
        button.backgroundColor = UIColor(named: "CustomBlack")
        button.layer.cornerRadius = Constants.cornerRadius
        button.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    init(
        keyboardManager: KeyboardManageable = KeyboardManager(),
        onAddCategory: @escaping (String) -> Void
    ) {
        self.keyboardManager = keyboardManager
        self.onAddCategory = onAddCategory
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
           super.viewDidLoad()
           view.backgroundColor = .systemBackground
           navigationController?.navigationBar.tintColor = UIColor(named: "CustomBlack")
           navigationItem.title = Constants.navigationTitle
           setupUI()
           setupTextFieldObserver()
           updateAddButtonState()
        
        setupKeyboard()
       }
    
    private func setupKeyboard() {
        keyboardManager.setupKeyboardDismissal(for: view)
        keyboardManager.registerTextField(textField)
    }

       private func setupTextFieldObserver() {
           textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
       }

       @objc private func textFieldDidChange() {
           updateAddButtonState()
       }

       private func updateAddButtonState() {
           let isEmpty = textField.text?.isEmpty ?? true
           addButton.isEnabled = !isEmpty
           addButton.backgroundColor = isEmpty ? UIColor(named: "CustomGray") : UIColor(named: "CustomBlack")
           addButton.setTitleColor(UIColor(named: "CustomWhite"), for: .normal)
           addButton.setTitleColor(UIColor(named: "AlwaysWhiteColor"), for: .disabled)
       }

    
    private func setupUI() {
        view.addSubview(textField)
        view.addSubview(addButton)
        
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.topPadding),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.horizontalPadding),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.horizontalPadding),
            textField.heightAnchor.constraint(equalToConstant: Constants.textFieldHeight),
            
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: Constants.bottomPadding),
            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.buttonHorizontalPadding),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.buttonHorizontalPadding),
            addButton.heightAnchor.constraint(equalToConstant: Constants.buttonHeight),
        ])
    }
    
    @objc private func addButtonTapped() {
        guard let text = textField.text, !text.isEmpty else { return }
        onAddCategory(text)
        dismiss(animated: true)
    }
}

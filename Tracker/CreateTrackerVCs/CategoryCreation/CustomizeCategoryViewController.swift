//
//  CustomizeCategoryViewController.swift
//  Tracker
//
//  Created by Ilya Grishanov on 28.04.2025.
//

import UIKit

final class CustomizeCategoryViewController: UIViewController {
    private let viewModel: CategoryCreationViewModel
    private let categoryIndex: Int
    private let initialTitle: String
    
    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.text = initialTitle
        textField.backgroundColor = UIColor(named: "CustomBackgroundDay")
        textField.layer.cornerRadius = 16
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 75))
        textField.leftViewMode = .always
        textField.clearButtonMode = .whileEditing
        textField.font = UIFont.systemFont(ofSize: 17)
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Готово", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = UIColor(named: "CustomBlack")
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        button.isEnabled = !initialTitle.isEmpty
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    init(viewModel: CategoryCreationViewModel, categoryIndex: Int, initialTitle: String) {
        self.viewModel = viewModel
        self.categoryIndex = categoryIndex
        self.initialTitle = initialTitle
        super.init(nibName: nil, bundle: nil)
    }
    
    private func setupNavigationItem() {
        navigationItem.hidesBackButton = true
        navigationItem.leftBarButtonItem = nil
        navigationItem.rightBarButtonItem = nil
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateDoneButtonState()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.tintColor = UIColor(named: "CustomBlack")
        navigationItem.title = "Редактирование категории"
        
        view.addSubview(textField)
        view.addSubview(doneButton)
        
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textField.heightAnchor.constraint(equalToConstant: 75),
            
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        textField.becomeFirstResponder()
    }
    
    @objc private func textFieldDidChange() {
        updateDoneButtonState()
    }
    
    private func updateDoneButtonState() {
        let isEmpty = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true
        doneButton.isEnabled = !isEmpty
        doneButton.backgroundColor = isEmpty ? UIColor(named: "CustomGray") : UIColor(named: "CustomBlack")
    }
    
    @objc private func doneButtonTapped() {
        guard let newTitle = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !newTitle.isEmpty else { return }
        
        viewModel.editCategory(at: categoryIndex, newTitle: newTitle)
        navigationController?.popViewController(animated: true)
    }
}

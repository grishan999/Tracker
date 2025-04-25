//
//  CategoryCreationViewController.swift
//  Tracker
//
//  Created by Ilya Grishanov on 24.04.2025.
//

protocol CategorySelectionDelegate: AnyObject {
    func didSelectCategory(_ category: TrackerCategory)
}

import UIKit

final class CategoryCreationViewController: UIViewController {
    
    weak var delegate: CategorySelectionDelegate?
    private var categories: [TrackerCategory] = []
    private var selectedCategory: TrackerCategory?
    private let trackerCategoryStore = TrackerCategoryStore()
    
    private let starImage = UIImageView()
    private let questionLabel = UILabel()
    
    private lazy var placeholderView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    private lazy var addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Добавить категорию", for: .normal)
        button.titleLabel?.font = UIFont(name: "YS Display Medium", size: 16)
        button.setTitleColor(UIColor(named: "CustomWhite"), for: .normal)
        button.backgroundColor = UIColor(named: "CustomBlack")
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let categoryTableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.layer.cornerRadius = 16
        tableView.isScrollEnabled = true
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(CategoryCell.self, forCellReuseIdentifier: CategoryCell.reuseIdentifier)
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.tintColor = UIColor(named: "CustomBlack")
        navigationItem.title = "Категория"
        
        setupUI()
        loadCategories()
    }
    
    private func setupUI() {
        setupStarImage()
        setupQuestionLabel()
        
        view.addSubview(placeholderView)
        view.addSubview(addButton)
        view.addSubview(categoryTableView)
        
        categoryTableView.delegate = self
        categoryTableView.dataSource = self
        
        NSLayoutConstraint.activate([
            placeholderView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addButton.heightAnchor.constraint(equalToConstant: 60),
            
            categoryTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            categoryTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            categoryTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            categoryTableView.bottomAnchor.constraint(equalTo: addButton.topAnchor, constant: -16),
        ])
    }
    
    private func setupStarImage() {
        starImage.image = UIImage(named: "Star")
        starImage.translatesAutoresizingMaskIntoConstraints = false
        placeholderView.addSubview(starImage)
        
        NSLayoutConstraint.activate([
            starImage.topAnchor.constraint(equalTo: placeholderView.topAnchor),
            starImage.centerXAnchor.constraint(equalTo: placeholderView.centerXAnchor),
            starImage.widthAnchor.constraint(equalToConstant: 80),
            starImage.heightAnchor.constraint(equalToConstant: 80),
        ])
    }
    
    private func setupQuestionLabel() {
        questionLabel.text = "Привычки и события можно объединить по смыслу"
        questionLabel.font = UIFont(name: "YS Display Medium", size: 12)
        questionLabel.textColor = UIColor(named: "CustomBlack")
        questionLabel.translatesAutoresizingMaskIntoConstraints = false
        placeholderView.addSubview(questionLabel)
        
        NSLayoutConstraint.activate([
            questionLabel.topAnchor.constraint(equalTo: starImage.bottomAnchor, constant: 8),
            questionLabel.centerXAnchor.constraint(equalTo: placeholderView.centerXAnchor),
            questionLabel.bottomAnchor.constraint(equalTo: placeholderView.bottomAnchor),
        ])
    }
    
    private func loadCategories() {
        categories = trackerCategoryStore.fetchCategories()
        updatePlaceholderVisibility()
        categoryTableView.reloadData()
    }
    
    private func updatePlaceholderVisibility() {
        let isEmpty = categories.isEmpty
        placeholderView.isHidden = !isEmpty
        categoryTableView.isHidden = isEmpty
    }
    
    @objc private func addButtonTapped() {
        let addCategoryVC = AddCategoryViewController()
        addCategoryVC.delegate = self
        let navController = UINavigationController(rootViewController: addCategoryVC)
        present(navController, animated: true)
    }
}

extension CategoryCreationViewController: UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CategoryCell.reuseIdentifier,
            for: indexPath
        ) as? CategoryCell else {
            return UITableViewCell()
        }
        
        let category = categories[indexPath.row]
        let isSelected = selectedCategory?.title == category.title
        let isLastCell = indexPath.row == categories.count - 1
        
        cell.configure(
            with: category,
            isSelected: isSelected,
            isLastCell: isLastCell
        )
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
           tableView.deselectRow(at: indexPath, animated: true)
           
           let category = categories[indexPath.row]
           selectedCategory = category
           delegate?.didSelectCategory(category)
           
           tableView.reloadData()
           
           DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
               self.dismiss(animated: true)
           }
       }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let isFirstCell = indexPath.row == 0
        let isLastCell = indexPath.row == categories.count - 1
        
        if isFirstCell {
            cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            cell.layer.cornerRadius = 16
        } else if isLastCell {
            cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            cell.layer.cornerRadius = 16
        } else {
            cell.layer.cornerRadius = 0
        }
        cell.layer.masksToBounds = true
    }
}

extension CategoryCreationViewController: AddCategoryDelegate {
    func didAddCategory(title: String) {
        trackerCategoryStore.addCategory(title: title)
        loadCategories()
    }
}

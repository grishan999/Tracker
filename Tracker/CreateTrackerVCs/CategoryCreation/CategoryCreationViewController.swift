//
//  CategoryCreationViewController.swift
//  Tracker
//
//  Created by Ilya Grishanov on 24.04.2025.
//

protocol TrackerCategoryStoreProtocol {
    func addCategory(title: String)
    func fetchCategories() -> [TrackerCategory]
    func editCategory(_ category: TrackerCategory, newTitle: String)
    func deleteCategory(_ category: TrackerCategory)
}

import UIKit

final class CategoryCreationViewController: UIViewController {
    private let viewModel: CategoryCreationViewModel
    private var onCategorySelected: ((TrackerCategory) -> Void)?
    
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
    
    init(
        viewModel: CategoryCreationViewModel = CategoryCreationViewModel(),
        onCategorySelected: ((TrackerCategory) -> Void)?
    ) {
        self.viewModel = viewModel
        self.onCategorySelected = onCategorySelected
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.tintColor = UIColor(named: "CustomBlack")
        navigationItem.title = "Категория"
        
        setupUI()
        bindViewModel()
    }
    
    private func bindViewModel() {
        viewModel.updateCategories = { [weak self] categories in
            self?.categoryTableView.reloadData()
        }
        
        viewModel.updatePlaceholderVisibility = { [weak self] isEmpty in
            self?.placeholderView.isHidden = !isEmpty
            self?.categoryTableView.isHidden = isEmpty
            
            self?.view.layoutIfNeeded()
        }
    }
    
    private func setupUI() {
        setupStarImage()
        setupQuestionLabel()
        
        view.addSubview(placeholderView)
        view.addSubview(categoryTableView)
        view.addSubview(addButton)
        
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
        
        placeholderView.isHidden = !viewModel.getCategories().isEmpty
        categoryTableView.isHidden = viewModel.getCategories().isEmpty
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
        questionLabel.text = "Привычки и события можно \n объединить по смыслу"
        questionLabel.font = UIFont(name: "YS Display Medium", size: 12)
        questionLabel.numberOfLines = 2
        questionLabel.textAlignment = .center
        questionLabel.textColor = UIColor(named: "CustomBlack")
        questionLabel.translatesAutoresizingMaskIntoConstraints = false
        placeholderView.addSubview(questionLabel)
        
        NSLayoutConstraint.activate([
            questionLabel.topAnchor.constraint(equalTo: starImage.bottomAnchor, constant: 8),
            questionLabel.centerXAnchor.constraint(equalTo: placeholderView.centerXAnchor),
            questionLabel.bottomAnchor.constraint(equalTo: placeholderView.bottomAnchor),
        ])
    }
    
    @objc private func addButtonTapped() {
        let addCategoryVC = AddCategoryViewController { [weak self] title in
            self?.viewModel.addCategory(title: title)
        }
        let navController = UINavigationController(rootViewController: addCategoryVC)
        present(navController, animated: true)
    }
}

extension CategoryCreationViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getCategoriesCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CategoryCell.reuseIdentifier,
            for: indexPath
        ) as? CategoryCell else {
            return UITableViewCell()
        }
        
        guard let category = viewModel.getCategory(at: indexPath.row) else {
            return UITableViewCell()
        }
        
        let isSelected = viewModel.isCategorySelected(at: indexPath.row)
        let isLastCell = indexPath.row == viewModel.getCategoriesCount() - 1
        
        cell.configure(
            with: category,
            isSelected: isSelected,
            isLastCell: isLastCell,
            onEdit: { [weak self] in
                self?.showEditCategoryScreen(category: category, index: indexPath.row)
            },
            onDelete: { [weak self] in
                self?.viewModel.deleteCategory(at: indexPath.row)
            }
        )
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let category = viewModel.selectCategory(at: indexPath.row) {
            onCategorySelected?(category)
            tableView.reloadData()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.dismiss(animated: true)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let totalRows = tableView.numberOfRows(inSection: indexPath.section)
        
        if totalRows == 1 {
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }
        else if indexPath.row == 0 {
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }
        else if indexPath.row == totalRows - 1 {
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }
        else {
            cell.layer.cornerRadius = 0
        }
        cell.layer.masksToBounds = true
    }
}

extension CategoryCreationViewController {
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        guard let cell = tableView.cellForRow(at: indexPath) as? CategoryCell,
              let category = viewModel.getCategory(at: indexPath.row) else {
            return nil
        }
        
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        blurView.frame = view.bounds
        view.addSubview(blurView)
        
        cell.backgroundColor = UIColor(named: "CustomBackgroundDay")
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ -> UIMenu? in
            let edit = UIAction(title: "Редактировать") { [weak self] _ in
                self?.showEditCategoryScreen(category: category, index: indexPath.row)
                blurView.removeFromSuperview()
                cell.backgroundColor = UIColor(named: "CustomBackgroundDay")
            }
            
            let delete = UIAction(title: "Удалить", attributes: .destructive) { [weak self] _ in
                self?.showDeleteAlert(for: category, at: indexPath.row, blurView: blurView)
            }
            
            return UIMenu(title: "", children: [edit, delete])
        }
    }
    
    func tableView(_ tableView: UITableView, willEndContextMenuInteraction configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionAnimating?) {
        view.subviews.filter { $0 is UIVisualEffectView }.forEach { $0.removeFromSuperview() }
        tableView.visibleCells.forEach { $0.backgroundColor = UIColor(named: "CustomBackgroundDay") }
    }
    
    private func showEditCategoryScreen(category: TrackerCategory, index: Int) {
        let editVC = CustomizeCategoryViewController(
            viewModel: viewModel,
            categoryIndex: index,
            initialTitle: category.title
        )
        navigationController?.pushViewController(editVC, animated: true)
    }
    
    private func showDeleteAlert(for category: TrackerCategory, at index: Int, blurView: UIVisualEffectView) {
        let alert = UIAlertController(
            title: nil,
            message: "Эта категория точно не нужна?",
            preferredStyle: .actionSheet
        )
        
        let deleteAction = UIAlertAction(title: "Удалить", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            
            self.viewModel.deleteCategory(at: index)
            
            blurView.removeFromSuperview()
            
            self.viewModel.loadCategories()
        }
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel) { _ in
            blurView.removeFromSuperview()
        }
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.maxY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        present(alert, animated: true, completion: nil)
    }
}

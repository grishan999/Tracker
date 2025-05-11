//
//  FiltersViewController.swift
//  Tracker
//
//  Created by Ilya Grishanov on 05.05.2025.
//

import UIKit

protocol FiltersViewControllerDelegate: AnyObject {
    func didSelectFilter(_ filter: FilterType)
}

enum FilterType: String, CaseIterable {
    case all
    case today
    case completed
    case notCompleted
    
    var localizedTitle: String {
        let key: String
        switch self {
        case .all: key = "filters.alltrackers.case"
        case .today: key = "filters.today.case"
        case .completed: key = "filters.completed.case"
        case .notCompleted: key = "filters.notcompleted.case"
        }
        return NSLocalizedString(key, comment: "Название фильтра трекеров")
    }
    
    var rawValue: String {
        return localizedTitle
    }
}

final class FiltersViewController: UIViewController {
    
    weak var delegate: FiltersViewControllerDelegate?
    private var selectedFilter: FilterType?
    
    private lazy var filtersTableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.layer.cornerRadius = 16
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = false
        tableView.separatorStyle = .none
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.register(FiltersCell.self, forCellReuseIdentifier: FiltersCell.reuseIdentifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    init(selectedFilter: FilterType? = nil) {
        self.selectedFilter = selectedFilter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(filtersTableView)
        
        NSLayoutConstraint.activate([
            filtersTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            filtersTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            filtersTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            filtersTableView.heightAnchor.constraint(equalToConstant: CGFloat(FilterType.allCases.count * 75))
        ])
    }
    
    private func setupNavigationBar() {
        navigationItem.title = NSLocalizedString("filters.navigation.title",
                                                 comment: "Заголовок экрана Фильтры")
        navigationController?.navigationBar.prefersLargeTitles = false
    }
}

extension FiltersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return FilterType.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: FiltersCell.reuseIdentifier,
            for: indexPath
        ) as? FiltersCell else {
            return UITableViewCell()
        }
        
        let filter = FilterType.allCases[indexPath.row]
        let isSelected = filter == selectedFilter
        let isLastCell = indexPath.row == FilterType.allCases.count - 1
        
        cell.configure(
            with: filter.rawValue,
            isSelected: isSelected,
            isLastCell: isLastCell
        )
        
        return cell
    }
}

extension FiltersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedFilter = FilterType.allCases[indexPath.row]
        self.selectedFilter = selectedFilter
        delegate?.didSelectFilter(selectedFilter)
        tableView.reloadData()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.dismiss(animated: true)
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

extension TrackersViewController: FiltersViewControllerDelegate {
    func didSelectFilter(_ filter: FilterType) {
        applyFilter(filter)
    }
}

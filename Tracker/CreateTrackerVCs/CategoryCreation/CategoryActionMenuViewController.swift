//
//  CategoryActionMenuViewController.swift
//  Tracker
//
//  Created by Ilya Grishanov on 28.04.2025.
//

import UIKit

final class CategoryActionMenuViewController: UIViewController {
    private let editAction: () -> Void
    private let deleteAction: () -> Void
    
    init(editAction: @escaping () -> Void, deleteAction: @escaping () -> Void) {
        self.editAction = editAction
        self.deleteAction = deleteAction
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .clear
        
        let tableView = UITableView()
        tableView.backgroundColor = UIColor(named: "CustomWhite")
        tableView.layer.cornerRadius = 10
        tableView.isScrollEnabled = false
        tableView.separatorStyle = .none
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.widthAnchor.constraint(equalToConstant: 250),
            tableView.heightAnchor.constraint(equalToConstant: 97),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        ])
    }
}

extension CategoryActionMenuViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = indexPath.row == 0 ?  NSLocalizedString("customize.button",
                                                                       comment: "Кнопка Редактировать") : NSLocalizedString("delete.button",
                                                                                                                            comment: "Кнопка Удалить")
        cell.textLabel?.font = UIFont.systemFont(ofSize: 17)
        cell.textLabel?.textAlignment = .center
        cell.backgroundColor = .clear
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        48.5
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        dismiss(animated: true) {
            if indexPath.row == 0 {
                self.editAction()
            } else {
                self.deleteAction()
            }
        }
    }
}

//
//  CategoryCreationViewModel.swift
//  Tracker
//
//  Created by Ilya Grishanov on 27.04.2025.
//
import Foundation

final class CategoryCreationViewModel {
    var updateCategories: (([TrackerCategory]) -> Void)?
    var updatePlaceholderVisibility: ((Bool) -> Void)?
    
    private let trackerCategoryStore: TrackerCategoryStoreProtocol
    private var categories: [TrackerCategory] = []
    private var selectedCategory: TrackerCategory?
    
    init(trackerCategoryStore: TrackerCategoryStoreProtocol = TrackerCategoryStore()) {
        self.trackerCategoryStore = trackerCategoryStore
        loadCategories()
    }
    
    func loadCategories() {
        categories = trackerCategoryStore.fetchCategories()
        updateCategories?(categories)
        updatePlaceholderVisibility?(categories.isEmpty)
    }
    
    func addCategory(title: String) {
        trackerCategoryStore.addCategory(title: title)
        loadCategories()
    }
    
    func getCategories() -> [TrackerCategory] {
        return categories
    }
    
    func selectCategory(at index: Int) -> TrackerCategory? {
        guard
            index < categories.count else { return nil }
        selectedCategory = categories[index]
        return selectedCategory
    }
    
    func isCategorySelected(at index: Int) -> Bool {
        guard
            index < categories.count else { return false }
        return selectedCategory?.title == categories[index].title
    }
    
    func getCategoriesCount() -> Int {
        return categories.count
    }
    
    func getCategory(at index: Int) -> TrackerCategory? {
        guard
            index < categories.count else { return nil }
        return categories[index]
    }
    
    func editCategory(at index: Int, newTitle: String) {
        guard
            index < categories.count else { return }
        let category = categories[index]
        trackerCategoryStore.editCategory(category, newTitle: newTitle)
        loadCategories()
        
        if selectedCategory?.title == category.title {
            selectedCategory = TrackerCategory(title: newTitle, trackers: category.trackers)
        }
    }
    
    func deleteCategory(at index: Int) {
        guard
            index < categories.count else { return }
        let category = categories[index]
        trackerCategoryStore.deleteCategory(category)
        loadCategories()
    }
    
}

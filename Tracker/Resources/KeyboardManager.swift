//
//  KeyboardManager.swift
//  Tracker
//
//  Created by Ilya Grishanov on 14.05.2025.
//

import UIKit

protocol KeyboardManageable: AnyObject {
    func setupKeyboardDismissal(for view: UIView)
    func registerTextField(_ textField: UITextField)
}

final class KeyboardManager: NSObject, KeyboardManageable {
    private weak var currentTextField: UITextField?
    
    func setupKeyboardDismissal(for view: UIView) {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    func registerTextField(_ textField: UITextField) {
        currentTextField = textField
        textField.delegate = self
    }
    
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        currentTextField?.resignFirstResponder()
    }
}

extension KeyboardManager: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

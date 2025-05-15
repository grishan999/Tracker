//
//  TextFieldDelegate(search).swift
//  Tracker
//
//  Created by Ilya Grishanov on 02.05.2025.
//
import UIKit

extension TrackersViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        filterTrackers(for: currentDate, with: updatedText)
        return true
    }
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        filterTrackers(for: currentDate)
        return true
        
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}



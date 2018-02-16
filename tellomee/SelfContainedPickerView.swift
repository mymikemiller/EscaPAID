//
//  SelfContainedPickerView.swift
//  tellomee
//
//  Created by Michael Miller on 12/19/17.
//  Copyright © 2017 Michael Miller. All rights reserved.
//

import UIKit

class SelfContainedPickerView: UIPickerView {
    
    var strings: [String] = []
    var textField: UITextField?
    
    func setUp(textField: UITextField?, strings: [String]) {
        
        dataSource = self
        delegate = self
        self.textField = textField
        self.textField?.inputView = self
        self.strings = strings
        // Set the default for the picker
        for (index, element) in strings.enumerated() {
            if (element == textField?.text) {
                selectRow(index, inComponent: 0, animated: false)
                break
            }
        }
        showsSelectionIndicator = true
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.sizeToFit()
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(cancel))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(done))
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        textField?.inputAccessoryView = toolBar
        
        setSelection()
    }
    
    @objc func cancel() {
        textField?.resignFirstResponder()
    }
    @objc func done() {
        textField?.text = selectedString
        textField?.resignFirstResponder()
    }
    
    var selectedString: String {
        get {
            return strings[selectedRow(inComponent: 0)]
        }
    }
    
    // Selects the row corresponding to the text in the text box, if there's a match
    private func setSelection() {
        for (index, str) in strings.enumerated() {
            if (textField?.text == str) {
                selectRow(index, inComponent: 0, animated: true)
            }
        }
    }
}


extension SelfContainedPickerView: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return strings.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return strings[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
    }
}



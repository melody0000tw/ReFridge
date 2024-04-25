//
//  CardQtyCell.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/4/21.
//

import UIKit

protocol ItemInfoCellDelegate: AnyObject {
    func didChangeQty(qty: Int, mesureWord: String)
}

class ItemInfoCell: UITableViewCell {
    weak var delegate: ItemInfoCellDelegate?
    static let reuseIdentifier = String(describing: ItemInfoCell.self)
    
    var qty = 1
    var mesureWord = "個"
    
    @IBOutlet weak var mesureWordTextField: UITextField!
    @IBOutlet weak var qtyTextField: UITextField!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var iconImage: UIImageView!
    
    let mesureWordPicker = UIPickerView()
    let mesureWords = MesureWordData.shared.data
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        qtyTextField.delegate = self
        mesureWordTextField.delegate = self
        qtyTextField.text = String(qty)
        mesureWordTextField.text = mesureWord
        setupMesureWordPicker()
        
        // Initialization code
    }
    
    private func setupMesureWordPicker() {
        mesureWordTextField.inputView = mesureWordPicker
        mesureWordPicker.delegate = self
        mesureWordPicker.dataSource = self
        mesureWordTextField.iq.addDone(target: self, action: #selector(donePickingMesureWord))
    }
    
    @objc func donePickingMesureWord() {
        let row = mesureWordPicker.selectedRow(inComponent: 0)
        mesureWord = mesureWords[row]
        mesureWordTextField.text = mesureWord
        mesureWordTextField.resignFirstResponder()
    }
    
}

// MARK: - UITextFieldDelegate
extension ItemInfoCell: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let mesureWord = mesureWordTextField.text, let qtyString = qtyTextField.text {
            self.qty = Int(qtyString) ?? 1
            self.mesureWord = mesureWord
            delegate?.didChangeQty(qty: qty, mesureWord: mesureWord)
        }
    }
}

// MARK: - UIPickerViewDataSource, UIPickerViewDelegate
extension ItemInfoCell: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        mesureWords.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return mesureWords[row]
    }
}


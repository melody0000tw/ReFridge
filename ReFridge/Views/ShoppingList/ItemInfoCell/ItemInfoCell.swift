//
//  CardQtyCell.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/4/21.
//

import UIKit

protocol ItemInfoCellDelegate: AnyObject {
    func didChangeQty(qty: Int, mesureWord: String, notes: String)
    func didTappedIconImg()
}

class ItemInfoCell: UITableViewCell {
    weak var delegate: ItemInfoCellDelegate?
    static let reuseIdentifier = String(describing: ItemInfoCell.self)
    
    var qty = 1
    var mesureWord = "個"
    var notes = ""
    
    @IBOutlet weak var mesureWordTextField: UITextField!
    @IBOutlet weak var qtyTextField: UITextField!
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var noteTextField: UITextField!
    
    let mesureWordPicker = UIPickerView()
    let mesureWords = MesureWordData.shared.data
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        qtyTextField.delegate = self
        mesureWordTextField.delegate = self
        noteTextField.delegate = self
        qtyTextField.text = String(qty)
        mesureWordTextField.text = mesureWord
        noteTextField.text = notes
        setupMesureWordPicker()
        let tapRecongnizer = UITapGestureRecognizer(target: self, action: #selector(didTappedIcon))
        iconImage.isUserInteractionEnabled = true
        iconImage.addGestureRecognizer(tapRecongnizer)
        // Initialization code
    }
    
    private func setupMesureWordPicker() {
        mesureWordTextField.inputView = mesureWordPicker
        mesureWordPicker.delegate = self
        mesureWordPicker.dataSource = self
        mesureWordTextField.iq.addDone(target: self, action: #selector(donePickingMesureWord))
    }
    
    @objc func didTappedIcon() {
        delegate?.didTappedIconImg()
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
        if let mesureWord = mesureWordTextField.text, let qtyString = qtyTextField.text, let notes = noteTextField.text {
            self.qty = Int(qtyString) ?? 1
            self.mesureWord = mesureWord
            self.notes = notes
            delegate?.didChangeQty(qty: qty, mesureWord: mesureWord, notes: notes)
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


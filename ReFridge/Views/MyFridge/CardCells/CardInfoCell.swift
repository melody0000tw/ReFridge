//
//  CardInfoCell.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/4/20.
//

import UIKit

protocol CardInfoCellDelegate: AnyObject {
    func didTappedBarcodeBtn()
    func didChangeCardInfo(foodCard: FoodCard)
    func didTappedIconImg()
}

class CardInfoCell: UITableViewCell {
    weak var delegate: CardInfoCellDelegate?
    static let reuseIdentifier = String(describing: CardInfoCell.self)
    
    var foodCard = FoodCard()
    
    let datePicker = UIDatePicker()
    let formatter = FormatterManager.share.formatter
    
    let mesureWordPicker = UIPickerView()
    let mesureWords = MesureWordData.shared.data
    
    @IBOutlet weak var iconBgView: UIView!
    @IBOutlet weak var qtyTextField: UITextField!
    @IBOutlet weak var mesureWordTextField: UITextField!
    @IBOutlet weak var noteTextView: UITextView!
    @IBOutlet weak var storageSegment: UISegmentedControl!
    @IBOutlet weak var barcodeBtn: UIButton!
    @IBOutlet weak var dateBtn: UIButton!
    @IBOutlet weak var barcodeTextField: UITextField!
    @IBOutlet weak var expireDateTextField: UITextField!
    @IBOutlet weak var routineItemSwitch: UISwitch!
    @IBOutlet weak var iconImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        setups()
        setupDatePicker()
        setupMesureWordPicker()
    }

    private func setups() {
        qtyTextField.delegate = self
        mesureWordTextField.delegate = self
        noteTextView.delegate = self
        storageSegment.addTarget(self, action: #selector(onChangeStorageType(sender:)), for: .valueChanged)
        routineItemSwitch.addTarget(self, action: #selector(onChangeRoutineStatus(sender:)), for: .valueChanged)
        barcodeTextField.delegate = self
        barcodeBtn.backgroundColor = .clear
        barcodeBtn.setImage(UIImage(systemName: "barcode.viewfinder"), for: .normal)
        barcodeBtn.tintColor = .C2
        barcodeBtn.addTarget(self, action: #selector(didTappedBarcodeBtn), for: .touchUpInside)
        dateBtn.backgroundColor = .clear
        dateBtn.setImage(UIImage(systemName: "calendar"), for: .normal)
        dateBtn.addTarget(self, action: #selector(didTappedDateBtn), for: .touchUpInside)
        dateBtn.tintColor = .C2
        expireDateTextField.delegate = self
        iconBgView.backgroundColor = .C1
        let tapRecongnizer = UITapGestureRecognizer(target: self, action: #selector(didTappedIcon))
        iconImage.isUserInteractionEnabled = true
        iconImage.addGestureRecognizer(tapRecongnizer)
    }
    
    func setupData() {
        if foodCard.cardId != "" {
            // editing
            qtyTextField.text = String(describing: foodCard.qty)
            mesureWordTextField.text = foodCard.mesureWord
            noteTextView.text = foodCard.notes == "" ? nil : String(describing: foodCard.notes)
            storageSegment.selectedSegmentIndex = foodCard.storageType
            barcodeTextField.text = foodCard.barCode == "" ? nil : String(describing: foodCard.barCode)
            expireDateTextField.text = formatter.string(from: foodCard.expireDate)
            iconImage.image = UIImage(named: foodCard.iconName)
            routineItemSwitch.setOn(foodCard.isRoutineItem, animated: false)
        } else {
            // adding
            qtyTextField.text = nil
            mesureWordTextField.text = nil
            noteTextView.text = nil
            barcodeTextField.text = nil
            expireDateTextField.text = nil
            routineItemSwitch.setOn(false, animated: false)
        }
    }
    
    // MARK: - DatePicker
    private func setupDatePicker() {
        datePicker.preferredDatePickerStyle = .inline
        datePicker.datePickerMode = .date
        expireDateTextField.inputView = datePicker
        expireDateTextField.iq.addDone(target: self, action: #selector(donePickingDate))
    }
    
    @objc func donePickingDate() {
        let expiredDate = datePicker.date
        foodCard.expireDate = expiredDate
        expireDateTextField.text = formatter.string(from: expiredDate)
        expireDateTextField.resignFirstResponder()
    }
    
    @objc func didTappedIcon() {
        delegate?.didTappedIconImg()
    }
    
    // MARK: - MesureWordPicker
    private func setupMesureWordPicker() {
        mesureWordTextField.inputView = mesureWordPicker
        mesureWordPicker.delegate = self
        mesureWordPicker.dataSource = self
        mesureWordTextField.iq.addDone(target: self, action: #selector(donePickingMesureWord))
    }
    
    @objc func donePickingMesureWord() {
        let row = mesureWordPicker.selectedRow(inComponent: 0)
        let mesureWord = mesureWords[row]
        
        foodCard.mesureWord = mesureWord
        mesureWordTextField.text = foodCard.mesureWord
        mesureWordTextField.resignFirstResponder()
    }
    
    // MARK: - Storge & Routine
    @objc func onChangeStorageType(sender: UISegmentedControl) {
        let index = sender.selectedSegmentIndex
        foodCard.storageType = index
        delegate?.didChangeCardInfo(foodCard: foodCard)
        
    }
    
    @objc func onChangeRoutineStatus(sender: UISwitch) {
        let isRoutineItem = sender.isOn
        foodCard.isRoutineItem = isRoutineItem
        delegate?.didChangeCardInfo(foodCard: foodCard)
    }
    
    @objc func didTappedBarcodeBtn() {
        delegate?.didTappedBarcodeBtn()
    }
    
    @objc func didTappedDateBtn() {
        expireDateTextField.becomeFirstResponder()
    }
}

// MARK: - UITextFieldDelegate, UITextViewDelegate
extension CardInfoCell: UITextFieldDelegate, UITextViewDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == qtyTextField, let qty = textField.text {
            foodCard.qty = Int(qty) ?? 1
            
        } else if textField == barcodeTextField, let barcode = textField.text {
            foodCard.barCode = barcode
        } else if textField == mesureWordTextField, let mesureWord = textField.text {
            foodCard.mesureWord = mesureWord
        }
        delegate?.didChangeCardInfo(foodCard: foodCard)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView == noteTextView, let notes = noteTextView.text {
            foodCard.notes = notes
            delegate?.didChangeCardInfo(foodCard: foodCard)
        }
    }
}

// MARK: - UIPickerViewDataSource, UIPickerViewDelegate
extension CardInfoCell: UIPickerViewDataSource, UIPickerViewDelegate {
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

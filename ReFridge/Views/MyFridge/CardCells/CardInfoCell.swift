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
}

class CardInfoCell: UITableViewCell {
    weak var delegate: CardInfoCellDelegate?
    static let reuseIdentifier = String(describing: CardInfoCell.self)
    
    var foodCard = FoodCard() {
        didSet {
            print("=============== cardInfo 已更改 foodCard: \(foodCard)")
            delegate?.didChangeCardInfo(foodCard: foodCard)
//            barcodeTextField.text = foodCard.barCode
//            iconImage.image = UIImage(named: foodCard.iconName)
            
        }
    }
    
    let datePicker = UIDatePicker()
    let formatter = FormatterManager.share.formatter
    
    @IBOutlet weak var iconBgView: UIView!
    @IBOutlet weak var qtyTextField: UITextField!
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
    }

    
    private func setups() {
        qtyTextField.delegate = self
        noteTextView.delegate = self
        storageSegment.addTarget(self, action: #selector(onChangeStorageType(sender:)), for: .valueChanged)
//        storageSegment.backgroundColor = .clear
//        storageSegment.
//        storageSegment.selectedSegmentTintColor = .C1
        routineItemSwitch.addTarget(self, action: #selector(onChangeRoutineStatus(sender:)), for: .valueChanged)
        barcodeTextField.delegate = self
        barcodeBtn.backgroundColor = .clear
        barcodeBtn.setImage(UIImage(systemName: "barcode.viewfinder"), for: .normal)
        barcodeBtn.tintColor = .C2
        barcodeBtn.addTarget(self, action: #selector(didTappedBarcodeBtn), for: .touchUpInside)
        dateBtn.backgroundColor = .clear
        dateBtn.setImage(UIImage(systemName: "calendar"), for: .normal)
        dateBtn.tintColor = .C2
        expireDateTextField.delegate = self
        iconBgView.backgroundColor = .C1
//        iconBgView.layer.cornerRadius = 5
    }
    
    func setupData() {
        if foodCard.cardId != "" {
            // editing
            qtyTextField.text = String(describing: foodCard.qty)
            noteTextView.text = foodCard.notes == "" ? nil : String(describing: foodCard.notes)
            storageSegment.selectedSegmentIndex = foodCard.storageType
            barcodeTextField.text = foodCard.barCode == "" ? nil : String(describing: foodCard.barCode)
            expireDateTextField.text = formatter.string(from: foodCard.expireDate)
            iconImage.image = UIImage(named: foodCard.iconName)
            routineItemSwitch.setOn(foodCard.isRoutineItem, animated: false)
        } else {
            // adding
            qtyTextField.text = String(describing: foodCard.qty)
            noteTextView.text = nil
            barcodeTextField.text = nil
            expireDateTextField.text = nil
            routineItemSwitch.setOn(false, animated: false)
        }
    }
    
    private func setupDatePicker() {
        datePicker.preferredDatePickerStyle = .inline
        datePicker.datePickerMode = .date
        expireDateTextField.inputView = datePicker
        
        // Toolbar
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneAction))
        toolbar.setItems([doneButton], animated: true)
        expireDateTextField.inputAccessoryView = toolbar
    }
    
    @objc func doneAction() {
        let expiredDate = datePicker.date
        foodCard.expireDate = expiredDate
        expireDateTextField.text = formatter.string(from: expiredDate)
        expireDateTextField.resignFirstResponder()
    }
    
    @objc func onChangeStorageType(sender: UISegmentedControl) {
        let index = sender.selectedSegmentIndex
        print("已選取儲存方式：\(index)")
        foodCard.storageType = index
        
    }
    
    @objc func onChangeRoutineStatus(sender: UISwitch) {
        let isRoutineItem = sender.isOn
        foodCard.isRoutineItem = isRoutineItem
    }
    
    @objc func didTappedBarcodeBtn() {
        print("didTappedBarcode")
        delegate?.didTappedBarcodeBtn()
    }
}

extension CardInfoCell: UITextFieldDelegate, UITextViewDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == qtyTextField, let qty = textField.text {
            print("已輸入選取數量：\(qty)")
            foodCard.qty = Int(qty) ?? 1
            
        } else if textField == barcodeTextField, let barcode = textField.text{
            print("已輸入 bar code: \(barcode)")
            foodCard.barCode = barcode
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView == noteTextView, let notes = noteTextView.text {
            foodCard.notes = notes
        }
    }
}

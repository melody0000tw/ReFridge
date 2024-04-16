//
//  ListCell.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/4/14.
//

import UIKit
import SnapKit

protocol ListCellDelegate: AnyObject {
    func delete(cell: UITableViewCell)
}

class ListCell: UITableViewCell {
    weak var delegate: ListCellDelegate?
    static let reuseIdentifier = String(describing: ListCell.self)
    
    lazy var squareView = UIView(frame: CGRect())
    lazy var checkView = UIImageView(frame: CGRect())
    
    @IBOutlet weak var itemLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    
    @IBAction func didTappedDeleteBtn(_ sender: Any) {
        delegate?.delete(cell: self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        setupMarks()
    }
    
    private func setupMarks() {
        squareView.layer.borderWidth = 1
        squareView.layer.borderColor = UIColor.darkGray.cgColor
        squareView.backgroundColor = .clear
        contentView.addSubview(squareView)
        squareView.snp.makeConstraints { make in
            make.leading.equalTo(contentView.safeAreaLayoutGuide.snp.leading).offset(24)
            make.width.height.equalTo(24)
            make.centerY.equalTo(contentView.snp.centerY)
        }
        squareView.isHidden = false
        
        checkView.image = UIImage(systemName: "checkmark")
        checkView.tintColor = .darkGray
        contentView.addSubview(checkView)
        checkView.snp.makeConstraints { make in
            make.leading.equalTo(contentView.safeAreaLayoutGuide.snp.leading).offset(24)
            make.width.height.equalTo(20)
            make.centerY.equalTo(contentView.snp.centerY)
        }
        checkView.isHidden = true
    }
    
    func toggleStyle(checkStatus: Int) {
        if checkStatus == 0 {
            squareView.isHidden = false
            checkView.isHidden = true
        } else {
            squareView.isHidden = true
            checkView.isHidden = false
        }
    }

}

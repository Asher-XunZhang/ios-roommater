//
//  Cells.swift
//  Roommater
//
//  Created by KAMIKU on 12/5/21.
//

import UIKit
import Former

public final class ButtonRowFormer<T: UITableViewCell>: BaseRowFormer<T>, Formable {
    public required init(instantiateType: Former.InstantiateType = .Class, cellSetup: ((T) -> Void)? = nil) {
        super.init(instantiateType: instantiateType, cellSetup: cellSetup)
    }
}

final class ProfileImageCell: UITableViewCell, LabelFormableRow {
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    var onClickImage : (()->Void)? = nil
    
    @IBAction func clickImage(){
        onClickImage?()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.textColor = .gray
        iconView.layer.cornerRadius = iconView.bounds.height / 2
        iconView.layer.borderColor = CGColor(red: 8, green: 8, blue: 8, alpha: 1)
        iconView.layer.borderWidth = 1
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        if iconViewColor == nil {
            iconViewColor = iconView.backgroundColor
        }
        super.setHighlighted(highlighted, animated: animated)
        if let color = iconViewColor {
            iconView.backgroundColor = color
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        if iconViewColor == nil {
            iconViewColor = iconView.backgroundColor
        }
        super.setSelected(selected, animated: animated)
        if let color = iconViewColor {
            iconView.backgroundColor = color
        }
    }
    
    func formTextLabel() -> UILabel? {
        return titleLabel
    }
    
    func formSubTextLabel() -> UILabel? {
        return nil
    }
    
    func updateWithRowFormer(_ rowFormer: RowFormer) {}
    
    // MARK: Private
    private var iconViewColor: UIColor?
}


class TextFieldWithHintCell : UITableViewCell, TextFieldFormableRow {
    @IBOutlet weak var hint : UILabel!
    @IBOutlet weak var label : UILabel!
    @IBOutlet weak var textfield : UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func formTextField() -> UITextField {
        return textfield
    }
    
    func formTitleLabel() -> UILabel? {
        return label
    }
    
    func updateWithRowFormer(_ rowFormer: RowFormer) {}
    
    func hint(msg: String, color: UIColor) {
        hint.textColor = color
        hint.text = msg
        textfield.textColor = color
    }
    
    func clear() {
        hint.text = ""
        hint.textColor = .gray
        textfield.textColor = .black
    }
}

class ButtonCell : UITableViewCell, FormableRow {
    @IBOutlet weak var button : UIButton!
    var buttonHandler : ((UIButton)->Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        button.addTarget(self, action: #selector(onBottonClicked), for: .touchUpInside)
    }
    
    func updateWithRowFormer(_ rowFormer: RowFormer) {}
    
    @objc func onBottonClicked(btn: UIButton){
        if button.isEnabled {
            buttonHandler?(btn)
        }
    }
}

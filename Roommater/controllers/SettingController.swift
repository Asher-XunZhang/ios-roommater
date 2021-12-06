//
//  SettingController.swift
//  Roommater
//
//  Created by KAMIKU on 10/23/21.
//

import Foundation
import UIKit
import SPIndicator
import Alamofire
import Former

extension FormLabelFooterView  {
    static var createFooter: ((String) -> ViewFormer) = { text in
        return LabelViewFormer<FormLabelFooterView>()
            .configure {
                $0.text = text
                $0.viewHeight = 100
            }
    }
}

class SettingController : UITableViewController, UINavigationControllerDelegate {
    @IBOutlet var usernameLabel : UILabel!
    @IBOutlet var roomConigCell : UITableViewCell!
    @IBOutlet var userAvatar : UIImageView!
    @IBOutlet var ratingLable : UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        usernameLabel.text = SessionManager.instance.user?.nickname
        ratingLable.text = String(format: "%.1f", SessionManager.instance.user?.rating ?? 0.0)
    
        userAvatar.layer.cornerRadius = userAvatar.bounds.height / 2
        userAvatar.layer.borderColor = CGColor(red: 8, green: 8, blue: 8, alpha: 1)
        userAvatar.layer.borderWidth = 1
        
        switch SessionManager.instance.user?.rating ?? -1{
            case 0...5:
                ratingLable.textColor = .red
            case 6...8:
                ratingLable.textColor = .yellow
            case 9:
                ratingLable.textColor = .green
            case 10:
                ratingLable.textColor = .systemGreen
            default:
                ratingLable.textColor = .gray
        }
        SessionManager.instance.getAvatar(callback: {res, err in
            if err == 0 {
                self.userAvatar.image = res!.af.imageAspectScaled(toFill: CGSize(width: self.userAvatar.bounds.width, height: self.userAvatar.bounds.height))
            }else{
                SPIndicator.present(title: "Error", message: "Failed to get the avatar", preset: .error)
            }
        })
    }

    
    @IBAction func logout(){
        APIAction.logout(callback: {res in
            switch res {
                case .Success(_):
                    self.navigationController?.navigationController?.popViewController(animated: true);
                case .Fail(let msg), .Timeout(let msg), .Error(let msg):
                    SPIndicator.present(title: "Error", message: msg, preset: .error)
                case .NONE:
                    SPIndicator.present(title: "Error", message: "Unknown Error", preset: .error)
            }
        })
    }
}

class ProfileController : FormViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    var imagePicker = UIImagePickerController()
    var avatar : CustomRowFormer<ProfileImageCell>? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Edit Profile"
        avatar = CustomRowFormer<ProfileImageCell>(instantiateType: .Nib(nibName: "AvatarCell")){
            if let avatar = SessionManager.instance.user?.avatarImage{
                $0.iconView.setImage(avatar.af.imageAspectScaled(toFill: CGSize(width: $0.iconView.bounds.width, height: $0.iconView.bounds.height)))
            }
            $0.onClickImage = {
                if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
                    self.imagePicker.delegate = self
                    self.imagePicker.sourceType = .photoLibrary
                    self.imagePicker.allowsEditing = true
                    self.present(self.imagePicker, animated: true, completion: nil)
                }
            }
        }.configure{
            $0.rowHeight = 120
        }
        former.append(sectionFormer: SectionFormer(rowFormer: avatar!))
        
        let userLaebl = LabelRowFormer<FormLabelCell>()
            .configure { row in
                row.text = "Username"
                row.subText = SessionManager.instance.user?.nickname
                row.enabled = false
                row.textDisabledColor = .black
                row.subTextDisabledColor = .gray
            }
        
        let emailLaebl = LabelRowFormer<FormLabelCell>()
            .configure { row in
                row.text = "Email"
                row.subText = SessionManager.instance.user?.email
                row.enabled = false
                row.textDisabledColor = .black
                row.subTextDisabledColor = .gray
            }
        former.append(sectionFormer: SectionFormer(rowFormers: [userLaebl,emailLaebl]))
        
        
        let nicknameLabel = TextFieldRowFormer<FormTextFieldCell>() { row in
            row.titleLabel.text = "Nickname"
            row.titleLabel.textColor = .black
            row.titleLabel.font = .boldSystemFont(ofSize: 16)
            row.textField.textColor = .black
            row.textField.textAlignment = .right
            row.textField.font = .boldSystemFont(ofSize: 14)
            row.textField.returnKeyType = .done
            row.tintColor = .black
        }.configure { row in
            row.placeholder = "Your nickname"
            row.text = SessionManager.instance.user?.nickname
        }.onTextChanged{
            SessionManager.instance.user?.nickname = $0
        }
        
        let passwordFld = LabelRowFormer<FormLabelCell>()
            .configure { row in
                row.text = "Passowrd"
            }.onSelected{row in
                self.performSegue(withIdentifier: "passwordPage", sender: nil)
            }
        
        let section = SectionFormer(rowFormer: nicknameLabel, passwordFld)
            .set(footerViewFormer: FormLabelFooterView.createFooter(SessionManager.instance.user?.uid ?? ""))
        
        former.append(sectionFormer: section)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "passwordPage"{
            
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let pickedImage = info[UIImagePickerController.InfoKey(rawValue: UIImagePickerController.InfoKey.originalImage.rawValue)] as! UIImage
        self.dismiss(animated: true, completion: { () -> Void in
            APIAction.updateAvatar(image: pickedImage, callback: {res in
                switch res {
                    case .Success(let data):
                        if let avatar = (data as! [String : Any])["avatar"] as? String{
                            SessionManager.instance.user?.avatar = avatar
                        }
                        SessionManager.instance.updateAvatar(callback: {res, err in
                            if err == 0 {
                                self.avatar?.cell.iconView.setImage(res!.af.imageAspectScaled(toFill: CGSize(width: self.avatar!.cell.iconView.bounds.width, height: self.avatar!.cell.iconView.bounds.height)))
                            }else{
                                SPIndicator.present(title: "Error", message: "Failed to get the avatar", preset: .error)
                            }
                        })
                    case .Fail(let msg),.Timeout(let msg),.Error(let msg):
                        SPIndicator.present(title: "Error", message: msg, preset: .error)
                    case .NONE:
                        SPIndicator.present(title: "Error", message: "Timeout", preset: .error)
                }
            })
        })
    }
}

class PasswordChangeController : FormViewController {
    var password : String? = nil
    var ressPass : String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initForm()
    }
    
    func initForm(){
        let updateBtn = CustomRowFormer<ButtonCell>(instantiateType: .Nib(nibName: "ButtonCell")){
            $0.button.setTitle("Update Password", for: .normal)
            $0.button.isEnabled = false
        }
        .configure{ row in
            row.cell.buttonHandler = { btn in
                btn.isEnabled = false
                row.enabled = false
                //TODO: update password
            }
        }
        
        let repasswordRow = TextFieldRowFormer<TextFieldWithHintCell>(instantiateType: .Nib(nibName: "TextFieldWithHintCell")) {
            $0.textfield.textColor = .gray
            $0.textfield.font = .systemFont(ofSize: 15)
            $0.textfield.isSecureTextEntry = true
            $0.label.text = "Reenter password"
        }.configure {
            $0.placeholder = "Reenter your new password"
            $0.rowHeight = 80
        }.onUpdate{ row in
            if self.ressPass != self.password {
                row.cell.hint(msg: "Mismatched password", color: .systemRed)
                updateBtn.cell.button.isEnabled = false
                updateBtn.enabled = false
            }else{
                row.cell.clear()
                updateBtn.enabled = true
                updateBtn.cell.button.isEnabled = true
            }
        }
        repasswordRow.onTextChanged {row in
            if self.ressPass != self.password {
                repasswordRow.cell.hint(msg: "Mismatched password", color: .systemRed)
                updateBtn.cell.button.isEnabled = false
                updateBtn.enabled = false
            }else{
                repasswordRow.cell.clear()
                updateBtn.cell.button.isEnabled = true
                updateBtn.enabled = true
            }
        }.onReturn{[weak self] in
            self?.ressPass = $0
            repasswordRow.update()
        }
        
        let passwordRow = TextFieldRowFormer<TextFieldWithHintCell>(instantiateType: .Nib(nibName: "TextFieldWithHintCell")) {
            $0.textfield.textColor = .gray
            $0.textfield.font = .systemFont(ofSize: 15)
            $0.textfield.isSecureTextEntry = true
            $0.label.text = "Password"
        }.configure {
            $0.placeholder = "Enter your new password"
            $0.rowHeight = 80
        }.onUpdate{
            if !passwordMatcher.match(input: self.password ?? ""){
                $0.cell.hint(msg: "Not meet the requirement", color: .systemRed)
                updateBtn.cell.button.isEnabled = false
            }else{
                $0.cell.clear()
            }
        }
        passwordRow.onTextChanged {_ in
            repasswordRow.cell.textfield.text = nil
            if !passwordMatcher.match(input: self.password ?? ""){
                passwordRow.cell.hint(msg: "Not meet the requirement", color: .systemRed)
                updateBtn.cell.button.isEnabled = false
            }else{
                passwordRow.cell.clear()
            }
        }.onReturn{ [weak self] in
            self?.password = $0
            passwordRow.update()
        }
        
        former.append(sectionFormer: SectionFormer(rowFormers: [passwordRow, repasswordRow]))
        former.append(sectionFormer: SectionFormer(rowFormer: updateBtn))
    }
}

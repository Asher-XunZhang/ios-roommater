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

class SettingController : UITableViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    @IBOutlet var usernameLabel : UILabel!
    @IBOutlet var roomConigCell : UITableViewCell!
    @IBOutlet var userAvatar : UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SessionManager.instance.user?.getAvatar(callback: {res, err in
            if err == 0 {
                self.userAvatar.image = res
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let pickedImage = info[UIImagePickerController.InfoKey(rawValue: UIImagePickerController.InfoKey.originalImage.rawValue)] as! UIImage
        self.dismiss(animated: true, completion: { () -> Void in
            APIAction.updateAvatar(image: pickedImage, callback: {res in
                switch res {
                    case .Success(_):
                        SPIndicator.present(title: "Success", message: "Updated Avatar", preset: .done)
                        SessionManager.instance.user?.getAvatar(callback: {res, err in
                            if err == 0 {
                                self.userAvatar.image = res
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
    
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: NSDictionary!){
        self.dismiss(animated: true, completion: { () -> Void in
            APIAction.updateAvatar(image: image, callback: {res in
                switch res {
                    case .Success(_):
                        SessionManager.instance.user?.getAvatar(callback: {res, err in
                            if err == 0 {
                                self.userAvatar.image = res
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

class RoomInfoCell : UITableViewCell {
    
}

class ProfileController : FormViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    var imagePicker = UIImagePickerController()
    
    @IBAction func onClickAvatar(){
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = true
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Edit Profile"
        
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
        }.onUpdate{row in
            
        }
        
        let passwordFld = LabelRowFormer<FormLabelCell>()
            .configure { row in
                row.text = "Passowrd"
            }.onSelected{row in
                
            }
        
        let footer = LabelViewFormer<FormLabelFooterView>() { view in
            view.titleLabel.text = SessionManager.instance.user?.uid
            view.titleLabel.textAlignment = .left
        }
        let section = SectionFormer(rowFormer: nicknameLabel, passwordFld)
            .set(footerViewFormer: footer)
        
        former.append(sectionFormer: section)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
}

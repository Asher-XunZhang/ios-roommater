//
//  ViewController.swift
//  Roommater
//
//  Created by KAMIKU on 10/5/21.
//

import UIKit

class LoginViewController: PrototypeViewController {
    @IBOutlet var Username: NoNullTextField!
    @IBOutlet var Password: NoNullTextField!
    @IBOutlet var Login: PrototypeButton!
    @IBOutlet var loadingBar: UIActivityIndicatorView!

    @IBAction func login(_ sender: PrototypeButton){
        loginAction()
    }
    
    func loginAction(){
        Login.notAvailableAction()
        loading()
        Roommater.login(
            username: Username.text!,
            pass: Password.text!
        )
    }
    
    func loading(){
        Login.setTitleColor(.clear, for: .normal)
        loadingBar.startAnimating()
    }
    
    override func viewLoadAction() {
        textFieldAction()
    }
    
    override func textFieldAction() {
        if !(Username.text!.isEmpty) && !(Password.text!.isEmpty){
            Login.availableAction()
        }else{
            Login.notAvailableAction()
        }
    }
    
    override func textFieldDone(_ textField: UITextField) {
        textField.resignFirstResponder()
        loginAction()
    }
}



class SignupViewController: PrototypeViewController{
    @IBOutlet var Username: NoNullTextField!
    @IBOutlet var Password: NoNullTextField!
    @IBOutlet var RePassword: NoNullTextField!
    @IBOutlet var Email: NoNullTextField!
    
    
    @IBOutlet var noticeU: UILabel!
    @IBOutlet var noticeP: UILabel!
    @IBOutlet var noticeRP: UILabel!
    @IBOutlet var noticeE: UILabel!
    
    
    @IBOutlet var Signup: PrototypeButton!
    @IBOutlet var loadingBar: UIActivityIndicatorView!
    
    
    @IBAction func signup(_ sender: UIButton){
        signupAction()
    }
    @IBAction func back(_ sender: UIButton){
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func passwordChangedAction(_ sender: UITextField){
        self.RePassword.text = ""
        self.noticeRP.isHidden = true
    }
    override func textFieldAction() {
        if !(Username.text!.isEmpty), !(Password.text!.isEmpty), !(RePassword.text!.isEmpty), !(Email.text!.isEmpty), checkRePassword(){
            Signup.availableAction()
        }else{
            Signup.notAvailableAction()
        }
    }
    
    func signupAction(){
        Signup.notAvailableAction()
        loading()
        Roommater.signup(
            username: Username.text!,
            pass: Password.text!,
            email: Email.text!
        )
    }
    private func checkUsername()->Bool{
        return true
    }
    private func checkPassword()->Bool{
        return true
    }
    private func checkRePassword()->Bool{
        return RePassword.text! == Password.text!
    }
    private func checkEmail()->Bool{
        return true
    }
    
    
    override func textFieldAvailableCheck()->Bool{
        return UsernameTextFieldCheckAction() && PasswordTextFieldCheckAction() && RePasswordTextFieldCheckAction() && EmailTextFieldCheckAction()
    }
    
    private func UsernameTextFieldCheckAction() -> Bool {
        noticeU.isHidden = checkUsername()
        return noticeRP.isHidden
    }
    private func PasswordTextFieldCheckAction() -> Bool {
        noticeP.isHidden = checkPassword()
        return noticeP.isHidden
    }
    private func RePasswordTextFieldCheckAction() -> Bool {
        noticeRP.isHidden = checkRePassword()
        return noticeE.isHidden
    }
    private func EmailTextFieldCheckAction() -> Bool {
        noticeE.isHidden = checkEmail()
        return noticeE.isHidden
    }
    
    func loading(){
        Signup.setTitleColor(.clear, for: .normal)
        loadingBar.isHidden = false
        loadingBar.startAnimating()
    }
    
    override func viewLoadAction() {
        textFieldAction()
        noticeRP.isHidden = true
        loadingBar.isHidden = true
    }
    
    override func textFieldDone(_ textField: UITextField) {
        textField.resignFirstResponder()
        signupAction()
    }
    
}



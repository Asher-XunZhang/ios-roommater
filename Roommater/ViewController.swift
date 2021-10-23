//
//  ViewController.swift
//  Roommater
//
//  Created by KAMIKU on 10/5/21.
//

import UIKit
import SPIndicator

class LoginViewController: PrototypeViewController {

    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var passwordLabel: UILabel!

    @IBOutlet var usernameTextField: NoNullTextField!
    @IBOutlet var passwordTextField: NoNullTextField!

    @IBOutlet var forgotPassword: UIButton!
    @IBOutlet var jumpToSignUp: UIButton!
    @IBOutlet var login: PrototypeButton!

    @IBOutlet var loadingBar: UIActivityIndicatorView!

    @IBAction func login(_ sender: PrototypeButton){
        loginAction()
    }

    func loginAction(){
        login.notAvailableAction()
        loading()
        exec()
    }

    func handle(res: Result, err: Error?){
        if let e = err {
            //TODO: Error Handel
            print(e)
        }
        switch res{
            case .Success:
                Login.availableAction()
                loadingBar.stopAnimating()
            case .Fail(let msg), .Timeout(let msg), .Error(let msg):
                SPIndicator.present(title: "Error", message: msg, preset: .error)
                self.Login.isEnabled = true
            case .NONE:
                print("None")
        }
    }

    func exec(){
        APIAction.login(username: Username.text!, pass: Password.text!, callback: handle)
    }

    func loading(){
        login.setTitleColor(.clear, for: .normal)
        loadingBar.startAnimating()
    }
    
    override func viewLoadAction() {
        let labelHeight = usernameLabel.frame.maxY - usernameLabel.frame.minY
        let textFieldHeight = usernameTextField.frame.maxY - usernameTextField.frame.minY

        usernameLabel.frame.origin.y = HEIGHT/3
        usernameTextField.frame.origin.y = usernameLabel.frame.origin.y + labelHeight/2 + textFieldHeight/2 + 10
        passwordLabel.frame.origin.y = usernameTextField.frame.maxY + 10 + labelHeight/2
        forgotPassword.frame.origin.y = passwordLabel.frame.origin.y
        passwordTextField.frame.origin.y = passwordLabel.frame.origin.y + labelHeight/2 + textFieldHeight/2 + 10
        login.frame.origin.y = passwordTextField.frame.maxY + textFieldHeight
        loadingBar.frame.origin.y = login.frame.origin.y
        jumpToSignUp.frame.origin.y = login.frame.maxY + textFieldHeight

        textFieldAction()
    }
    
    override func textFieldAction() {
        if !(usernameTextField.text!.isEmpty) && !(passwordTextField.text!.isEmpty){
            login.availableAction()
        }else{
            login.notAvailableAction()
        }
    }
    
    override func textFieldDone(_ textField: UITextField) {
        textField.resignFirstResponder()
        loginAction()
    }
}

class SignupViewController: PrototypeViewController{
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var passwordLabel: UILabel!
    @IBOutlet var rePasswordLabel: UILabel!
    @IBOutlet var emailLabel: UILabel!

    @IBOutlet var usernameTextField: UsernameTextField!
    @IBOutlet var passwordTextField: PasswordTextField!
    @IBOutlet var rePasswordTextField: RePasswordTextField!
    @IBOutlet var emailTextField: EmailTextField!

    @IBOutlet var noticeU: UILabel!
    @IBOutlet var noticeP: UILabel!
    @IBOutlet var noticeRP: UILabel!
    @IBOutlet var noticeE: UILabel!

    @IBOutlet var backLogin: UIButton!
    @IBOutlet var signup: PrototypeButton!
    @IBOutlet var loadingBar: UIActivityIndicatorView!


    
    @IBAction func signup(_ sender: UIButton){
        signupAction()
    }

    @IBAction func back(_ sender: UIButton){
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func passwordChangedAction(_ sender: UITextField){
        self.rePasswordTextField.text = ""
        self.noticeRP.isHidden = true
    }

    override func textFieldAction() {
        if !(usernameTextField.text!.isEmpty), !(passwordTextField.text!.isEmpty), !(rePasswordTextField.text!.isEmpty), !(emailTextField.text!.isEmpty), checkRePassword(){
            signup.availableAction()
        }else{
            signup.notAvailableAction()
        }
    }
    
    func signupAction(){
        signup.notAvailableAction()
        loading()
        exec()
    }

    private func checkUsername()->Bool{
        // TODO: add regex condition
        return true
    }
    private func checkPassword()->Bool{
        // TODO: add regex condition
        return true
    }
    private func checkRePassword()->Bool{
        return rePasswordTextField.text! == passwordTextField.text!
    }
    private func checkEmail()->Bool{
        // TODO: add regex condition
        return true
    }


    func UsernameTextFieldCheckAction() -> Bool {
        noticeU.isHidden = checkUsername()
        return noticeRP.isHidden
    }

    func PasswordTextFieldCheckAction() -> Bool {
        noticeP.isHidden = checkPassword()
        return noticeP.isHidden
    }

    func RePasswordTextFieldCheckAction() -> Bool {
        noticeRP.isHidden = checkRePassword()
        return noticeE.isHidden
    }

    func EmailTextFieldCheckAction() -> Bool {
        noticeE.isHidden = checkEmail()
        return noticeE.isHidden
    }

    func loading(){
        signup.setTitleColor(.clear, for: .normal)
        loadingBar.isHidden = false
        loadingBar.startAnimating()
    }

    override func textFieldAvailableCheck(_ textField: UITextField)->Bool{
        if textField.isKind(of: UsernameTextField.self) {
            return UsernameTextFieldCheckAction()
        }else if textField.isKind(of: PasswordTextField.self){
            return PasswordTextFieldCheckAction()
        }else if textField.isKind(of: RePasswordTextField.self){
            return RePasswordTextFieldCheckAction()
        }else if textField.isKind(of: EmailTextField.self){
            return EmailTextFieldCheckAction()
        }
        return false
    }

    override func viewLoadAction() {
        let buttonHeight =  backLogin.frame.height
        let labelHeight = usernameLabel.frame.height
        let textFieldHeight = usernameTextField.frame.height
        let noticeHeight = noticeU.frame.height

        backLogin.frame.origin.y = HEIGHT/30 + buttonHeight/2

        usernameLabel.frame.origin.y =  backLogin.frame.maxY + noticeHeight/2
        usernameTextField.frame.origin.y =  usernameLabel.frame.maxY + 10
        noticeU.frame.origin.y = usernameTextField.frame.maxY

        passwordLabel.frame.origin.y =  noticeU.frame.maxY
        passwordTextField.frame.origin.y =  passwordLabel.frame.maxY + 10
        noticeP.frame.origin.y = passwordTextField.frame.maxY

        rePasswordLabel.frame.origin.y =  noticeP.frame.maxY
        rePasswordTextField.frame.origin.y =  rePasswordLabel.frame.maxY + 10
        noticeRP.frame.origin.y = rePasswordTextField.frame.maxY

        emailLabel.frame.origin.y =  noticeRP.frame.maxY - 5
        emailTextField.frame.origin.y =  emailLabel.frame.maxY + 10
        noticeE.frame.origin.y = emailTextField.frame.maxY

        signup.frame.origin.y = noticeE.frame.maxY
        loadingBar.frame.origin.y = signup.frame.origin.y

        textFieldAction()
        noticeU.isHidden = true
        noticeP.isHidden = true
        noticeRP.isHidden = true
        noticeE.isHidden = true
        loadingBar.isHidden = true
    }

    override func textFieldDone(_ textField: UITextField) {
        textField.resignFirstResponder()
        signupAction()
    }

    func exec(){
        APIAction.signup(username: Username.text!, pass: Password.text!,email: Email.text!, callback: { res, err in
            if let e = err {
                //TODO: Error Handel
                print(e)
            }
            switch res{
            case .Success(let data):
                print(data?.status ?? 600)
            case .Fail(let msg), .Timeout(let msg), .Error(let msg):
                print(msg)
            case .NONE:
                print("None")
            }
        })
    }
}

class ForgotPasswordViewController: PrototypeViewController{
    @IBOutlet var backToLoginButton: PrototypeButton!
    @IBOutlet var emailLabel: UILabel!
    @IBOutlet var emailRecoveryTextField: EmailTextField!
    @IBOutlet var emailNotice: UILabel!

    @IBOutlet var resetButton: PrototypeButton!
    @IBOutlet var loadingBar: UIActivityIndicatorView!

    func resetAction(){
        loading()
        resetButton.notAvailableUI()
//        forgot(email: emailRecoveryTextField.text!, callback: {})
    }

    @IBAction func reset(_ sender: UIButton){
        resetAction()
    }


    @IBAction func back(_ sender: UIButton){
        self.dismiss(animated: true, completion: nil)
    }

    func loading(){
        resetButton.setTitleColor(.clear, for: .normal)
        loadingBar.isHidden = false
        loadingBar.startAnimating()
    }

    override func viewLoadAction() {
        let buttonHeight =  backToLoginButton.frame.height
        let labelHeight = emailLabel.frame.height
        let textFieldHeight = emailRecoveryTextField.frame.height
        let noticeHeight = emailNotice.frame.height

        backToLoginButton.frame.origin.y = HEIGHT/30 + buttonHeight/2


        emailLabel.frame.origin.y = backToLoginButton.frame.maxY + noticeHeight/2
        emailRecoveryTextField.frame.origin.y =  emailLabel.frame.maxY + 10
        emailNotice.frame.origin.y = emailRecoveryTextField.frame.maxY

        resetButton.frame.origin.y = emailNotice.frame.maxY
        loadingBar.frame.origin.y = resetButton.frame.origin.y

        textFieldAction()
        emailNotice.isHidden =  true
    }

    override func textFieldAvailableCheck(_ textField: UITextField)->Bool{
        if textField.isKind(of: EmailTextField.self){
            return EmailTextFieldCheckAction()
        }
        return false
    }

    private func checkEmail() -> Bool{
        // TODO: add regex condition
        return true
    }

    func EmailTextFieldCheckAction() -> Bool {
        emailNotice.isHidden = checkEmail()
        return emailNotice.isHidden
    }

    override func textFieldAction() {
        if !(emailRecoveryTextField.text!.isEmpty) && checkEmail(){
            resetButton.availableAction()
        }else{
            resetButton.notAvailableAction()
        }
    }

    override func textFieldDone(_ textField: UITextField) {
        textField.resignFirstResponder()
        resetAction()
    }
}

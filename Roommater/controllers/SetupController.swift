//
//  ViewController.swift
//  Roommater
//
//  Created by KAMIKU on 10/5/21.
//

import UIKit
import SPIndicator
import SkyFloatingLabelTextField

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
                login.availableAction()
                
            case .Fail(let msg), .Timeout(let msg), .Error(let msg):
                SPIndicator.present(title: "Error", message: msg, preset: .error)
                self.login.availableUI()
                loadingBar.stopAnimating()
                self.enableAllTextField()
            case .NONE:
                print("None")
        }
    }

    func exec(){
        APIAction.login(username: usernameTextField.text!, pass: passwordTextField.text!, callback: handle)
    }

    func loading(){
        login.setTitleColor(.clear, for: .normal)
        loadingBar.startAnimating()
    }
    func unloading(){
        login.notAvailableUI()
        loadingBar.stopAnimating()
    }
    
    
    override func viewLoadAction() {
        let labelHeight = usernameLabel.frame.maxY - usernameLabel.frame.minY
        let textFieldHeight = usernameTextField.frame.maxY - usernameTextField.frame.minY
        

        usernameLabel.frame.origin.y = HEIGHT/3
        
        usernameTextField.frame.origin.x = WIDTH/2 - usernameTextField.frame.width/2
        usernameTextField.frame.origin.y = usernameLabel.frame.origin.y + labelHeight/2 + textFieldHeight/2 + 10
        usernameLabel.frame.origin.x = usernameTextField.frame.origin.x
        
        passwordLabel.frame.origin.y = usernameTextField.frame.maxY + 10 + labelHeight/2
        
        forgotPassword.frame.origin.y = passwordLabel.frame.origin.y
        
        passwordTextField.frame.origin.x = WIDTH/2 - passwordTextField.frame.width/2
        passwordTextField.frame.origin.y = passwordLabel.frame.origin.y + labelHeight/2 + textFieldHeight/2 + 10
        passwordLabel.frame.origin.x = passwordTextField.frame.origin.x
        forgotPassword.frame.origin.x = passwordTextField.frame.maxX-forgotPassword.frame.width
        
        login.frame.origin.x = WIDTH/2 - login.frame.width/2
        login.frame.origin.y = passwordTextField.frame.maxY + textFieldHeight
        
        loadingBar.frame.origin.x = WIDTH/2 - loadingBar.frame.width/2
        loadingBar.frame.origin.y = passwordTextField.frame.maxY + textFieldHeight
        
        jumpToSignUp.frame.origin.x = WIDTH/2 - jumpToSignUp.frame.width/2
        jumpToSignUp.frame.origin.y = login.frame.maxY + textFieldHeight

        login.notAvailableAction()
    }
    
    override func textFieldAction(_ textField: UITextField) {
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

    override func textFieldAction(_ textField: UITextField) {
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
        
        backLogin.frame.origin.x = WIDTH/2 - backLogin.frame.width/2
        backLogin.frame.origin.y = HEIGHT/30 + buttonHeight/2

        usernameLabel.frame.origin.y =  backLogin.frame.maxY + noticeHeight/2
        
        usernameTextField.frame.origin.x = WIDTH/2 - usernameTextField.frame.width/2
        usernameTextField.frame.origin.y =  usernameLabel.frame.maxY + 10
        usernameLabel.frame.origin.x = usernameTextField.frame.origin.x
        
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

        signup.notAvailableAction()
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
        APIAction.signup(username: usernameTextField.text!, pass: passwordTextField.text!,email: emailTextField.text!, callback: { res, err in
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
    @IBOutlet var emailTextField: SkyFloatingLabelTextField!

    @IBOutlet var resetButton: PrototypeButton!
    @IBOutlet var loadingBar: UIActivityIndicatorView!

    func resetAction(){
        resetButton.notAvailableUI()
        loading()
//        forgot(email: emailTextField.text!, callback: {})
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
        let textFieldHeight = emailTextField.frame.height
        
        
        backToLoginButton.frame.origin.x = WIDTH/2 - backToLoginButton.frame.width/2
        backToLoginButton.frame.origin.y = HEIGHT/30 + buttonHeight/2

        emailLabel.frame.origin.x = WIDTH/2 - emailLabel.frame.width/2
        emailLabel.frame.origin.y = backToLoginButton.frame.maxY
        emailTextField.frame.origin.x = WIDTH/2 - emailTextField.frame.width/2
        emailTextField.frame.origin.y =  emailLabel.frame.maxY
        
        emailTextField.placeholder = "E-mail"
        emailTextField.title = "Your E-mail Address"
        emailTextField.tintColor = overcastBlueColor
        emailTextField.errorColor = .red
        emailTextField.selectedTitleColor = overcastBlueColor
        emailTextField.selectedLineColor = overcastBlueColor
        emailTextField.addTarget(self, action: #selector(textFieldAction(_:)), for: .editingDidEnd)
        
        resetButton.frame.origin.x = emailTextField.frame.midX - resetButton.frame.width/2
        resetButton.frame.origin.y = emailTextField.frame.maxY + textFieldHeight/2
        resetButton.frame.origin.x = emailTextField.frame.midX - resetButton.frame.width/2
        loadingBar.frame.origin.y = emailTextField.frame.maxY + textFieldHeight/2
        resetButton.notAvailableUI()
    }
    
    override func textFieldAvailableCheck(_ textField: UITextField)->Bool{
        if textField.isKind(of: SkyFloatingLabelTextField.self){
            return EmailTextFieldCheckAction()
        }
        return false
    }

    private func checkEmail() -> Bool{
        return mailMatcher.match(input: emailTextField.text!)
    }

    func EmailTextFieldCheckAction() -> Bool {
        if checkEmail() {
            emailTextField.errorMessage = ""
        }else{
            emailTextField.errorMessage = "Invalid email format"
        }
        return checkEmail()
    }

    override func textFieldAction(_ textField: UITextField) {
        if !(emailTextField.text!.isEmpty) && EmailTextFieldCheckAction(){
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

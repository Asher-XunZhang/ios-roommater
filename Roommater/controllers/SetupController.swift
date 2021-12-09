//
//  ViewController.swift
//  Roommater
//
//  Created by KAMIKU on 10/5/21.
//

import UIKit
import SPIndicator
import SkyFloatingLabelTextField
import TransitionButton

class AuthNavVC : UINavigationController {
    override func viewDidLoad() {
        if let token = UserDefaults.standard.string(forKey: "token") {
            self.performSegue(withIdentifier: "dashboardPage", sender: nil)
            APIAction.login(token: token, callback: {res in
                switch res {
                    case .Success:
                        break
                    case .Fail(let msg), .Timeout(let msg), .Error(let msg):
                        SPIndicator.present(title: "Session Out", message: msg, preset: .done)
                        UserDefaults.standard.removeObject(forKey: "token")
                        self.popViewController(animated: true)
                    case .NONE:
                        UserDefaults.standard.removeObject(forKey: "token")
                        self.popViewController(animated: true)
                }
            })
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "dashboardPage"{
            
        }
    }
}

class LoginViewController: PrototypeViewController {
    @IBOutlet var usernameTextField: SkyFloatingLabelTextField!
    @IBOutlet var passwordTextField: SkyFloatingLabelTextField!

    @IBOutlet var forgotPassword: UIButton!
    @IBOutlet var jumpToSignUp: UIButton!
    @IBOutlet var login: TransitionButton!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "dashboardPage" {
            
        }
    }
    

    func handle(res: Result){
        switch res{
            case .Success(let data):
                // redirect to another storyboard with name is "App"
                login.stopAnimation(animationStyle: .expand, completion: {
                    self.navigationController?.performSegue(withIdentifier: "dashboardPage", sender: data)})
            case .Fail(let msg), .Timeout(let msg), .Error(let msg):
                login.stopAnimation(animationStyle: .shake, completion: {
                    SPIndicator.present(title: "Error", message: msg, preset: .error)
                    self.enableAllTextField()
                })
            case .NONE:
                print("None")
        }
    }

    func exec(){
        self.disableAllTextField()
        APIAction.login(username: usernameTextField.text!, pass: passwordTextField.text!, callback: handle)
    }
    
    override func viewLoadAction() {
        let textFieldHeight = usernameTextField.frame.maxY - usernameTextField.frame.minY

        usernameTextField.frame.origin.x = WIDTH/2 - usernameTextField.frame.width/2
        usernameTextField.frame.origin.y = HEIGHT/3
        
        usernameTextField.tag = 0
        usernameTextField.returnKeyType = .next
        usernameTextField.enablesReturnKeyAutomatically = true
        usernameTextField.spellCheckingType = .no
        usernameTextField.clearButtonMode = .whileEditing
        usernameTextField.placeholder = "Username"
        usernameTextField.title = "Your Username"
        usernameTextField.tintColor = overcastBlueColor
        usernameTextField.errorColor = .red
        usernameTextField.selectedTitleColor = overcastBlueColor
        usernameTextField.selectedLineColor = overcastBlueColor
        usernameTextField.addTarget(self, action: #selector(textFieldAction(_:)), for: .editingChanged)
        

        forgotPassword.frame.origin.y = usernameTextField.frame.maxY + textFieldHeight/2

        passwordTextField.frame.origin.x = WIDTH/2 - passwordTextField.frame.width/2
        passwordTextField.frame.origin.y = usernameTextField.frame.maxY + textFieldHeight

        forgotPassword.frame.origin.x = passwordTextField.frame.maxX-forgotPassword.frame.width
        
        passwordTextField.tag = 1
        
        passwordTextField.returnKeyType = .done
        passwordTextField.enablesReturnKeyAutomatically = true
        passwordTextField.spellCheckingType = .no
        passwordTextField.clearButtonMode = .whileEditing
        passwordTextField.isSecureTextEntry = true
        passwordTextField.placeholder = "Password"
        passwordTextField.title = "Your Password"
        passwordTextField.tintColor = overcastBlueColor
        passwordTextField.errorColor = .red
        passwordTextField.selectedTitleColor = overcastBlueColor
        passwordTextField.selectedLineColor = overcastBlueColor
        passwordTextField.addTarget(self, action: #selector(textFieldAction(_:)), for: .editingChanged)
        
        
        login.frame.origin.x = WIDTH/2 - login.frame.width/2
        login.frame.origin.y = passwordTextField.frame.maxY + textFieldHeight
        
        login.setTitle("Login", for: .normal)
        login.cornerRadius = 20
        disableLoginButton()
        login.addTarget(self, action: #selector(buttonAction(_:)), for: .touchUpInside)
        
        jumpToSignUp.frame.origin.x = WIDTH/2 - jumpToSignUp.frame.width/2
        jumpToSignUp.frame.origin.y = login.frame.maxY + textFieldHeight
    }
    
    func disableLoginButton(){
        login.backgroundColor = .systemGray5
        login.isUserInteractionEnabled = false
        login.spinnerColor = .systemGray3
    }
    func enableLoginButton(){
        login.backgroundColor = overcastBlueColor
        login.isUserInteractionEnabled = true
        login.spinnerColor = .white
    }
    
    private func checkUsername() -> Bool{
        return usernameMatcher.match(input: usernameTextField.text!)
    }
    private func checkPassword() -> Bool{
        return passwordMatcher.match(input: passwordTextField.text!)
    }
    
    func checkTextFieldAction(_ textField: UITextField) -> Bool{
        if(textField.isKind(of: SkyFloatingLabelTextField.self)){
            switch(textField.tag){
            case 0:
                usernameTextField.errorMessage = checkUsername() ? "" : "Invalid Username"
                return checkUsername()
            case 1:
                passwordTextField.errorMessage = checkPassword() ? "" : "Invalid Password"
                return checkPassword()
            default:
                return false
            }
        }
        return false
    }
    
    override func textFieldAction(_ textField: UITextField) {
        if checkTextFieldAction(textField), checkUsername(), checkPassword(){
            enableLoginButton()
        }else{
            disableLoginButton()
        }
    }
    
    @IBAction func buttonAction(_ button: TransitionButton) {
        login.startAnimation()
        exec()
    }
    
    override func textFieldDone(_ textField: UITextField) {
        textField.resignFirstResponder()
//        buttonAction(login)
    }
}

class SignupViewController: PrototypeViewController{

    @IBOutlet var usernameTextField: SkyFloatingLabelTextField!
    @IBOutlet var passwordTextField: SkyFloatingLabelTextField!
    @IBOutlet var rePasswordTextField: SkyFloatingLabelTextField!
    @IBOutlet var emailTextField: SkyFloatingLabelTextField!

    @IBOutlet var backLogin: UIButton!
    @IBOutlet var signup: TransitionButton!

    func disableSignupButton(){
        signup.backgroundColor = .systemGray5
        signup.isUserInteractionEnabled = false
        signup.spinnerColor = .systemGray3
    }
    func enableSignupButton(){
        signup.backgroundColor = overcastBlueColor
        signup.isUserInteractionEnabled = true
        signup.spinnerColor = .white
    }
    
    func exec(){
        self.disableAllTextField()
        APIAction.signup(username: usernameTextField.text!, pass: passwordTextField.text!,email: emailTextField.text!){ res in
            switch res{
                case .Success(_):
                    self.signup.stopAnimation(animationStyle: .expand, completion: {
                        self.navigationController?.popViewController(animated: true)
                        SPIndicator.present(title: "Success", message: "Successfully send! Please check your email!", preset: .done)
                    })
                case .Fail(let msg), .Timeout(let msg), .Error(let msg), .NONE(let msg):
                    self.signup.stopAnimation(animationStyle: .shake, completion: {SPIndicator.present(title: msg, preset: .error)})
            }
        }
    }
    
    @IBAction func buttonAction(_ button: TransitionButton) {
        signup.startAnimation()
        exec()
    }
    
    @IBAction func back(_ sender: UIButton){
        self.navigationController?.popViewController(animated: true)
    }

    override func textFieldAction(_ textField: UITextField) {
        if checkTextFieldAction(textField), checkUsername(), checkPassword(), checkRePassword(), checkEmail(){
            enableSignupButton()
        }else{
            disableSignupButton()
        }
    }
    
    func checkTextFieldAction(_ textField: UITextField)->Bool{
        if(textField.isKind(of: SkyFloatingLabelTextField.self)){
            switch(textField.tag){
            case 0:
                usernameTextField.errorMessage = checkUsernameStr()
                return (checkUsernameStr() == "")
            case 1:
                passwordTextField.errorMessage = checkPasswordStr()
                return (checkPasswordStr() == "")
            case 2:
                rePasswordTextField.errorMessage = checkRePassword() ? "" : "Different from Password"
                return checkRePassword()
            case 3:
                emailTextField.errorMessage = checkEmail() ? "" : "Invalid Email Address"
                return checkEmail()
            default:
                return false
            }
        }
        return false
        
    }
    
    private func checkUsernameStr()->String{
        if !(usernameMatcher.match(input: usernameTextField.text!)){
            let errmsg = "Username "
            if !(noSpecialCharMatcher.match(input: usernameTextField.text!)) {
                return errmsg + regexErrMsg["noSpeChar"]!
            }
            if !(lower4LimitedMatcher.match(input: usernameTextField.text!)) {
                return errmsg + regexErrMsg["lower4Limited"]!
            }
            if !(upperLimitedMatcher.match(input: usernameTextField.text!)) {
                return errmsg + regexErrMsg["upperLimited"]!
            }
        }
        return ""
    }
    
    private func checkPasswordStr()->String{
        rePasswordTextField.text! = ""
        if !(passwordMatcher.match(input: passwordTextField.text!)){
            let errmsg = "Password "
            if !(specialCharRequireMatcher.match(input: passwordTextField.text!)) {
                return errmsg + regexErrMsg["speChar"]!
            }
            if !(digitRequireMatcher.match(input: passwordTextField.text!)) {
                return errmsg + regexErrMsg["digit"]!
            }
            if !(uppercaseRequireMatcher.match(input: passwordTextField.text!)) {
                return errmsg + regexErrMsg["uppercase"]!
            }
            if !(lowercaseRequireMatcher.match(input: passwordTextField.text!)) {
                return errmsg + regexErrMsg["lowercase"]!
            }
            if !(lower8LimitedMatcher.match(input: passwordTextField.text!)) {
                return errmsg + regexErrMsg["lower8Limited"]!
            }
            if !(upperLimitedMatcher.match(input: usernameTextField.text!)) {
                return errmsg + regexErrMsg["upperLimited"]!
            }
        }
        return ""
    }
    
    private func checkUsername()->Bool{
        return usernameMatcher.match(input: usernameTextField.text!)
    }
    private func checkPassword()->Bool{
        return passwordMatcher.match(input: passwordTextField.text!)
    }
    private func checkRePassword()->Bool{
        return rePasswordTextField.text! == passwordTextField.text!
    }
    private func checkEmail()->Bool{
        return emailMatcher.match(input: emailTextField.text!)
    }
    

    override func viewLoadAction() {
        let buttonHeight =  backLogin.frame.height
        let textFieldHeight = usernameTextField.frame.height

        backLogin.frame.origin.x = WIDTH/2 - backLogin.frame.width/2
        backLogin.frame.origin.y = HEIGHT/30 + buttonHeight/2
        
        
        usernameTextField.frame.origin.x = WIDTH/2 - usernameTextField.frame.width/2
        usernameTextField.frame.origin.y =  backLogin.frame.maxY + textFieldHeight/2
        usernameTextField.tag = 0
        usernameTextField.returnKeyType = .next
        usernameTextField.enablesReturnKeyAutomatically = true
        usernameTextField.spellCheckingType = .no
        usernameTextField.clearButtonMode = .whileEditing
        usernameTextField.placeholder = "Username"
        usernameTextField.title = "Your Username"
        usernameTextField.tintColor = overcastBlueColor
        usernameTextField.errorColor = .red
        usernameTextField.selectedTitleColor = overcastBlueColor
        usernameTextField.selectedLineColor = overcastBlueColor
        usernameTextField.addTarget(self, action: #selector(textFieldAction(_:)), for: .editingChanged)
        
        passwordTextField.frame.origin.x = WIDTH/2 - passwordTextField.frame.width/2
        passwordTextField.frame.origin.y =  usernameTextField.frame.maxY + textFieldHeight/4
        passwordTextField.tag = 1
        passwordTextField.returnKeyType = .next
        passwordTextField.spellCheckingType = .no
        passwordTextField.enablesReturnKeyAutomatically = true
        passwordTextField.clearButtonMode = .whileEditing
        passwordTextField.isSecureTextEntry = true
        passwordTextField.placeholder = "Password"
        passwordTextField.title = "Your Password"
        passwordTextField.tintColor = overcastBlueColor
        passwordTextField.errorColor = .red
        passwordTextField.selectedTitleColor = overcastBlueColor
        passwordTextField.selectedLineColor = overcastBlueColor
        passwordTextField.addTarget(self, action: #selector(textFieldAction(_:)), for: .editingChanged)

        rePasswordTextField.frame.origin.x = WIDTH/2 - rePasswordTextField.frame.width/2
        rePasswordTextField.frame.origin.y =  passwordTextField.frame.maxY + textFieldHeight/4
        rePasswordTextField.tag = 2
        rePasswordTextField.returnKeyType = .next
        rePasswordTextField.spellCheckingType = .no
        rePasswordTextField.enablesReturnKeyAutomatically = true
        rePasswordTextField.clearButtonMode = .whileEditing
        rePasswordTextField.isSecureTextEntry = true
        rePasswordTextField.placeholder = "Confirm Password"
        rePasswordTextField.title = "Confirm Password"
        rePasswordTextField.tintColor = overcastBlueColor
        rePasswordTextField.errorColor = .red
        rePasswordTextField.selectedTitleColor = overcastBlueColor
        rePasswordTextField.selectedLineColor = overcastBlueColor
        rePasswordTextField.addTarget(self, action: #selector(textFieldAction(_:)), for: .editingChanged)
        
        
        emailTextField.frame.origin.x = WIDTH/2 - emailTextField.frame.width/2
        emailTextField.frame.origin.y =  rePasswordTextField.frame.maxY + textFieldHeight/4
        emailTextField.tag = 3
        emailTextField.returnKeyType = .done
        emailTextField.spellCheckingType = .no
        emailTextField.enablesReturnKeyAutomatically = true
        emailTextField.clearButtonMode = .whileEditing
        emailTextField.spellCheckingType = .no
        emailTextField.placeholder = "E-mail"
        emailTextField.title = "Your E-mail"
        emailTextField.tintColor = overcastBlueColor
        emailTextField.errorColor = .red
        emailTextField.selectedTitleColor = overcastBlueColor
        emailTextField.selectedLineColor = overcastBlueColor
        emailTextField.addTarget(self, action: #selector(textFieldAction(_:)), for: .editingChanged)
        
        signup.frame.origin.y = emailTextField.frame.maxY + textFieldHeight/4
        signup.frame.origin.x = WIDTH/2 - signup.frame.width/2
        signup.setTitle("Signup", for: .normal)
        signup.cornerRadius = 20
        
        disableSignupButton()
        signup.addTarget(self, action: #selector(buttonAction(_:)), for: .touchUpInside)
    }

    override func textFieldDone(_ textField: UITextField) {
        textField.resignFirstResponder()
//        buttonAction(signup)
    }
}

class ForgotPasswordViewController: PrototypeViewController{
    @IBOutlet var backToLoginButton: PrototypeButton!
    @IBOutlet var emailLabel: UILabel!
    @IBOutlet var emailTextField: SkyFloatingLabelTextField!

    @IBOutlet var resetButton: TransitionButton!
    
    func exec(){
        self.disableAllTextField()
        APIAction.forgot(email: emailTextField.text!, callback:handle)
    }
    
    func handle(res: Result){
        switch res{
        case .Success(_):
            self.resetButton.stopAnimation(animationStyle: .expand, completion: {
                self.navigationController?.popViewController(animated: true)
                SPIndicator.present(title: "Success", message: "Successfully send! Please check your email!", preset: .done)
            })
        case .Fail(let msg), .Timeout(let msg), .Error(let msg):
            self.resetButton.stopAnimation(animationStyle: .shake, completion: {
                SPIndicator.present(title: "Error", message: msg, preset: .error)
                self.enableAllTextField()
            })
        case .NONE:
            print("None")
        }
    }

    func disableResetButton(){
        resetButton.backgroundColor = .systemGray5
        resetButton.isUserInteractionEnabled = false
        resetButton.spinnerColor = .systemGray3
    }
    func enableResetButton(){
        resetButton.backgroundColor = overcastBlueColor
        resetButton.isUserInteractionEnabled = true
        resetButton.spinnerColor = .white
    }
    
    @IBAction func buttonAction(_ button: TransitionButton) {
        resetButton.startAnimation()
        exec()
    }

    @IBAction func back(_ sender: UIButton){
        self.navigationController?.popViewController(animated: true)
    }


    override func viewLoadAction() {
        
        let buttonHeight =  backToLoginButton.frame.height
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
        emailTextField.returnKeyType  = .done
        emailTextField.enablesReturnKeyAutomatically = true
        emailTextField.spellCheckingType = .no
        emailTextField.selectedTitleColor = overcastBlueColor
        emailTextField.selectedLineColor = overcastBlueColor
        emailTextField.addTarget(self, action: #selector(textFieldAction(_:)), for: .editingChanged)

        resetButton.frame.origin.x = emailTextField.frame.midX - resetButton.frame.width/2
        resetButton.frame.origin.y = emailTextField.frame.maxY + textFieldHeight/2
        resetButton.setTitle("Send", for: .normal)
        resetButton.cornerRadius = 20
        disableResetButton()
        resetButton.addTarget(self, action: #selector(buttonAction(_:)), for: .touchUpInside)
    }

    private func checkEmail() -> Bool{
        return emailMatcher.match(input: emailTextField.text!)
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
        if EmailTextFieldCheckAction(){
            enableResetButton()
        }else{
            disableResetButton()
        }
        
    }

    override func textFieldDone(_ textField: UITextField) {
        textField.resignFirstResponder()
//        buttonAction(resetButton)
    }
}

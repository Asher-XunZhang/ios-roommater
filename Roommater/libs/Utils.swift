//
//  Utils.swift
//  Roommater
//
//  Created by KAMIKU on 12/5/21.
//

import Foundation
import UIKit
import CryptoSwift
import Alamofire
import AlamofireImage

let WIDTH: CGFloat = UIScreen.main.bounds.width
let HEIGHT: CGFloat = UIScreen.main.bounds.height

let emailPattern = "^([a-z0-9_\\.-]+)@([\\da-z\\.-]+)\\.([a-z\\.]{2,6})$"
let emailMatcher = MyRegex(emailPattern)
let usernamePattern = "^[a-zA-Z0-9_-]{4,20}$"
let usernameMatcher = MyRegex(usernamePattern)
let passwordPattern = "^(?=.*[a-z])(?=.*[\\d])(?=.*[A-Z])(?=.*[-!@#$%&*ˆ+=_<>?,\\.;:\\'\\\"\\\\\\]\\[\\}\\{]).{8,20}$"
let passwordMatcher = MyRegex(passwordPattern)


// for username check
let lower4Limited = "^.{4,}$"
let lower4LimitedMatcher = MyRegex(lower4Limited)

let lower8Limited = "^.{8,}$"
let lower8LimitedMatcher = MyRegex(lower8Limited)

let upperLimited = "^.{0,20}$"
let upperLimitedMatcher = MyRegex(upperLimited)

let noSpecialCharacterLimited = "^[A-Z0-9a-z_]+$"
let noSpecialCharMatcher = MyRegex(noSpecialCharacterLimited)

let specialChararcterRequire = "^(?=.*[-!@#$%&*ˆ+=_<>?,\\.;:\\'\\\"\\\\\\]\\[\\}\\{]).*$"
let specialCharRequireMatcher = MyRegex(specialChararcterRequire)

let uppercaseRequire = "^(?=.*[A-Z]).*$"
let uppercaseRequireMatcher = MyRegex(uppercaseRequire)

let lowercaseRequire = "^(?=.*[a-z]).*$"
let lowercaseRequireMatcher = MyRegex(lowercaseRequire)

let digitRequire = "^(?=.*[\\d]).*$"
let digitRequireMatcher = MyRegex(digitRequire)

let regexErrMsg = [
    "lower4Limited": "should be at least 4 characters",
    "lower8Limited": "should be at least 8 characters",
    "upperLimited": "should be at most 20 characters",
    "noSpeChar": "cannot have any special character",
    "speChar": "should have at least 1 special character",
    "lowercase": "should have at least 1 lowercase character",
    "uppercase": "should have at least 1 uppercase character",
    "digit": "should have at least 1 digit"
]


//colors
let overcastBlueColor = UIColor(red: 0, green: 187 / 255, blue: 204 / 255, alpha: 1.0)

func encryptPassword(plain: String) -> String? {
    do {
        return try
        PKCS5.PBKDF2(
                        password: Array(plain.utf8),
                        salt: Array(SessionManager.instance.user!.uid.utf8),
                        iterations: 4096,
                        keyLength: 32,
                        variant: .sha2(.sha256))
                .calculate()
                .toHexString()
    } catch {
        return nil
    }
}

struct MyRegex {
    let regex: NSRegularExpression?

    init(_ pattern: String) {
        regex = try? NSRegularExpression(pattern: pattern)
    }

    func match(input: String) -> Bool {
        if let matches = regex?.matches(in: input,
                options: [],
                range: NSMakeRange(0, (input as NSString).length)) {
            return matches.count > 0
        } else {
            return false
        }
    }
}

extension String {
    static func mediumDateShortTime(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = .current
        dateFormatter.timeStyle = .short
        dateFormatter.dateStyle = .medium
        return dateFormatter.string(from: date)
    }

    static func mediumDateNoTime(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = .current
        dateFormatter.timeStyle = .none
        dateFormatter.dateStyle = .medium
        return dateFormatter.string(from: date)
    }

    static func fullDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = .current
        dateFormatter.timeStyle = .none
        dateFormatter.dateStyle = .full
        return dateFormatter.string(from: date)
    }
}

extension UInt64 {
    func megabytes() -> UInt64 {
        return self * 1024 * 1024
    }
}

extension UIViewController {
    func alert(title: String, msg: String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true)
    }

    func alertWithConfirm(title: String, msg: String, callback: @escaping (UIAlertAction) -> Void) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: callback))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
}

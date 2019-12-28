//
//  Stripe_Constant.swift
//  Intrigued
//
//  Created by SWS on 02/02/18.
//  Copyright © 2018 daniel helled. All rights reserved.
//

import Foundation

let STRIPE_CLIENT_ID = "ca_CR8Vq6PoLlgVrj03rTiqhBKS5QCP9zOV"
let STRIPE_SECRET_KEY = "sk_test_kU5tSZaJxUFwfGVGK2kYtAFX"
//let STRIPE_SECRET_KEY = "sk_test_bty9lbObzGarijyOTq688HLa"
let STRIPE_URL = "https://api.stripe.com/v1/customers/"
let STRIPE_Charge_URL = "http://13.228.52.104:3002"
let kCharge_User:String = "/charge_Insertpayment"
let appDelegateRef = UIApplication.shared.delegate as! AppDelegate




//ravi 14Feb2018
let STRIPE_PAYMENT_URL = "https://api.stripe.com/v1/charges"
let STRIPE_OAUTH_URL = "https://connect.stripe.com/oauth/token"
//let STRIPE_REDIRECT_URI = "http://34.214.26.56/stripeauthredirect"
let STRIPE_REDIRECT_URI = "http://13.228.52.104:3002/stripe_auth_redirect"

let STRIPE_CONNECT = "https://connect.stripe.com/oauth/authorize?response_type=code&scope=read_write&client_id="

let STRIPE_CONNECT_URL = "\(STRIPE_CONNECT)\(STRIPE_CLIENT_ID)&redirect_uri=\(STRIPE_REDIRECT_URI)"

let STRIPE_DEOAUTH_URL = "https://connect.stripe.com/oauth/deauthorize"

let kSTRIPE_CONNECT:String = "/stripeConnect"
let kSTRIPE_DISCONNECT:String = "/stripe_deauthorized"
let SUCCESS_MESSAGE = "Success"
/////////////// Stripe ////////////////////



//MARK: Show AlertView Controller
func showAlerView(title: String, message: String ,self1: UIViewController){
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
    alertController.addAction(okAction)
    self1.present(alertController, animated: false, completion: nil)
}



extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}

extension Decimal {
    var significantFractionalDecimalDigits: Int {
        return max(-exponent, 0)
    }
}


extension UIViewController {
    func showInputDialog(title:String? = nil,
                         subtitle:String? = nil,
                         actionTitle:String? = "Add",
                         cancelTitle:String? = "Cancel",
                         inputPlaceholder:String? = nil,
                         inputKeyboardType:UIKeyboardType = UIKeyboardType.default,
                         cancelHandler: ((UIAlertAction) -> Swift.Void)? = nil,
                         actionHandler: ((_ text: String?) -> Void)? = nil) {
        
        let alert = UIAlertController(title: title, message: subtitle, preferredStyle: .alert)
        alert.addTextField { (textField:UITextField) in
            textField.placeholder = inputPlaceholder
            textField.textAlignment = .center
            textField.keyboardType = inputKeyboardType
        }
        alert.addAction(UIAlertAction(title: actionTitle, style: .destructive, handler: { (action:UIAlertAction) in
            guard let textField =  alert.textFields?.first else {
                actionHandler?(nil)
                return
            }
            actionHandler?(textField.text)
        }))
        alert.addAction(UIAlertAction(title: cancelTitle, style: .cancel, handler: cancelHandler))
        
        self.present(alert, animated: true, completion: nil)
    }
}


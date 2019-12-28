//
//  PassCodeTouch.swift
//  Intrigued
//
//  Created by Shineweb-solutions on 12/01/18.
//  Copyright © 2018 daniel helled. All rights reserved.
//

import UIKit
import LocalAuthentication
import STZPopupView
import IQKeyboardManagerSwift

struct KeychainConfiguration {
    static let serviceName = "SwifttouchId"
    static let accessGroup: String? = nil
}
class PassCodeTouch: UIViewController,UITextFieldDelegate {
    var passwordItems: [KeychainPasswordItem] = []
    var OnePassCodeBtn = UIButton()
    var SecondPassCodeBtn = UIButton()
    var ThirdPassCodeBtn = UIButton()
    var FourPassCodeBtn = UIButton()
    var UnselectImg    = UIImage()
    var SelectImg      = UIImage()
    var sampleTextField:UITextField = UITextField()
    var passcodeStr = String()
    var descLbl = UILabel()
    var ConfirmPassCodeLbl = UILabel()
    var confirmDoneBtn = UIButton()
    var confirmCancelBtn = UIButton()
    var confirmPopUpBaseView = UIView()
    var confirmTextField:UITextField = UITextField()
    
    @IBOutlet weak var HeaderBaseView: UIView!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var headerLbl: UILabel!
    @IBOutlet var baseView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
         IQKeyboardManager.sharedManager().enable = false
        
        baseView.backgroundColor = hexStringToUIColor(hex: "#34a0ce")
        
       baseView.isUserInteractionEnabled = false
      
        let iconImg = UIImage(named: "login_logo")
        let iconImgView = UIImageView(image: iconImg!)
        iconImgView.frame = CGRect(x: (self.view.frame.size.width -  230)/2, y: 60, width: 230, height: 100)
        baseView.addSubview(iconImgView)

        
        let buttonBaseView = UIView(frame: CGRect(x: (self.view.frame.size.width - 240)/2, y: iconImgView.frame.origin.y + iconImgView.frame.size.height + 50 , width: 240, height: 70))
        buttonBaseView.backgroundColor = hexStringToUIColor(hex: "#3398c4")
        buttonBaseView.layer.masksToBounds = true
        buttonBaseView.layer.cornerRadius = 20.0
        baseView.addSubview(buttonBaseView)
        
        
        UnselectImg =  UIImage(named: "unFillCircle")!
        SelectImg =  UIImage(named: "fillCircle")!
        OnePassCodeBtn = UIButton(frame: CGRect(x:24 , y: 20, width: 30, height: 30))
        OnePassCodeBtn.isUserInteractionEnabled = false
        OnePassCodeBtn.setBackgroundImage(UnselectImg, for: .normal)
        buttonBaseView.addSubview(OnePassCodeBtn)
        
        SecondPassCodeBtn = UIButton(frame: CGRect(x:OnePassCodeBtn.frame.size.width + OnePassCodeBtn.frame.origin.x + 24 , y: 20, width: 30, height: 30))
        SecondPassCodeBtn.isUserInteractionEnabled = false
        SecondPassCodeBtn.setBackgroundImage(UnselectImg, for: .normal)
        buttonBaseView.addSubview(SecondPassCodeBtn)
        
        ThirdPassCodeBtn = UIButton(frame: CGRect(x:SecondPassCodeBtn.frame.size.width + SecondPassCodeBtn.frame.origin.x + 24 , y: 20, width: 30, height: 30))
        ThirdPassCodeBtn.isUserInteractionEnabled = false
        ThirdPassCodeBtn.setBackgroundImage(UnselectImg, for: .normal)
        buttonBaseView.addSubview(ThirdPassCodeBtn)
        
        FourPassCodeBtn = UIButton(frame: CGRect(x:ThirdPassCodeBtn.frame.size.width + ThirdPassCodeBtn.frame.origin.x + 24 , y: 20, width: 30, height: 30))
        FourPassCodeBtn.isUserInteractionEnabled = false
        FourPassCodeBtn.setBackgroundImage(UnselectImg, for: .normal)
        buttonBaseView.addSubview(FourPassCodeBtn)
        
        
        
        sampleTextField =  UITextField(frame: CGRect(x: 20, y: 400, width: 300, height: 40))
        sampleTextField.placeholder = "Enter text here"
        sampleTextField.font = UIFont.systemFont(ofSize: 15)
        sampleTextField.keyboardType = UIKeyboardType.numberPad
      
        sampleTextField.delegate = self
        sampleTextField.isHidden = true
        sampleTextField.backgroundColor = UIColor.red
        sampleTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        sampleTextField.becomeFirstResponder()
        self.view.addSubview(sampleTextField)
        
        
        descLbl = UILabel(frame: CGRect(x:(self.view.frame.size.width - 250)/2 , y: buttonBaseView.frame.origin.y + buttonBaseView.frame.size.height + 30, width: 250, height: 30))
        let hasLoginKey = UserDefaults.standard.bool(forKey: "hasLoginKey")
        if !hasLoginKey {
            print("")
            
            descLbl.text = "Set PassCode"
            print("Passcode set")
        }else{
            print("")
            descLbl.text = "Login With PassCode"
            
            print("Passcode Not set")
        }
        descLbl.text = "Please Enter New PassCode"
        descLbl.textColor = UIColor.white
        descLbl.textAlignment = .center
        baseView.addSubview(descLbl)
        
        if let storedUsername = UserDefaults.standard.value(forKey: "username") as? String {
            //   newAccountName = storedUsername
            
            print("Passcode Not set")
            print("Passcode set")
            print("Passcode set")
        }
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05, execute: {
//            self.presentController()
//        })
        
        self.createConfirmPopup()

    }
    func createConfirmPopup() {
        
        
        let popupConfig = STZPopupViewConfig()
        popupConfig.dismissTouchBackground = false
        popupConfig.cornerRadius = 10
        
        confirmPopUpBaseView.frame = CGRect.init(x: 0, y: 0, width: 250, height: 200)
        confirmPopUpBaseView.backgroundColor = hexStringToUIColor(hex: "#34a0ce")
        confirmPopUpBaseView.layer.masksToBounds = true
        confirmPopUpBaseView.layer.cornerRadius = 20.0
        confirmPopUpBaseView.center = self.view.center
        confirmPopUpBaseView.isHidden = true
        
        ConfirmPassCodeLbl = UILabel(frame: CGRect(x:20 , y:20 , width: 210, height: 30))
        ConfirmPassCodeLbl.text = "Please Confirm PassCode"
        ConfirmPassCodeLbl.textColor = UIColor.white
        ConfirmPassCodeLbl.textAlignment = .center
        confirmPopUpBaseView.addSubview(ConfirmPassCodeLbl)
        
        confirmTextField =  UITextField(frame: CGRect(x: 20, y:ConfirmPassCodeLbl.frame.origin.y + ConfirmPassCodeLbl.frame.size.height + 20 , width: 210, height: 40))
        confirmTextField.font = UIFont.systemFont(ofSize: 15)
        confirmTextField.keyboardType = UIKeyboardType.numberPad
        confirmTextField.delegate = self
        confirmTextField.isSecureTextEntry = true
        confirmTextField.textColor = UIColor.white
        confirmTextField.layer.masksToBounds = true
        let myColor : UIColor = UIColor.white
        confirmTextField.delegate = self
        confirmTextField.layer.borderColor = myColor.cgColor
        confirmTextField.layer.borderWidth = 1.0
        let lfetView = UIView()
        lfetView.frame = CGRect.init(x: 0, y: 0, width: 10, height: 40)
        lfetView.backgroundColor = UIColor.clear
        confirmTextField.leftView =  lfetView
        confirmTextField.leftViewMode = UITextFieldViewMode.always
        confirmTextField.leftViewMode = .always
        confirmTextField.attributedPlaceholder = NSAttributedString(string: "Enter text here",
                                                                    attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
        
        confirmPopUpBaseView.addSubview(confirmTextField)
        
        confirmDoneBtn = UIButton(frame: CGRect(x:10 , y: confirmTextField.frame.origin.y + confirmTextField.frame.size.height + 20, width: 110, height: 30))
        confirmDoneBtn.setTitle("Done", for: .normal)
        confirmDoneBtn.setTitleColor(UIColor.white, for: .normal)
        confirmDoneBtn.addTarget(self, action:#selector(confirmDoneBtnTapped(_:)), for: .touchUpInside)
        confirmDoneBtn.backgroundColor = hexStringToUIColor(hex: "#3398c4")
        confirmDoneBtn.layer.masksToBounds = true
        confirmDoneBtn.layer.cornerRadius = 10.0
        confirmPopUpBaseView.addSubview(confirmDoneBtn)
        
        confirmCancelBtn = UIButton(frame: CGRect(x:130 , y:confirmTextField.frame.origin.y + confirmTextField.frame.size.height + 20 , width: 110, height: 30))
        confirmCancelBtn.setTitle("Cancel", for: .normal)
        confirmCancelBtn.setTitleColor(UIColor.white, for: .normal)
        confirmCancelBtn.addTarget(self, action:#selector(confirmCancelBtnTapped(_:)), for: .touchUpInside)
        confirmCancelBtn.backgroundColor = hexStringToUIColor(hex: "#3398c4")
        confirmCancelBtn.layer.masksToBounds = true
        confirmCancelBtn.layer.cornerRadius = 10.0
        confirmPopUpBaseView.addSubview(confirmCancelBtn)
    }
    @objc func confirmDoneBtnTapped(_ sender: UIButton){
        print(confirmTextField.text)
        print(self.passcodeStr)
        if confirmTextField.text == self.passcodeStr {
            print("Confirm PassCode")
            self.createPassCode()
        } else {
            let alert = UIAlertController(title: "Wrong PassCode", message: "Please Try Again Passcode", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                self.confirmTextField.text =  ""
                self.OnePassCodeBtn.setBackgroundImage(self.UnselectImg, for: .normal)
                self.SecondPassCodeBtn.setBackgroundImage(self.UnselectImg, for: .normal)
                self.ThirdPassCodeBtn.setBackgroundImage(self.UnselectImg, for: .normal)
                self.FourPassCodeBtn.setBackgroundImage(self.UnselectImg, for: .normal)
                
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    @objc func confirmCancelBtnTapped(_ sender: UIButton){
        
        sampleTextField.becomeFirstResponder()
        confirmTextField.resignFirstResponder()
        self.confirmTextField.text =  ""
        self.passcodeStr = ""
        self.sampleTextField.text = ""
        self.OnePassCodeBtn.setBackgroundImage(self.UnselectImg, for: .normal)
        self.SecondPassCodeBtn.setBackgroundImage(self.UnselectImg, for: .normal)
        self.ThirdPassCodeBtn.setBackgroundImage(self.UnselectImg, for: .normal)
        self.FourPassCodeBtn.setBackgroundImage(self.UnselectImg, for: .normal)
        dismissPopupView()
        confirmPopUpBaseView.isHidden = true
    }
    @IBAction func backBtnPressed(_ sender: Any) {
         IQKeyboardManager.sharedManager().enable = true
          self.navigationController?.popViewController(animated: true)
    }
   
   
    @objc func textFieldDidChange(_ textField: UITextField) {
        print(textField.text)
        let str = textField.text
        if str?.characters.count == 0 {
            OnePassCodeBtn.setBackgroundImage(UnselectImg, for: .normal)
            SecondPassCodeBtn.setBackgroundImage(UnselectImg, for: .normal)
            ThirdPassCodeBtn.setBackgroundImage(UnselectImg, for: .normal)
            FourPassCodeBtn.setBackgroundImage(UnselectImg, for: .normal)
        }
        if str?.characters.count == 1 {
            OnePassCodeBtn.setBackgroundImage(SelectImg, for: .normal)
            SecondPassCodeBtn.setBackgroundImage(UnselectImg, for: .normal)
            ThirdPassCodeBtn.setBackgroundImage(UnselectImg, for: .normal)
            FourPassCodeBtn.setBackgroundImage(UnselectImg, for: .normal)
        }
        if str?.characters.count == 2 {
            OnePassCodeBtn.setBackgroundImage(SelectImg, for: .normal)
            SecondPassCodeBtn.setBackgroundImage(SelectImg, for: .normal)
            ThirdPassCodeBtn.setBackgroundImage(UnselectImg, for: .normal)
            FourPassCodeBtn.setBackgroundImage(UnselectImg, for: .normal)
        }
        if str?.characters.count == 3 {
            OnePassCodeBtn.setBackgroundImage(SelectImg, for: .normal)
            SecondPassCodeBtn.setBackgroundImage(SelectImg, for: .normal)
            ThirdPassCodeBtn.setBackgroundImage(SelectImg, for: .normal)
            FourPassCodeBtn.setBackgroundImage(UnselectImg, for: .normal)
        }
        if str?.characters.count == 4 {
            OnePassCodeBtn.setBackgroundImage(SelectImg, for: .normal)
            SecondPassCodeBtn.setBackgroundImage(SelectImg, for: .normal)
            ThirdPassCodeBtn.setBackgroundImage(SelectImg, for: .normal)
            FourPassCodeBtn.setBackgroundImage(SelectImg, for: .normal)
            passcodeStr = str!
            var name: String = str!
            
            confirmPopUpBaseView.isHidden = false
            //  sampleTextField.resignFirstResponder()
            confirmTextField.becomeFirstResponder()
            
            let popupConfig = STZPopupViewConfig()
            popupConfig.dismissTouchBackground = false
            popupConfig.cornerRadius = 10
            
            presentPopupView(confirmPopUpBaseView, config: popupConfig)
           // presentPopupView(confirmPopUpBaseView)
          
           
        }
        if str?.characters.count == 5 {
            OnePassCodeBtn.setBackgroundImage(SelectImg, for: .normal)
            SecondPassCodeBtn.setBackgroundImage(SelectImg, for: .normal)
            ThirdPassCodeBtn.setBackgroundImage(SelectImg, for: .normal)
            FourPassCodeBtn.setBackgroundImage(SelectImg, for: .normal)
            var name: String = str!
            name.remove(at: name.index(before: name.endIndex))
            print(name)      // "Dolphi"
            sampleTextField.text = name
            passcodeStr = name
            let alert = UIAlertController(title: "Alert", message: "PassCodeOnly Four Digits", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { action in
                print("TouchID")
            }))
            
            self.present(alert, animated: true, completion: nil)
        }
        
        
        print("textfield Enter")
    }
    
   
    
    func presentController() {
        self.sampleTextField.becomeFirstResponder()
    }
    
    @objc func createPassCode()  {
        let newAccountName = "PassCodeTouch"
        let newPassword = passcodeStr
        let hasLoginKey = UserDefaults.standard.bool(forKey: "hasLoginKey")
        if !hasLoginKey {
            UserDefaults.standard.setValue("PassCodeTouch", forKey: "username")
        }
        
        do {
            
            // This is a new account, create a new keychain item with the account name.
            let passwordItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName,
                                                    account: newAccountName,
                                                    accessGroup: KeychainConfiguration.accessGroup)
            
            // Save the password for the new item.
            try passwordItem.savePassword(newPassword)
            self.sampleTextField.resignFirstResponder()
            stringLoad =  "YES"
             kUserTouchAndPassCode.set("YES", forKey: "Passcode")
            DispatchQueue.main.async(execute: {
                self.dismissPopupView()
            })
             IQKeyboardManager.sharedManager().enable = true
             self.navigationController?.popViewController(animated: true)
           
            
        } catch {
            fatalError("Error updating keychain - \(error)")
        }
        
        UserDefaults.standard.set(true, forKey: "hasLoginKey")
        
        
        
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == confirmTextField {
            guard let text = textField.text else { return true }
            let newLength = text.characters.count + string.characters.count - range.length
            return newLength <= 4 // Bool
        }
        return true
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

  

}

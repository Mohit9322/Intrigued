//
//  TouchScreen.swift
//  Intrigued
//
//  Created by Shineweb-solutions on 18/01/18.
//  Copyright © 2018 daniel helled. All rights reserved.
//

import UIKit
import LocalAuthentication


class TouchScreen: UIViewController, UITextFieldDelegate {
    
    var passCodeBasVeView = UIView()
    var passwordItems: [KeychainPasswordItem] = []
    var OnePassCodeBtn = UIButton()
    var SecondPassCodeBtn = UIButton()
    var ThirdPassCodeBtn = UIButton()
    var FourPassCodeBtn = UIButton()
    var sampleTextField:UITextField = UITextField()
    var passcodeStr = String()
    var descLbl = UILabel()
    var UnselectImg    = UIImage()
    var SelectImg      = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor =  hexStringToUIColor(hex: "#34a0ce")
        
        let iconImg = UIImage(named: "login_logo")
        let iconImgView = UIImageView(image: iconImg!)
        iconImgView.frame = CGRect(x: (self.view.frame.size.width -  230)/2, y: 120, width: 230, height: 120)
        self.view.addSubview(iconImgView)
        
        let TouchImg = UIImage(named: "fingerPrintTouch")
        let touchBtn = UIButton(frame: CGRect(x:(self.view.frame.size.width -  80)/2 , y: iconImgView.frame.size.height + iconImgView.frame.origin.y + 150, width: 80, height: 80))
        touchBtn.setBackgroundImage(TouchImg, for: .normal)
        touchBtn.addTarget(self, action:#selector(touchBtnTapped(_:)), for: .touchUpInside)
        touchBtn.backgroundColor = UIColor.black
        touchBtn.layer.masksToBounds = true
        touchBtn.layer.cornerRadius = 40.0
        self.view.addSubview(touchBtn)
        
        let unlockLbl = UILabel(frame: CGRect(x:(self.view.frame.size.width - 150)/2 , y: touchBtn.frame.size.height + touchBtn.frame.origin.y + 5, width: 150, height: 30))
        unlockLbl.textColor = UIColor.white
        unlockLbl.text = "Touch ID to unlock"
        unlockLbl.textAlignment = .center
        self.view.addSubview(unlockLbl)
        
        let pinCodeBtn = UIButton(frame: CGRect(x:(self.view.frame.size.width -  200)/2 , y: (self.view.frame.size.height -  100), width: 200, height: 50))
        pinCodeBtn.setTitle("Enter Pin Code", for: UIControlState.normal)
        pinCodeBtn.setTitleColor(.white, for: .normal)
        pinCodeBtn.addTarget(self, action:#selector(PincodeBtnTapped(_:)), for: .touchUpInside)
        pinCodeBtn.backgroundColor = hexStringToUIColor(hex: "#3398c4")
        pinCodeBtn.layer.masksToBounds = true
        pinCodeBtn.layer.cornerRadius = 30.0
        self.view.addSubview(pinCodeBtn)
        
        
        /* **************   PascdoeTouchView       *********  */
      
        passCodeBasVeView.frame = CGRect(x:0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        passCodeBasVeView.backgroundColor =  hexStringToUIColor(hex: "#34a0ce")
         passCodeBasVeView.isHidden = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapBlurButton(_:)))
        tapGesture.numberOfTapsRequired = 1
        passCodeBasVeView.addGestureRecognizer(tapGesture)
        let str2 =   kUserTouchAndPassCode.string(forKey: "Touchid")
        
        if str2 == "NO" {
            let str1 =   kUserTouchAndPassCode.string(forKey: "Passcode")
            if str1 == "NO"{
                
            }else if str1 ==  "YES"{
                passCodeBasVeView.isHidden = false
                self.passCodeBasVeView.isHidden = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05, execute: {
                    self.presentController()
                })
            }
        }
       
        self.view.addSubview(passCodeBasVeView)
    
        
        let iconImgViewPasscode = UIImageView(image: iconImg!)
        iconImgViewPasscode.frame = CGRect(x: (self.view.frame.size.width -  230)/2, y: 100, width: 230, height: 100)
        passCodeBasVeView.addSubview(iconImgViewPasscode)
        
        
        let buttonBaseView = UIView(frame: CGRect(x: (self.view.frame.size.width - 240)/2, y: iconImgView.frame.origin.y + iconImgView.frame.size.height + 50 , width: 240, height: 70))
        buttonBaseView.backgroundColor = hexStringToUIColor(hex: "#3398c4")
        buttonBaseView.layer.masksToBounds = true
        buttonBaseView.layer.cornerRadius = 20.0
        passCodeBasVeView.addSubview(buttonBaseView)
        
        
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
        passCodeBasVeView.addSubview(sampleTextField)
        
        
        descLbl = UILabel(frame: CGRect(x:(self.view.frame.size.width - 250)/2 , y: buttonBaseView.frame.origin.y + buttonBaseView.frame.size.height + 30, width: 250, height: 30))
        let hasLoginKey = UserDefaults.standard.bool(forKey: "hasLoginKey")
        if !hasLoginKey {
            print("")
            
            descLbl.text = "Please Enter PassCode"
            print("Passcode set")
        }else{
            print("")
            descLbl.text = "Login With PassCode"
            
            print("Passcode Not set")
        }
        
        descLbl.textColor = UIColor.white
        descLbl.textAlignment = .center
        passCodeBasVeView.addSubview(descLbl)
        
        if let storedUsername = UserDefaults.standard.value(forKey: "username") as? String {
            //   newAccountName = storedUsername
            
            print("Passcode Not set")
            print("Passcode set")
            print("Passcode set")
        }
        
       

         /* **************   PascdoeTouchView       *********  */

        // Do any additional setup after loading the view.
    }
    
    @objc func tapBlurButton(_ sender: UITapGestureRecognizer) {
        print("Please Help!")
         self.sampleTextField.becomeFirstResponder()
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
            
            let hasLoginKey = UserDefaults.standard.bool(forKey: "hasLoginKey")
            if !hasLoginKey {
                print("")
                createPassCode()
            }else{
                print("")
                // createPassCode()
                checkPassCode()
            }
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
            
            let alertView = UIAlertController(title: "Alert",
                                              message: "Passcode set successfully",
                                              preferredStyle: .alert)
            alertView.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                print("TouchID not available")
                self.dismiss(animated: true, completion: nil)
                
            }))
            
            present(alertView, animated: true, completion: nil)
        } catch {
            fatalError("Error updating keychain - \(error)")
        }
        
        UserDefaults.standard.set(true, forKey: "hasLoginKey")
        
        
        
    }
    func checkPassCode() {
        
        let newAccountName = "PassCodeTouch"
        let newPassword = passcodeStr
        if checkLogin(username: newAccountName, password: newPassword) {
            print("Successful Password")
            stringLoad = "YES"
            self.sampleTextField.resignFirstResponder()
            self.dismiss(animated: true, completion: nil)
            
        } else {
            
            let alertView = UIAlertController(title: "Icorrect Passcode",
                                              message: "Wrong username or Passcode.",
                                              preferredStyle: .alert)
            alertView.addAction(UIAlertAction(title: "Try Again", style: .default, handler: { action in
                print("TouchID not available")
                self.sampleTextField.text = ""
                self.passcodeStr = ""
                self.OnePassCodeBtn.setBackgroundImage(self.UnselectImg, for: .normal)
                self.SecondPassCodeBtn.setBackgroundImage(self.UnselectImg, for: .normal)
                self.ThirdPassCodeBtn.setBackgroundImage(self.UnselectImg, for: .normal)
                self.FourPassCodeBtn.setBackgroundImage(self.UnselectImg, for: .normal)
                
            }))
            
            present(alertView, animated: true, completion: nil)
        }
        
        
    }
    func checkLogin(username: String, password: String) -> Bool {
        
        guard username == UserDefaults.standard.value(forKey: "username") as? String else {
            return false
        }
        
        do {
            let passwordItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName,
                                                    account: username,
                                                    accessGroup: KeychainConfiguration.accessGroup)
            let keychainPassword = try passwordItem.readPassword()
            return password == keychainPassword
        }
        catch {
            fatalError("Error reading password from keychain - \(error)")
        }
        
        return false
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @objc func touchBtnTapped(_ sender: UIButton){
        print("Touch Button Pressed")
        self.authenticateUser()
    }
    @objc func PincodeBtnTapped(_ sender: UIButton){
        print("Touch Button Pressed")
        let str2 =   kUserTouchAndPassCode.string(forKey: "Passcode")
        
        if str2 == "NO" {
            let alert = UIAlertController(title: "Alert", message: "Please Login with Passcode", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { action in
                self.passCodeBasVeView.isHidden = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05, execute: {
                    self.presentController()
                })
                
            }))
            self.present(alert, animated: true, completion: nil)
            
        }else if str2 == "YES"{
            passCodeBasVeView.isHidden = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05, execute: {
                self.presentController()
            })
        }
       
       

    }
    func authenticateUser() {
        let context:LAContext = LAContext();
        var error:NSError?
        var _:Bool;
        let reason:String = "Please authenticate using TouchID.";
        
        
        
        if (context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: &error))
        {
            context.evaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason, reply: { (success, error) -> Void in
                if (success) {
                    stringLoad = "YES"
                    print("Auth was OK");
                    
                    
                     self.dismiss(animated: true, completion: nil)
                    
                }
                else
                {
                    
                    if error != nil {
                        stringLoad = "YES"
                        
                        print("Error received: %d", error!._code);
                        print(error?.localizedDescription as Any)
                        
                        let n = error!._code
                        
                        if n == -2 {
                            print("Cancel Pressed")
                            
                            
                        }else if n  == -3 {
                            print("Enter PassCode Pressed")
                            let str2 =   kUserTouchAndPassCode.string(forKey: "Passcode")
                            
                            if str2 == "NO" {
                                let alert = UIAlertController(title: "Alert", message: "Please Login With Passcode", preferredStyle: UIAlertControllerStyle.alert)
                                alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { action in
                                    
                                    
                                        self.passCodeBasVeView.isHidden = false
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05, execute: {
                                            self.presentController()
                                        })
                                   
                                 
                                    
                                }))
                                self.present(alert, animated: true, completion: nil)
                                
                            }else if str2 == "YES"{
                                DispatchQueue.main.sync {
                                    self.passCodeBasVeView.isHidden = false
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05, execute: {
                                        self.presentController()
                                    })
                                }
                            }
                            
                            
       
                            
                            
                        }else{
                            
                            let str2 =   kUserTouchAndPassCode.string(forKey: "Passcode")
                            
                            if str2 == "NO" {
                                let alert = UIAlertController(title: "Alert", message: "Please Login With Passcode", preferredStyle: UIAlertControllerStyle.alert)
                                alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { action in
                             
                                    self.passCodeBasVeView.isHidden = false
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05, execute: {
                                        self.presentController()
                                    })
                                    
                                }))
                                self.present(alert, animated: true, completion: nil)
                                
                            }else if str2 == "YES"{
                                DispatchQueue.main.sync {
                                    self.passCodeBasVeView.isHidden = false
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05, execute: {
                                        self.presentController()
                                    })
                                }
                            }
                        }
                    }
                    
                    
                }
            })
        }else{
            stringLoad = "YES"
            // If the security policy cannot be evaluated then show a short message depending on the error.
            
            let alert = UIAlertController(title: "Alert", message: "Not reconized user or you have crossed your limit.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { action in
                self.passCodeBasVeView.isHidden = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05, execute: {
                    self.presentController()
                })
            }))
           
            self.present(alert, animated: true, completion: nil)
            
        }
    }
    
}

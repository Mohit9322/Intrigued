//
//  LoginVC.swift
//  DatingAdvice
//
//  Created by daniel helled on 14/09/17.
//  Copyright © 2017 daniel helled. All rights reserved.
//

import UIKit
import FBSDKLoginKit
class LoginVC: UIViewController,GIDSignInDelegate,GIDSignInUIDelegate {
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var tf_passwordTF: DesignableUITextField!
    @IBOutlet weak var tf_emailId: DesignableUITextField!
    
    //var userDeviceArray = NSArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.async(execute: {
            GIDSignIn.sharedInstance().uiDelegate = self
            GIDSignIn.sharedInstance().delegate = self
        })
        // Do any additional setup after loading the view.
    }
    @IBAction func backButtonAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func loginButtonAction(_ sender: Any) {
        if ischeckManadoryDetails() {
            showProgressIndicator(refrenceView: self.view)
            let request = ["email": tf_emailId.text,"password":tf_passwordTF.text]
            WebServices().mainFunctiontoGetDetails(data: request as NSDictionary,serviceType:kLOGIN_USER) { (responseData)  in
                stopProgressIndicator()
                if responseData != nil
                {
                    let code = responseData?["code"] as? NSNumber
                    print("responseData",responseData ?? "")
                    if code == 200{
                        guard let resultDict = responseData?["result"] as? NSDictionary else {
                            return
                        }
                      
                        removeUserDetails()
                        saveUserDetails(userDict: resultDict)
                        CloseChatDays = resultDict["close_chat"] as? String ?? ""
                        ServiceTaxValue = resultDict["service_tax"] as? String ?? ""
                        
                        kUserTouchAndPassCode.set("NO", forKey: "Passcode")
                        kUserTouchAndPassCode.set("NO", forKey: "Touchid")
                        kUserTouchAndPassCode.synchronize()
                        pushView(viewController: self, identifier: "HomeTabbarVC")
                    }
                    else {
                        if let message = responseData?["result"] as? String {
                            notifyUser("", message: message , vc: self)
                        }
                        else{
                            // notifyUser("", message: "Something went wrong", vc: self)
                        }
                    }
                }
                else{ stopProgressIndicator()}
                
            }
        }
    }
    
    
    @IBAction func facebookButtonAction(_ sender: Any) {
        showProgressIndicator(refrenceView: self.view)
        FacebookManager().login(withPermissions: ["public_profile", "email", "user_friends"], viewController: self, completionHandler: {(_ userInfo: Any, _ error: Error?) -> Void in
            stopProgressIndicator()
            if error == nil {
                print("Facebook response info = \(userInfo)")
                if let dict = userInfo as? NSDictionary {
                    let socialId = dict["id"]
                    let email = dict["email"]
                    let name = dict["name"]
                    let token = UserDefaults.standard.object(forKey: "deviceToken")
                    let userDeviceArray = ["deviceToken": token ?? "","deviceId": appDelegateDeviceId.deviceId ?? "","deviceType": "I"]
                    let request = ["socialId": socialId,"socialType": "F","email": email,"username":name,"user_devices":[userDeviceArray]]
                    
                    self.loginWithFaceook_Google(requestDict: request as NSDictionary)
                }
            }
            else{
                print("Facebook error")
            }
        })
    }
    
    @IBAction func googleButtonAction(_ sender: Any) {
        showProgressIndicator(refrenceView: self.view)
        GIDSignIn.sharedInstance().signIn()
    }
    
    @IBAction func forgotPasswordButtonAction(_ sender: Any) {
        pushView(viewController: self, identifier: "ForgetPasswordVC")
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if (error == nil) {
            // Perform any operations on signed in user here.
            let userId = user.userID                  // For client-side use only!
            //let idToken = user.authentication.idToken // Safe to send to the server
            let fullName = user.profile.name ?? ""
            let givenName = user.profile.givenName ?? ""
            let familyName = user.profile.familyName ?? ""
            let email = user.profile.email ?? ""
            print("fullName==",fullName,"familyName==",familyName,"givenName==",givenName, "email==",email )
            let token = UserDefaults.standard.object(forKey: "deviceToken")
            let userDeviceArray = ["deviceToken": token ?? "","deviceId": appDelegateDeviceId.deviceId ?? "","deviceType": "I"]
            let request = ["socialId": userId ?? "","socialType": "G","email": email,"username":fullName,"user_devices":[userDeviceArray]] as [String : Any]
            print(request)
            
            self.loginWithFaceook_Google(requestDict: request as NSDictionary)
            
        } else {
            print("\(error.localizedDescription)")
        }
        stopProgressIndicator()
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user:GIDGoogleUser!,
              withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // ...
        stopProgressIndicator()
    }
    //MARK: ****** Check Field is empty / valid **************
    func ischeckManadoryDetails() -> Bool {
        
        if String.isNilOrEmpty(self.tf_emailId.text)  {
            notifyUser("", message: kEMAIL_BLANK, vc: self)
            return false
        }
        //        else if !String.isValidEmail(self.tf_emailId.text) {
        //            notifyUser("", message: kVALID_EMAIL, vc: self)
        //            return false
        //        }
        //        else if String.isNilOrEmpty(self.tf_passwordTF.text) {
        //            notifyUser("", message: kPASSWORD_BLANK, vc: self)
        //            return false
        //        }
        return true
    }
    func loginWithFaceook_Google(requestDict : NSDictionary) {
        showProgressIndicator(refrenceView: self.view)
        
        WebServices().mainFunctiontoGetDetails(data: requestDict as NSDictionary,serviceType:kLOGIN_USER) { (responseData)  in
            stopProgressIndicator()
            if responseData != nil
            {
                let code = responseData?["code"] as? NSNumber
                print("responseData",responseData ?? "")
                if code == 200{
                    guard let resultDict = responseData?["result"] as? NSDictionary else {
                        return
                    }
                  //  saveUserDetails(userDict: resultDict)
                    removeUserDetails()
                    saveUserDetails(userDict: resultDict)
                    CloseChatDays = resultDict["close_chat"] as? String ?? ""
                    ServiceTaxValue = resultDict["service_tax"] as? String ?? ""
                    
                    kUserTouchAndPassCode.set("NO", forKey: "Passcode")
                    kUserTouchAndPassCode.set("NO", forKey: "Touchid")
                    kUserTouchAndPassCode.synchronize()
                    pushView(viewController: self, identifier: "HomeTabbarVC")
                }
                else {
                    if let message = responseData?["result"] as? String {
                        notifyUser("", message: message , vc: self)
                    }
                    else{
                        //notifyUser("", message: "Something went wrong", vc: self)
                    }
                }
            }
            else{ stopProgressIndicator()}
            
        }
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}


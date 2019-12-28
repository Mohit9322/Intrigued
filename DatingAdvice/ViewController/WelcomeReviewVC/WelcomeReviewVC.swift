//
//  WelcomeReviewVC.swift
//  DatingAdvice
//
//  Created by daniel helled on 15/09/17.
//  Copyright © 2017 daniel helled. All rights reserved.
//

import UIKit
import SocketIO

class WelcomeReviewVC: UIViewController,GIDSignInDelegate,GIDSignInUIDelegate,UIGestureRecognizerDelegate {
    
    
    
    @IBOutlet weak var loginBtn: UIButton!
    let attributes : [NSAttributedStringKey : Any] = [NSAttributedStringKey(rawValue: NSAttributedStringKey.font.rawValue) : UIFont(name: "OpenSans-Bold", size: 15.0) ??  UIFont.systemFont(ofSize: 15.0),
                                                      NSAttributedStringKey(rawValue: NSAttributedStringKey.foregroundColor.rawValue) :UIColor.loginRed,
                                                      NSAttributedStringKey(rawValue: NSAttributedStringKey.underlineStyle.rawValue) : NSUnderlineStyle.styleSingle.rawValue]
    var attributedString = NSMutableAttributedString(string:"Already a user?  ")
    @IBOutlet weak var advisor_collectionView: AdvisorCollectionView!
    var coachListArray = NSMutableArray()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        let buttonTitleStr = NSMutableAttributedString(string:"Login", attributes:attributes)
        attributedString.append(buttonTitleStr)
        loginBtn.setAttributedTitle(attributedString, for: .normal)
        DispatchQueue.main.async(execute: {
            GIDSignIn.sharedInstance().uiDelegate = self
            GIDSignIn.sharedInstance().delegate = self
        })
        getCoachDetails()
        navigationController?.interactivePopGestureRecognizer?.delegate = self as UIGestureRecognizerDelegate
        // Do any additional setup after loading the view.
    }
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if(navigationController!.viewControllers.count > 1){
            return true
        }
        return false
    }
    
    
    @IBAction func backButtonAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func loginButtonAction(_ sender: Any) {
        pushView(viewController: self, identifier: "LoginVC")
    }
    @IBAction func facebookButtonAction(_ sender: Any) {
        
        
        
    //    showProgressIndicator(refrenceView: self.view)
        FacebookManager().login(withPermissions: ["public_profile", "email", "user_friends"], viewController: self, completionHandler: {(_ userInfo: Any, _ error: Error?) -> Void in
            stopProgressIndicator()
            if error == nil {
                print("Facebook response info = \(userInfo)")
                if let dict = userInfo as? NSDictionary {
                    let socialId = dict["id"]
                    let email = dict["email"] as? String ?? ""
                    let first_name = dict["first_name"]
                    let last_name = dict["last_name"]
                    var imageurl = ""
                    if let image_URL = ((dict["picture"] as? NSDictionary)?["data"] as? [String: Any])?["url"] as? String {
                        //Download image from imageURL
                        imageurl = image_URL
                    }
                    removeUserDetails()
//                    imageurl = ""
                    let token = UserDefaults.standard.object(forKey: "deviceToken")
                    let userDeviceArray = ["deviceToken": token ?? "","deviceId": appDelegateDeviceId.deviceId ?? "","deviceType": "I"]
                    
                    let request = ["socialId": socialId,"socialType": "F","email": email,"firstname":first_name,"lastname":last_name,"profilepic" : imageurl,"user_devices":[userDeviceArray]]
                    print(request)
                    
                    if email == "" {
                        
                    }else{
                        self.checkUserExistence(emailId: email,details: request as NSDictionary, social_type: "F")
                       
                        
                    }
                   
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
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if (error == nil) {
            var firstName = ""
            var lastName = ""
            // Perform any operations on signed in user here.
            let userId = user.userID ?? ""                   // For client-side use only!
            //let idToken = user.authentication.idToken // Safe to send to the server
            let fullName = user.profile.name ?? ""
            let givenName = user.profile.givenName ?? ""
            let familyName = user.profile.familyName ?? ""
            let email = user.profile.email ?? ""
            var profilePicStr = ""
            
            if user.profile.hasImage
            {
                let pic = user.profile.imageURL(withDimension: 100)
               print(pic)
                profilePicStr = (pic?.absoluteString)!
            }
            let nameArray = fullName.components(separatedBy: " ")
            if nameArray.count > 0 {
                firstName = nameArray[0]
                if nameArray.count > 1 {
                    lastName = nameArray[1]
                }
            }
            removeUserDetails()
            print(profilePicStr)
           // profilePicStr = ""
            
            print("fullName==",fullName,"familyName==",familyName,"givenName==",givenName, "email==",email )
            let token = UserDefaults.standard.object(forKey: "deviceToken")
            let userDeviceArray = ["deviceToken": token ?? "","deviceId": appDelegateDeviceId.deviceId ?? "","deviceType": "I"]
            let request = ["socialId": userId,"socialType": "G","email": email,"firstname":firstName,"lastname":lastName,"profilepic" : profilePicStr,"user_devices":[userDeviceArray]] as [String : Any]
            print(request)
            
            checkUserExistence(emailId: email, details: request as NSDictionary, social_type: "G")
            
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
    
    func checkUserExistence(emailId : String, details: NSDictionary, social_type : String) {
        showProgressIndicator(refrenceView: self.view)
        let requestDict = ["email": emailId]
        WebServices().mainFunctiontoGetDetails(data: requestDict as NSDictionary, serviceType:kCHECK_USEREXISTENCE) { (responseData)  in
            stopProgressIndicator()
            if responseData != nil
            {
                let code = responseData?["code"] as? NSNumber
                print("responseData",responseData ?? "")
                if code == 200{
                    guard let isNew = responseData?["isNew"] as? NSNumber else {
                        return
                    }
                    //1 means - user is not registered , it's new user (final to build)
                    
                    if isNew == 1 {
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SignupVC") as? SignupVC
                        if social_type == "G" {
                            vc?.socialType = "G"
                        }
                        else{
                            vc?.socialType = "F"
                        }
                        vc?.socialInfo = details
                        let serviceCharge = responseData?["service_tax"] as? String ?? ""
                        
                        CloseChatDays = responseData?["close_chat"] as? String ?? ""
                        ServiceTaxValue = responseData?["service_tax"] as? String ?? ""
                        
                        vc?.serviceTaxPercent = serviceCharge
                        
                        
                        
                        let alert = UIAlertController(title: "", message: "", preferredStyle: UIAlertControllerStyle.alert)
                        let titleFont = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 18)]
                        let messageFont = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 17)]
                        
                        let titleAttrString = NSMutableAttributedString(string: "Welcome to Intrigued!", attributes: titleFont)
                        let messageAttrString = NSMutableAttributedString(string: "\n How would you like to register?", attributes: messageFont)
                        
                        alert.setValue(titleAttrString, forKey: "attributedTitle")
                        alert.setValue(messageAttrString, forKey: "attributedMessage")
                      
                        alert.addAction(UIAlertAction(title: "Coach", style: .default, handler: { action in
                            UserOrCoachSignUpPopup = 1
                             self.navigationController?.pushViewController(vc!, animated: true)
                            
                        }))
                        alert.addAction(UIAlertAction(title: "User", style: .default, handler: { action in
                            UserOrCoachSignUpPopup = 0
                            self.navigationController?.pushViewController(vc!, animated: true)
                            
                        }))
                        self.present(alert, animated: true, completion: nil)
                        
                      
                    }
                    else{
                        let token = UserDefaults.standard.object(forKey: "deviceToken")
                        let userDeviceArray = ["deviceToken": token ?? "","deviceId": appDelegateDeviceId.deviceId ?? "","deviceType": "I"] as [String : Any]
                        
                        let request = ["socialId": details["socialId"],"socialType": social_type,"email": emailId,"user_devices":[userDeviceArray]]
                        self.loginWithFaceook_Google(requestDict: request as NSDictionary)
                    }
                    
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
    func loginWithFaceook_Google(requestDict : NSDictionary) {
        showProgressIndicator(refrenceView: self.view)
        GIDSignIn.sharedInstance().signOut()
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
                    kUserTouchAndPassCode.set("NO", forKey: "Passcode")
                    kUserTouchAndPassCode.set("NO", forKey: "Touchid")
                    kUserTouchAndPassCode.synchronize()
                    
                    removeUserDetails()
                    saveUserDetails(userDict: resultDict)
                    CloseChatDays = resultDict["close_chat"] as? String ?? ""
                    ServiceTaxValue = resultDict["service_tax"] as? String ?? ""
                    
                  let serviceTaxKey = getUserServiceTax() as String
                    print(serviceTaxKey)
                    
                  
                    
                    if let val = resultDict["categories"]  {
                        print(val)
                        pushView(viewController: self, identifier: "CoachesTabbarVC")
                        
                    }
                    else{
                        pushView(viewController: self, identifier: "HomeTabbarVC")
                    }
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
    
    func getCoachDetails() {
        
        let request = ["user_id": "1"] as [String : Any]
        
        print(request)
        WebServices().mainFunctiontoGetDetails(data: request as NSDictionary,serviceType:kGET_COACH_LISTING_simple) { (responseData)  in
            stopProgressIndicator()
            if responseData != nil
            {
                let code = responseData?["code"] as? NSNumber
                print("responseData",responseData ?? "")
                if code == 200{
                    stopProgressIndicator()
                    guard let resultArray = responseData?["result"] as? NSArray else {
                        return
                    }
                    self.coachListArray = resultArray.mutableCopy() as! NSMutableArray
                    self.advisor_collectionView.setUpDataOfCollection(coachesArray: self.coachListArray)
                }
                else {
                    if let message = responseData?["result"] as? String {
                        //notifyUser("", message: message , vc: self)
                    }
                    else{
                        // notifyUser("", message: "Something went wrong", vc: self)
                    }
                }
            }
            else{ stopProgressIndicator()}
            
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}


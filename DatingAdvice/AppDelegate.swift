//
//  AppDelegate.swift
//  DatingAdvice
//
//  Created by daniel helled on 13/09/17.
//  Copyright © 2017 daniel helled. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import FBSDKCoreKit
import GoogleSignIn
import GLKit
//import Google
import GLKit
//import FirebaseCore
import Fabric
import Crashlytics
import AWSS3
import AWSCore
import SVGeocoder
import UserNotificationsUI
import UserNotifications
import MagicalRecord
import Stripe
import MBProgressHUD
import SocketIO

let kUserTouchAndPassCode = UserDefaults.standard
let kServIceTaxKey = UserDefaults.standard
let kCloseChatKEy =  UserDefaults.standard
var  UserDeviceToken:String = String()
var  isFirstTimeCoach:String = String()
let appDelegateDeviceId = UIApplication.shared.delegate! as! AppDelegate

var  CloseChatDays:String = ""
var  ServiceTaxValue:String = ""

var  UserOrCoachSignUpPopup:Int = 2
var  isFromLiveChatBackBtn:Int = 0

//var manager = SocketManager(socketURL: URL(string: "http://13.228.52.104:3002/")!, config:[.log(true), .compress])
//var   socket : SocketIOClient?

//var tabControllerVc:HomeTabbarVC!
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,UNUserNotificationCenterDelegate {

    var window: UIWindow?
    // configure S3
    // For AWS SETUP KEYS
    let CognitoRegionType = AWSRegionType.USEast1
    let DefaultServiceRegionType = AWSRegionType.USEast1
    let CognitoIdentityPoolId = "us-east-1:53ac7085-42f0-41a5-8dbf-daa611a3d8db"
    let S3BucketName = "wystap"
    var currentLocationSVplacemark:SVPlacemark?
    var currentAddress = ""
    var currentLongitude = ""
    var currectLatitude = ""
    var coachPriceDict = NSMutableDictionary()
      var tabbarVC : UITabBarController?
    var Defaults = UserDefaults.standard
    var deviceId: String!
    var isPushReceived = false
    var notifDict : [String:Any]?
    
    var backgroundNotifDict : [String:Any]?
    var sen_Id = ""
    var sender_id = ""
    var sender_type : Int?
    var notifyType:Int?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        
        
      
      //  socket?.connect()
        
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        //*********** Device id for unique *************
        deviceId = UIDevice.current.identifierForVendor!.uuidString
        
        
   //********** Notification Configure ************/
        STPPaymentConfiguration.shared().publishableKey = "pk_test_aycpMNDYWgJZRTVEg7vqn7ZB"
        
       // pk_test_ZNumkfAZppgmkapkyilNXNXa
        
        // *********** Register Push Notification *****************
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options:[.badge, .alert, .sound]) { (granted, error) in
            if error == nil{
                // UIApplication.shared.registerForRemoteNotifications()
            }
        }
        application.registerForRemoteNotifications()
        
        if launchOptions != nil{
            let userInfo = launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification]
            NSLog("Launch Options Dict = \(String(describing: userInfo))")
             if userInfo != nil {
                // Perform action here
                isPushReceived = true
                notifDict = userInfo as? [String:Any]
                if let params = notifDict?["param1"] as? [String:Any] {
                    if let type = params["type"] as? Int {
                        self.notifyType = type
                    }
                }
                
                NSLog("Launch Options Dict = \(String(describing: notifDict))")
            }
        }
        

        //application.applicationIconBadgeNumber = 0
        /********** Notification Configure ************/
        
         coachPriceDict = ["DirectPricing" :"$0.00" , "RushDirectPricing" : "$0.00", "LiveChatPricing" :"$0.00"]
   //     IQKeyboardManager.sharedManager().enable = false
        IQKeyboardManager.sharedManager().enable = true
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        LocationManager.sharedInstance//.startUpdatingLocation()
        
       getCategoryDetails()
        //MARK: Add credential for AWS
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType:CognitoRegionType, identityPoolId: CognitoIdentityPoolId)
        let configuration = AWSServiceConfiguration(region: DefaultServiceRegionType, credentialsProvider: credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration  = configuration
        
        // Initialize sign-in
//          DispatchQueue.main.async(execute: {
//            var configureError: NSError?
//            CGContext.sharedInstance().configureWithError(&configureError)
//            assert(configureError == nil, "Error configuring Google services:\(String(describing: configureError))")
//
//        })
       GIDSignIn.sharedInstance().clientID = "528500117225-slnjff66h8qdhjcduap1k5h60jiikbua.apps.googleusercontent.com"
        Fabric.with([Crashlytics.self])

       MagicalRecord.setupCoreDataStack(withStoreNamed: "Intrigude")
        // Override point for customization after application launch.
        return true
    }
    
    //To show global activity indicator
    func showIndicator() {
      
        let loadingNotification = MBProgressHUD.showAdded(to: window!, animated: true)
        loadingNotification.mode = MBProgressHUDMode.indeterminate
        loadingNotification.contentColor = UIColor.white
        loadingNotification.bezelView.backgroundColor = UIColor.black
        loadingNotification.label.textColor = UIColor.white
        loadingNotification.label.text = "Processing..."
        
    //    MBProgressHUD.showAdded(to: window!, animated: true)
    }
    func showTitleIndicator() {
      
      
        let loadingNotification = MBProgressHUD.showAdded(to: window!, animated: true)
        loadingNotification.mode = MBProgressHUDMode.indeterminate
        loadingNotification.contentColor = UIColor.white
        loadingNotification.bezelView.backgroundColor = UIColor.black
        loadingNotification.label.textColor = UIColor.white
        loadingNotification.label.text = "Uploading..."
        
    }
    //To hide global activity indicator
    func hideIndicator() {
        MBProgressHUD.hide(for: window!, animated: true)
    }
    /********** Notification Configure ************/
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
     
        print("DEVICE TOKEN = \(deviceToken)")
        
        UserDeviceToken = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        Defaults.set(UserDeviceToken, forKey: "deviceToken")
        print(UserDeviceToken)
        print(UserDeviceToken)
    }
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(error)
    }
    private func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        print(userInfo)
    }
     /********** Notification Configure ************/
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
      
        let urlString: String = url.absoluteString
        var componentArr = urlString.components(separatedBy: "code=")
        
        if componentArr.count == 2 {
            let code = componentArr[1] as? String
            NotificationCenter.default.post(name: NSNotification.Name("stripeConnect"), object: code)
        }
        
        let canHandleURL = FBSDKApplicationDelegate.sharedInstance().application(app, open: url, options: options)
        let canHandleGoogleUrl =  GIDSignIn.sharedInstance().handle(url,
                                                                    sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
                                                                    annotation: options[UIApplicationOpenURLOptionsKey.annotation])
        if canHandleURL {
            return true
        } else if canHandleGoogleUrl {
            return true
        } else {
            return false
        }
    }

    //MARK: ************** PUSH ON NOTIFICATION DELEGATE METHODS ***************
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        //completionHandler(.alert)
        NSLog("foreground userNotify Response \(notification.request.content.userInfo)")
        if let userInfo = notification.request.content.userInfo["param1"] as? [String:Any] {
            if let apsUserInfo = notification.request.content.userInfo["aps"] as? [String:Any] {
                notifDict = userInfo
                
                let notiType = notifDict?["type"] as? Int
                self.notifyType = notiType
               // isPushReceived = true
                // type for request
                if notiType == 1 {
                    print("notify 1")
                    //self.showAlertForViewDetail(userInfo: apsUserInfo)
                }
                else if notiType == 2 {
                 //   self.showAlertForViewDetail(userInfo: apsUserInfo)
                }
                else if notiType == 3 {
                    //self.showAlertForViewDetail(userInfo: apsUserInfo)
                }
                else if notiType == 5 {
                    //self.showAlertForViewDetail(userInfo: apsUserInfo)
                }
                else if notiType == 4 {
                    //self.showAlertForViewDetail(userInfo: apsUserInfo)
                }
                else{
                    
                }
            }
        }
        
    }
    
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        NSLog("background userNotify Response \(response.notification.request.content.userInfo)")
        let paramDict = response.notification.request.content.userInfo["param1"] as? [String:Any]
        notifDict = paramDict
        NSLog("background params\(String(describing: notifDict))")
        NSLog("background paramDict for view application \(String(describing: paramDict))")
        
        let application = UIApplication.shared
        switch application.applicationState {
        case .active:
            print("show local notif or anything that you want")
            self.handlePush(true)
            break
        case .inactive:
            print("handle notif from hare and goto specific view")
            isPushReceived = true
            self.handlePush(false)
            break
        case .background:
            break
        default:
            break
        }
    }
    
    
    
    func handlePush(_ appstate:Bool)
    {
        if appstate == true {//active
            
        }
        else//inactive
        {
            if (isPushReceived) {
                
                if backgroundNotifDict != nil {
                    NSLog("backgroundNotifDict inactive\(String(describing: backgroundNotifDict))")
                }
                else {
                    if let id = notifDict?["Id"] as? String {
                        self.sen_Id = id
                    }
                    if let employer_id = notifDict?["sender_id"] as? String {
                        self.sender_id = employer_id
                    }
                    if let user_id = notifDict?["sender_type"] as? Int {
                        self.sender_type = user_id
                    }
                    if let type = notifDict?["type"] as? Int {
                        self.notifyType = type
                        NSLog("background params inactive type \(String(describing: notifDict))")
                    }
                }
                
                if backgroundNotifDict != nil {
                    NSLog("backgroundNotifDict params inactive type \(String(describing: backgroundNotifDict))")
                }
                else{
                    if self.notifyType == 1 {
                        let rootViewController = self.window!.rootViewController as!
                        UINavigationController
                        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                        let CoachTabVC = mainStoryboard.instantiateViewController(withIdentifier: "CoachesTabbarVC") as! CoachesTabbarVC
                        rootViewController.pushViewController(CoachTabVC, animated: true)
                    }
                    else if self.notifyType == 2 {
                        NSLog("background params notifyType2 \(String(describing: tabbarVC))")
                        isPushReceived = true
                        NSLog("background params notifyType2 \(String(describing: notifDict))")
                        
                        
                        NSLog("RKGupta-->Appdelegate called"); //ravi 20feb018
                        tabbarVC?.selectedIndex = 1
                        // _ = tabbarVC?.viewControllers?[1] as? UINavigationController
                    }
                    else if self.notifyType == 3 {
                        isPushReceived = true
                        if self.sender_type == 1 {
                            let rootViewController = self.window!.rootViewController as!
                            UINavigationController
                            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                            let CoachTabVC = mainStoryboard.instantiateViewController(withIdentifier: "CoachesTabbarVC") as! CoachesTabbarVC
                            rootViewController.pushViewController(CoachTabVC, animated: true)
                        }else {
                            let rootViewController = self.window!.rootViewController as!
                            UINavigationController
                            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                            let CoachTabVC = mainStoryboard.instantiateViewController(withIdentifier: "HomeTabbarVC") as! HomeTabbarVC
                            rootViewController.pushViewController(CoachTabVC, animated: true)
                        }
                        
                    }
                    else if self.notifyType == 4 {
                        isPushReceived = true
                        tabbarVC?.selectedIndex = 1
                        _ = tabbarVC?.viewControllers?[1] as? UINavigationController
                    }
                    else if self.notifyType == 5 {
                        isPushReceived = true
                        tabbarVC?.selectedIndex = 1
                        _ = tabbarVC?.viewControllers?[1] as? UINavigationController
                    }
                    else if self.notifyType == 6 {
                        let rootViewController = self.window!.rootViewController as!
                        UINavigationController
                        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                        let CoachTabVC = mainStoryboard.instantiateViewController(withIdentifier: "CoachesTabbarVC") as! CoachesTabbarVC
                        rootViewController.pushViewController(CoachTabVC, animated: true)
                    }
                    else if self.notifyType == 7 {
                        //isPushReceived = true
                        //tabbarVC?.selectedIndex = 3
                    }
                    
                }
                
            }
        }
    }
    
    //MARK:- *****Show Notification Alert Method ******
    func showAlertForViewDetail(userInfo: [String:Any])
    {
        //let dict = (userInfo["aps"] as! NSDictionary)
        let alertMessageDict = userInfo["alert"] as? [String:Any]
        let bodyMessage = alertMessageDict!["body"] as? String ?? ""
        
        let parentViewController: UIViewController = UIApplication.shared.keyWindow!.rootViewController!
        
        let alert = UIAlertController(title: "Notifications", message: bodyMessage, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: {(action: UIAlertAction!) in
            
            self.moveToNotificationScreen()
            
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.destructive, handler: {(action: UIAlertAction!) in
            /// action on button , write something
        }))
        parentViewController.present(alert, animated: true, completion: nil)
    }
    
    
    
    //
    func moveToNotificationScreen()
    {
        //self.ischatNotifi = true
        let notiType = notifDict?["type"] as? Int
        let senderType = notifDict?["sender_type"] as? Int
        // friend request
        if notiType == 1 {
            let rootViewController = self.window!.rootViewController as!
            UINavigationController
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let CoachTabVC = mainStoryboard.instantiateViewController(withIdentifier: "CoachesTabbarVC") as! CoachesTabbarVC
            rootViewController.pushViewController(CoachTabVC, animated: true)
        }
            // friend request accepted
        else if senderType == 2 {
            isPushReceived = true
            tabbarVC?.selectedIndex = 1
            _ = tabbarVC?.viewControllers?[1] as? UINavigationController
        }
        else if notiType == 5 {
            isPushReceived = true
            tabbarVC?.selectedIndex = 1
            _ = tabbarVC?.viewControllers?[1] as? UINavigationController
        }
        else if notiType == 4 {
            isPushReceived = true
            tabbarVC?.selectedIndex = 1
            _ = tabbarVC?.viewControllers?[1] as? UINavigationController
        }
    }
    
    
    
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
      
//        manager = SocketManager(socketURL: URL(string: "http://13.228.52.104:3002/")!, config:["connectParams": queryDic])
//        socket = manager.defaultSocket
//        socket = manager.socket(forNamespace: "/advisor")
//        socket?.on(clientEvent: .connect) {data, ack in
//            print("socket connected")
//            print("ravi-->socket connected \(data) \(ack)")
//            print("socket connected")
//
//        }
//        socket?.connect()
        
        
        /********************** touch id and passcode when app gets enter into foreground **/
       
        if  stringLoad ==  "YES" {

        }else{
            let str2 =   kUserTouchAndPassCode.string(forKey: "Touchid")

            if str2 == "NO" {
                let str1 =   kUserTouchAndPassCode.string(forKey: "Passcode")
                if str1 == "NO"{

                }else if str1 ==  "YES"{
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let viewController2 = storyboard.instantiateViewController(withIdentifier: "TouchScreen")

                    self.window?.rootViewController?.present(viewController2, animated: true, completion: nil)
                }

            }else if str2 == "YES"{
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let viewController2 = storyboard.instantiateViewController(withIdentifier: "TouchScreen")

                self.window?.rootViewController?.present(viewController2, animated: true, completion: nil)
            }
        }
        
    }
    
   
    

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    //MARK:- ************ Hit Api to get coach category details ***************
    
    func getCategoryDetails() {
        
        WebServices().hitAPiTogetDetails(serviceType:kGETALL_CATEGORY) { (responseData)  in
            stopProgressIndicator()
            if responseData != nil
            {
                let code = responseData?["code"] as? NSNumber
                print("responseData",responseData ?? "")
                if code == 200{
                    stopProgressIndicator()
                    
                    self.getPricingDetails()
                    guard let resultArray = responseData?["result"] as? NSArray else {
                        return
                    }
                     saveCategoryDetails(categoryList: resultArray)
                     print("category list ======",getCategoryList())
                 }
                    
                 else {}
            }            else{ }
            
        }
    }
    
    func getPricingDetails() {
    //    showProgressIndicator(refrenceView: self.view)
          var requestDict = [String: String]()
        //  let requestDict = NSDictionary()
        
      //  var requestDict = [AnyHashable: Any]()
       // requestDict["type"] = 1
        WebServices().mainFunctiontoGetDetails(data: requestDict as NSDictionary, serviceType:kGET_CoachPricingDetails) { (responseData)  in
            
            if responseData != nil
            {
                let code = responseData?["code"] as? NSNumber
                print("responseData",responseData ?? "")
                if code == 200 {
                    stopProgressIndicator()
                    
                   
                    guard let resultArray = responseData?["result"] as? NSArray else {
                        return
                    }
                    savePricingDetails(categoryList: resultArray)
                    print("category list ======",getCategoryList())
                }
                    
                else {}
            }
            else {
                if let message = responseData?["result"] as? String {
                   // notifyUser("", message: message , vc: self)
                }
                else{
                    //notifyUser("", message: "Something went wrong", vc: self)
                }
            }
        }
        
        
    }
}


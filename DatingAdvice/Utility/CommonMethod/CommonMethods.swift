//
//  CommonMethods.swift
//  DatingAdvice
//
//  Created by daniel helled on 13/09/17.
//  Copyright © 2017 daniel helled. All rights reserved.
//

import Foundation
import UIKit
import SystemConfiguration

//********************************* Constants *************************************
let SCREEN_WIDTH = UIScreen.main.bounds.width
let SCREEN_HEIGHT = UIScreen.main.bounds.height
let SCREEN_SIZE  = UIScreen.main.bounds
let APPDELEGATE = UIApplication.shared.delegate as! AppDelegate

 func notifyUser(_ title: String, message: String, vc: UIViewController) -> Void
{
    let alert = UIAlertController(title: title,
                                  message: message,
                                  preferredStyle: UIAlertControllerStyle.alert)
    
    let cancelAction = UIAlertAction(title: "OK",
                                     style: .cancel, handler: nil)
    
    alert.addAction(cancelAction)
    //vc will be the view controller on which you will present your alert as you cannot use self because this method is static.
    vc.present(alert, animated: true, completion: nil)
}


func moveToTabbarScreen()
{
    
}

func pushView(viewController: UIViewController, identifier : String){
    let vc = viewController.storyboard?.instantiateViewController(withIdentifier: identifier)
    viewController.navigationController?.pushViewController(vc!, animated: true)
}

func pushView_ToFilterAdvisor(viewController: UIViewController, identifier : String, type : String, filter: Bool){
    let vc = viewController.storyboard?.instantiateViewController(withIdentifier: identifier) as? AllAdvisorsVC
    vc?.filteredType = type
    vc?.checkFiltered = filter
    viewController.navigationController?.pushViewController(vc!, animated: true)
}
//func moveToHomeScreen()
//{
//    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
//    let initialViewController = storyBoard.instantiateViewControllerWithIdentifier("HomTabViewController") as! HomTabViewController
//    let navigationController = UINavigationController(rootViewController: initialViewController)
//    APPDELEGATE.window?.rootViewController = navigationController
//    APPDELEGATE.window?.makeKeyAndVisible()
//}
func moveToLoginScreen(){
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let initialViewController = storyboard.instantiateViewController(withIdentifier: "LaunchViewController")
    let navigationController = UINavigationController(rootViewController: initialViewController)
    APPDELEGATE.window?.rootViewController = navigationController
    APPDELEGATE.window?.makeKeyAndVisible()
}

//MARK: ****** Set border width, corner radius of button ********
@IBDesignable extension UIButton {
    
    @IBInspectable var borderWidth: CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        set {
            layer.cornerRadius = newValue
        }
        get {
            return layer.cornerRadius
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        set {
            guard let uiColor = newValue else { return }
            layer.borderColor = uiColor.cgColor
        }
        get {
            guard let color = layer.borderColor else { return nil }
            return UIColor(cgColor: color)
        }
    }
}



//MARK: Activity Indicator view
var activityIndicatorView :UIActivityIndicatorView?

func showProgressIndicator(refrenceView:UIView?,opacity:Float = 0.7){
    if activityIndicatorView == nil{
        activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    }
    activityIndicatorView?.backgroundColor = UIColor.white
    activityIndicatorView?.layer.opacity = opacity
    activityIndicatorView?.hidesWhenStopped = true
    activityIndicatorView?.startAnimating()
    if refrenceView == nil {
        if let window :UIWindow = UIApplication.shared.keyWindow {
            activityIndicatorView?.frame = window.bounds
            window.addSubview(activityIndicatorView!)
        }
    }else{
        activityIndicatorView?.frame = refrenceView!.bounds
        refrenceView!.addSubview(activityIndicatorView!)
    }
    
}

func stopProgressIndicator(){
    DispatchQueue.main.async(execute: { () -> Void in
        //dispatch_get_main_queue().asynchronously(execute: { () -> Void in
        activityIndicatorView?.stopAnimating()
        activityIndicatorView?.removeFromSuperview()
        activityIndicatorView?.isHidden = true})
}
func checkIsConnectedToNetwork() -> Bool {
    
    let reachability = Reachability()!
    reachability.whenReachable = { reachability in
        if reachability.connection == .wifi {
            //return true
        } else {
          //  return true
        }
    }
    reachability.whenUnreachable = { _ in
        return false
    }
    
    do {
        try reachability.startNotifier()
    } catch {
        print("Unable to start notifier")
    }
    return true
    
}

/*********************** Func to get the color form hex code of color *********/
func hexStringToUIColor (hex:String) -> UIColor {
    var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
    
    if (cString.hasPrefix("#")) {
        cString.remove(at: cString.startIndex)
    }
    
    if ((cString.count) != 6) {
        return UIColor.gray
    }
    
    var rgbValue:UInt32 = 0
    Scanner(string: cString).scanHexInt32(&rgbValue)
    
    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat(1.0)
    )
}
/*********************** Func to get the color form hex code of color *********/
func isInternetAvailable() -> Bool
{
    var zeroAddress = sockaddr_in()
    zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
    zeroAddress.sin_family = sa_family_t(AF_INET)
    
    let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
        $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
            SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
        }
    }
    
    var flags = SCNetworkReachabilityFlags()
    if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
        return false
    }
    let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
    let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
    return (isReachable && !needsConnection)
}
//MARK:- ************** Save User details into locale *******
func saveUserDetails(userDict:NSDictionary){
    print(userDict)
     UserDefaults.standard.setValue(NSKeyedArchiver.archivedData(withRootObject: userDict), forKey: "USERDETAILS")
    
}
func removeUserDetails(){
    UserDefaults.standard.setValue(nil, forKey: "USERDETAILS")
    
}
func getUserDetails() -> NSDictionary {
    
    if let userObject = UserDefaults.standard.value(forKey: "USERDETAILS") as? NSData {
         guard let dict  = NSKeyedUnarchiver.unarchiveObject(with: userObject as Data) as? NSDictionary else {return NSDictionary() }
        return dict
    }
    return NSDictionary()
}
func getUserStripe_CustomerId() -> String {
    let dict =  getUserDetails()
    guard let userStripeCustomerId =  dict["stripe_customerId"] as? String else {return ""}
    return userStripeCustomerId
}

func getTotalEarning() -> String {
    let dict =  getUserDetails()
    guard let coachEarning =  dict["total_earn"] as? String else {return ""}
    return coachEarning
}
func getUserBalance() -> String {
    let dict =  getUserDetails()
    guard let UserBalance =  dict["balance"] as? String else {return ""}
    return UserBalance
}

func getUserEmail() -> String {
   let dict =  getUserDetails()
   guard let useremail =  dict["email"] as? String else {return ""}
   return useremail
}
func getUserServiceTax() -> String {
    let dict =  getUserDetails()
    print(dict)
   guard  let serviceTax =  dict["service_tax"] as? String else {return ""}
    print(serviceTax)
    return serviceTax
}

func getUserChatClosedDays() -> String {
    let dict =  getUserDetails()
    guard let closeChatDays =  dict["close_chat"] as? String else {return ""}
    return closeChatDays
}
func getFirstName() -> String {
    let dict =  getUserDetails()
    guard let username =  dict["fname"] as? String else {return ""}
    return username
}
func getIntroVideoUrl() -> String {
    let dict =  getUserDetails()
    guard let username =  dict["coach_video"] as? String else {return ""}
    return username
}

func getVideoThumbUrl() -> String {
    let dict =  getUserDetails()
    guard let username =  dict["coach_video_thumb"] as? String else {return ""}
    return username
}
func getLastName() -> String {
    let dict =  getUserDetails()
    guard let username =  dict["lname"] as? String else {return ""}
    return username
}
func getProfilePicUrl() -> String {
    let dict =  getUserDetails()
    guard let profilePicUrl =  dict["profile_pic"] as? String else {return ""}
    return profilePicUrl
}
func getAddress() -> String {
    let dict =  getUserDetails()
    guard let username =  dict["address"] as? String else {return ""}
    return username
}
func getPhoneNo() -> String {
    let dict =  getUserDetails()
    guard let username =  dict["phone_no"] as? String else {return ""}
    return username
}
func getProfilePic() -> String {
    let dict = getUserDetails()
    guard let username =  dict["profile_pic"] as? String else {return ""}
    return username
}
func getUserId() -> String {
    let dict =  getUserDetails()
    guard let username =  dict["_id"] as? String else {return ""}
    return username
}
func getSessionId() -> String {
    let dict =  getUserDetails()
    guard let username =  dict["sessionId"] as? String else {return ""}
    return username
}
func getLocationPoint() -> NSArray {
    let dict = getUserDetails()
    guard let username =  dict["longlat"] as? NSArray else {return NSArray()}
    return username
}
func getRushDirectPrice() -> String {
    let dict =  getUserDetails()
    guard let rush_direct =  dict["rush_direct_price"] as? String else {return ""}
    return rush_direct
}
func getDirectPrice() -> String {
    let dict =  getUserDetails()
    guard let direct_Price =  dict["direct_price"] as? String else {return ""}
    return direct_Price
}

func getLiveChatPrice() -> String {
    let dict = getUserDetails()
    guard let liveChat_Price =  dict["livechat_price"] as? String else {return ""}
    return liveChat_Price
}

func getAboutDetail() -> String {
    let dict = getUserDetails()
    guard let aboutDetail =  dict["about"] as? String else {return ""}
    return aboutDetail
}

func getAbout_services() -> String {
    let dict =  getUserDetails()
    guard let aboutServices =  dict["about_services"] as? String else {return ""}
    return aboutServices
}

func getCategoryArray() -> NSArray {
    let dict =  getUserDetails()
    guard let categoryArray =  dict["categories"] as? NSArray else {return NSArray()}
    return categoryArray
}

func getDirect_Status() -> Int {
    let dict =  getUserDetails()
    guard let direct_Status = dict["direct_Status"] as? Int else  {return 0}
    return direct_Status
}

func getRushDirect_Status() -> Int {
    let dict =  getUserDetails()
    guard let rush_direct_Status = dict["rush_direct_Status"] as? Int else  {return 0}
    return rush_direct_Status
}
func getlivechat_Status() -> Int {
    let dict =  getUserDetails()
    guard let livechat_Status = dict["livechat_Status"] as? Int else  {return 0}
    return livechat_Status
}

func isCoach() -> Bool {
    let dict =  getUserDetails()
    guard let coachStatus = dict["isCoach"] as? Bool else  {return false}
    return coachStatus
}
func getUserNotificationKey() -> Bool {
    let dict =  getUserDetails()
    guard let notification =  dict["notification"] as? Bool
        else {
            return false
    }
    return notification
}

func saveCategoryDetails(categoryList:NSArray){
    UserDefaults.standard.setValue(NSKeyedArchiver.archivedData(withRootObject: categoryList), forKey: "CATEGORY")
}
func savePricingDetails(categoryList:NSArray){
    UserDefaults.standard.setValue(NSKeyedArchiver.archivedData(withRootObject: categoryList), forKey: "PRICING")
}

func getCategoryList() -> NSArray {
    
    if let userObject = UserDefaults.standard.value(forKey: "CATEGORY") as? NSData {
        guard let categoryList  = NSKeyedUnarchiver.unarchiveObject(with: userObject as Data) as? NSArray else {return NSArray() }
        return categoryList
    }
    return NSArray()
}
func getPricingList() -> NSArray {
    
    if let userObject = UserDefaults.standard.value(forKey: "PRICING") as? NSData {
        guard let categoryList  = NSKeyedUnarchiver.unarchiveObject(with: userObject as Data) as? NSArray else {return NSArray() }
        return categoryList
    }
    return NSArray()
}

//MARK:- ************** Generate UUID *******
func generateUUID() -> String {
    let uuid = UUID().uuidString
    return uuid
}

func getCategoryList(array:NSArray) -> String
{
    var  categoryList = ""
    for str  in array
    {
        if categoryList == ""
        {
            categoryList = categoryList+(str as! String)
        }
        else
        {
            categoryList = categoryList+", "+(str as? String ?? "")
        }
    }
    return categoryList
}

func convertStringintoDate(dateStr:String) -> Date{
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    //dateFormatter.timeZone = TimeZone(abbreviation: "GMT+0:00") //Current time zone
    dateFormatter.locale = NSLocale.init(localeIdentifier: "en_US_POSIX") as Locale!
    dateFormatter.timeZone = NSTimeZone(name: "GMT")! as TimeZone
    let date = dateFormatter.date(from: dateStr) //according to date format your date string
    print(date ?? Date()) //Convert String to Date
    return date ?? Date()
}




//
//  CoachesTabbarVC.swift
//  Intrigued
//
//  Created by daniel helled on 06/10/17.
//  Copyright © 2017 daniel helled. All rights reserved.
//

import UIKit
import SocketIO
class CoachesTabbarVC: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let tabBar = self.tabBar
//
//        let UUIDValue = UIDevice.current.identifierForVendor!.uuidString
//        var queryDic = [AnyHashable: Any]()
//        queryDic["id"] = getUserId() as String
//        queryDic["deviceToken"] = UserDeviceToken
//        //     queryDic["deviceToken"] = "74fa04984114ca830f5e5b2f6ffe398dc25595ec5322cd8177b636b7450177ce"
//        queryDic["deviceId"] = UUIDValue
//        queryDic["deviceType"] = "I"
//
//        if isCoach() {
//            queryDic["type"] = 2
//        }else {
//            queryDic["type"] = 1
//        }
//        print(queryDic)
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
////
        if  firstTimeCoachSignUp ==  "YES" {
      //    notifyUser("", message: "Welcome to Intrigued! We are reviewing your new profile for approval and will be in touch shortly." , vc: self)
            
            
            let alert = UIAlertController(title: "", message: "", preferredStyle: UIAlertControllerStyle.alert)
            let titleFont = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 18)]
            let messageFont = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 17)]
            
            let titleAttrString = NSMutableAttributedString(string: "Welcome to Intrigued!", attributes: titleFont)
            let messageAttrString = NSMutableAttributedString(string: "\n We are reviewing your new profile for approval and will be in touch shortly.", attributes: messageFont)
            
            alert.setValue(titleAttrString, forKey: "attributedTitle")
            alert.setValue(messageAttrString, forKey: "attributedMessage")
            
            
            alert.addAction(UIAlertAction(title: "Ok.", style: .default, handler: { action in
               
            }))
            
            self.present(alert, animated: true, completion: nil)
            
            firstTimeCoachSignUp = "NO"
        }else{
        }
        
        let tabSession = tabBar.items![0]
        tabSession.image=UIImage(named: "my_session_unsel")?.withRenderingMode(.alwaysOriginal) // deselect image
        tabSession.selectedImage = UIImage(named: "my_session_sel")?.withRenderingMode(.alwaysOriginal) // select image
   
     /************* add badgeCount on tabbar item  *************************/
//        tabBar.items![0].badgeValue = "2"
//        tabBar.items![0].badgeColor = UIColor.red
     /************* add badgeCount on tabbar item *************************/
        
        let tabEarn = tabBar.items![1]
        tabEarn.image=UIImage(named: "earn_unsel")?.withRenderingMode(.alwaysOriginal)
        tabEarn.selectedImage = UIImage(named: "earn_sel")?.withRenderingMode(.alwaysOriginal) // select image
        
        let tabProfile = tabBar.items![2]
        tabProfile.image=UIImage(named: "profile_unsel")?.withRenderingMode(.alwaysOriginal) // deselect image
        tabProfile.selectedImage = UIImage(named: "profile_sel")?.withRenderingMode(.alwaysOriginal) // select image
        let tabSetting = tabBar.items![3]
        tabSetting.image=UIImage(named: "setting_unsel")?.withRenderingMode(.alwaysOriginal) // deselect image
        tabSetting.selectedImage = UIImage(named: "setting_sel")?.withRenderingMode(.alwaysOriginal) // select image
         navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05, execute: {
          self.presentController()
        })
        
    }
    func presentController() {
        
        if  stringLoad ==  "YES" {
            
        }else{
           
            let str2 =   kUserTouchAndPassCode.string(forKey: "Touchid")
            
            if str2 == "NO" {
                let str1 =   kUserTouchAndPassCode.string(forKey: "Passcode")
                if str1 == "NO"{
                    
                }else if str1 ==  "YES"{
                    let viewController2 = self.storyboard?.instantiateViewController(withIdentifier: String("TouchScreen")) as! TouchScreen
                    
                    self.view.window?.rootViewController?.present(viewController2, animated: true, completion: nil)
                }
                
            }else if str2 == "YES"{
                let viewController2 = self.storyboard?.instantiateViewController(withIdentifier: String("TouchScreen")) as! TouchScreen
                
                self.view.window?.rootViewController?.present(viewController2, animated: true, completion: nil)
            }

            
        }
        
    }
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

   

}

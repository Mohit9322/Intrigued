//
//  HomeTabbarVC.swift
//  DatingAdvice
//
//  Created by daniel helled on 13/09/17.
//  Copyright © 2017 daniel helled. All rights reserved.
//

import UIKit
import SocketIO
class HomeTabbarVC: UITabBarController {
    
    var selectedTabIndex = 0
    override func viewDidLoad() {
        super.viewDidLoad()
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
//          print(queryDic)
//    
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

        
        appDelegateDeviceId.tabbarVC = self
        // appDelegateRef.tabControllerVc = self
        let tabBar = self.tabBar

        let tabCoaches = tabBar.items![0]
        tabCoaches.image=UIImage(named: "coaches_unsel")?.withRenderingMode(.alwaysOriginal) // deselect image
        tabCoaches.selectedImage = UIImage(named: "coaches_sel")?.withRenderingMode(.alwaysOriginal) // select image
       
        /************* add badgeCount on tabbar item  *************************/
//        tabBar.items![0].badgeValue = "2"
//        tabBar.items![0].badgeColor = UIColor.red
        self.repositionBadge(tabIndex: 1)
        /************* add badgeCount on tabbar item *************************/
        
        let tabSession = tabBar.items![1]
        tabSession.image=UIImage(named: "my_session_unsel")?.withRenderingMode(.alwaysOriginal) // deselect image
        tabSession.selectedImage = UIImage(named: "my_session_sel")?.withRenderingMode(.alwaysOriginal) // select image
        
        let tabProfile = tabBar.items![2]
        tabProfile.image=UIImage(named: "profile_unsel")?.withRenderingMode(.alwaysOriginal) // deselect image
        tabProfile.selectedImage = UIImage(named: "profile_sel")?.withRenderingMode(.alwaysOriginal) // select image
        
        let tabSetting = tabBar.items![3]
        tabSetting.image=UIImage(named: "setting_unsel")?.withRenderingMode(.alwaysOriginal) // deselect image
        tabSetting.selectedImage = UIImage(named: "setting_sel")?.withRenderingMode(.alwaysOriginal) // select image
        
       // tabHome.titlePositionAdjustment.vertical = tabHome.titlePositionAdjustment.vertical-4 // title position change
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
        // Do any additional setup after loading the view.
    }
    func repositionBadge(tabIndex: Int){
        
        for badgeView in self.tabBar.subviews[tabIndex].subviews {
            
            if NSStringFromClass(badgeView.classForCoder) == "_UIBadgeView" {
                badgeView.layer.transform = CATransform3DIdentity
                badgeView.layer.transform = CATransform3DMakeTranslation(47.0, 11.0,11.0)
            }
        }
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

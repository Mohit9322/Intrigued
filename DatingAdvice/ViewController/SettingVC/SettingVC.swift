//
//  SettingVC.swift
//  DatingAdvice
//
//  Created by daniel helled on 13/09/17.
//  Copyright © 2017 daniel helled. All rights reserved.
//

import UIKit
import MessageUI
import LocalAuthentication
import IQKeyboardManagerSwift

class SettingVC: UIViewController,UITableViewDelegate,UITableViewDataSource,MFMailComposeViewControllerDelegate {

    @IBOutlet weak var settingsTbleView: UITableView!
    var settingArray = NSArray()
        var pushKey:Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
     
        let context:LAContext = LAContext();
        var error:NSError?
        var _:Bool;
        let reason:String = "Please authenticate using TouchID.";
        
     
        if (context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: &error))
        {
            
              self.settingArray = ["Notifications","About","Privacy Policy","Terms of service","Customer Support","Touch Id/ PassCode", "Version"];
                
            }else {
            
          
            self.settingArray = ["Notifications","About","Privacy Policy","Terms of service","Customer Support","PassCode", "Version"]
            print("Not reconized user or you have crossed your limit.")
         
            
        }
        
//        {
//            settingArray = ["Notifications","About","Privacy Policy","Terms of service","Customer Support","PassCode", "Version"]
//            settingsTbleView.reloadData()
//            print("Not supprot Touch id")
//
//        }
        
        settingsTbleView.delegate = self
        settingsTbleView.dataSource = self
        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    @IBAction func swichValueChanged(_ sender: UISwitch) {
        sender.isOn = (sender as UISwitch).isOn
        UserDefaults.standard.set(sender.isOn, forKey: "autoAdjustSettings")
        UserDefaults.standard.synchronize()
        
        if sender.isOn == true {
            pushKey = true
            notificationON_OFF_Api(pushKey: pushKey ?? true)
        }
        else if sender.isOn == false {
            pushKey = false
            notificationON_OFF_Api(pushKey: pushKey ?? true)
        }
    }
    
    
    //MARK: ******* Notification ON OR OFF *************
    func notificationON_OFF_Api(pushKey:Bool) {
        
        var type:Int?
        var  service: String?
        if isCoach() {
            type = 2
            service = kNotification_Coach_ON_OFF
        }
        else{
            type = 1
            service = kNotification_ON_OFF
        }
        let request = ["user_id": getUserId(),"notification":pushKey,"type":type ?? 0] as [String : Any]
        print(request)
        WebServices().mainFunctiontoGetDetails(data: request as NSDictionary,serviceType:service ?? "") { (responseData)  in
            if responseData != nil
            {
                let code = responseData?["code"] as? NSNumber
                print("responseData",responseData ?? "")
                if code == 200{
                    stopProgressIndicator()
                    
                }
                else if code == 100{
                    if let message = responseData?["result"] as? String {
                        notifyUser("", message: message , vc: self)
                    }
                }
                else if code == 500{
                    if let message = responseData?["result"] as? String {
                        notifyUser("", message: message , vc: self)
                    }
                }
            }
            
        }
    }
    
    //MARK: *********** UITABLE VIEW DELEGATE **************
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         if section == 1 {
            return 6
         }
         return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: SettingCell! =  tableView.dequeueReusableCell(withIdentifier: "SettingCell") as? SettingCell
        cell.selectionStyle = .none
        cell.lbl_details.isHidden = true
        cell.view_BottomSepartor.isHidden = true
        cell.view_Logout.isHidden = true
        if indexPath.section == 0 {
            cell.next_icon.isHidden = true
            cell.lbl_SettingTitle.text = settingArray[indexPath.row] as? String
            cell.switchView.isHidden = false
            cell.view_BottomSepartor.isHidden = false
             cell.switchOn_Off.setOn(getUserNotificationKey(), animated: true)
            
        }
        else if indexPath.section == 1{
             cell.lbl_SettingTitle.text = settingArray[indexPath.row+1] as? String
             if indexPath.row == 5 {
                cell.lbl_details.isHidden = false
                cell.next_icon.isHidden = true
                cell.lbl_details.text = "1.0"
                cell.view_BottomSepartor.isHidden = false
            }
        }
        else if indexPath.section == 2{
            cell.view_Logout.isHidden = false
            cell.view_BottomSepartor.isHidden = false
        }
        return cell
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
       let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 40))
       let header_lbl = UILabel(frame: CGRect(x: 15, y: 0, width: 200, height: 40))
        if section == 1{
            header_lbl.text = "MORE"
        }
        header_lbl.font =  UIFont.boldSystemFont(ofSize: 14)
        headerView.addSubview(header_lbl)
        return headerView
   }
        
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return 50
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat{
        if section == 0 || section == 2  {
            return 20
        }
        return 40
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        if indexPath.section == 1{
            if indexPath.row == 0 || indexPath.row == 1 || indexPath.row == 2 {
                pushView(viewController: self, identifier: "AboutVC")
            }else if indexPath.row == 3{
                let mailComposeViewController = configuredMailComposeViewController()
                if MFMailComposeViewController.canSendMail() {
                    self.present(mailComposeViewController, animated: true, completion: nil)
                } else {
                    self.showSendMailErrorAlert()
                }
            }else if indexPath.row == 4{
        pushView(viewController: self, identifier: "PassCodeSettingVc")
           //      pushView(viewController: self, identifier: "IntroductoryVideoVC")
           //     pushView(viewController: self, identifier: "VideoCameraVc")
                
       
            }
        }
        else if indexPath.section == 2 {
           
            kUserTouchAndPassCode.set("NO", forKey: "Passcode")
            kUserTouchAndPassCode.set("NO", forKey: "Touchid")
            kUserTouchAndPassCode.synchronize()
          
            logoutUser()
            
        }
    }
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        
        mailComposerVC.setToRecipients(["support@intrigued.co"])
        mailComposerVC.setSubject("Contact to Intrigued")
     //   mailComposerVC.setMessageBody("mohit", isHTML: false)
   //     mailComposerVC.setBccRecipients(["mohittyagi.shineweb@gmail.com"])
    //    mailComposerVC.setCcRecipients(["abctest@gmail.com"])
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertView(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", delegate: self, cancelButtonTitle: "OK")
        sendMailErrorAlert.show()
    }
    
    // MARK: MFMailComposeViewControllerDelegate Method
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func logoutUser() {
        
        showProgressIndicator(refrenceView: self.view)
        var type = ""
        if isCoach() {
            type = "1"
        }
        else{
             type = "2"
        }
        let request = ["user_id": getUserId(),"type":type] as [String : Any]
        WebServices().mainFunctiontoGetDetails(data: request as NSDictionary,serviceType:kLOGOUT) { (responseData)  in
            stopProgressIndicator()
            if responseData != nil
            {
                let code = responseData?["code"] as? NSNumber
                print("responseData",responseData ?? "")
                if code == 200{
                    stopProgressIndicator()
                    removeUserDetails()
                    GIDSignIn.sharedInstance().signOut()
                    moveToLoginScreen()
                    
                    
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

//
//  PassCodeSettingVc.swift
//  Intrigued
//
//  Created by Shineweb-solutions on 15/01/18.
//  Copyright © 2018 daniel helled. All rights reserved.
//

import UIKit
import LocalAuthentication

class PassCodeSettingVc: UIViewController,UITableViewDelegate, UITableViewDataSource {
   
    

    @IBOutlet var HeaderBaseview: UIView!
    @IBOutlet var BaseView: UIView!
    @IBOutlet var BackBtn: UIButton!
    @IBOutlet weak var settingTblView: UITableView!
    var numberOfRows: Int?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let context:LAContext = LAContext();
        var error:NSError?
        var _:Bool;
        let reason:String = "Please authenticate using TouchID.";
        
        
        if (context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: &error))
        {
            
            self.numberOfRows = 3
            
        }else {
            
            
           numberOfRows = 2
            print("Not reconized user or you have crossed your limit.")
            
            
        }
        
        BaseView.backgroundColor =  hexStringToUIColor(hex: "#34a0ce")
        settingTblView.delegate = self
        settingTblView.dataSource = self
        settingTblView.tableFooterView = UIView()
        // Do any additional setup after loading the view.
    }
   
        @IBAction func BackBtnPressed(_ sender: Any) {
             self.navigationController?.popViewController(animated: true)
        }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        return numberOfRows!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if numberOfRows == 3 {
            if indexPath.row == 0 || indexPath.row == 1
            {
                let cell:switchPassCodeCell! =  tableView.dequeueReusableCell(withIdentifier: "switchPassCodeCell") as? switchPassCodeCell
                cell.switch.addTarget(self, action: #selector(switchChanged), for: UIControlEvents.valueChanged)
                if indexPath.row == 0{
                    cell.titleLbl.text = "Touch Id"
                    
                    let str2 =   kUserTouchAndPassCode.string(forKey: "Touchid")
                    
                    if str2 == "NO" {
                        cell.switch.isOn = false
                    }else if str2 == "YES"{
                        cell.switch.isOn = true
                    }
                }else{
                    cell.titleLbl.text = "Passcode"
                    let str1 =   kUserTouchAndPassCode.string(forKey: "Passcode")
                    if str1 == "NO" {
                        cell.switch.isOn = false
                    }else if str1 == "YES"{
                        cell.switch.isOn = true
                    }
                }
                
                cell.switch.tag = indexPath.row
                cell.selectionStyle = .none
                return cell
            }else{
                let cell:changePassCodeCell! =  tableView.dequeueReusableCell(withIdentifier: "changePassCodeCell") as? changePassCodeCell
                cell.titleLbl.text = "Change PassCode"
                cell.selectionStyle = .none
                return cell
            }
        } else if numberOfRows == 2 {
            if indexPath.row == 0
            {
                let cell:switchPassCodeCell! =  tableView.dequeueReusableCell(withIdentifier: "switchPassCodeCell") as? switchPassCodeCell
                cell.switch.addTarget(self, action: #selector(switchChanged), for: UIControlEvents.valueChanged)
               
                    cell.titleLbl.text = "Passcode"
                    let str1 =   kUserTouchAndPassCode.string(forKey: "Passcode")
                    if str1 == "NO" {
                        cell.switch.isOn = false
                    }else if str1 == "YES"{
                        cell.switch.isOn = true
                    }
                
                cell.switch.tag = indexPath.row + 1
                cell.selectionStyle = .none
                return cell
            }else{
                let cell:changePassCodeCell! =  tableView.dequeueReusableCell(withIdentifier: "changePassCodeCell") as? changePassCodeCell
                cell.titleLbl.text = "Change PassCode"
                cell.selectionStyle = .none
                return cell
            }
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "changePassCodeCell") as! changePassCodeCell
     return cell
      
    }
    
    @objc func switchChanged(mySwitch: UISwitch) {
        let value = mySwitch.isOn
        let tagValue = mySwitch.tag
        if value {
            if tagValue == 0 {
                
                kUserTouchAndPassCode.set("YES", forKey: "Touchid")
                kUserTouchAndPassCode.synchronize()
            }else if tagValue == 1{
                kUserTouchAndPassCode.set("YES", forKey: "Passcode")
                kUserTouchAndPassCode.synchronize()
               
                    pushView(viewController: self, identifier: "SetPassCodeVc")
               
            }
        }else{
            if tagValue == 0 {
                kUserTouchAndPassCode.set("NO", forKey: "Touchid")
                kUserTouchAndPassCode.synchronize()
                
            }else if tagValue == 1{
                kUserTouchAndPassCode.set("NO", forKey: "Passcode")
                kUserTouchAndPassCode.synchronize()
              
                
            }
        }
        
        // Do something
    }
   
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if numberOfRows == 3 {
            if indexPath.row == 2{
                let str2 =   kUserTouchAndPassCode.string(forKey: "Passcode")
                
                if str2 == "NO" {
                    let alert = UIAlertController(title: "Alert", message: "Please Enable Passcode", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { action in
                        
                    }))
                    self.present(alert, animated: true, completion: nil)
                    
                }else if str2 == "YES"{
                    pushView(viewController: self, identifier: "PassCodeTouch")
                }
                
            }
        }else if numberOfRows == 2 {
            if indexPath.row == 1{
                let str2 =   kUserTouchAndPassCode.string(forKey: "Passcode")
                
                if str2 == "NO" {
                    let alert = UIAlertController(title: "Alert", message: "Please Enable Passcode", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { action in
                        
                    }))
                    self.present(alert, animated: true, completion: nil)
                    
                }else if str2 == "YES"{
                    pushView(viewController: self, identifier: "PassCodeTouch")
                }
                
            }
        }
       
       
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    

}

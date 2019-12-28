//
//  ChangePasswordVC.swift
//  DatingAdvice
//
//  Created by daniel helled on 15/09/17.
//  Copyright © 2017 daniel helled. All rights reserved.
//

import UIKit

class ChangePasswordVC: UIViewController {

    @IBOutlet weak var oldPassword_TF: UITextField!
    @IBOutlet weak var newPasswordTF: UITextField!
    @IBOutlet weak var confirmPasswordTF: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    @IBAction func backButtonAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveButtonAction(_ sender: Any) {
        if ischeckManadoryDetails() {
            
            let request = ["user_id":getUserId(),"old_password": oldPassword_TF.text ?? "","new_password": newPasswordTF.text ?? "","c_password": confirmPasswordTF.text ?? ""]
            showProgressIndicator(refrenceView: self.view)
            WebServices().mainFunctiontoGetDetails(data: request as NSDictionary,serviceType:kCHANGE_PASSWORD) { (responseData)  in
                stopProgressIndicator()
                if responseData != nil
                {
                    let code = responseData?["code"] as? NSNumber
                    print("responseData",responseData ?? "")
                    if code == 200{
                        guard let message = responseData?["result"] as? String else {
                            return
                        }
                         DispatchQueue.main.async(execute: {
                            notifyUser("", message: message, vc: self)
                         })
                        self.navigationController?.popViewController(animated: true)
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
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //MARK: ****** Check Field is empty / valid **************
    func ischeckManadoryDetails() -> Bool {
        
        if String.isNilOrEmpty(self.oldPassword_TF.text)  {
            notifyUser("", message: kOLD_PASSWORD_BLANK, vc: self)
            return false
        }
        else if String.isNilOrEmpty(self.newPasswordTF.text) {
            notifyUser("", message: kNEW_PASSWORD_BLANK, vc: self)
            return false
        }
//        else if String.isNilOrEmpty(self.confirmPasswordTF.text) {
//            notifyUser("", message: kCONFIRM_PASSWORD_BLANK, vc: self)
//            return false
//        }
//        else if (self.newPasswordTF.text != self.confirmPasswordTF.text) {
//            notifyUser("", message: kPASSWORD_NOT_MATCH, vc: self)
//            return false
//        }
        return true
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

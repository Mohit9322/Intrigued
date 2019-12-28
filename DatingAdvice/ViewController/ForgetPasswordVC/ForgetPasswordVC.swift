//
//  ForgetPasswordVC.swift
//  DatingAdvice
//
//  Created by daniel helled on 15/09/17.
//  Copyright © 2017 daniel helled. All rights reserved.
//

import UIKit

class ForgetPasswordVC: UIViewController {

    @IBOutlet weak var email_TxtField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func submitButtonAction(_ sender: Any) {
        if ischeckManadoryDetails() {
            
            let request = ["email": email_TxtField.text ?? ""]
            showProgressIndicator(refrenceView: self.view)
            WebServices().mainFunctiontoGetDetails(data: request as NSDictionary,serviceType:kFORGOT_PASSWORD) { (responseData)  in
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
                      
                        
                       // pushView(viewController: self, identifier: "HomeTabbarVC")
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
        
        if String.isNilOrEmpty(self.email_TxtField.text)  {
            notifyUser("", message: kEMAIL_BLANK, vc: self)
            return false
        }
        else if !String.isValidEmail(self.email_TxtField.text) {
            notifyUser("", message: kVALID_EMAIL, vc: self)
            return false
        }
        
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

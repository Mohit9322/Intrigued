//
//  ViewController.swift
//  DatingAdvice
//
//  Created by daniel helled on 13/09/17.
//  Copyright © 2017 daniel helled. All rights reserved.
//

import UIKit

var stringLoad = String()

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        if isCoach() {
            self.getServiceTax(type: k_GET_COACH_SERVICE_TAX)
        }else {
            self.getServiceTax(type: k_GET_USER_SERVICE_TAX)
        }
        
        
       
       // Do any additional setup after loading the view, typically from a nib.
    }
    func getServiceTax(type:String) {
        
        
        let requestDict =   NSDictionary()
        print(requestDict)
     //   showProgressIndicator(refrenceView: self.view)
        WebServices().mainFunctiontoGetDetails(data: requestDict,serviceType:type) { (responseData)  in
            stopProgressIndicator()
            if responseData != nil
            {
                let code = responseData?["code"] as? NSNumber
                print("responseData",responseData ?? "")
                if code == 200{
                    if let resultDict = responseData?["result"] as? NSDictionary {
                        
                        CloseChatDays = resultDict["close_chat"] as? String ?? ""
                        ServiceTaxValue = resultDict["service_tax"] as? String ?? ""
                        if getUserId() != "" {
                            if isCoach(){
                                pushView(viewController: self, identifier: "CoachesTabbarVC")
                            }
                            else{
                                pushView(viewController: self, identifier: "HomeTabbarVC")
                            }
                        }
                        else{
                            pushView(viewController: self, identifier: "LaunchViewController")
                        }
                    }
                }
            }
            else{
                stopProgressIndicator()
            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


//
//  CoachesEarningVC.swift
//  Intrigued
//
//  Created by daniel helled on 06/10/17.
//  Copyright © 2017 daniel helled. All rights reserved.
//

import UIKit

class CoachesEarningVC: UIViewController {
   @IBOutlet weak var table_View: UITableView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var NoRecordLbl: UILabel!
    @IBOutlet weak var TotalEarningLbl: UILabel!
    var sessionArray = NSMutableArray()
    var type = Int()
   @IBOutlet weak var noRecordView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        type = 2
        
       
        segmentControl.translatesAutoresizingMaskIntoConstraints = true
        segmentControl.frame = CGRect(x: segmentControl.frame.origin.x, y: segmentControl.frame.origin.y, width: UIScreen.main.bounds.size.width-20, height: 35);
        
        //getCoachCompleteSessionDetails()
        // Do any additional setup after loading the view.
        if isCoach() {
            self.getServiceTax(type: k_GET_COACH_SERVICE_TAX)
        }else {
            self.getServiceTax(type: k_GET_USER_SERVICE_TAX)
        }
        
    }
    
    func getServiceTax(type:String) {
        
        
        let requestDict =   NSDictionary()
        print(requestDict)
        showProgressIndicator(refrenceView: self.view)
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
                    }
                }
            }
            else{
                stopProgressIndicator()
            }
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        if segmentControl.selectedSegmentIndex == 0 {
            type = 1
            self.NoRecordLbl.text =  "You have no Pending Earnings at this time."
            getCoachCompleteSessionDetails()
            print("Pending earnings")
        }
        else{
            
            print("Complete earnings")
            type = 2
            self.NoRecordLbl.text =  "You have no Completed Earnings at this time."
            getCoachCompleteSessionDetails()
           
        }
       
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //MARK:- ************ Hit Api to get coach details ***************
  
    @IBAction func segmentControlValue_Changed(_ sender: Any) {
        
        
        if segmentControl.selectedSegmentIndex == 0 {
            type = 1
            self.NoRecordLbl.text =  "You have no Pending Earnings at this time."
            getCoachCompleteSessionDetails()
            print("Pending earnings")
           
        }
        else{
        
            type = 2
            self.NoRecordLbl.text =  "You have no Completed Earnings at this time."
            getCoachCompleteSessionDetails()
        }
    }
    
    
    func getCoachCompleteSessionDetails() {
        
        self.noRecordView.isHidden = true
        self.table_View.isHidden = false
     let sessionID =    getSessionId() as String
        print(sessionID)
        showProgressIndicator(refrenceView: self.view)
        let request = ["coach_id": getUserId(),"pageNo":1,"type":type] as [String : Any]
        WebServices().mainFunctiontoGetDetails(data: request as NSDictionary,serviceType:kGET_COACH_EARNINGS) { (responseData)  in
            stopProgressIndicator()
            if responseData != nil
            {
                let code = responseData?["code"] as? NSNumber
                print("responseData",responseData ?? "")
                self.TotalEarningLbl.text = "$0.00"
                if code == 200{
                    stopProgressIndicator()
                    guard let resultArray = responseData?["result"] as? NSMutableArray else {
                        return
                    }
                    self.sessionArray = resultArray
                 
                    self.table_View.delegate = self
                    self.table_View.dataSource = self
                    self.table_View.reloadData()
                    let totalEarnValue = responseData?["total_earn"] as? NSNumber

                    let numberFormatter = NumberFormatter()
                    numberFormatter.minimumFractionDigits = 2
                    numberFormatter.maximumFractionDigits = 2
                    
                    let str = numberFormatter.string(from: totalEarnValue!)!
                    
                    print(str)
                    
                    self.TotalEarningLbl.text = "$" + str
                }
                else {
                    DispatchQueue.main.async(execute: {
                        self.noRecordView.isHidden = false
                    })
                    
                    self.table_View.isHidden = true
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
extension CoachesEarningVC : UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sessionArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = table_View.dequeueReusableCell(withIdentifier: "CoachEarningCell") as! CoachEarningCell
        let detailDict  = sessionArray.object(at: indexPath.row) as! NSDictionary
        print(detailDict)
        cell.setupDetailsonView(detailsDict: detailDict)
 
        return cell
    }
}

extension CoachesEarningVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 87
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
     
//        let vc = self.storyboard?.instantiateViewController(withIdentifier: "CoachRequestUserProfileVC") as! CoachRequestUserProfileVC
//        if let dict = sessionArray[indexPath.row] as? NSDictionary {
//            vc.userOrderInfo = dict
//        }
//        self.navigationController?.pushViewController(vc,animated: true)
//
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "EarningDetailVC") as! EarningDetailVC
        vc.userOrderInfo = self.sessionArray.object(at: indexPath.row) as! NSDictionary
        self.navigationController?.pushViewController(vc,animated: true)
        
    }
}

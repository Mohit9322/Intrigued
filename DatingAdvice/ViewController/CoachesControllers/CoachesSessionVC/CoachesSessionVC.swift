//
//  CoachesSessionVC.swift
//  Intrigued
//
//  Created by daniel helled on 06/10/17.
//  Copyright © 2017 daniel helled. All rights reserved.
//

import UIKit

class CoachesSessionVC: UIViewController {
    
    @IBOutlet weak var noRecordView: UIView!
    @IBOutlet weak var sessionTble_View: UITableView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var NoRecordLbl: UILabel!
    var sessionArray = NSMutableArray()
    
    
    var ChargeId : String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        noRecordView.isHidden = true
        getCoachSessionDetails(type:"2")
        // Do any
        segmentControl.translatesAutoresizingMaskIntoConstraints = true
        segmentControl.frame = CGRect(x: segmentControl.frame.origin.x, y: segmentControl.frame.origin.y, width: UIScreen.main.bounds.size.width-20, height: 35);
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
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
        if appDelegateDeviceId.isPushReceived == true {
            if appDelegateDeviceId.notifyType == 1 {
                appDelegateDeviceId.isPushReceived = false
                segmentControl.selectedSegmentIndex = 0
                getCoachSessionDetails(type:"2")
                self.sessionTble_View.reloadData()
            }
                // For Message notify
            else if appDelegateDeviceId.notifyType == 3 {
                appDelegateDeviceId.isPushReceived = false
                segmentControl.selectedSegmentIndex = 1
                getCoachSessionDetails(type:"1")
                self.sessionTble_View.reloadData()
            }
                // For Rating notify
            else if appDelegateDeviceId.notifyType == 6 {
                appDelegateDeviceId.isPushReceived = false
                segmentControl.selectedSegmentIndex = 2
                getCoachCompleteSessionDetails()
                self.sessionTble_View.reloadData()
            }
        }
        else {
            if segmentControl.selectedSegmentIndex == 0 {
                getCoachSessionDetails(type:"2")
            }else if segmentControl.selectedSegmentIndex == 1 {
                getCoachSessionDetails(type:"1")
            } else if segmentControl.selectedSegmentIndex == 2 {
                getCoachCompleteSessionDetails()
            }
            //getCoachSessionDetails(type:"2")
        }
    }
    
    //MARK: *********** SEGMENT CONTROL ACTION **************
    @IBAction func segementControlValueChanged(_ sender: Any) {
        
        sessionArray.removeAllObjects()
        if segmentControl.selectedSegmentIndex == 0 {
            self.NoRecordLbl.text =  "You have no requested sessions at this time."
            getCoachSessionDetails(type:"2")
            
        }
        else if segmentControl.selectedSegmentIndex == 1{
            self.NoRecordLbl.text =  "You have no active sessions at this time."
            getCoachSessionDetails(type:"1")
        }else if segmentControl.selectedSegmentIndex == 2
        {
            self.NoRecordLbl.text =  "You have no completed sessions at this time."
            getCoachCompleteSessionDetails()
            print ("completed")
        }
    }
    @objc func clickOnAcceptButton(sender:UIButton) {
        
        
        let userArray = sessionArray[sender.tag] as? [String:Any]
        self.ChargeId = userArray?["charge_id"] as? String
        
        if let userIdDict = userArray!["user_id"] as? [String:Any] {
            let Id = userIdDict["_id"] as? String ?? ""
            print(userArray ?? "")
            accept_reject_UserRequest(type: "1", index: sender.tag,Id: Id)
        }
    }
    @objc func clickOnRejectButton(sender:UIButton) {
        
        let userArray = sessionArray[sender.tag] as? [String:Any]
        self.ChargeId = userArray?["charge_id"] as? String
        
        if let userIdDict = userArray!["user_id"] as? [String:Any] {
            let Id = userIdDict["_id"] as? String ?? ""
            print(userArray ?? "")
            accept_reject_UserRequest(type: "2", index: sender.tag,Id: Id)
        }
    }
    
    @objc func LeaveReviewBtn(sender:UIButton) {
        
        print("Leave Review Btn Pressed")
    }
    @objc func userInfoRequestProfileBtn(sender:UIButton) {
        print("User Info Profile Btn tapped")
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "CoachRequestUserProfileVC") as! CoachRequestUserProfileVC
        let dict = sessionArray[sender.tag] as? NSDictionary
        vc.userOrderInfo = dict!
        self.navigationController?.pushViewController(vc,animated: true)
    }
    func getCoachCompleteSessionDetails() {
        
        self.noRecordView.isHidden = true
        self.sessionTble_View.isHidden = false
        showProgressIndicator(refrenceView: self.view)
        let request = ["user_id": getUserId(),"type":3] as [String : Any]
        WebServices().mainFunctiontoGetDetails(data: request as NSDictionary,serviceType:kGET_COACH_REQUEST) { (responseData)  in
            stopProgressIndicator()
            if responseData != nil
            {
                let code = responseData?["code"] as? NSNumber
                print("responseData",responseData ?? "")
                if code == 200{
                    stopProgressIndicator()
                    guard let resultArray = responseData?["result"] as? NSMutableArray else {
                        return
                    }
                    self.sessionArray = resultArray
                    self.sessionTble_View.delegate = self
                    self.sessionTble_View.dataSource = self
                    self.sessionTble_View.reloadData()
                    
                }
                else {
                    DispatchQueue.main.async(execute: {
                        self.noRecordView.isHidden = false
                    })
                    
                    self.sessionTble_View.isHidden = true
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
    
    
    
    func getCoachSessionDetails(type: String) {
        
        self.noRecordView.isHidden = true
        self.sessionTble_View.isHidden = false
        showProgressIndicator(refrenceView: self.view)
        let request = ["user_id": getUserId(),"type":type] as [String : Any]
        WebServices().mainFunctiontoGetDetails(data: request as NSDictionary,serviceType:kGET_COACH_REQUEST) { (responseData)  in
            stopProgressIndicator()
            if responseData != nil
            {
                let code = responseData?["code"] as? NSNumber
                print("responseData",responseData ?? "")
                if code == 200{
                    stopProgressIndicator()
                    guard let resultArray = responseData?["result"] as? NSMutableArray else {
                        return
                    }
                    self.sessionArray = resultArray
                    self.sessionTble_View.delegate = self
                    self.sessionTble_View.dataSource = self
                    self.sessionTble_View.reloadData()
                    
                }
                else {
                    DispatchQueue.main.async(execute: {
                        self.noRecordView.isHidden = false
                    })
                    
                    self.sessionTble_View.isHidden = true
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
    
    func accept_reject_UserRequest(type: String,index: Int,Id:String) {
        
        var orderId = ""
        if let dict = sessionArray[index] as? NSDictionary {
            orderId = dict["_id"] as? String ?? ""
        }
        
        let request = ["coach_id": getUserId(),"type":type,"order_id":orderId,"user_id": Id, "charge_id" : self.ChargeId] as [String : Any]
        print(request)
        print(getSessionId())
        
        WebServices().mainFunctiontoGetDetails(data: request as NSDictionary,serviceType:kCOACH_RESPOND_REQUEST) { (responseData)  in
            stopProgressIndicator()
            if responseData != nil
            {
                let code = responseData?["code"] as? NSNumber
                print("responseData",responseData ?? "")
                if code == 200{
                    
                    let message1 = responseData?["result"] as? String
                    if type == "1" {
                        notifyUser("", message: "Your request is successfully accepted", vc: self)
                    }else  if message1 == "Success"{
                        notifyUser("", message: "Your request is successfully Completed", vc: self)
                    }else{
                        notifyUser("", message: "Your request is rejected", vc: self)
                    }
                    stopProgressIndicator()
                    self.sessionArray.removeObject(at: index)
                    self.sessionTble_View.reloadData()
                    if self.sessionArray.count == 0 {
                        DispatchQueue.main.async(execute: {
                            self.noRecordView.isHidden = false
                        })
                        
                        self.sessionTble_View.isHidden = true
                        
                        if self.segmentControl.selectedSegmentIndex == 0 {
                            self.NoRecordLbl.text =  "You have no requested sessions at this time."
                            
                        }
                        else if self.segmentControl.selectedSegmentIndex == 1{
                            self.NoRecordLbl.text =  "You have no active sessions at this time."
                            
                        }else if self.segmentControl.selectedSegmentIndex == 2
                        {
                            self.NoRecordLbl.text =  "You have no completed sessions at this time."
                            
                        }
                        
                    }
                    
                    
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
    
    func UerRefundForLiveChat(userDetail: NSDictionary, type: String,index: Int,Id:String)  {
        
     
        var orderId = ""
        var duration = ""
        var chatEndTime = ""
        var liveChatAmount = ""
        var refundAmount = ""
        var coachAmount = ""
        var serviceTax = ""
        
        if let dict = sessionArray[index] as? NSDictionary {
            orderId = dict["_id"] as? String ?? ""
            duration = dict["duration"] as? String ?? ""
            chatEndTime = dict["chat_end_time"] as? String ?? ""
            liveChatAmount = dict["live_chat_amount"] as? String ?? ""
            refundAmount = dict["pay_amount"] as? String ?? ""
            coachAmount = dict["amount"] as? String ?? ""
            serviceTax = dict["service_tax"] as? String ?? ""
            
        }
        coachAmount = coachAmount.replacingOccurrences(of: "$", with: "")
        var serviceTaxValue  = Double(serviceTax)
        serviceTaxValue = 100.0 - serviceTaxValue!
        let durationValue = Double(duration)
        var chatEndTimeValue = Double(chatEndTime)
        chatEndTimeValue =   Double(chatEndTimeValue! / 60)
        let liveChatAmountValue  = Double(liveChatAmount)
        let CoachAmountValue = Double(coachAmount)
       
        let ChatRemainngMin = Double(durationValue! - chatEndTimeValue!)
        let refundedAmountValue = Double(ChatRemainngMin * CoachAmountValue!)
        let LiveChatAmountValueRef =  Double(liveChatAmountValue! - refundedAmountValue)
        let coachAmountValueRefunded = Double((serviceTaxValue! * LiveChatAmountValueRef) / 100)
        
        
        liveChatAmount = String(LiveChatAmountValueRef)
        refundAmount = String(refundedAmountValue)
        coachAmount  = String(coachAmountValueRefunded)
        
        let request = ["order_id":orderId,"user_id": Id, "duration" :duration ,  "chat_end_time" : chatEndTime, "live_chat_amount" : liveChatAmount, "refund_amount" : refundAmount, "coach_amount" : coachAmount] as [String : Any]
      
        
        WebServices().mainFunctiontoGetDetails(data: request as NSDictionary,serviceType:kCOACH_USER_REFUND) { (responseData)  in
            stopProgressIndicator()
            if responseData != nil
            {
                let code = responseData?["code"] as? NSNumber
                print("responseData",responseData ?? "")
                if code == 200{
                    
                  self.accept_reject_UserRequest(type: "3", index: index,Id: Id)
                    
                    
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

extension CoachesSessionVC: UITableViewDataSource {
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sessionArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell: CoachesSessionCell! =  tableView.dequeueReusableCell(withIdentifier: "CoachesSessionCell") as? CoachesSessionCell
        cell.selectionStyle = .none
        if segmentControl.selectedSegmentIndex == 1 {
            cell.requesView.isHidden = true
            cell.InfoBtnRequest.isHidden = true
            cell.ReviewBaseView.isHidden = true
            
        }else if segmentControl.selectedSegmentIndex == 2 {
            cell.requesView.isHidden = true
            cell.InfoBtnRequest.isHidden = true
            cell.ReviewBaseView.isHidden = false
            cell.LeaveReviewBtn.isHidden = true
        } else {
            cell.requesView.isHidden = false
            cell.InfoBtnRequest.isHidden = false
            cell.ReviewBaseView.isHidden = true
        }
        
        if let dict = sessionArray[indexPath.row] as? NSDictionary {
            cell.setupDataOnCell(orderDetails:dict)
        }
        cell?.btn_accept.tag = indexPath.row
        cell?.btn_accept.addTarget(self, action: #selector(CoachesSessionVC.clickOnAcceptButton(sender:)), for: .touchUpInside)
        cell?.btn_decline.tag = indexPath.row
        cell?.InfoBtnRequest.tag = indexPath.row
        cell?.btn_decline.addTarget(self, action: #selector(CoachesSessionVC.clickOnRejectButton(sender:)), for: .touchUpInside)
        cell?.InfoBtnRequest.addTarget(self, action: #selector(CoachesSessionVC.userInfoRequestProfileBtn(sender:)), for: .touchUpInside)
        cell?.LeaveReviewBtn.addTarget(self, action: #selector(CoachesSessionVC.LeaveReviewBtn(sender:)), for: .touchUpInside)
        return cell
        
    }
    
}

extension CoachesSessionVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if segmentControl.selectedSegmentIndex == 1 {
            return 110
        }
        else{
            return 154
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if segmentControl.selectedSegmentIndex == 0 {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "CoachRequestUserProfileVC") as! CoachRequestUserProfileVC
            if let dict = sessionArray[indexPath.row] as? NSDictionary {
                vc.userOrderInfo = dict
            }
            self.navigationController?.pushViewController(vc,animated: true)
        }
        else{
            
            let catInfoDict = self.sessionArray.object(at: indexPath.row) as! NSDictionary
            print(catInfoDict)
            let type = catInfoDict["type"] as! Int
            
            
            if type ==  1 {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "MessageController") as! MessageController
                if let dict = sessionArray[indexPath.row] as? NSDictionary {
                    vc.userQuestInfo = dict
                    print(dict)
                    vc.completeTime = dict["complete_time"] as! String
                }
                print( vc.userQuestInfo)
                
                self.navigationController?.pushViewController(vc,animated: true)
            }else if type ==  2 {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "MessageController") as! MessageController
                if let dict = sessionArray[indexPath.row] as? NSDictionary {
                    vc.userQuestInfo = dict
                    vc.completeTime = dict["complete_time"] as! String
                }
                self.navigationController?.pushViewController(vc,animated: true)
            } else if type == 3 {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "TextChatVC") as! TextChatVC
                if let dict = sessionArray[indexPath.row] as? NSDictionary {
                    vc.userQuestInfo = dict
                    vc.completeTime = dict["complete_time"] as! String
                }
                print(vc.userQuestInfo)
                let catInfoDict = self.sessionArray.object(at: indexPath.row) as! NSDictionary
                vc.room_Id = catInfoDict["room_id"] as! String
                self.navigationController?.pushViewController(vc,animated: true)
            }
            //            let vc = self.storyboard?.instantiateViewController(withIdentifier: "MessageController") as! MessageController
            //            if let dict = sessionArray[indexPath.row] as? NSDictionary {
            //                vc.userQuestInfo = dict
            //            }
            //            self.navigationController?.pushViewController(vc,animated: true)
            
            
            //            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ChatVC") as! ChatVC
            //            if let dict = sessionArray[indexPath.row] as? NSDictionary {
            //                vc.userQuestInfo = dict
            //            }
            //            self.navigationController?.pushViewController(vc,animated: true)
            
            
            //
            //                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "TextChatVC") as! TextChatVC
            //                        if let dict = sessionArray[indexPath.row] as? NSDictionary {
            //                            vc.userQuestInfo = dict
            //                        }
            //            print(vc.userQuestInfo)
            //            let catInfoDict = self.sessionArray.object(at: indexPath.row) as! NSDictionary
            //            vc.room_Id = catInfoDict["room_id"] as! String
            //            self.navigationController?.pushViewController(vc,animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if segmentControl.selectedSegmentIndex == 1 {
            let completed = UITableViewRowAction(style: .normal, title: "Completed") { action, index in
                //self.isEditing = false
                print("more button tapped")
                let userArray = self.sessionArray[indexPath.row] as? [String:Any]
                if let userIdDict = userArray!["user_id"] as? [String:Any] {
                    print(userIdDict)
                    let Id = userIdDict["_id"] as? String ?? ""
                    print(userArray ?? "")
                let type = userArray!["type"] as! Int
                        
                        if type == 3 {
                            self.UerRefundForLiveChat(userDetail: userArray! as NSDictionary, type: "3", index:indexPath.row , Id: Id)
                        }else {
                            self.accept_reject_UserRequest(type: "3", index: indexPath.row,Id: Id)
                        }
                    
                    
                }
            }
            completed.backgroundColor = UIColor.red
            
            
            
            return [ completed]
        }
        return nil
    }
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if segmentControl.selectedSegmentIndex == 1 {
            
            return true
        }else {
            return false
        }
    }
}


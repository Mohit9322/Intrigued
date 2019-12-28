//
//  AddCreditCardList.swift
//  Intrigued
//
//  Created by SWS on 01/02/18.
//  Copyright © 2018 daniel helled. All rights reserved.
//

import UIKit
import Stripe
import STZPopupView

protocol ProfileBalanceDelegate {
    func updateBalance()
}

protocol SendUserMessageDelegate {
    func sendMessageApi()
}
protocol UpdateUserInfoDelegate {
    func getUserDetailApi()
}

class AddCreditCardList: UIViewController {
    
    var cardArray = [[String:Any]]()
    @IBOutlet weak var table_view: UITableView!
    var selectedIndexPath = -1
    var buyCreditAmount:String?
    var delegate : ProfileBalanceDelegate?
    var sendMsgDelegate: SendUserMessageDelegate?
    var userDelegate: UpdateUserInfoDelegate?
    ///// direct pay
    var directPrice:Float = 0.0
    var pay_balance:String?
    var pageString:String?
    var Total_balance:String?
    var cardArrayDict : NSDictionary?
    let defaults = UserDefaults.standard
    var questionDict : NSDictionary?
    var imageArray : NSArray?
    var uploadUrlArray = NSMutableArray()
    var transaction_type: Int?
    var PaymentId : String?
    var ChargeId : String?
    
    var AddPaymentPopup = UIView()
    var cancelAddPaymentBtn = UIButton()
    var OkAddPaymentBtn = UIButton()
    var AddPaymentLbl  =  UILabel()
    var PaymentTblView: UITableView!
    var paymentTableIndexSelectedValue : Int?
    var LiveChatPaymentAmount = ""
    var LiveChatTotalAmount = ""
    
    var LiveChatDuration = ""
    var LiveChatTotalPrice = ""
    var LiveChatCoachPrice = ""
    
    @IBOutlet weak var add_Card_View: UIView!
    @IBOutlet weak var Add_Card_button:UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        if pageString == "userSendMessageVC" {
            let liveChatType = questionDict!["type"] as! String
            
            let LiveChatValue = Int(liveChatType)
            if LiveChatValue == 3 {
                
                paymentTableIndexSelectedValue = 0
                self.createChoosePaymentSlotPopup()
                
            }
        }
  
      
        table_view.separatorStyle = .none
        self.table_view.estimatedRowHeight = 50
        self.table_view.rowHeight = UITableViewAutomaticDimension
        add_Card_View.isHidden = true
        self.table_view.isHidden = false
        self.getCardList()
        
        
    }
    
    func getCardList() {
        showProgressIndicator(refrenceView: self.view)
        StripeManager().getCardsListFromStripe() { (response,statusCode) in
            print("responseData",response ?? "", "responseCode -====",statusCode)
            stopProgressIndicator()
            if statusCode == 200 {
                let responseData = response!["data"] as? [[String:Any]]
                self.cardArray = responseData ?? []
                if self.cardArray.count == 0 {
                    self.table_view.isHidden = true
                    self.add_Card_View.isHidden = false
                    self.showNoCardView()
                }
                else{
                    self.table_view.isHidden = false
                    self.add_Card_View.isHidden = true
                }
                self.table_view.reloadData()
                print(self.cardArray.count)
            }
        }
    }
    func showNoCardView() {
        
        if self.cardArray.count == 0 {
            self.table_view.isHidden = true
            self.add_Card_View.isHidden = false
            //self.table_view.backgroundColor = .clear
            
        } else {
            self.table_view.isHidden = false
            self.add_Card_View.isHidden = true
            //self.table_view.backgroundColor = .white
        }
    }
    
    @IBAction func Empty_AddCard_Button(_ sender: UIButton) {
        
        let addCardVc = self.storyboard?.instantiateViewController(withIdentifier: "PaymentMethodVC") as! PaymentMethodVC
        addCardVc.delegate = self
        self.navigationController?.pushViewController(addCardVc, animated: true)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func clickOnAddCard(_ sender: UIButton) {
        let addCardVc = self.storyboard?.instantiateViewController(withIdentifier: "PaymentMethodVC") as! PaymentMethodVC
        addCardVc.delegate = self
        self.navigationController?.pushViewController(addCardVc, animated: true)
    }
    
    @IBAction func clickOnBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func createChoosePaymentSlotPopup()  {
        
        
        AddPaymentPopup = UIView(frame: CGRect(x: 10, y: (self.view.frame.size.height -  280)/2 , width:self.view.frame.size.width - 20, height: 300))
        AddPaymentPopup.backgroundColor = hexStringToUIColor(hex: "#1d7399")
        AddPaymentPopup.layer.masksToBounds = true
        AddPaymentPopup.layer.cornerRadius = 5.0
        AddPaymentPopup.isHidden = true
        self.view.addSubview(AddPaymentPopup)
        
        AddPaymentLbl = UILabel(frame: CGRect(x:10 , y: 5, width: AddPaymentPopup.frame.size.width - 20 , height: 25))
        AddPaymentLbl.textColor = UIColor.white
        AddPaymentLbl.textAlignment = .center
        AddPaymentLbl.text = "You must buy more credits to keep it going."
        AddPaymentLbl.font = UIFont.boldSystemFont(ofSize: 16)
        AddPaymentPopup.addSubview(AddPaymentLbl)
        
        PaymentTblView =  UITableView(frame:CGRect(x: 0, y: AddPaymentLbl.frame.size.height + AddPaymentLbl.frame.origin.y + 5 , width:AddPaymentPopup.frame.size.width , height: AddPaymentPopup.frame.size.height - 50 - 35  ))
        self.PaymentTblView.register(UINib(nibName: "AddPaymentLiveChatCellTableViewCell", bundle: nil), forCellReuseIdentifier: "AddPaymentLiveChatCellTableViewCell")
        PaymentTblView.delegate = self
        PaymentTblView.dataSource = self
        PaymentTblView.tag = 2
        AddPaymentPopup.addSubview(PaymentTblView)
        
        
        cancelAddPaymentBtn = UIButton(frame: CGRect(x:0  , y: PaymentTblView.frame.size.height + PaymentTblView.frame.origin.y + 10, width:AddPaymentPopup.frame.size.width/2 , height: 40))
        cancelAddPaymentBtn.setTitle("Cancel", for: .normal)
        cancelAddPaymentBtn.tintColor = UIColor.gray
        cancelAddPaymentBtn.titleLabel?.textColor = UIColor.gray
        cancelAddPaymentBtn.addTarget(self, action:#selector(AddPaymentCancelBtnPressed(_:)), for: .touchUpInside)
        AddPaymentPopup.addSubview(cancelAddPaymentBtn)
        
        OkAddPaymentBtn = UIButton(frame: CGRect(x:cancelAddPaymentBtn.frame.size.width   , y: PaymentTblView.frame.size.height + PaymentTblView.frame.origin.y + 10, width:AddPaymentPopup.frame.size.width/2  , height: 40))
        OkAddPaymentBtn.setTitle("Pay", for: .normal)
        OkAddPaymentBtn.tintColor = UIColor.blue
        OkAddPaymentBtn.addTarget(self, action:#selector(AddPaymentBtnPressed(_:)), for: .touchUpInside)
        AddPaymentPopup.addSubview(OkAddPaymentBtn)
        
    }
    @objc func AddPaymentCancelBtnPressed(_ sender: UIButton) {
        
        
        
        DispatchQueue.main.async(execute: {
            self.dismissPopupView()
        })
    }
  
 
    
    @objc func paymentSelectedBtnPressed(_ sender: UIButton) {
        
        paymentTableIndexSelectedValue = sender.tag
        PaymentTblView.reloadData()
        
        
      //  notifyUser("", message: "In Progress Work", vc: self)
    }
    
    @objc func AddPaymentBtnPressed(_ sender: UIButton) {
        
        print("Show poopup")
        
        var Total_balance = ""
        
        
        
        if pageString == "userSendMessageVC" {
            
            if selectedIndexPath == -1 {
                showAlerView(title: "Alert", message: "Please select the Card", self1: self)
            }
            else{
                
                    DispatchQueue.main.async(execute: {
                        self.dismissPopupView()
                    })
                
                
                        let cardArray = self.cardArray[selectedIndexPath]
                        let card_Id = cardArray["id"] as? String ?? ""
                        let userDetail = getUserDetails()
                        
             
                print(buyCreditAmount)
                var pay_amount : Double = 0.00
                //let pay_amount1 = Float64(buyCreditAmount ?? "")
                print(pay_amount)
             
                    
                    let coachPrice = self.questionDict!["pay_amount"] as! NSNumber
                    //   let CoachPriceStr:String = String(describing: coachPrice)
                    //     let coachpriceValue = Int(CoachPriceStr)
                    let coachPricePerTenMin = String(format:"%3.2f",coachPrice.doubleValue * 10)
                    let coachPricePerFiftenMin = String(format:"%3.2f",coachPrice.doubleValue * 15)
                    let coachPricePerTwentyMin = String(format:"%3.2f",coachPrice.doubleValue * 20)
                    let coachPricePerThirtyMin = String(format:"%3.2f",coachPrice.doubleValue * 30)
                    
                    if paymentTableIndexSelectedValue == 0 {
                        pay_amount = Double(coachPricePerTenMin)!
                    }else if paymentTableIndexSelectedValue == 1 {
                        pay_amount = Double(coachPricePerFiftenMin)!
                    }else if paymentTableIndexSelectedValue == 2{
                        pay_amount = Double(coachPricePerTwentyMin)!
                    }else if paymentTableIndexSelectedValue == 3 {
                        pay_amount = Double(coachPricePerThirtyMin)!
                    }
                    
            
                
                let user_balance = userDetail["balance"] as? String ?? "0.0"
                let balance = Double(user_balance)
                print(balance ?? 0.0)
                
                pay_amount = pay_amount - balance!
                
                let main_balance = (balance ?? 0.0) + pay_amount
                Total_balance = String(main_balance)
                
                buyCreditAmount =  String(pay_amount)
                
                let request = ["pay_amount": buyCreditAmount ?? "","user_id": getUserId(),"card_id": card_Id,"stripe_customerId":getUserStripe_CustomerId(),"currency":"usd","total_amount":Total_balance,"transaction_type": 1] as NSDictionary
                        
                        print("request dict \(request)")
                        showProgressIndicator(refrenceView: self.view)
                        WebServices().mainFunctiontoGetDetails(data: request,serviceType:kCharge_User) { (responseData)  in
                            print(responseData ?? [:])
                            let code = responseData?["code"] as? NSNumber
                         //   stopProgressIndicator()
                            
                            self.ChargeId = responseData?["charge_id"] as? String
                            self.PaymentId = responseData?["Id"]  as? String
                            print(self.ChargeId, self.PaymentId)
                            
                            if code == 200 {
                                
                                
                                   self.sendUserMessage_to_coach()
                                
                                

                            }
                            else if code == 100 {
                                showAlerView(title: "Payment Failed", message: responseData?["result"] as? String ?? "", self1: self)
                            }
                        }
            
            }
        }
        //}
        
        
    }
    
    @IBAction func clickOnPayButton(_ sender: UIButton) {
        
      
            
            var Total_balance = ""
            
            
            
            if pageString == "userSendMessageVC" {
                
                if selectedIndexPath == -1 {
                    showAlerView(title: "Alert", message: "Please select the Card", self1: self)
                }
                else{
                    
                    let liveChatType = questionDict!["type"] as! String
                    
                    let LiveChatValue = Int(liveChatType)
                    if LiveChatValue == 3 {
                        
                          self.confirm_payment(transaction_type:2)
                    
                        
                    }else {
                         self.confirm_payment(transaction_type:2)
                    }
                   
                }
            }
            else {
                if selectedIndexPath == -1 {
                    showAlerView(title: "Alert", message: "Please select the Card", self1: self)
                }
                else{
                    let cardArray = self.cardArray[selectedIndexPath]
                    let card_Id = cardArray["id"] as? String ?? ""
                    let userDetail = getUserDetails()
                    
                    let pay_amount = (buyCreditAmount! as NSString).floatValue
                    //let pay_amount1 = Float64(buyCreditAmount ?? "")
                    print(pay_amount)
                    
                    let user_balance = userDetail["balance"] as? String ?? ""
                    let balance = Float(user_balance)
                    print(balance ?? 0.0)
                    
                    let main_balance = (balance ?? 0.0) + pay_amount
                    Total_balance = String(main_balance)
                    
                    let request = ["pay_amount": buyCreditAmount ?? "","user_id": getUserId(),"card_id": card_Id,"stripe_customerId":getUserStripe_CustomerId(),"currency":"usd","total_amount":Total_balance,"transaction_type":1] as NSDictionary
                    
                    print("request dict \(request)")
                    showProgressIndicator(refrenceView: self.view)
                    WebServices().mainFunctiontoGetDetails(data: request,serviceType:kCharge_User) { (responseData)  in
                        print(responseData ?? [:])
                        let code = responseData?["code"] as? NSNumber
                        stopProgressIndicator()
                        
                        self.ChargeId = responseData?["charge_id"] as? String
                        self.PaymentId = responseData?["Id"]  as? String
                        print(self.ChargeId, self.PaymentId)
                        
                        if code == 200 {
                            let alert = UIAlertController(title: "Payment Success", message: "Payment Succeeded.", preferredStyle: UIAlertControllerStyle.alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                                self.delegate?.updateBalance()
                                self.navigationController?.popViewController(animated: true)
                            }))
                            self.present(alert, animated: true, completion: nil)
                        }
                        else if code == 100 {
                            showAlerView(title: "Payment Failed", message: responseData?["result"] as? String ?? "", self1: self)
                        }
                    }
                }
            }
            //}
        
      
    }
    
  
      
    
    
    func sendUserMessage_to_coach() {
        
        if self.imageArray?.count == 0 {
            print(questionDict)
       
            let serviceTaxKey =   ServiceTaxValue as? String ?? ""
            var serviceTaxValue22 =  (serviceTaxKey as NSString).doubleValue
            print(serviceTaxValue22)
            serviceTaxValue22 =  100.00 - serviceTaxValue22
            print(serviceTaxValue22)
            let PaymentStr =      questionDict!["pay_amount"] as! NSNumber
            let PaymentStr1:String = String(format:"%f", PaymentStr.doubleValue) //formats the string to accept double/float
          //  print(s)
          //  let PaymentStr1 =      String(describing: PaymentStr)
            print(PaymentStr1)
            print(PaymentStr)
            let paymentValue = (PaymentStr1 as! NSString).doubleValue
            var coachAmount  = (paymentValue * serviceTaxValue22)/100
       
            let liveChatType = self.questionDict!["type"] as! String
            var request1 : NSDictionary = NSDictionary()
            let LiveChatValue = Int(liveChatType)
            
           
            
            if LiveChatValue == 3 {
               
                let coachLiveChatPrice =      questionDict!["CoachPriceLiveChat"] as! String
                
                let serviceTaxKey1 =   ServiceTaxValue as? String ?? ""
                var serviceTaxValue1 =  (serviceTaxKey as NSString).doubleValue
                serviceTaxValue1 = 100.0 -  serviceTaxValue1
                var liveChatCoachAmount =  Double(LiveChatTotalPrice)
                liveChatCoachAmount = ((serviceTaxValue1 * liveChatCoachAmount! )/100 )
                
                request1 = ["user_id": questionDict!["user_id"],
                            "coach_id":questionDict!["coach_id"],
                            "type":questionDict!["type"],
                            "title":questionDict!["title"],
                            "question":questionDict!["question"],
                            "images":questionDict!["images"],
                            "pay_amount": coachLiveChatPrice,
                            "payment_type":questionDict!["payment_type"],
                            "user_balance":questionDict!["user_balance"],
                            "coach_amount": liveChatCoachAmount,
                            "service_tax":serviceTaxKey1,
                             "close_chat" : CloseChatDays,
                            "charge_id" : self.ChargeId,
                            "payment_id": self.PaymentId,
                            "duration" : LiveChatDuration,
                            "live_chat_amount" : LiveChatTotalPrice] as NSDictionary
                print(request1)
                
                
                
            }else {
            
            request1 = ["user_id": questionDict!["user_id"],
                            "coach_id":questionDict!["coach_id"],
                            "type":questionDict!["type"],
                            "title":questionDict!["title"],
                            "question":questionDict!["question"],
                            "images":questionDict!["images"],
                            "pay_amount": questionDict!["pay_amount"],
                            "payment_type":questionDict!["payment_type"],
                            "user_balance":questionDict!["user_balance"],
                            "coach_amount": coachAmount,
                            "service_tax":serviceTaxKey,
                             "close_chat" : CloseChatDays,
                            "charge_id" : self.ChargeId,
                            "payment_id": self.PaymentId] as NSDictionary
            print(request1)
                
            }
          //  showProgressIndicator(refrenceView: self.view)
            WebServices().mainFunctiontoGetDetails(data: request1 as! NSDictionary,serviceType:kADD_NEWORDER) { (responseData)  in
            //    stopProgressIndicator()
                self.defaults.set(false, forKey: "PaymentVerified")
                if responseData != nil
                {
                    let code = responseData?["code"] as? NSNumber
                    print("responseData",responseData ?? "")
                    if code == 200{
                        
                        
                        let liveChatType = self.questionDict!["type"] as! String
                        
                        let LiveChatValue = Int(liveChatType)
                        if LiveChatValue == 3 {
                               self.userLoginApi()
                        }else {
                            stopProgressIndicator()
                            let refreshAlert = UIAlertController(title: "Alert", message: "Your Question has been submitted successfully and We will get you back shortly", preferredStyle: UIAlertControllerStyle.alert)
                            
                            refreshAlert.addAction(UIAlertAction(title: "Ok", style: .destructive, handler: { (action: UIAlertAction!) in
                                //  self.sendMsgDelegate?.sendMessageApi()
                                if let viewControllers = self.navigationController?.viewControllers {
                                    for viewController in viewControllers {
                                        // some process
                                        if viewController.isKind(of: HomeTabbarVC.self){
                                            if let vc = viewController as? HomeTabbarVC {
                                                NotificationCenter.default.post(name: NSNotification.Name("getSessionIndex"), object: nil)
                                                vc.selectedIndex = 1
                                                self.navigationController?.popToViewController(vc, animated: true)
                                                break
                                            }
                                        }
                                    }
                                }
                                
                                print("Success")
                            }))
                            self.present(refreshAlert, animated: true, completion: nil)
                        }
                       
                        
                      
                    }
                    else {
                        stopProgressIndicator()
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
        }else if self.imageArray?.count != 0 {
            //   showProgressIndicator(refrenceView: self.view)
            //    showProgressIndicator(refrenceView: self.view)
            self.uploadImageOnserver()
        }
        
    }
    
   
    func userLoginApi() {
        
        let userDetail = getUserDetails()
        let requestDict = ["user_id":getUserId()] as NSDictionary
        print(requestDict)
        
        showProgressIndicator(refrenceView: self.view)
        WebServices().mainFunctiontoGetDetails(data: requestDict,serviceType:k_USER_Profile) { (responseData)  in
            stopProgressIndicator()
            if responseData != nil
            {
                let code = responseData?["code"] as? NSNumber
                print("responseData",responseData ?? "")
                if code == 200{
                    if let resultDict = responseData?["result"] as? NSDictionary {
                        let balance =  resultDict["balance"] as? String ?? ""
//                        self.price = Float(balance)
//                        print(self.price ?? 0.0)
//                        self.profileTableView.reloadData()
                        
                        removeUserDetails()
                        saveUserDetails(userDict: resultDict)
                        CloseChatDays = resultDict["close_chat"] as? String ?? ""
                        ServiceTaxValue = resultDict["service_tax"] as? String ?? ""
                        stopProgressIndicator()
                        let refreshAlert = UIAlertController(title: "Alert", message: "Your Question has been submitted successfully and We will get you back shortly", preferredStyle: UIAlertControllerStyle.alert)
                        
                        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .destructive, handler: { (action: UIAlertAction!) in
                            //  self.sendMsgDelegate?.sendMessageApi()
                            if let viewControllers = self.navigationController?.viewControllers {
                                for viewController in viewControllers {
                                    // some process
                                    if viewController.isKind(of: HomeTabbarVC.self){
                                        if let vc = viewController as? HomeTabbarVC {
                                            NotificationCenter.default.post(name: NSNotification.Name("getSessionIndex"), object: nil)
                                            vc.selectedIndex = 1
                                            self.navigationController?.popToViewController(vc, animated: true)
                                            break
                                        }
                                    }
                                }
                            }
                            
                            print("Success")
                        }))
                        self.present(refreshAlert, animated: true, completion: nil)
                        
                    }
                }
            }
            else{
                //stopProgressIndicator()
            }
        }
    }
    
    
    func sendUserMsgWithImage() {
        

        
        let serviceTaxKey =   ServiceTaxValue as? String ?? ""
        var serviceTaxValue33 =  (serviceTaxKey as NSString).doubleValue
        let PaymentStr =      questionDict!["pay_amount"] as! NSNumber
        let PaymentStr1:String = String(format:"%f", PaymentStr.doubleValue) //formats
        
        print(PaymentStr1)
        print(PaymentStr)
        serviceTaxValue33 =  100.00 - serviceTaxValue33
        let paymentValue = (PaymentStr1 as! NSString).doubleValue
        var coachAmount  = (paymentValue * serviceTaxValue33)/100
        
        
        let liveChatType = self.questionDict!["type"] as! String
        var request1 : NSDictionary = NSDictionary()
        let LiveChatValue = Int(liveChatType)
        
        print(LiveChatDuration)
        print(LiveChatTotalPrice)
        print(LiveChatCoachPrice)
        
        if LiveChatValue == 3 {
            
            
              let coachLiveChatPrice =      questionDict!["CoachPriceLiveChat"] as! String
            
            let serviceTaxKey1 =   ServiceTaxValue as? String ?? ""
            var serviceTaxValue1 =  (serviceTaxKey as NSString).doubleValue
            serviceTaxValue1 = 100.0 -  serviceTaxValue1
            var liveChatCoachAmount =  Double(LiveChatTotalPrice)
            liveChatCoachAmount = ((serviceTaxValue1 * liveChatCoachAmount! )/100 )
            
                
             request1 = ["user_id": questionDict!["user_id"],
                            "coach_id":questionDict!["coach_id"],
                            "type":questionDict!["type"],
                            "title":questionDict!["title"],
                            "question":questionDict!["question"],
                            "images":uploadUrlArray,
                            "pay_amount": coachLiveChatPrice,
                            "payment_type":2,
                            "user_balance":questionDict!["user_balance"],
                            "coach_amount": liveChatCoachAmount,
                            "service_tax":serviceTaxKey,
                            "charge_id" : self.ChargeId,
                            "payment_id": self.PaymentId,
                             "close_chat" : CloseChatDays,
                            "duration" : LiveChatDuration,
                            "live_chat_amount" : LiveChatTotalPrice] as NSDictionary
        }else {
            request1 = ["user_id": questionDict!["user_id"],
                            "coach_id":questionDict!["coach_id"],
                            "type":questionDict!["type"],
                            "title":questionDict!["title"],
                            "question":questionDict!["question"],
                            "images":uploadUrlArray,
                            "pay_amount": questionDict!["pay_amount"],
                            "payment_type":2,
                            "user_balance":questionDict!["user_balance"],
                            "coach_amount": coachAmount,
                             "close_chat" : CloseChatDays,
                            "service_tax":serviceTaxKey,
                            "charge_id" : self.ChargeId,
                            "payment_id": self.PaymentId] as NSDictionary
        }
      
        print(request1)
      //  showProgressIndicator(refrenceView: self.view)
        
        WebServices().mainFunctiontoGetDetails(data: request1 as! NSDictionary,serviceType:kADD_NEWORDER) { (responseData)  in
            
            self.defaults.set(false, forKey: "PaymentVerified")
            if responseData != nil
            {
                let code = responseData?["code"] as? NSNumber
                print("responseData",responseData ?? "")
                if code == 200{
                   
                    let liveChatType = self.questionDict!["type"] as! String
                    
                    let LiveChatValue = Int(liveChatType)
                    if LiveChatValue == 3 {
                        self.userLoginApi()
                    }else {
                        let refreshAlert = UIAlertController(title: "Alert", message: "Your Question has been submitted successfully and We will get you back shortly", preferredStyle: UIAlertControllerStyle.alert)
                        
                        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .destructive, handler: { (action: UIAlertAction!) in
                            //  self.sendMsgDelegate?.sendMessageApi()
                            
                            print("Success")
                            if let viewControllers = self.navigationController?.viewControllers {
                                for viewController in viewControllers {
                                    // some process
                                    if viewController.isKind(of: HomeTabbarVC.self){
                                        if let vc = viewController as? HomeTabbarVC {
                                            NotificationCenter.default.post(name: NSNotification.Name("getSessionIndex"), object: nil)
                                            vc.selectedIndex = 1
                                            self.navigationController?.popToViewController(vc, animated: true)
                                            break
                                        }
                                        
                                    }
                                }
                            }
                            
                        }))
                        
                        stopProgressIndicator()
                        
                        self.present(refreshAlert, animated: true, completion: nil)
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
    func uploadImageOnserver() {
  //  showProgressIndicator(refrenceView: self.view)
      
        for image in imageArray! {
            let fileManager = FileManager.default
            let path = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("\(String(describing: image)).jpeg")
            let imageData = UIImageJPEGRepresentation(image as! UIImage, 0.5)
            fileManager.createFile(atPath: path as String, contents: imageData, attributes: nil)
            let fileUrl = URL(fileURLWithPath: path)
        
            WebServices().uploadImageonServer(imageURL: fileUrl){ (responseData)  in
               //  stopProgressIndicator()
                if responseData != nil{
                    if let uploadUrl = responseData {
                        self.uploadUrlArray.add(uploadUrl)
                    }
                    if self.uploadUrlArray.count == self.imageArray?.count {
                        self.sendUserMsgWithImage()
                        
                    }
                    print("responseData",responseData ?? "")
                    print("uploadUrlArray============",self.uploadUrlArray )
                }
                else{
                    stopProgressIndicator()
                    
                }
            }
        }
    }
    
    
    
    //MARK: PAY Direct from usersendMessage and click on payConfirm ////////
    /////////// For Direct Payment Method ???????????
    func confirm_payment(transaction_type:Int) {
        
        
            var pay_amount:String?
            let userDetail = getUserDetails()
            
            if directPrice != 0.0 {
                pay_amount = String(directPrice)
            }
        let liveChatType = self.questionDict!["type"] as! String
        let LiveChatValue = Int(liveChatType)
        
        if LiveChatValue == 3 {
            
            pay_amount = self.LiveChatTotalPrice
        }
      
        
            let user_balance = userDetail["balance"] as? String ?? ""
            let balance = Float(user_balance)
            print(balance ?? 0.0)
            
            if pay_balance != nil{
                pay_amount = pay_balance ?? ""
            }
            let cardArray = self.cardArray[selectedIndexPath]
            let getCardId = cardArray["id"] as? String ?? ""
        

        
            let request = ["pay_amount": pay_amount ?? ""
                ,"user_id": getUserId(),"card_id": getCardId,"stripe_customerId":getUserStripe_CustomerId(),"currency":"usd","total_amount":Total_balance ?? "0","transaction_type":transaction_type] as NSDictionary
        
        
            print("request dict \(request)")
            showProgressIndicator(refrenceView: self.view)
            WebServices().mainFunctiontoGetDetails(data: request,serviceType:kCharge_User) { (responseData)  in
                //    stopProgressIndicator()
                print(responseData ?? [:])
                let code = responseData?["code"] as? NSNumber
                //   stopProgressIndicator()
                
                
                
                if code == 200 {

                    self.ChargeId = responseData?["charge_id"] as? String
                    self.PaymentId = responseData?["Id"]  as! String
                    //  self.PaymentId = Int(PaymentNumber)
                    print(self.ChargeId, self.PaymentId)
                    self.defaults.set(true, forKey: "PaymentVerified")
                    self.sendUserMessage_to_coach()
                    self.userDelegate?.getUserDetailApi()
                }
                else if code == 100 {
                    self.defaults.set(false, forKey: "PaymentVerified")
                    showAlerView(title: "Payment Failed", message: responseData?["result"] as? String ?? "", self1: self)
                }
        }
        
        
      
    }
}


extension AddCreditCardList: getSaveCardListDelegate {
    func getSaveCardList() {
        self.getCardList()
        self.table_view.reloadData()
    }
}


extension AddCreditCardList: UITableViewDataSource,UITableViewDelegate {
    
   
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView.tag == 2 {
             return 50
        }else {
          return  UITableViewAutomaticDimension
        }
        
       
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView.tag == 2 {
            return 4
        }else {
               return self.cardArray.count
        }
     //   return self.cardArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView.tag == 2 {
            let cell: AddPaymentLiveChatCellTableViewCell! =  tableView.dequeueReusableCell(withIdentifier: "AddPaymentLiveChatCellTableViewCell") as? AddPaymentLiveChatCellTableViewCell
            cell.selectionStyle = .none
            cell.frame = CGRect(x:0, y: 0, width: tableView.frame.size.width, height:50)
            cell.contentView.frame =  CGRect(x:0, y: 0, width: tableView.frame.size.width, height:50)
            cell.BaseView.frame = CGRect(x:0, y: 0, width: tableView.frame.size.width, height:50)
            
            cell.rightIconBtn.frame = CGRect(x:10, y: 10, width: 40, height:30)
            
            cell.paymentValueLbl.frame =  CGRect(x:cell.rightIconBtn.frame.size
                .width + cell.rightIconBtn.frame.origin.x + 10, y: 10, width:cell.frame.size.width - (cell.rightIconBtn.frame.size
                    .width + cell.rightIconBtn.frame.origin.x + 10), height:30)
            cell.PaymentBtn.frame =  CGRect(x:0, y: 0, width: tableView.frame.size.width, height:50)
            cell.PaymentBtn.tag = indexPath.row
            print(self.questionDict)
            let coachPrice = self.questionDict!["pay_amount"] as! NSNumber
         //   let CoachPriceStr:String = String(describing: coachPrice)
       //     let coachpriceValue = Int(CoachPriceStr)
            let coachPricePerTenMin = String(format:"10 Min / $%3.2f",coachPrice.doubleValue * 10)
            let coachPricePerFiftenMin = String(format:"15 Min / $%3.2f",coachPrice.doubleValue * 15)
             let coachPricePerTwentyMin = String(format:"20 Min / $%3.2f",coachPrice.doubleValue * 20)
             let coachPricePerThirtyMin = String(format:"30 Min / $%3.2f",coachPrice.doubleValue * 30)
            

            cell.rightIconBtn.isSelected = false
            if indexPath.row == 0 {
                cell.paymentValueLbl.text = coachPricePerTenMin
              
                if paymentTableIndexSelectedValue == 0 {
                    cell.rightIconBtn.isSelected = true
                }
                
            }else if indexPath.row == 1 {
                cell.paymentValueLbl.text = coachPricePerFiftenMin
             
                
                if  paymentTableIndexSelectedValue == 1 {
                    cell.rightIconBtn.isSelected = true
                }
            }else if indexPath.row == 2 {
                cell.paymentValueLbl.text = coachPricePerTwentyMin
              
                if  paymentTableIndexSelectedValue == 2 {
                    cell.rightIconBtn.isSelected = true
                }
            }else if indexPath.row == 3 {
                cell.paymentValueLbl.text = coachPricePerThirtyMin
                
                if paymentTableIndexSelectedValue == 3 {
                    cell.rightIconBtn.isSelected = true
                }
            }
            
            
            cell.PaymentBtn.addTarget(self, action: #selector(paymentSelectedBtnPressed), for: .touchUpInside)
            
            
            return cell
        }else {
            let cell = table_view.dequeueReusableCell(withIdentifier: "SelectCardCell") as! SelectCardCell
            let cardDetail = self.cardArray[indexPath.row]
            let brandCard = cardDetail["brand"] as? String ?? ""
            cell.cardNumber_lbl.text = "**** **** **** \(cardDetail["last4"] as? String ?? "")"
            //cell.card_type_image.image = #imageLiteral(resourceName: "visa_icon")
            cell.card_brand_lbl.text = brandCard
            if selectedIndexPath == indexPath.row {
                cell.select_image.image = #imageLiteral(resourceName: "select_mark")
            }
            else{
                cell.select_image.image = #imageLiteral(resourceName: "unselect_mark")
            }
            cell.selectionStyle = .none
            return cell
        }
        
        
    }
    
    //    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    //        return true
    //    }
    
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            // delete item at indexPath
            let allCardsArray = self.cardArray[indexPath.row]
            print(allCardsArray)
            let cardId = allCardsArray["id"] as? String ?? ""
            print(cardId)
            StripeManager().deleteCardFromStripe(cardId: cardId, completionBlock: { (resultDict, statusCode) in
                print("result dict \(String(describing: resultDict))")
                self.getCardList()
                self.table_view.reloadData()
            })
        }
        return [delete]
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //let cardDetail = self.cardArray[indexPath.row]
        self.selectedIndexPath = indexPath.row
        self.table_view.reloadData()
        print(self.selectedIndexPath)
    }
    func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) {
        self.selectedIndexPath = -1
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        self.selectedIndexPath = -1
        self.table_view.reloadData()
    }
}



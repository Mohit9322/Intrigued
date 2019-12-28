//
//  UserSendMessageVc.swift
//  Intrigued
//
//  Created by SWS on 10/10/17.
//  Copyright © 2017 daniel helled. All rights reserved.
//

import UIKit
import STZPopupView
var coachIDPassMessage = String()
var commTypePassMsg = String()
var userNamePassMsg = String()
var checkFromController = String()



class UserSendMessageVc: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextViewDelegate {
    
    @IBOutlet weak var aboutTextView: UITextView!
    @IBOutlet weak var questionTextView: UITextView!
    
    @IBOutlet weak var lbl_questionLength: UILabel!
    @IBOutlet weak var lbl_aboutLenght: UILabel!
    
    @IBOutlet weak var lbl_titleName: UILabel!
    var picker = UIImagePickerController()
    var coachId = ""
    var communicationType = ""
    var aboutPlaceholder = "Tell me about whats going on."
    var questionPlaceholder = "Whats your questions"
    var advisor_Details = NSDictionary()
    @IBOutlet weak var collection_view: UICollectionView!
    var imageArray = [UIImage]()
    var uploadUrlArray = NSMutableArray()
    
    var remain_balance:String?
    var user_old_balance:String?
    var pay_balance:String?
    var main_direct_Price:Int?
    let defaults = UserDefaults.standard
    var directFloatBalance : Float?
    
    var PaymentId : String?
    var ChargeId : String?
    
    
    var AddPaymentPopup = UIView()
    var cancelAddPaymentBtn = UIButton()
    var OkAddPaymentBtn = UIButton()
    var AddPaymentLbl  =  UILabel()
    var PaymentTblView: UITableView!
    var paymentTableIndexSelectedValue : Int?
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.backgroundColor = hexStringToUIColor(hex: "#EFEFF4")
        coachId = advisor_Details["_id"] as? String ?? ""
        print( "coach id is this %@",coachId)
        var userName = (advisor_Details["fname"] as? String ?? "")  + " " + (advisor_Details["lname"] as? String ?? "")
        
        if checkFromController == "YES" {
            userName = userNamePassMsg
            coachId = coachIDPassMessage
            communicationType = commTypePassMsg
            checkFromController = "NO"
        }
        
        lbl_titleName.text = userName
        aboutTextView.delegate = self
        questionTextView.delegate = self
        aboutTextView.placeholder = "Any background information I should be aware of?"
        questionTextView.placeholder = "What would you like to work on today?"
        collection_view.delegate = self
        collection_view.dataSource = self
        
        if communicationType == "3" {
            
            paymentTableIndexSelectedValue = 0
            self.createChoosePaymentSlotPopup()
            
        }
      
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
        print("get user default value \(defaults.bool(forKey: "PaymentVerified"))")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
        
        print("get user default value \(defaults.bool(forKey: "PaymentVerified"))")
       
        let paymentVerify = defaults.bool(forKey: "PaymentVerified")
        var direct_price = advisor_Details["direct_price"] as? String ?? ""
        
        if communicationType == "1" {
            direct_price = advisor_Details["direct_price"] as? String ?? ""
        }
        else if communicationType == "2" {
            direct_price = advisor_Details["rush_direct_price"] as? String ?? ""
        }
        else {
            direct_price = advisor_Details["livechat_price"] as? String ?? ""
        }
  
       let outputString = String(direct_price.characters.dropFirst())
        var directOutputInt = Float(outputString)
        
        if paymentTableIndexSelectedValue == 0 {
          
            directOutputInt = directOutputInt! * 10.0
        }else if paymentTableIndexSelectedValue == 1 {

            directOutputInt = directOutputInt! * 15.0
        }else if paymentTableIndexSelectedValue == 2{
          
            directOutputInt = directOutputInt! * 20.0
        }else if paymentTableIndexSelectedValue == 3 {
            
            directOutputInt = directOutputInt! * 30.0
        }
        
    
      
      //  let directOutputInt = Float(outputString)
       
        
        self.directFloatBalance = directOutputInt
        print(self.directFloatBalance ?? 0.0)
        
        let userDetails = getUserDetails()
        let balance = userDetails["balance"] as? String ?? ""
        let user_balance = (balance as NSString).floatValue
        self.user_old_balance = balance
        
        print(self.imageArray)
        
        if paymentVerify == true {
            defaults.set(false, forKey: "PaymentVerified")
            if  ischeckManadoryDetails() {
                if imageArray.count == 0 {
                    showProgressIndicator(refrenceView: self.view)
                    defaults.set(false, forKey: "PaymentVerified")
                    self.sendUserMessage_to_coach()
                }
                else{
                    uploadImageOnserver()
                }
            }
        }
        else {
            //false
        }
        
        if (user_balance) > (directOutputInt ?? 0.0) {
            let main_balance = user_balance - directOutputInt!
            remain_balance  = String(main_balance)
            
            if  ischeckManadoryDetails() {
                if imageArray.count == 0 {
                    showProgressIndicator(refrenceView: self.view)
                    self.sendUserMessage_to_coach()
                }
                else{
                    uploadImageOnserver()
                }
            }
        }
        else if balance == "0.0" || balance == "0" || remain_balance == "0.0" {
            if  ischeckManadoryDetails() {
            }
            
            
            let addCardVc = self.storyboard?.instantiateViewController(withIdentifier: "AddCreditCardList") as? AddCreditCardList
            
            var pay_amount : Double = 0.00
            //let pay_amount1 = Float64(buyCreditAmount ?? "")
            print(pay_amount)
            
            var coachPrice11 = advisor_Details["livechat_price"] as? String ?? ""
            coachPrice11 = String(coachPrice11.characters.dropFirst())
            //   let CoachPriceStr:String = String(describing: coachPrice)
            //     let coachpriceValue = Int(CoachPriceStr)
            let CoachPriceValue  = Double(coachPrice11)
            let coachPricePerTenMin = String(format:"%3.2f",CoachPriceValue! * 10)
            let coachPricePerFiftenMin = String(format:"%3.2f", CoachPriceValue! * 15)
            let coachPricePerTwentyMin = String(format:"%3.2f",CoachPriceValue! * 20)
            let coachPricePerThirtyMin = String(format:"%3.2f",CoachPriceValue! * 30)
              var  liveChatDuration = ""
            if paymentTableIndexSelectedValue == 0 {
                 liveChatDuration = "10"
                pay_amount = Double(coachPricePerTenMin)!
            }else if paymentTableIndexSelectedValue == 1 {
                 liveChatDuration = "15"
                pay_amount = Double(coachPricePerFiftenMin)!
            }else if paymentTableIndexSelectedValue == 2{
                 liveChatDuration = "20"
                pay_amount = Double(coachPricePerTwentyMin)!
            }else if paymentTableIndexSelectedValue == 3 {
                 liveChatDuration = "30"
                pay_amount = Double(coachPricePerThirtyMin)!
            }
            
            
            let userDetail = getUserDetails()
            let user_balance = userDetail["balance"] as? String ?? "0.0"
            let balance = Double(user_balance)
            print(balance ?? 0.0)
            
            pay_amount = pay_amount - balance!
            
            var Total_balance = ""
            let main_balance = (balance ?? 0.0) + pay_amount
            Total_balance = String(main_balance)
            
            addCardVc?.sendMsgDelegate = self
            let request = ["user_id": getUserId(),
                           "coach_id":coachId,
                           "type":communicationType,
                           "images":uploadUrlArray,
                           "user_balance":remain_balance ?? self.user_old_balance ?? "0",
                           "pay_amount":self.directFloatBalance ?? 0.0,
                           "payment_type":communicationType,
                           "question":questionTextView.text,
                           "title":aboutTextView.text,
                           "CoachPriceLiveChat" : advisor_Details["livechat_price"] as? String] as [String : Any]
            print(request)
            print(imageArray)
            addCardVc?.LiveChatTotalAmount = Total_balance
            addCardVc?.LiveChatPaymentAmount = String(pay_amount)
            addCardVc?.imageArray = self.imageArray as NSArray
            addCardVc?.questionDict = request as NSDictionary
            addCardVc?.userDelegate = self
            addCardVc?.directPrice = directOutputInt!
            addCardVc?.pageString =  "userSendMessageVC"
            addCardVc?.LiveChatDuration = liveChatDuration
            addCardVc?.LiveChatCoachPrice = coachPrice11
            addCardVc?.LiveChatTotalPrice = Total_balance
            DispatchQueue.main.async(execute: {
                self.dismissPopupView()
            })
            self.navigationController?.pushViewController((addCardVc)!, animated: true)
        }
            
        else if (directOutputInt ?? 0.0) > (user_balance) {
            let main_balance = directOutputInt! - user_balance
            let userRemain = user_balance - directOutputInt!
            print(userRemain)
            
            // Check Condition for balance less or more from 0.05
            if main_balance >= 0.05 || main_balance >= 0.5 {
                
                pay_balance = String(main_balance)
                if  ischeckManadoryDetails() {
                }
                let addCardVc = self.storyboard?.instantiateViewController(withIdentifier: "AddCreditCardList") as? AddCreditCardList
                
                
                var pay_amount : Double = 0.00
                //let pay_amount1 = Float64(buyCreditAmount ?? "")
                print(pay_amount)
                
                var coachPrice22 = advisor_Details["livechat_price"] as? String ?? ""
                coachPrice22 = String(coachPrice22.characters.dropFirst())
                //   let CoachPriceStr:String = String(describing: coachPrice)
                //     let coachpriceValue = Int(CoachPriceStr)
                let CoachPriceValue  = Double(coachPrice22)
                let coachPricePerTenMin = String(format:"%3.2f",CoachPriceValue! * 10)
                let coachPricePerFiftenMin = String(format:"%3.2f", CoachPriceValue! * 15)
                let coachPricePerTwentyMin = String(format:"%3.2f",CoachPriceValue! * 20)
                let coachPricePerThirtyMin = String(format:"%3.2f",CoachPriceValue! * 30)
                
                var  liveChatDuration = ""
                if paymentTableIndexSelectedValue == 0 {
                    liveChatDuration = "10"
                    pay_amount = Double(coachPricePerTenMin)!
                }else if paymentTableIndexSelectedValue == 1 {
                     liveChatDuration = "15"
                    pay_amount = Double(coachPricePerFiftenMin)!
                }else if paymentTableIndexSelectedValue == 2{
                     liveChatDuration = "20"
                    pay_amount = Double(coachPricePerTwentyMin)!
                }else if paymentTableIndexSelectedValue == 3 {
                     liveChatDuration = "30"
                    pay_amount = Double(coachPricePerThirtyMin)!
                }
                
                
                let userDetail = getUserDetails()
                let user_balance = userDetail["balance"] as? String ?? "0.0"
                let balance = Double(user_balance)
                print(balance ?? 0.0)
                
                pay_amount = pay_amount - balance!
                
                var Total_balance = ""
                let main_balance = (balance ?? 0.0) + pay_amount
                Total_balance = String(main_balance)
                
                let request = ["user_id": getUserId(),
                               "coach_id":coachId,
                               "type":communicationType,
                               "title":aboutTextView.text,
                               "question":questionTextView.text,
                               "images":uploadUrlArray,
                               "user_balance":"0.00",
                               "pay_amount":self.directFloatBalance ?? 0.0,
                               "payment_type":communicationType,
                               "CoachPriceLiveChat" : advisor_Details["livechat_price"] as? String] as [String : Any]
                print(request)
                print(imageArray)
                addCardVc?.LiveChatTotalAmount = Total_balance
                addCardVc?.LiveChatPaymentAmount = String(pay_amount)
                addCardVc?.imageArray = self.imageArray as NSArray
                addCardVc?.questionDict = request as NSDictionary
                addCardVc?.userDelegate = self
                addCardVc?.sendMsgDelegate = self
                addCardVc?.pay_balance = pay_balance
                addCardVc?.pageString =  "userSendMessageVC"
                addCardVc?.LiveChatDuration = liveChatDuration
                addCardVc?.LiveChatCoachPrice = coachPrice22
                addCardVc?.LiveChatTotalPrice = Total_balance
                DispatchQueue.main.async(execute: {
                    self.dismissPopupView()
                })
                self.navigationController?.pushViewController((addCardVc)!, animated: true)
            }
            else{
                pay_balance = String(self.directFloatBalance ?? 0.0)
                if  ischeckManadoryDetails() {
                }
                let addCardVc = self.storyboard?.instantiateViewController(withIdentifier: "AddCreditCardList") as? AddCreditCardList
                
                var pay_amount : Double = 0.00
                //let pay_amount1 = Float64(buyCreditAmount ?? "")
                print(pay_amount)
                
                var coachPrice33 = advisor_Details["livechat_price"] as? String ?? ""
                 coachPrice33 = String(coachPrice33.characters.dropFirst())
                //   let CoachPriceStr:String = String(describing: coachPrice)
                //     let coachpriceValue = Int(CoachPriceStr)
                let CoachPriceValue  = Double(coachPrice33)
                let coachPricePerTenMin = String(format:"%3.2f",CoachPriceValue! * 10)
                let coachPricePerFiftenMin = String(format:"%3.2f", CoachPriceValue! * 15)
                let coachPricePerTwentyMin = String(format:"%3.2f",CoachPriceValue! * 20)
                let coachPricePerThirtyMin = String(format:"%3.2f",CoachPriceValue! * 30)
                var  liveChatDuration = ""
                
                
                if paymentTableIndexSelectedValue == 0 {
                    pay_amount = Double(coachPricePerTenMin)!
                        liveChatDuration = "10"
                }else if paymentTableIndexSelectedValue == 1 {
                    pay_amount = Double(coachPricePerFiftenMin)!
                        liveChatDuration = "15"
                }else if paymentTableIndexSelectedValue == 2{
                    pay_amount = Double(coachPricePerTwentyMin)!
                        liveChatDuration = "20"
                }else if paymentTableIndexSelectedValue == 3 {
                    pay_amount = Double(coachPricePerThirtyMin)!
                        liveChatDuration = "30"
                }
                
                
                let userDetail = getUserDetails()
                let user_balance = userDetail["balance"] as? String ?? "0.0"
                let balance = Double(user_balance)
                print(balance ?? 0.0)
                
                pay_amount = pay_amount - balance!
                
                var Total_balance = ""
                let main_balance = (balance ?? 0.0) + pay_amount
                Total_balance = String(main_balance)
                
                let request = ["user_id": getUserId(),
                               "coach_id":coachId,
                               "type":communicationType,
                               "title":aboutTextView.text,
                               "question":questionTextView.text,
                               "images":uploadUrlArray,
                               "user_balance": self.user_old_balance,
                               "pay_amount":self.directFloatBalance ?? 0.0,
                               "payment_type":communicationType,
                               "CoachPriceLiveChat" : advisor_Details["livechat_price"] as? String] as [String : Any]
                print(request)
                print(imageArray)
                addCardVc?.LiveChatTotalAmount = Total_balance
                addCardVc?.LiveChatPaymentAmount = String(pay_amount)
                addCardVc?.imageArray = self.imageArray as NSArray
                addCardVc?.questionDict = request as NSDictionary
                addCardVc?.userDelegate = self
                addCardVc?.sendMsgDelegate = self
                addCardVc?.pay_balance = pay_balance
                addCardVc?.pageString =  "userSendMessageVC"
                addCardVc?.LiveChatDuration = liveChatDuration
                addCardVc?.LiveChatCoachPrice = coachPrice33
                addCardVc?.LiveChatTotalPrice = Total_balance
                DispatchQueue.main.async(execute: {
                    self.dismissPopupView()
                })
                self.navigationController?.pushViewController((addCardVc)!, animated: true)
            }
            
        }
    }
    
    
    
    //MARK: ************  clickOnGallery Button **************
    @objc func clickOnGalleryButton() {
        
        
        
        let actionSheetController = UIAlertController(title: "Choose Image", message:nil , preferredStyle: .actionSheet)
        
        // actionSheetController.view.tintColor = UIColor.headerBlue
        
        let galleryButton = UIAlertAction(title: "Gallery", style: .default) { action -> Void in
            self.openGallary()
        }
        let cameraButton = UIAlertAction(title: "Camera", style: .default) { action -> Void in
            self.openCamera()
        }
        let cancelActionButton = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
            
        }
        picker.delegate = self
        picker.allowsEditing = false
        cancelActionButton.setValue(UIColor.red, forKey: "titleTextColor")
        actionSheetController.addAction(galleryButton)
        actionSheetController.addAction(cameraButton)
        actionSheetController.addAction(cancelActionButton)
        self.present(actionSheetController, animated: true, completion: nil)
        
    }
    func openCamera(){
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)){
            picker.sourceType = UIImagePickerControllerSourceType.camera
            self .present(picker, animated: true, completion: nil)
        }else{
            notifyUser("", message: "Your device doesn't support camera", vc: self)
        }
    }
    
    func openGallary(){
        picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        self.present(picker, animated: true, completion: nil)
    }
    
    
    @objc func clickOnCancelButton(sender:UIButton) {
        self.imageArray.remove(at: sender.tag)
        self.collection_view.reloadData()
    }
    
    // MARK: - UIImagePickerControllerDelegate Methods
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        selectedImage = selectedImage?.resizeWithWidth(width: 200)!
        
        self.imageArray.append(selectedImage!)
        self.collection_view.reloadData()
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: ************** UITextView Methods ******************
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool{
        let currentString: NSString = textView.text! as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: text) as NSString
        if textView.tag == 1 {
            let textLength =  100 - newString.length
            if newString.length <= 100 {
                lbl_aboutLenght.text = String(textLength) + " character"
            }
            return newString.length <= 100
        }
        else{
            let textLength =  500 - newString.length
            if newString.length <= 500 {
                lbl_questionLength.text = String(textLength) + " character"
            }
            return newString.length <= 500
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        if let placeholderLabel = textView.viewWithTag(100) as? UILabel {
            placeholderLabel.isHidden = textView.text.characters.count > 0
        }
    }
    //MARK: Back Button Action
    @IBAction func backButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    func userLoginUpdateBalanceForQuestionSubmit() {
        
        let userDetail = getUserDetails()
        //        let socialId = userDetail["socialId"] as? String ?? ""
        //        let socialType = userDetail["socialType"] as? String ?? ""
        //
        let requestDict = ["user_id":getUserId()] as NSDictionary
        print(requestDict)
        WebServices().mainFunctiontoGetDetails(data: requestDict,serviceType:k_USER_Profile) { (responseData)  in
            //stopProgressIndicator()
            if responseData != nil
            {
                let code = responseData?["code"] as? NSNumber
                print("responseData",responseData ?? "")
                if code == 200{
                    if let resultDict = responseData?["result"] as? NSDictionary {
                       
                        removeUserDetails()
                        saveUserDetails(userDict: resultDict)
                        CloseChatDays = resultDict["close_chat"] as? String ?? ""
                        ServiceTaxValue = resultDict["service_tax"] as? String ?? ""
                        /************* Redirect to my session Page **********/
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
                         /************* Redirect to my session Page **********/
                    }
                }
            }
            else{
                stopProgressIndicator()
            }
        }
    }
    
    func userLoginApi() {
        
        let userDetail = getUserDetails()
        //        let socialId = userDetail["socialId"] as? String ?? ""
        //        let socialType = userDetail["socialType"] as? String ?? ""
        //
        let requestDict = ["user_id":getUserId()] as NSDictionary
        print(requestDict)
        WebServices().mainFunctiontoGetDetails(data: requestDict,serviceType:k_USER_Profile) { (responseData)  in
            //stopProgressIndicator()
            if responseData != nil
            {
                let code = responseData?["code"] as? NSNumber
                print("responseData",responseData ?? "")
                if code == 200{
                    if let resultDict = responseData?["result"] as? NSDictionary {
                         removeUserDetails()
                        saveUserDetails(userDict: resultDict)
                        CloseChatDays = resultDict["close_chat"] as? String ?? ""
                        ServiceTaxValue = resultDict["service_tax"] as? String ?? ""
                    }
                }
            }
            else{
                //stopProgressIndicator()
            }
        }
    }
    
    
    
    //MARK: *********** Send Message Button  ***********
    @IBAction func sendMessage(_ sender: Any) {
        
        if communicationType == "3" {

            AddPaymentPopup.isHidden = false
            let popupConfig = STZPopupViewConfig()
            popupConfig.dismissTouchBackground = false
            popupConfig.cornerRadius = 10

            presentPopupView(AddPaymentPopup, config: popupConfig)

        }else {
            print("get user default value \(defaults.bool(forKey: "PaymentVerified"))")
            let paymentVerify = defaults.bool(forKey: "PaymentVerified")
            var direct_price = advisor_Details["direct_price"] as? String ?? ""
            
            if communicationType == "1" {
                direct_price = advisor_Details["direct_price"] as? String ?? ""
            }
            else if communicationType == "2" {
                direct_price = advisor_Details["rush_direct_price"] as? String ?? ""
            }
            else {
                direct_price = advisor_Details["livechat_price"] as? String ?? ""
            }
            
            let outputString = String(direct_price.characters.dropFirst())
            let directOutputInt = Float(outputString)
            self.directFloatBalance = directOutputInt
            print(self.directFloatBalance ?? 0.0)
            
            let userDetails = getUserDetails()
            let balance = userDetails["balance"] as? String ?? ""
            let user_balance = (balance as NSString).floatValue
            self.user_old_balance = balance
            
            print(self.imageArray)
            
            if paymentVerify == true {
                defaults.set(false, forKey: "PaymentVerified")
                if  ischeckManadoryDetails() {
                    if imageArray.count == 0 {
                        showProgressIndicator(refrenceView: self.view)
                        defaults.set(false, forKey: "PaymentVerified")
                        self.sendUserMessage_to_coach()
                    }
                    else{
                        uploadImageOnserver()
                    }
                }
            }
            else {
                //false
            }
            
            if (user_balance) > (directOutputInt ?? 0.0) {
                let main_balance = user_balance - directOutputInt!
                remain_balance  = String(main_balance)
                
                if  ischeckManadoryDetails() {
                    if imageArray.count == 0 {
                        showProgressIndicator(refrenceView: self.view)
                        self.sendUserMessage_to_coach()
                    }
                    else{
                        uploadImageOnserver()
                    }
                }
            }
            else if balance == "0.0" || balance == "0" || remain_balance == "0.0" {
                if  ischeckManadoryDetails() {
                }
                let addCardVc = self.storyboard?.instantiateViewController(withIdentifier: "AddCreditCardList") as? AddCreditCardList
                addCardVc?.sendMsgDelegate = self
                let request = ["user_id": getUserId(),
                               "coach_id":coachId,
                               "type":communicationType,
                               "images":uploadUrlArray,
                               "user_balance":remain_balance ?? self.user_old_balance ?? "0",
                               "pay_amount":self.directFloatBalance ?? 0.0,
                               "payment_type":communicationType,
                               "question":questionTextView.text,
                               "title":aboutTextView.text,] as [String : Any]
                print(request)
                print(imageArray)
                addCardVc?.imageArray = self.imageArray as NSArray
                addCardVc?.questionDict = request as NSDictionary
                addCardVc?.userDelegate = self
                addCardVc?.directPrice = directOutputInt!
                addCardVc?.pageString =  "userSendMessageVC"
                self.navigationController?.pushViewController((addCardVc)!, animated: true)
            }
                
            else if (directOutputInt ?? 0.0) > (user_balance) {
                let main_balance = directOutputInt! - user_balance
                let userRemain = user_balance - directOutputInt!
                print(userRemain)
                
                // Check Condition for balance less or more from 0.05
                if main_balance >= 0.05 || main_balance >= 0.5 {
                    
                    pay_balance = String(main_balance)
                    if  ischeckManadoryDetails() {
                    }
                    let addCardVc = self.storyboard?.instantiateViewController(withIdentifier: "AddCreditCardList") as? AddCreditCardList
                    let request = ["user_id": getUserId(),
                                   "coach_id":coachId,
                                   "type":communicationType,
                                   "title":aboutTextView.text,
                                   "question":questionTextView.text,
                                   "images":uploadUrlArray,
                                   "user_balance":"0.00",
                                   "pay_amount":self.directFloatBalance ?? 0.0,
                                   "payment_type":communicationType] as [String : Any]
                    print(request)
                    print(imageArray)
                    addCardVc?.imageArray = self.imageArray as NSArray
                    addCardVc?.questionDict = request as NSDictionary
                    addCardVc?.userDelegate = self
                    addCardVc?.sendMsgDelegate = self
                    addCardVc?.pay_balance = pay_balance
                    addCardVc?.pageString =  "userSendMessageVC"
                    self.navigationController?.pushViewController((addCardVc)!, animated: true)
                }
                else{
                    pay_balance = String(self.directFloatBalance ?? 0.0)
                    if  ischeckManadoryDetails() {
                    }
                    let addCardVc = self.storyboard?.instantiateViewController(withIdentifier: "AddCreditCardList") as? AddCreditCardList
                    let request = ["user_id": getUserId(),
                                   "coach_id":coachId,
                                   "type":communicationType,
                                   "title":aboutTextView.text,
                                   "question":questionTextView.text,
                                   "images":uploadUrlArray,
                                   "user_balance": self.user_old_balance,
                                   "pay_amount":self.directFloatBalance ?? 0.0,
                                   "payment_type":communicationType] as [String : Any]
                    print(request)
                    print(imageArray)
                    addCardVc?.imageArray = self.imageArray as NSArray
                    addCardVc?.questionDict = request as NSDictionary
                    addCardVc?.userDelegate = self
                    addCardVc?.sendMsgDelegate = self
                    addCardVc?.pay_balance = pay_balance
                    addCardVc?.pageString =  "userSendMessageVC"
                    self.navigationController?.pushViewController((addCardVc)!, animated: true)
                }
                
            }
        }
        
        
       
    }
    
    func sendUserMessage_to_coach() {
       
        print(uploadUrlArray)
        print(imageArray)
        print(imageArray.count)
        if self.imageArray.count == 0 {
            //   showProgressIndicator(refrenceView: self.view)
          
//
            var coachPrice : String = ""
            if communicationType == "1"  {
                print("Direct")
                coachPrice = advisor_Details["direct_price"] as! String
            }else if communicationType == "2"  {
                 print("Rush Direct")
                coachPrice = advisor_Details["rush_direct_price"] as! String
            }else if communicationType == "3" {
                 print("Live Chat")
                
                coachPrice = advisor_Details["livechat_price"] as! String
            }
           
            coachPrice =   String(coachPrice.characters.dropFirst())
          
             let liveChatPaymentValue = coachPrice
           
            
           
            let serviceTaxKey =   ServiceTaxValue as? String ?? ""
            var serviceTaxValue22 =  (serviceTaxKey as NSString).doubleValue
            print(serviceTaxValue22)
            serviceTaxValue22 =  100.00 - serviceTaxValue22
            print(serviceTaxValue22)
           
            let PaymentStr =      coachPrice
            
            print(PaymentStr)
            let paymentValue = (PaymentStr as! NSString).doubleValue
            var coachAmount  = (paymentValue * serviceTaxValue22)/100

            var  request : NSDictionary = NSDictionary()
            if communicationType == "3" {
                
                
                var liveChatAmount : Double = 0.00
                //let pay_amount1 = Float64(buyCreditAmount ?? "")
             
                
                var coachPrice1 = advisor_Details["livechat_price"] as? String ?? ""
                coachPrice1 =  String(coachPrice1.characters.dropFirst())
                //   let CoachPriceStr:String = String(describing: coachPrice)
                //     let coachpriceValue = Int(CoachPriceStr)
                let CoachPriceValue  = Double(coachPrice1)
                let coachPricePerTenMin = String(format:"%3.2f",CoachPriceValue! * 10)
                let coachPricePerFiftenMin = String(format:"%3.2f", CoachPriceValue! * 15)
                let coachPricePerTwentyMin = String(format:"%3.2f",CoachPriceValue! * 20)
                let coachPricePerThirtyMin = String(format:"%3.2f",CoachPriceValue! * 30)
                var  liveChatDuration = ""
                
                
                if paymentTableIndexSelectedValue == 0 {
                    liveChatAmount = Double(coachPricePerTenMin)!
                    liveChatDuration = "10"
                }else if paymentTableIndexSelectedValue == 1 {
                    liveChatAmount = Double(coachPricePerFiftenMin)!
                    liveChatDuration = "15"
                }else if paymentTableIndexSelectedValue == 2{
                    liveChatAmount = Double(coachPricePerTwentyMin)!
                    liveChatDuration = "20"
                }else if paymentTableIndexSelectedValue == 3 {
                    liveChatAmount = Double(coachPricePerThirtyMin)!
                    liveChatDuration = "30"
                }
                
                let getTax = ServiceTaxValue as? String ?? ""
                var  ServiceTaxValue1 = Double(getTax)
                ServiceTaxValue1 =  100.0 - ServiceTaxValue1!
                let CoachAmountPrice = Double((ServiceTaxValue1! *  liveChatAmount)/100)
                let CoachAmountPriceStr = String(CoachAmountPrice)
                let liveChatAmountStr = String(liveChatAmount)
                
                
                
                request = ["user_id": getUserId(),
                               "coach_id":coachId,
                               "type":communicationType,
                               "images":uploadUrlArray,
                               "user_balance":remain_balance ?? self.user_old_balance ?? "0",
                               "pay_amount":liveChatPaymentValue ?? 0.0,
                               "payment_type":communicationType,
                               "title":aboutTextView.text,
                               "question":questionTextView.text,
                               "charge_id" : "",
                               "payment_id": "",
                               "close_chat" : CloseChatDays,
                               "service_tax":serviceTaxKey,
                               "coach_amount": CoachAmountPriceStr,
                               "duration" : liveChatDuration,
                               "live_chat_amount" : liveChatAmountStr] as NSDictionary
                
                DispatchQueue.main.async(execute: {
                    self.dismissPopupView()
                })
            }else {
                 request = ["user_id": getUserId(),
                               "coach_id":coachId,
                               "type":communicationType,
                               "images":uploadUrlArray,
                               "user_balance":remain_balance ?? self.user_old_balance ?? "0",
                               "pay_amount":self.directFloatBalance ?? 0.0,
                               "payment_type":communicationType,
                               "title":aboutTextView.text,
                               "question":questionTextView.text,
                               "charge_id" : "",
                                "close_chat" : CloseChatDays,
                               "payment_id": "",
                               "service_tax":serviceTaxKey,
                               "coach_amount": coachAmount] as NSDictionary
            }
            
        
           
            
            print(request)
            print(uploadUrlArray)
            
            
            WebServices().mainFunctiontoGetDetails(data: request as NSDictionary,serviceType:kADD_NEWORDER) { (responseData)  in
             //   stopProgressIndicator()
                self.defaults.set(false, forKey: "PaymentVerified")
                if responseData != nil
                {
                    let code = responseData?["code"] as? NSNumber
                    print("responseData",responseData ?? "")
                    if code == 200{
                       
                        self.userLoginUpdateBalanceForQuestionSubmit()
//                        stopProgressIndicator()
//                        DispatchQueue.main.async(execute: {
//
//                            notifyUser("", message: " Your Question has been submitted successfully and We will get you back shortly", vc: self)
//                            self.defaults.set(false, forKey: "PaymentVerified")
//                        })
                        ////////// ***************** /////////////////
//
//                        if let viewControllers = self.navigationController?.viewControllers {
//                            for viewController in viewControllers {
//                                // some process
//                                if viewController.isKind(of: HomeTabbarVC.self){
//                                    if let vc = viewController as? HomeTabbarVC {
//                                        vc.selectedIndex = 0;
//                                        vc.viewDidLoad()
//                                        self.navigationController?.popToViewController(vc, animated: true)
//                                        break
//                                    }
//
//                                }
//                            }
//                        }
                        ////////// ***************** //////////////////
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
        }else if self.imageArray.count > 0 {
            //  showProgressIndicator(refrenceView: self.view)
            self.uploadImageOnserver()
        }
        
    }
    
    func sendUserMsgWithImage() {
        
        
        //    showProgressIndicator(refrenceView: self.view)
        
        
        let serviceTaxKey =   ServiceTaxValue as? String ?? ""
        var serviceTaxValue2 =  (serviceTaxKey as NSString).doubleValue
        print(serviceTaxValue2)
        serviceTaxValue2 =  100.00 - serviceTaxValue2
        print(serviceTaxValue2)
        
        var coachPrice : String = ""
        if communicationType == "1"  {
            print("Direct")
            coachPrice = advisor_Details["direct_price"] as! String
        }else if communicationType == "2"  {
            print("Rush Direct")
            coachPrice = advisor_Details["rush_direct_price"] as! String
        }else if communicationType == "3" {
            print("Live Chat")
            
            coachPrice = advisor_Details["livechat_price"] as! String
        }
        
        coachPrice =   String(coachPrice.characters.dropFirst())
        
        let PaymentStr =      coachPrice
        
        print(PaymentStr)
        let paymentValue = (PaymentStr as! NSString).doubleValue
        var coachAmount  = (paymentValue * serviceTaxValue2)/100
        
        var  request : NSDictionary = NSDictionary()
        if communicationType == "3" {
      
            var liveChatAmount : Double = 0.00
            //let pay_amount1 = Float64(buyCreditAmount ?? "")
            
            
            var coachPrice1 = advisor_Details["livechat_price"] as? String ?? ""
            coachPrice1 =  String(coachPrice1.characters.dropFirst())
             let liveChatPaymentValue = coachPrice1
            //   let CoachPriceStr:String = String(describing: coachPrice)
            //     let coachpriceValue = Int(CoachPriceStr)
            let CoachPriceValue  = Double(coachPrice1)
            let coachPricePerTenMin = String(format:"%3.2f",CoachPriceValue! * 10)
            let coachPricePerFiftenMin = String(format:"%3.2f", CoachPriceValue! * 15)
            let coachPricePerTwentyMin = String(format:"%3.2f",CoachPriceValue! * 20)
            let coachPricePerThirtyMin = String(format:"%3.2f",CoachPriceValue! * 30)
            var  liveChatDuration = ""
            
            
            if paymentTableIndexSelectedValue == 0 {
                liveChatAmount = Double(coachPricePerTenMin)!
                liveChatDuration = "10"
            }else if paymentTableIndexSelectedValue == 1 {
                liveChatAmount = Double(coachPricePerFiftenMin)!
                liveChatDuration = "15"
            }else if paymentTableIndexSelectedValue == 2{
                liveChatAmount = Double(coachPricePerTwentyMin)!
                liveChatDuration = "20"
            }else if paymentTableIndexSelectedValue == 3 {
                liveChatAmount = Double(coachPricePerThirtyMin)!
                liveChatDuration = "30"
            }
            
            let getTaxLive = ServiceTaxValue as? String ?? ""
            var  ServiceTaxValue1 = Double(getTaxLive)
            ServiceTaxValue1 =  100.0 - ServiceTaxValue1!
            let CoachAmountPrice = Double((ServiceTaxValue1! *  liveChatAmount)/100)
            let CoachAmountPriceStr = String(CoachAmountPrice)
            let liveChatAmountStr = String(liveChatAmount)
            
          
            request = ["user_id": getUserId(),
                       "coach_id":coachId,
                       "type":communicationType,
                       "images":uploadUrlArray,
                       "user_balance":remain_balance ?? self.user_old_balance ?? "0",
                       "pay_amount":liveChatPaymentValue ?? 0.0,
                       "payment_type":communicationType,
                       "title":aboutTextView.text,
                       "question":questionTextView.text,
                       "charge_id" : "",
                       "payment_id": "",
                       "service_tax":serviceTaxKey,
                        "close_chat" : CloseChatDays,
                       "coach_amount": CoachAmountPriceStr,
                       "duration" : liveChatDuration,
                       "live_chat_amount" : liveChatAmountStr] as NSDictionary
        }else {
            request = ["user_id": getUserId(),
                       "coach_id":coachId,
                       "type":communicationType,
                       "images":uploadUrlArray,
                       "user_balance":remain_balance ?? self.user_old_balance ?? "0",
                       "pay_amount":self.directFloatBalance ?? 0.0,
                       "payment_type":communicationType,
                       "title":aboutTextView.text,
                       "question":questionTextView.text,
                       "charge_id" : "",
                       "payment_id": "",
                        "close_chat" : CloseChatDays,
                       "service_tax":serviceTaxKey,
                       "coach_amount": coachAmount] as! NSDictionary
        }
        
        
     
        
        print(request)
        print(uploadUrlArray)
        WebServices().mainFunctiontoGetDetails(data: request as NSDictionary,serviceType:kADD_NEWORDER) { (responseData)  in
            stopProgressIndicator()
            self.defaults.set(false, forKey: "PaymentVerified")
            if responseData != nil
            {
                let code = responseData?["code"] as? NSNumber
                print("responseData",responseData ?? "")
                if code == 200{
                //    stopProgressIndicator()
                    self.userLoginUpdateBalanceForQuestionSubmit()
//                    DispatchQueue.main.async(execute: {
//                        notifyUser("", message: " Your Question has been submitted successfully and We will get you back shortly", vc: self)
//                        self.defaults.set(false, forKey: "PaymentVerified")
//                    })
                    ////////// ***************** /////////////////
                    
//                    if let viewControllers = self.navigationController?.viewControllers {
//                        for viewController in viewControllers {
//                            // some process
//                            if viewController.isKind(of: HomeTabbarVC.self){
//                                if let vc = viewController as? HomeTabbarVC {
//                                    vc.selectedIndex = 0;
//                                    self.navigationController?.popToViewController(vc, animated: true)
//                                    break
//                                }
//
//                            }
//                        }
//                    }
                    ////////// ***************** //////////////////
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
        showProgressIndicator(refrenceView: self.view)
        if communicationType == "3" {
            DispatchQueue.main.async(execute: {
                self.dismissPopupView()
            })
        }
     
        for image in imageArray {
            let fileManager = FileManager.default
            let path = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("\(String(describing: image)).jpeg")
            let imageData = UIImageJPEGRepresentation(image, 0.5)
            fileManager.createFile(atPath: path as String, contents: imageData, attributes: nil)
            let fileUrl = URL(fileURLWithPath: path)
            
            WebServices().uploadImageonServer(imageURL: fileUrl){ (responseData)  in
                
                if responseData != nil{
                    if let uploadUrl = responseData {
                        self.uploadUrlArray.add(uploadUrl)
                    }
                    if self.uploadUrlArray.count == self.imageArray.count {
                        self.sendUserMsgWithImage()
                    }
                    print("responseData",responseData ?? "")
                    print("uploadUrlArray============",self.uploadUrlArray )
                }
                else{ stopProgressIndicator()}
            }
        }
    }
    
    
    //    func AlertConfirmController(directOutputInt:Float,pay_balance:String) {
    //        let refreshAlert = UIAlertController(title: "Confirm", message: "You have not enough balance so please buy credit amount..", preferredStyle: UIAlertControllerStyle.alert)
    //
    //        refreshAlert.addAction(UIAlertAction(title: "Confirm", style: .destructive, handler: { (action: UIAlertAction!) in
    //            print("Handle Ok logic here")
    //            let addCardVc = self.storyboard?.instantiateViewController(withIdentifier: "PaymentMethodVC") as! PaymentMethodVC
    //            addCardVc.userDelegate = self
    //            addCardVc.sendMsgDelegate = self
    //            addCardVc.pay_balance = pay_balance
    //            //addCardVc.directPrice = directOutputInt
    //            addCardVc.pageString =  "userSendMessageVC"
    //            self.navigationController?.pushViewController(addCardVc, animated: true)
    //
    //        }))
    //
    //        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
    //            print("Handle Cancel Logic here")
    //        }))
    //        present(refreshAlert, animated: true, completion: nil)
    //    }
    //
    
    
    
    
    //MARK: ****** Check Field is empty / valid **************
    func ischeckManadoryDetails() -> Bool {
        
        if String.isNilOrEmpty(questionTextView.text)  {
            notifyUser("", message: kQUESTION_BLANK, vc: self)
            return false
        } else if String.isNilOrEmpty(aboutTextView.text)  {
            notifyUser("", message: "Please Enter Description", vc: self)
            return false
        }
        
        return true
    }
}


//MARK: ******** UPDATE LOGIN USERINFO DETAIL *****************
extension UserSendMessageVc:  UpdateUserInfoDelegate {
    func getUserDetailApi() {
        userLoginApi()
    }
    
}


//MARK: ******** UPDATE Send Message Api *****************
extension UserSendMessageVc: SendUserMessageDelegate  {
    func sendMessageApi() {
        sendUserMessage_to_coach()
    }
}


//MARK: Extension Collection View DataSource
extension UserSendMessageVc: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if imageArray.count == 3 {
            return self.imageArray.count
        }
        else{
            return self.imageArray.count + 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collection_view.dequeueReusableCell(withReuseIdentifier: "SendImageCollectionCell", for: indexPath) as! SendImageCollectionCell
        
        cell.cancelButton.tag = indexPath.row
        if imageArray.count == 3 {
            cell.galleryImageView.image = imageArray[indexPath.item]
            cell.cancelButton.isHidden = false
            cell.cancelButton.addTarget(self, action: #selector(self.clickOnCancelButton(sender:)), for: .touchUpInside)
        }
        else
        {
            if indexPath.row == imageArray.count {
                //+plus button
                cell.galleryImageView.image = #imageLiteral(resourceName: "gallery_Button")
                cell.cancelButton.isHidden = true
            }
            else {
                cell.galleryImageView.image = imageArray[indexPath.item]
                cell.cancelButton.isHidden = false
                cell.cancelButton.addTarget(self, action: #selector(self.clickOnCancelButton(sender:)), for: .touchUpInside)
            }
        }
        
        return cell
    }
}

//MARK: Extension Collection view Delegate
extension UserSendMessageVc:UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if imageArray.count != 3 {
            if indexPath.row == imageArray.count {
                clickOnGalleryButton()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 80, height: 80 )
    }
}
extension UserSendMessageVc: UITableViewDataSource,UITableViewDelegate {
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView.tag == 2 {
            return 50
        }
        
        return 50
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView.tag == 2 {
            return 4
        }
         return 4
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
           var  coachPrice  = ""
            
            if communicationType == "3" {
                print("Live Chat")
                
                coachPrice = advisor_Details["livechat_price"] as! String
            }
            
            coachPrice =   String(coachPrice.characters.dropFirst())
        
            let CoachPriceValue = Double(coachPrice)
            let coachPricePerTenMin = String(format:"10 Min / $%3.2f",CoachPriceValue! * 10.00)
            let coachPricePerFiftenMin = String(format:"15 Min / $%3.2f",CoachPriceValue! * 15.00)
            let coachPricePerTwentyMin = String(format:"20 Min / $%3.2f",CoachPriceValue! * 20.00)
            let coachPricePerThirtyMin = String(format:"30 Min / $%3.2f",CoachPriceValue! * 30.00)
            
            
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
        
        
        
    }
        
        return UITableViewCell()
        
    }

    
  
    
    
   
}

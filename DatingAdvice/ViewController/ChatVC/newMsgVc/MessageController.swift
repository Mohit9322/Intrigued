//
//  MessageController.swift
//  Intrigued
//
//  Created by Shineweb-solutions on 09/03/18.
//  Copyright © 2018 daniel helled. All rights reserved.
//

import UIKit
import MagicalRecord
import Foundation
import IQKeyboardManagerSwift
import MobileCoreServices
import AVFoundation
import MediaPlayer
import AVKit
import STZPopupView

class MessageController: UIViewController,UITextViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    @IBOutlet weak var messageTblView: UITableView!
    var headerBaseView: UIView!
    var chatNamelbl: UILabel!
    var backBtn: UIButton!
    var infoBtn: UIButton!
    var chatView: UIView!
    var cameraImgBtn: UIButton!
    var MsgTextView: UITextView!
    var MsgSendBtn: UIButton!
    var replyIcon: UIImageView!
    var picker = UIImagePickerController()
    var userQuestInfo = NSDictionary()
    var coach_id = ""
    var completeTime = ""
    var user_id = ""
    var orderId = ""
    var type = ""
    var messageListArray = NSArray()
    var PreviewUrl = NSURL()

    
    var closedChatDays = Int()
    var interval = Int()
 
    var reviewPopup = UIView()
    var reviewNameLbl  =  UILabel()
    var likeBtn = UIButton()
    var dislikeButton = UIButton()
    var  reviewTxtView = UITextView()
    var reviewCharLimit = UILabel()
    var cancelButton = UIButton()
    var  submitButton = UIButton()
    var grayLikeImg =  UIImage()
    var grayDislkeImg =  UIImage()
    var greenLikeImg =  UIImage()
    var redDislikeImg =  UIImage()
    
    var checkEdit = Bool()
    var reviewId = ""
    
    var CompleteType = Int()
    var serveiceTaxLiveChat = ""
    var closeChatLiveChat = ""
   

    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        serveiceTaxLiveChat = userQuestInfo["service_tax"] as! String
        closeChatLiveChat =  userQuestInfo["close_chat"] as! String
       print(serveiceTaxLiveChat,closeChatLiveChat )
        IQKeyboardManager.sharedManager().enable = false
        self.CreateView()
        setDoneOnKeyboard()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
         messageTblView.register(UINib(nibName: "VideoChatCellTableViewCell", bundle: nil), forCellReuseIdentifier: "VideoChatCellTableViewCell")
         self.messageTblView.register(UINib(nibName: "TextMsgCellTableViewCell", bundle: nil), forCellReuseIdentifier: "TextMsgCellTableViewCell")
        print(userQuestInfo)
        if isCoach() {
            type = "1"
            if let userInfo = userQuestInfo["user_id"] as? NSDictionary {
                let userName = (userInfo["fname"] as? String ?? "")  + " " + (userInfo["lname"] as? String ?? "")
                chatNamelbl.text = userName
                user_id = userInfo["_id"] as? String ?? ""
            }
        }
        else{
            type = "2"
            if let userId = userQuestInfo["user_id"] as? String {
                user_id = userId
            }
            
            if let coachInfo = userQuestInfo["coach_id"] as? NSDictionary {
                let userName = (coachInfo["fname"] as? String ?? "")  + " " + (coachInfo["lname"] as? String ?? "")
                chatNamelbl.text = userName
            }
        }
        orderId = userQuestInfo["_id"] as? String ?? ""
        if let coachInfo = userQuestInfo["coach_id"] as? NSDictionary{
            coach_id = coachInfo["_id"] as? String ?? ""
        }
        getListofmessage()
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true

      
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
   //     NotificationCenter.default.addObserver(self, selector: #selector(self.uploadImage_Video(_:)), name: NSNotification.Name(rawValue: "ImageVideoUploadNotification"), object: nil)
        
        // handle notification
        
    }
    
   
    
    func sendUserMessage_to_coach(request:NSDictionary) {
        
      
        WebServices().mainFunctiontoGetDetails(data: request as NSDictionary,serviceType:kSEND_MESSAGE) { (responseData)  in
            stopProgressIndicator()
            if responseData != nil
            {
                let code = responseData?["code"] as? NSNumber
                print("responseData",responseData ?? "")
                if code == 200{
                    stopProgressIndicator()
                   
                    self.getListofmessage()
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
    
    func getListofmessage() {
        
        let request = ["order_id":orderId] as [String : Any]
        
        showProgressIndicator(refrenceView: self.view)
        print(request)
        WebServices().mainFunctiontoGetDetails(data: request as NSDictionary,serviceType:kMESSAGE_LIST) { (responseData)  in
            stopProgressIndicator()
            if responseData != nil
            {
                let code = responseData?["code"] as? NSNumber
                print("responseData",responseData ?? "")
                if code == 200{
                    stopProgressIndicator()
                    guard let result = responseData?["result"] as? NSMutableArray else {
                        return
                    }
                    self.messageListArray = result
                    self.messageTblView.reloadData()
                    self.setLastIndexPath()
                    stopProgressIndicator()
                    
                }
                else {
                    if let message = responseData?["result"] as? String {
                        // notifyUser("", message: message , vc: self)
                    }
                    else{
                        // notifyUser("", message: "Something went wrong", vc: self)
                    }
                }
            }
            else{ stopProgressIndicator()}
            
        }
    }
  
    func setDoneOnKeyboard() {
        let keyboardToolbar = UIToolbar()
        keyboardToolbar.sizeToFit()
        let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.dismissKeyboard))
        keyboardToolbar.items = [flexBarButton, doneBarButton]
        self.MsgTextView.inputAccessoryView = keyboardToolbar
        //        #selector(InfoBtnPressed(_:))
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    func CreateView() {
        
        headerBaseView = UIView(frame: CGRect(x: 0, y: 0 , width:self.view.frame.size.width, height: 80))
        headerBaseView.backgroundColor = hexStringToUIColor(hex: "#1d7399")
        self.view.addSubview(headerBaseView)
        
        let backBtnImg =  UIImage(named: "back_white_icon")!
        let infoBtnImg =  UIImage(named: "info_white")!
        let cameraBtnImg =  UIImage(named: "camera_icon")!
        let ReplyBtnImg =  UIImage(named: "reply_icon")!
        
        
        
        
        backBtn = UIButton(frame: CGRect(x:5 , y: 47, width:60 , height: 15))
         backBtn.setImage(backBtnImg, for: .normal)
   
        backBtn.titleLabel?.textAlignment = .left
        backBtn.addTarget(self, action:#selector(backBtnPressed(_:)), for: .touchUpInside)
        headerBaseView.addSubview(backBtn)
        
        
        chatNamelbl = UILabel(frame: CGRect(x:(self.view.frame.size.width - 180 )/2  , y: 41, width: 180 , height: 25))
        chatNamelbl.textColor = UIColor.white
        chatNamelbl.textAlignment = .center
        headerBaseView.addSubview(chatNamelbl)
        
        infoBtn = UIButton(frame: CGRect(x:self.view.frame.size.width - 50  , y: 34, width:40 , height: 40))
       // infoBtn.setBackgroundImage(infoBtnImg, for: .normal)
          infoBtn.setImage(infoBtnImg, for: .normal)
        infoBtn.addTarget(self, action:#selector(InfoBtnPressed(_:)), for: .touchUpInside)
        headerBaseView.addSubview(infoBtn)
        
        
        messageTblView.frame =  CGRect(x:0 , y:headerBaseView.frame.origin.y + headerBaseView.frame.size.height , width:self.view.frame.size.width , height: self.view.frame.height - (headerBaseView.frame.origin.y + headerBaseView.frame.size.height + 80))
        messageTblView.delegate = self
        messageTblView.dataSource = self
        self.view.addSubview(messageTblView)
        
        chatView = UIView(frame: CGRect(x: 10, y: messageTblView.frame.origin.y + messageTblView.frame.size.height + 28  , width:self.view.frame.size.width - 20, height: 50))
        chatView.layer.cornerRadius = chatView.frame.size.height / 2
        chatView.clipsToBounds = true
        chatView.layer.borderColor = UIColor.lightGray.cgColor
        chatView.layer.borderWidth = 1.0
        self.view.addSubview(chatView)
        
        
        cameraImgBtn = UIButton(frame: CGRect(x:2 , y: 0, width:50 , height: 50))
        //  cameraImgBtn.setBackgroundImage(cameraBtnImg, for: .normal)
        cameraImgBtn.setImage(cameraBtnImg, for: .normal)
        cameraImgBtn.layer.masksToBounds = true
        cameraImgBtn.layer.cornerRadius = 25
        cameraImgBtn.addTarget(self, action:#selector(cameraImgBtnPressed(_:)), for: .touchUpInside)
        //     cameraImgBtn.backgroundColor = UIColor.red
        chatView.addSubview(cameraImgBtn)
        
        MsgTextView = UITextView(frame: CGRect(x: 52, y: 2  , width:chatView.frame.size.width - 60 - 52, height: chatView.frame.size.height - 4))
        MsgTextView.delegate = self
        MsgTextView.placeholder = "Write Your message..."
        MsgTextView.tag = 1
        chatView.addSubview(MsgTextView)
        
        
        MsgSendBtn = UIButton(frame: CGRect(x:chatView.frame.size.width - 52 , y: 0, width:50 , height: 50))
        MsgSendBtn.setBackgroundImage(ReplyBtnImg, for: .normal)
        MsgSendBtn.layer.masksToBounds = true
        MsgSendBtn.layer.cornerRadius = 25
        MsgSendBtn.addTarget(self, action:#selector(MsgSendBtnPressed(_:)), for: .touchUpInside)
        chatView.addSubview(MsgSendBtn)
        
//        if isCoach() {
//            cameraImgBtn.isHidden = false
//        }else {
//            cameraImgBtn.frame = CGRect(x:2 , y: 0, width:50 , height: 50)
//            cameraImgBtn.isHidden = true
//            MsgTextView.frame =  CGRect(x: 10, y: 2  , width:chatView.frame.size.width - 60 - 10, height: chatView.frame.size.height - 4)
//            MsgSendBtn.frame =  CGRect(x:chatView.frame.size.width - 52 , y: 0, width:50 , height: 50)
//        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        //dateFormatter.timeZone = TimeZone(abbreviation: "GMT+0:00") //Current time zone
        dateFormatter.locale = NSLocale.init(localeIdentifier: "en_US_POSIX") as Locale!
        dateFormatter.timeZone = NSTimeZone(name: "GMT")! as TimeZone
        let Currentdate = Date()
        let dateString = dateFormatter.string(from: Currentdate)
        print(dateString)
        
        print(completeTime)
//        completeTime = "2018-03-07T10:39:05.055Z"
        
        let dateFormatter1 = DateFormatter()
        dateFormatter1.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatter1.locale = NSLocale.init(localeIdentifier: "en_US_POSIX") as Locale!
        dateFormatter1.timeZone = NSTimeZone(name: "GMT")! as TimeZone
        let CompleteDate = dateFormatter1.date(from: completeTime)
        
        let calendar = NSCalendar.current
        let components = calendar.dateComponents([.day], from: CompleteDate!, to: Currentdate)
        
        print(components.day)
        let closedChatDaystr = closeChatLiveChat
         closedChatDays = Int(closedChatDaystr) as! Int
         interval = components.day as! Int
        
        if interval > closedChatDays {
            self.MsgTextView.isUserInteractionEnabled = false
            self.cameraImgBtn.isUserInteractionEnabled = false
           // self.replyIcon.isUserInteractionEnabled = false
            self.MsgSendBtn.isUserInteractionEnabled = false
            self.chatView.isHidden = true
            
            messageTblView.frame =  CGRect(x:0 , y:headerBaseView.frame.origin.y + headerBaseView.frame.size.height , width:self.view.frame.size.width , height: self.view.frame.height - (headerBaseView.frame.origin.y + headerBaseView.frame.size.height ))
            
            if isCoach() {
                
                let msg = String(format:"User is not allowed to chat after %d days. Please create a new session",closedChatDays)
                notifyUser("", message: msg , vc: self)
            }else {
                
            }
            
        }else {
            
        }
        
        if isCoach() {
            
        }else {
            self.CreateReviewPopup()
        }
        

        
    }
    
    func CreateReviewPopup()  {
        
        checkEdit = false
        
        reviewPopup = UIView(frame: CGRect(x: 10, y: (self.view.frame.size.height -  300)/2 , width:self.view.frame.size.width - 20, height: 320))
        reviewPopup.backgroundColor = hexStringToUIColor(hex: "#1d7399")
        reviewPopup.layer.masksToBounds = true
        reviewPopup.layer.cornerRadius = 5.0
        self.view.addSubview(reviewPopup)
        
        reviewNameLbl = UILabel(frame: CGRect(x:20 , y: 10, width: 200 , height: 25))
        reviewNameLbl.textColor = UIColor.white
        reviewNameLbl.textAlignment = .left
        reviewNameLbl.text = "Adam Kazmei"
        reviewNameLbl.font = UIFont.boldSystemFont(ofSize: 16)
        reviewPopup.addSubview(reviewNameLbl)
        
        let likeDislikeBaseView = UIView(frame: CGRect(x: (self.view.frame.size.width - 150)/2, y: reviewNameLbl.frame.size.height + reviewNameLbl.frame.origin.y + 5 , width:150, height: 40))
        likeDislikeBaseView.backgroundColor = UIColor.clear
        likeDislikeBaseView.layer.masksToBounds = true
        likeDislikeBaseView.layer.cornerRadius = 5.0
        reviewPopup.addSubview(likeDislikeBaseView)
        
        grayLikeImg =  UIImage(named: "gray_like")!
        grayDislkeImg =  UIImage(named: "gray_dislike")!
        greenLikeImg =  UIImage(named: "green_like")!
        redDislikeImg =  UIImage(named: "red_dislike")!
        
        
        
        likeBtn = UIButton(frame: CGRect(x:10  , y: 5, width:30 , height: 30))
        likeBtn.setBackgroundImage(greenLikeImg, for: .selected)
        likeBtn.addTarget(self, action:#selector(reviewLikeBtnPressed(_:)), for: .touchUpInside)
        likeBtn.isSelected =  true
        likeBtn.setBackgroundImage(grayLikeImg, for: .normal)
        likeDislikeBaseView.addSubview(likeBtn)
        
        var  DotGrayLbl = UILabel(frame: CGRect(x: (likeDislikeBaseView.frame.size.width - 4)/2 , y: 18, width: 4 , height: 4))
        DotGrayLbl.backgroundColor = UIColor.gray
        DotGrayLbl.layer.masksToBounds = true
        DotGrayLbl.layer.cornerRadius = 2.0
        likeDislikeBaseView.addSubview(DotGrayLbl)
        
        dislikeButton = UIButton(frame: CGRect(x:likeDislikeBaseView.frame.size.width - 40   , y: 5, width:30 , height: 30))
        dislikeButton.setBackgroundImage(#imageLiteral(resourceName: "gray_dislike"), for: .normal)
        dislikeButton.setBackgroundImage(redDislikeImg, for: .selected)
        dislikeButton.addTarget(self, action:#selector(ReviewDisLikeBtnPressed(_:)), for: .touchUpInside)
        dislikeButton.isSelected =  false
        likeDislikeBaseView.addSubview(dislikeButton)
        
        reviewTxtView = UITextView(frame: CGRect(x: 10, y: likeDislikeBaseView.frame.size.height +  likeDislikeBaseView.frame.origin.y + 5  , width:reviewPopup.frame.size.width - 20, height: 175))
        reviewTxtView.delegate = self
        reviewTxtView.layer.masksToBounds = true
        reviewTxtView.layer.cornerRadius = 5.0
        reviewTxtView.placeholder = "Write Your Review..."
        reviewTxtView.font = UIFont.systemFont(ofSize: 14)
        reviewTxtView.tag = 2
        reviewPopup.addSubview(reviewTxtView)
        
        cancelButton = UIButton(frame: CGRect(x:0  , y: reviewTxtView.frame.size.height + reviewTxtView.frame.origin.y + 10, width:reviewPopup.frame.size.width/2 , height: 40))
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.tintColor = UIColor.gray
        cancelButton.titleLabel?.textColor = UIColor.gray
        cancelButton.addTarget(self, action:#selector(reviewCancelBtnPressed(_:)), for: .touchUpInside)
        reviewPopup.addSubview(cancelButton)
        
        submitButton = UIButton(frame: CGRect(x:cancelButton.frame.size.width   , y: reviewTxtView.frame.size.height + reviewTxtView.frame.origin.y + 10, width:reviewPopup.frame.size.width/2  , height: 40))
        //  submitButton.setBackgroundImage(#imageLiteral(resourceName: "gray_dislike"), for: .normal)
        submitButton.setTitle("Submit", for: .normal)
        submitButton.tintColor = UIColor.blue
        //  submitButton.titleLabel?.textColor = UIColor.gray
        submitButton.addTarget(self, action:#selector(reviewSubmitBtnPressed(_:)), for: .touchUpInside)
        reviewPopup.addSubview(submitButton)
        
        reviewPopup.isHidden = true
        
        
        
        
    }
  
    @objc func LeaveReviewBtn(sender:UIButton) {
 
        let InfoDict = userQuestInfo["coach_id"] as! NSDictionary
        let firstName =  InfoDict["fname"] as! String
        let lastName =  InfoDict["lname"] as! String
        reviewNameLbl.text = firstName + " " + lastName
        submitButton.tag = sender.tag
        reviewPopup.isHidden = false
      
        let popupConfig = STZPopupViewConfig()
        popupConfig.dismissTouchBackground = false
        popupConfig.cornerRadius = 10
        
        presentPopupView(reviewPopup, config: popupConfig)
        
      //  presentPopupView(reviewPopup)
        reviewTxtView.placeholder = "Write Your Review..."
        reviewTxtView.text = ""
        
        if let reviewInfo = userQuestInfo["review"] as? NSDictionary {
            checkEdit = true
            reviewId = reviewInfo["_id"] as? String ?? ""
            reviewTxtView.placeholder = ""
            reviewTxtView.text = reviewInfo["review"] as? String ?? ""
            if let isLike = reviewInfo["isLike"] as? NSNumber{
                if isLike == 1 {
                    likeBtn.isSelected = true
                    dislikeButton.isSelected = false
                }
                else{
                    likeBtn.isSelected = false
                    dislikeButton.isSelected = true
                }
            }
            
        }
        
    }
    
    @objc func reviewSubmitBtnPressed(_ sender: UIButton) {
        
        print("Leave Review Btn Pressed")
        
        if reviewTxtView.text == "" {
            notifyUser("", message: "Please Write something about Coach as Review." , vc: self)
        }else {
            
            
            
            
            let InfoDict = userQuestInfo["coach_id"] as! NSDictionary
            let coachId =  InfoDict["_id"] as! String
            let orderId =  userQuestInfo["_id"] as! String
            var islikeUnlike  = Int()
            if likeBtn.isSelected {
                islikeUnlike = 1
            }else {
                islikeUnlike = 2
            }
            
            
            if checkEdit {
                let request = ["review_id":reviewId, "isLike": islikeUnlike, "review":reviewTxtView.text] as [String : Any]
                add_EditReviewToCoach(request: request as NSDictionary, requestType: kEDIT_REVIEW)
                
            }
            else{
                let request = ["user_id":getUserId(), "coach_id": coachId,  "order_id":orderId, "isLike": islikeUnlike,"review":reviewTxtView.text] as [String : Any]
                add_EditReviewToCoach(request: request as NSDictionary, requestType: kADD_REVIEW)
            }
            
            
        }
        
        
    }
    func add_EditReviewToCoach(request:NSDictionary , requestType : String) {
        showProgressIndicator(refrenceView: self.view)
        
        WebServices().mainFunctiontoGetDetails(data: request as NSDictionary,serviceType:requestType) { (responseData)  in
            stopProgressIndicator()
            if responseData != nil
            {
                let code = responseData?["code"] as? NSNumber
                print("responseData",responseData ?? "")
                if code == 200{
                    stopProgressIndicator()
                    ///// update dict /////////
                    //                    if let reviewInfo = self.userOrderInfo["review"] as? NSDictionary {
                    //                        var dict = [String: Any]()
                    //                        dict["_id"] = self.reviewId
                    //                        dict["review"] = self.reviewTextView.text ?? ""
                    //                        dict["isLike"] = self.islikeUnlike
                    //                    }
                    ///////////////////////////
                    if let message = responseData?["result"] as? String {
                        let alert = UIAlertController(title: "Your Review submitted successfully.", message: message, preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                            //  self.navigationController?.popViewController(animated: true)
                        }))
                        self.present(alert, animated: true, completion: nil)
                        //notifyUser("", message: message , vc: self)
                    }
                    self.reviewTxtView.text = nil
                    self.checkEdit = false
                    DispatchQueue.main.async(execute: {
                        self.dismissPopupView()
                    })
                   // self.getUpdatedDetails()
                    
                    
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
    
    @objc func reviewCancelBtnPressed(_ sender: UIButton) {
        
        DispatchQueue.main.async(execute: {
            self.dismissPopupView()
        })
    }
    
    @objc func reviewLikeBtnPressed(_ sender: UIButton) {
        
        print("Leave Review Btn Pressed")
        if sender.isSelected {
            
            sender.isSelected =  true
            // dislikeButton.isSelected = true
            
            
        }else {
            sender.isSelected =  true
            dislikeButton.isSelected = false
            
        }
    }
    
    @objc func ReviewDisLikeBtnPressed(_ sender: UIButton) {
        
        print("Leave Review Btn Pressed")
        if sender.isSelected {
            sender.isSelected =  true
            //  likeBtn.isSelected = true
        }else {
            sender.isSelected =  true
            likeBtn.isSelected = false
        }
    }
    
    
    func textViewDidBeginEditing(_ textView: UITextView)
    {

//            if (textView.text == "Write Your message..."){
//                textView.text = ""
//                textView.textColor = .black
//            }

   //     textView.becomeFirstResponder() //Optional
    }
    func textViewDidEndEditing(_ textView: UITextView)
    {
//        if (textView.text == ""){
//
//                textView.text = "Write Your message..."
//            MsgTextView.textColor = UIColor.gray
//
//        }

       // textView.resignFirstResponder()
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool{
        let currentString: NSString = textView.text! as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: text) as NSString
        
        if textView.tag == 1 {
            if newString.length >= 1
            {
                MsgTextView.placeholder = ""
            }else {
                
            }
        }else if textView.tag ==  2 {
            if newString.length >= 1
            {
                reviewTxtView.placeholder = ""
            }else if newString.length ==  0  {
                reviewTxtView.placeholder = "Write Your Review..."
            }else {
                
            }
            if  newString.length >= 500{
                textView.resignFirstResponder()
                notifyUser("Alert", message: "Maximum 500 characters for review allowed.", vc: self)
                return false
            }
        }
       
     return true
    }
    
      @objc func MsgSendBtnPressed(_ sender: Any) {
    
        let internetCheck = isInternetAvailable()
        
        
        
        
        if internetCheck {
            
          
            if MsgTextView.text.characters.count > 0 {
                let requestDict = ["user_id": user_id,
                                   "coach_id":coach_id,
                                   "order_id":orderId,
                                   "type":type,
                                   "message":MsgTextView.text ?? ""] as [String : Any]
                MsgTextView.text = ""
                MsgTextView.placeholder = "Write Your message..."
                //
                //            if (MsgTextView.text == ""){
                //
                //                MsgTextView.text = "Write Your message..."
                //                MsgTextView.textColor = UIColor.gray
                //
                //            }
                sendUserMessage_to_coach(request: requestDict as NSDictionary)
            }else {
                
            }
        }else {
            notifyUser("", message: "No Internet Connection. Please Check" , vc: self)
        }
            
     
        
    }
   
    @objc func keyboardWillShow(_ notification:Notification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            
           
            UIView.animate(withDuration: 0.1, animations: {
                self.messageTblView.frame = CGRect(x:0, y: 80 , width: self.messageTblView.frame.size.width, height: self.view.frame.size.height  - (keyboardSize.height + 80 + 52 + 28))
                self.chatView.frame = CGRect(x: 10, y:self.view.frame.size.height - (keyboardSize.height + 52) , width: self.view.frame.size.width - 20, height: 52)
                  self.messageTblView.reloadData()
                self.setLastIndexPath()
            }, completion:{ _ in
                
            })
            
//            messageTblView.frame = CGRect(x: messageTblView.frame.origin.x, y: messageTblView.frame.origin.y , width: messageTblView.frame.size.width, height: messageTblView.frame.size.height - keyboardSize.height)
//            chatView.frame =  CGRect(x: chatView.frame.origin.x, y: messageTblView.frame.origin.y + messageTblView.frame.size.height + 28, width: chatView.frame.size.width, height: chatView.frame.size.height)
//          
         //   self.messageTblView.reloadData()
//setLastIndexPath()
            print(keyboardSize)
        }
        print("Not success")
        
    }
    
    
    @objc func keyboardWillHide(_ notification:Notification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            
            UIView.animate(withDuration: 0.1, animations: {
                self.messageTblView.frame = CGRect(x: self.messageTblView.frame.origin.x, y: 80, width: self.messageTblView.frame.size.width, height: self.view.frame.size.height - (80 + 52 + 28) )
                self.chatView.frame =  CGRect(x: 10, y:self.view.frame.size.height - 52 , width: self.view.frame.size.width - 20, height: 52 )
                  self.messageTblView.reloadData()
                self.setLastIndexPath()
            
            }, completion:{ _ in
                
            })
            
            
            
//            messageTblView.frame = CGRect(x: messageTblView.frame.origin.x, y: messageTblView.frame.origin.y, width: messageTblView.frame.size.width, height: self.view.frame.size.height - (messageTblView.frame.origin.y + 80) )
//            chatView.frame =  CGRect(x: chatView.frame.origin.x, y: messageTblView.frame.origin.y + messageTblView.frame.size.height + 28, width: chatView.frame.size.width, height: chatView.frame.size.height )
//
           
        }
        
        print("Not success")
    }
  
    func setLastIndexPath() {
        let indexPath = IndexPath(row: self.messageListArray.count , section: 0) as? IndexPath
        self.messageTblView?.scrollToRow(at: indexPath!, at: UITableViewScrollPosition.bottom, animated: false)
        
    }
    @objc  func cameraImgBtnPressed(_ sender: Any) {
        
        
        var ActionTitle = ""
        if isCoach() {
            ActionTitle = "Choose Image Or Video"
        }else {
          ActionTitle = "Choose Image"
        }
        
        let actionSheetController = UIAlertController(title:ActionTitle , message:nil , preferredStyle: .actionSheet)
        
        // actionSheetController.view.tintColor = UIColor.headerBlue
        
        let galleryButton = UIAlertAction(title: "Gallery", style: .default) { action -> Void in
            self.openGallary()
        }
        let cameraButton = UIAlertAction(title: "Capture A Image", style: .default) { action -> Void in
            self.openCameraWithImageCaputure()
        }
        
        
        let cancelActionButton = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
            
        }
        picker.delegate = self
        cancelActionButton.setValue(UIColor.red, forKey: "titleTextColor")
        actionSheetController.addAction(galleryButton)
        actionSheetController.addAction(cameraButton)
        if isCoach() {
            let videoActionButton = UIAlertAction(title: "Record response video", style: .default) { action -> Void in
                self.openCameraWithVideorecord()
            }
            actionSheetController.addAction(videoActionButton)
        }
        
        actionSheetController.addAction(cancelActionButton)
        self.present(actionSheetController, animated: true, completion: nil)
        
        /*****************   action sheet for video upload   **********/
    }
    
    func openCameraWithVideorecord(){
        
        if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)){
            picker.sourceType = UIImagePickerControllerSourceType.camera
            //   picker.mediaTypes =  [kUTTypeImage as String]
            //      picker.mediaTypes =  [kUTTypeVideo as String]
            
            picker.mediaTypes = [kUTTypeMovie as String]
            //      picker.mediaTypes = [kUTTypeVideo as String]
            picker.delegate = self
            picker.videoMaximumDuration = 180.0
            picker.allowsEditing = false
            picker.cameraCaptureMode = .video
            picker.modalPresentationStyle = .fullScreen
            self .present(picker, animated: true, completion: nil)
        }else{
            notifyUser("", message: "Your device doesn't support camera", vc: self)
        }
    }
    
    
    func openCameraWithImageCaputure(){
        
        
        if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)){
            picker.sourceType = UIImagePickerControllerSourceType.camera
            picker.mediaTypes =  [kUTTypeImage as String]
            
            picker.delegate = self
            picker.videoMaximumDuration = 180.0
            picker.allowsEditing = false
            picker.modalPresentationStyle = .fullScreen
            self .present(picker, animated: true, completion: nil)
        }else{
            notifyUser("", message: "Your device doesn't support camera", vc: self)
        }
    }
    
    func openGallary(){
        picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        
        self.present(picker, animated: true, completion: nil)
    }
    
    //MARK:UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]){
        
        picker .dismiss(animated: true, completion: nil)
        let mediaType = info[UIImagePickerControllerMediaType] as! NSString
        
        if mediaType.isEqual(to: kUTTypeImage as String) {
            
            // Media is an image
            print("Capture Image")
            var image = info[UIImagePickerControllerOriginalImage] as? UIImage //userProfileImage.image
             let imageData1 = UIImageJPEGRepresentation(image!, 0.5)
            let imageSize1: Int = imageData1!.count
             print("size of befor upload compress in KB: %f ", Double(imageSize1) / 1024.0)
            image = image?.resizeWithWidth(width: 200)!
            let fileManager = FileManager.default
            let str = "\(String(describing: image)).jpeg"
            let path = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("\(String(describing: image)).jpeg")
            let imageData = UIImageJPEGRepresentation(image!, 0.5)
            let imageSize: Int = imageData!.count
            print("size of after compress image in KB: %f ", Double(imageSize) / 1024.0)
            fileManager.createFile(atPath: path as String, contents: imageData, attributes: nil)
            let fileUrl = URL(fileURLWithPath: path)
            
            
            
            showProgressIndicator(refrenceView: self.view)
            WebServices().uploadImageonServer(imageURL: fileUrl){ (responseData)  in
                stopProgressIndicator()
                if responseData != nil{
                    let uploadUrl = responseData!
                    let requestDict = ["user_id": self.user_id,
                                       "coach_id":self.coach_id,
                                       "order_id":self.orderId,
                                       "type":self.type,
                                       "image":uploadUrl] as [String : Any]
                    self.sendUserMessage_to_coach(request: requestDict as NSDictionary)
                    print("responseData",responseData ?? "")
                }
                else{ stopProgressIndicator()}
            }
            
        } else if mediaType.isEqual(to: kUTTypeMovie as String) {
            
            // Media is a video
            print("record a video")
            //     let videoURL = info[UIImagePickerControllerMediaURL] as! URL
            
            showProgressIndicator(refrenceView: self.view)
            
            let videoURL = info[UIImagePickerControllerMediaURL] as! NSURL
            print(videoURL)
            var thumbnialImg = self.createThumbnailOfVideoFromFileURL(videoURL: videoURL.absoluteString!) as! UIImage
            
            thumbnialImg = thumbnialImg.resizeWithWidth(width: 200)!
            let fileManager = FileManager.default
            let str = "\(String(describing: thumbnialImg)).jpeg"
            let path1 = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("\(String(describing: thumbnialImg)).jpeg")
            let imageData = UIImageJPEGRepresentation(thumbnialImg, 0.5)
            let imageSize: Int = imageData!.count
            print("size of image in KB: %f ", Double(imageSize) / 1024.0)
            fileManager.createFile(atPath: path1 as String, contents: imageData, attributes: nil)
            let fileUrl = URL(fileURLWithPath: path1)
            
            PreviewUrl = fileUrl as NSURL
            
            uploadIntroDuctionVideoToAmazon(url: videoURL as URL)
            
            
            
        }
        
        
    }
    
    func uploadIntroDuctionVideoToAmazon(url : URL)  {
        
        //   showProgressIndicator(refrenceView: self.view)
        //  appDelegateRef.showTitleIndicator()
        guard let data = NSData(contentsOf: url as URL) else {
            return
        }
        
        print("File size before compression: \(Double(data.length / 1024)) kb")
        let compressedURL = NSURL.fileURL(withPath: NSTemporaryDirectory() + NSUUID().uuidString + ".m4v")
        compressVideo(inputURL: url , outputURL: compressedURL) { (exportSession) in
            guard let session = exportSession else {
                return
            }
            
            switch session.status {
            case .unknown:
                break
            case .waiting:
                break
            case .exporting:
                break
            case .completed:
                guard let compressedData = NSData(contentsOf: compressedURL) else {
                    return
                }
                print("File size after compression: \(Double(compressedData.length / 1024)) kb")
                self.uploadVideo(url: compressedURL)
                
                
            case .failed:
                break
            case .cancelled:
                break
            }
        }
        
        
    }
    func uploadVideo(url : URL) {
        
        
        let videoURL = url as NSURL
        print(videoURL)
        let videoData = NSData(contentsOf: videoURL as URL)
        let path = try! FileManager.default.url(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask, appropriateFor: nil, create: false)
        let newPath = path.appendingPathComponent("/videoFileName.mp4")
        do {
            try videoData?.write(to: newPath)
        } catch {
            print(error)
        }
        
        //        }
        
 
        
        WebServices().uploadVideoonServer(imageURL: newPath){ (responseData)  in
            //   stopProgressIndicator()
            if responseData != nil{
                let uploadUrl = responseData!
                
                
                
                WebServices().uploadImageonServer(imageURL: self.PreviewUrl as URL){ (responseData)  in
                    //      stopProgressIndicator()
                    if responseData != nil{
                        let uploadUrlImage = responseData!
                        let requestDict = ["user_id": self.user_id,
                                           "coach_id":self.coach_id,
                                           "order_id":self.orderId,
                                           "type":self.type,
                                           "video":uploadUrl,
                                           "video_thumb":uploadUrlImage] as [String : Any]
                        
                        self.sendUserMessage_to_coach(request: requestDict as NSDictionary)
                        print("responseData",responseData ?? "")
                    }
                    else{ stopProgressIndicator()}
                }
                
            }
            else{ stopProgressIndicator()}
        }
    }
    
    func compressVideo(inputURL: URL, outputURL: URL, handler:@escaping (_ exportSession: AVAssetExportSession?)-> Void) {
        let urlAsset = AVURLAsset(url: inputURL, options: nil)
        guard let exportSession = AVAssetExportSession(asset: urlAsset, presetName: AVAssetExportPresetMediumQuality) else {
            handler(nil)
            
            return
        }
        
        exportSession.outputURL = outputURL
        exportSession.outputFileType = AVFileType.mov
        exportSession.shouldOptimizeForNetworkUse = true
        exportSession.exportAsynchronously { () -> Void in
            handler(exportSession)
        }
    }
    
    func createThumbnailOfVideoFromFileURL(videoURL: String) -> UIImage? {
        
        let asset = AVAsset(url: URL(string: videoURL)!)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        var time1: CMTime = CMTimeMakeWithSeconds(0.0, 600)
        time1.value = 0 as? CMTimeValue ?? CMTimeValue()
        var error: Error? = nil
        var actualTime = CMTime()
        //   var imageRef = (try? imageGenerator.copyCGImage(at: time1, actualTime: nil)) as? CGImage
        do {
            var imageRef =  try imageGenerator.copyCGImage(at: time1, actualTime: nil)
            // var thumbnail = UIImage(cgImage: imageRef as? CGImage ?? CGImage())
            let thumbnail = UIImage(cgImage: imageRef)
            return thumbnail
        } catch {
            print(error.localizedDescription)
            print(error.localizedDescription)
            return UIImage(named: "user_icon")
        }
        
        
    }
    @objc func clickOnPlayVideoButton(sender:UIButton) {
        
        let tagValue =  sender.tag
        let messageDict = messageListArray[tagValue] as? NSDictionary
        print("Url Fetched")
        let videoUrl  = messageDict!["video"] as? String
        print(videoUrl)
        let imageUrl = URL(string:videoUrl! )
        
        let player = AVPlayer(url: imageUrl!)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        self.present(playerViewController, animated: true)
        {
            playerViewController.player!.play()
        }
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController){
        print("picker cancel.")
        picker .dismiss(animated: true, completion: nil)
    }
    
    @objc func uploadImage_Video(_ notification: NSNotification){
        
        if let dict = notification.userInfo as NSDictionary? {
            if let id = dict["image"] as? UIImage{
                // do something with your image
                let image = id.resizeWithWidth(width: 200)!
                let fileManager = FileManager.default
                let path = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("\(String(describing: image)).jpeg")
                let imageData = UIImageJPEGRepresentation(image, 0.5)
                let imageSize: Int = imageData!.count
                print("size of image in KB: %f ", Double(imageSize) / 1024.0)
                fileManager.createFile(atPath: path as String, contents: imageData, attributes: nil)
                let fileUrl = URL(fileURLWithPath: path)
                
                showProgressIndicator(refrenceView: self.view)
                WebServices().uploadImageonServer(imageURL: fileUrl){ (responseData)  in
                    stopProgressIndicator()
                    if responseData != nil{
                        let uploadUrl = responseData!
                        let requestDict = ["user_id": self.user_id,
                                           "coach_id":self.coach_id,
                                           "order_id":self.orderId,
                                           "type":self.type,
                                           "image":uploadUrl] as [String : Any]
                        self.sendUserMessage_to_coach(request: requestDict as NSDictionary)
                        print("responseData",responseData ?? "")
                    }
                    else{ stopProgressIndicator()}
                }
            }
        }
        
        
    }
    
    @objc func InfoBtnPressed(_ sender: Any) {
        if isCoach() {
           
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "CoachRequestUserProfileVC") as! CoachRequestUserProfileVC
            vc.userOrderInfo = userQuestInfo
            self.navigationController?.pushViewController(vc,animated: true)
           
        }else{
            
            if CompleteType == 2 {
                if interval > closedChatDays {
                    
                    let InfoDict = userQuestInfo["coach_id"] as! NSDictionary
                    let firstName =  InfoDict["fname"] as! String
                    let lastName =  InfoDict["lname"] as! String
                    reviewNameLbl.text = firstName + " " + lastName
                    reviewPopup.isHidden = false
                    
                    
                  
             //       presentPopupView(reviewPopup)
                    
                    let popupConfig = STZPopupViewConfig()
                    popupConfig.dismissTouchBackground = false
                    popupConfig.cornerRadius = 10
                    
                    presentPopupView(reviewPopup, config: popupConfig)
                    
                    reviewTxtView.placeholder = "Write Your Review..."
                    reviewTxtView.text = ""
                    
                    if let reviewInfo = userQuestInfo["review"] as? NSDictionary {
                        checkEdit = true
                        reviewId = reviewInfo["_id"] as? String ?? ""
                        reviewTxtView.placeholder = ""
                        reviewTxtView.text = reviewInfo["review"] as? String ?? ""
                        if let isLike = reviewInfo["isLike"] as? NSNumber{
                            if isLike == 1 {
                                likeBtn.isSelected = true
                                dislikeButton.isSelected = false
                            }
                            else{
                                likeBtn.isSelected = false
                                dislikeButton.isSelected = true
                            }
                        }
                        
                    }
                    
                }else {
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "SessionInfoVC") as! SessionInfoVC
                    vc.userOrderInfo = userQuestInfo
                    self.navigationController?.pushViewController(vc,animated: true)
                }
                
            }else {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "SessionInfoVC") as! SessionInfoVC
                vc.userOrderInfo = userQuestInfo
                self.navigationController?.pushViewController(vc,animated: true)
            }
            
         
          
        }
    }
    
    @objc func backBtnPressed(_ sender: Any) {
        IQKeyboardManager.sharedManager().enable = true
         self.navigationController?.popViewController(animated: true)
       
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}

extension MessageController : UITableViewDataSource {
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  self.messageListArray.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            
            if isCoach() {
                let cell: UserQuestionsChatCell! =  tableView.dequeueReusableCell(withIdentifier: "UserQuestionsChatCell") as? UserQuestionsChatCell
                cell.selectionStyle = .none
                cell.setupDetailsonView(detailsDict:userQuestInfo)
                return cell
            }else {
                
                //                let cell: UserQuestionsChatCell! =  tableView.dequeueReusableCell(withIdentifier: "UserQuestionsChatCell") as? UserQuestionsChatCell
                //                cell.selectionStyle = .none
                //                cell.setupDetailsonView(detailsDict:userQuestInfo)
                //                return cell
                
                let cell: UserQuestionSenderCell! =  tableView.dequeueReusableCell(withIdentifier: "UserQuestionSenderCell") as? UserQuestionSenderCell
                cell.selectionStyle = .none
                cell.chatBgGrayCorner.backgroundColor = UIColor.clear
                cell.receiver_messageView.backgroundColor = hexStringToUIColor(hex: "#e5e5e5")
                cell.setupDetailsonView(detailsDict:userQuestInfo)
                return cell
            }
            
            
        }else {
            
         
             let messgDict  = messageListArray.object(at: indexPath.row -  1 ) as! NSDictionary
            
            if (messgDict["video"] as? String) != nil{
                let cell: VideoChatCellTableViewCell! =  tableView.dequeueReusableCell(withIdentifier: "VideoChatCellTableViewCell") 
                    as? VideoChatCellTableViewCell
                
                let DateStr = messgDict["createOn"] as! String
                let date =  convertStringintoDate(dateStr: DateStr)
                let dateStr = date.getElapsedInterval()
                
                let ProfileImg = UIImage(named: "user_image")
                let senderImg = UIImage(named: "chat_bg_gray_corner")
                let recieverImg = UIImage(named: "chat_bg_corner")
                
               cell.frame =   CGRect(x: 0, y: 0, width:self.view.frame.size.width, height: 250)
                cell.contentView.frame =  CGRect(x: 0, y: 0, width:self.view.frame.size.width, height: 250)
               cell.baseView.frame =  CGRect(x: 0, y: 10, width:cell.frame.size.width, height: cell.frame.size.height - 20)
               
               
                
                cell.RecieverProfileImgView.frame =  CGRect(x:10, y:  cell.frame.size.height - 20 - 30 - 10  , width: 30 , height:30)
                cell.RecieverProfileImgView.layer.masksToBounds = true
                cell.RecieverProfileImgView.layer.cornerRadius = 15.0
                cell.RecieverProfileImgView.image = ProfileImg
            
                cell.RecieverCoenerImgView.frame = CGRect(x:cell.RecieverProfileImgView.frame.size.width + cell.RecieverProfileImgView.frame.origin.x, y: cell.frame.size.height - 20 - 20  - 10, width: 30 , height:15)
                cell.RecieverCoenerImgView.image = recieverImg
              
                 cell.RecieverBaseView.frame =  CGRect(x:cell.RecieverCoenerImgView.frame.size.width + cell.RecieverCoenerImgView.frame.origin.x - 17, y: 0, width:cell.frame.size.height  - 20 - 10, height: cell.frame.size.height  - 20 )
                
                cell.RecieverThumbnailImgView.frame =  CGRect(x:10, y: 10, width:cell.frame.size.height - 30 - 20   , height:cell.frame.size.height - 20  - 30)
                
               cell.RecieverCenterPlayButton.frame = CGRect(x:(cell.RecieverThumbnailImgView.frame.size.width - 40 )/2, y:  (cell.RecieverThumbnailImgView.frame.size.height - 40 )/2, width: 40 , height:40)
                
                cell.recieverDateLbl.frame =  CGRect(x:cell.RecieverThumbnailImgView.frame.origin.x + 10, y: cell.RecieverThumbnailImgView.frame.origin.y + cell.RecieverThumbnailImgView.frame.size.height + 3, width: 150 , height:17)
                cell.recieverDateLbl.textAlignment = .left
                
                cell.recieverDateLbl.text = dateStr
                cell.recieverDateLbl.font = UIFont.systemFont(ofSize: 12)
                cell.recieverDateLbl.textColor = UIColor.gray
                
             
                cell.SenderBaseView.frame =  CGRect(x: cell.frame.size.width - (cell.frame.size.height  - 20 + 30 + 20), y: 0, width:cell.frame.size.height - 10  - 20 , height: cell.frame.size.height - 20 )
               
                cell.SenderThumbnailImgView.frame = CGRect(x:10, y: 10, width:cell.frame.size.height - 20  - 30  , height:cell.frame.size.height - 20  - 30)
                 cell.senderCenterPlayButton.frame = CGRect(x:(cell.SenderThumbnailImgView.frame.size.width - 40 )/2, y:  (cell.SenderThumbnailImgView.frame.size.height - 40 )/2, width: 40 , height:40)
            
                cell.SenderCoenerImgView.frame = CGRect(x:cell.SenderBaseView.frame.size.width + cell.SenderBaseView.frame.origin.x - 17, y:cell.frame.size.height - 20  - 20 - 10 , width: 30 , height:15)
                cell.SenderCoenerImgView.image = senderImg
                cell.SenderProfileImgView.frame =  CGRect(x:cell.SenderCoenerImgView.frame.size.width + cell.SenderCoenerImgView.frame.origin.x , y:cell.frame.size.height - 20  - 30 - 10 , width: 30 , height:30)
                cell.SenderProfileImgView.layer.masksToBounds = true
                cell.SenderProfileImgView.layer.cornerRadius = 15.0
                cell.SenderProfileImgView.image = ProfileImg
                
                cell.senderDateLbl.frame =  CGRect(x:cell.SenderBaseView.frame.size.width - 150  , y: cell.SenderThumbnailImgView.frame.origin.y + cell.SenderThumbnailImgView.frame.size.height + 3, width: 150 , height:17)
                cell.senderDateLbl.textAlignment = .right
                
          
                cell.senderDateLbl.text = dateStr
                cell.senderDateLbl.font = UIFont.systemFont(ofSize: 12)
                cell.senderDateLbl.textColor = UIColor.gray
                
               
                
                let videoThumbUrl  = messgDict["video_thumb"] as? String
                let imageUrl = URL(string:videoThumbUrl! )
                cell.RecieverThumbnailImgView.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "VideoDefaultImage"), options:.refreshCached)
                cell?.RecieverCenterPlayButton.addTarget(self, action: #selector(ChatVC.clickOnPlayVideoButton(sender:)), for: .touchUpInside)
                cell.RecieverCenterPlayButton.tag = indexPath.row - 1
                cell.SenderThumbnailImgView.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "VideoDefaultImage"), options:.refreshCached)
                cell?.senderCenterPlayButton.addTarget(self, action: #selector(ChatVC.clickOnPlayVideoButton(sender:)), for: .touchUpInside)
                cell.senderCenterPlayButton.tag = indexPath.row - 1
                cell.senderCenterPlayButton.isHidden = false
                cell.RecieverCenterPlayButton.isHidden = false

//
                cell.SenderBaseView.backgroundColor = hexStringToUIColor(hex: "#e5e5e5")
                cell.senderDateLbl.backgroundColor = hexStringToUIColor(hex: "#e5e5e5")

                cell.RecieverBaseView.backgroundColor = hexStringToUIColor(hex: "#73d4ff")
                cell.recieverDateLbl.backgroundColor = hexStringToUIColor(hex: "#73d4ff")
                
              
                let coachDict = messgDict["coach_id"] as! NSDictionary
                let UserDict = messgDict["user_id"] as! NSDictionary
                let coachProfileStr = coachDict["profile_pic"] as! String
                let UserProfileStr = UserDict["profile_pic"] as! String
                let coachId = coachDict["_id"] as! String
                let UserId = UserDict["_id"] as! String
                let senderType = messgDict["type"] as! Int
                let UserIdLogin = getUserId() as String
                var  senderId = "'"
                if senderType == 1 {
                    senderId =  coachId
                }else if senderType == 2 {
                    senderId =  UserId
                }
                
                let profilePicUrl = getProfilePic()
                
                let imageUrl1 = URL(string:profilePicUrl )
                
                if UserIdLogin == senderId {
                    cell.SenderBaseView.isHidden = false
                    cell.SenderCoenerImgView.isHidden = false
                    cell.SenderProfileImgView.isHidden = false
                    cell.RecieverBaseView.isHidden = true
                    cell.RecieverProfileImgView.isHidden = true
                    cell.RecieverCoenerImgView.isHidden = true
                   
                    
                    cell.SenderProfileImgView.sd_setImage(with: imageUrl1, placeholderImage: UIImage(named: "defult_pic"), options:.refreshCached)
                    
                }else {
                    cell.SenderBaseView.isHidden = true
                    cell.SenderCoenerImgView.isHidden = true
                    cell.SenderProfileImgView.isHidden = true
                    cell.RecieverBaseView.isHidden = false
                    cell.RecieverProfileImgView.isHidden = false
                    cell.RecieverCoenerImgView.isHidden = false
                    
                    if isCoach() {
                        let imageUrl = URL(string:UserProfileStr )
                        cell.RecieverProfileImgView.sd_setImage(with: imageUrl1, placeholderImage: UIImage(named: "defult_pic"), options:.refreshCached)
                    }else {
                        let imageUrl = URL(string:coachProfileStr )
                        cell.RecieverProfileImgView.sd_setImage(with: imageUrl1, placeholderImage: UIImage(named: "defult_pic"), options:.refreshCached)
                    }
                }
//                                cell.RecieverBaseView.backgroundColor = UIColor.green
//                                cell.SenderBaseView.backgroundColor = UIColor.green
//                                cell.RecieverBaseView.isHidden = false
//                                cell.RecieverProfileImgView.isHidden = false
//                                cell.RecieverCoenerImgView.isHidden = false
//                                cell.SenderBaseView.isHidden = true
//                                cell.SenderCoenerImgView.isHidden = true
//                                cell.SenderProfileImgView.isHidden = true
                
                return cell
            }else   if messgDict["image"] != nil  {
//                let cell: ChatImageCell! =  tableView.dequeueReusableCell(withIdentifier: "ChatImageCell") as? ChatImageCell
//                cell.msgTxtView.isEditable = false
//                 let type = messgDict["type"] as! Int
//                cell.senderMsgTextView.isEditable = false
//                if let dict = messageListArray[indexPath.row-1] as? NSDictionary {
//                    if isCoach() {
//                        if type == 1 {
//
//                            cell.showSenderDetailsonView(detailsDict:dict)
//
//                        }
//                        else{
//                            cell.setupDetailsonView(detailsDict:dict)
//                        }
//                    }
//                    else{
//                        if type == 2 {
//                            cell.showSenderDetailsonView(detailsDict:dict)
//
//                        }
//                        else{
//                            cell.setupDetailsonView(detailsDict:dict)
//                        }
//                    }
//                }
//                cell.selectionStyle = .none
//                return cell
                
                
                let cell: VideoChatCellTableViewCell! =  tableView.dequeueReusableCell(withIdentifier: "VideoChatCellTableViewCell")
                    as? VideoChatCellTableViewCell
                
                let DateStr = messgDict["createOn"] as! String
                let date =  convertStringintoDate(dateStr: DateStr)
                let dateStr = date.getElapsedInterval()
                
                let ProfileImg = UIImage(named: "user_image")
                let senderImg = UIImage(named: "chat_bg_gray_corner")
                let recieverImg = UIImage(named: "chat_bg_corner")
                
                cell.frame =   CGRect(x: 0, y: 0, width:self.view.frame.size.width, height: 250)
                cell.contentView.frame =  CGRect(x: 0, y: 0, width:self.view.frame.size.width, height: 250)
                cell.baseView.frame =  CGRect(x: 0, y: 10, width:cell.frame.size.width, height: cell.frame.size.height -  20)
                
                
                
                cell.RecieverProfileImgView.frame =  CGRect(x:10, y:  cell.frame.size.height - 20  - 30 - 10  , width: 30 , height:30)
                cell.RecieverProfileImgView.layer.masksToBounds = true
                cell.RecieverProfileImgView.layer.cornerRadius = 15.0
                cell.RecieverProfileImgView.image = ProfileImg
                
                cell.RecieverCoenerImgView.frame = CGRect(x:cell.RecieverProfileImgView.frame.size.width + cell.RecieverProfileImgView.frame.origin.x, y: cell.frame.size.height - 20   - 20  - 10, width: 30 , height:15)
                cell.RecieverCoenerImgView.image = recieverImg
                
                cell.RecieverBaseView.frame =  CGRect(x:cell.RecieverCoenerImgView.frame.size.width + cell.RecieverCoenerImgView.frame.origin.x - 17, y: 0, width:cell.frame.size.height - 20  - 10, height: cell.frame.size.height - 20 )
                
                cell.RecieverThumbnailImgView.frame =  CGRect(x:10, y: 10, width:cell.frame.size.height - 20  - 30  , height:cell.frame.size.height - 20  - 30)
                
                cell.RecieverCenterPlayButton.frame = CGRect(x:(cell.RecieverThumbnailImgView.frame.size.width - 40 )/2, y:  (cell.RecieverThumbnailImgView.frame.size.height - 40 )/2, width: 40 , height:40)
                
                cell.recieverDateLbl.frame =  CGRect(x:cell.RecieverThumbnailImgView.frame.origin.x + 10, y: cell.RecieverThumbnailImgView.frame.origin.y + cell.RecieverThumbnailImgView.frame.size.height + 3, width: 150 , height:17)
                cell.recieverDateLbl.textAlignment = .left
                
                cell.recieverDateLbl.text = dateStr
                cell.recieverDateLbl.font = UIFont.systemFont(ofSize: 12)
                cell.recieverDateLbl.textColor = UIColor.gray
                
                
                cell.SenderBaseView.frame =  CGRect(x: cell.frame.size.width - (cell.frame.size.height + 30 + 20  - 20 ), y: 0, width:cell.frame.size.height - 10 - 20 , height: cell.frame.size.height - 20 )
                
                cell.SenderThumbnailImgView.frame = CGRect(x:10, y: 10, width:cell.frame.size.height  - 20 - 30  , height:cell.frame.size.height - 20  - 30)
                cell.senderCenterPlayButton.frame = CGRect(x:(cell.SenderThumbnailImgView.frame.size.width - 40 )/2, y:  (cell.SenderThumbnailImgView.frame.size.height - 40 )/2, width: 40 , height:40)
                
                cell.SenderCoenerImgView.frame = CGRect(x:cell.SenderBaseView.frame.size.width + cell.SenderBaseView.frame.origin.x - 17, y:cell.frame.size.height - 20  - 20 - 10 , width: 30 , height:15)
                cell.SenderCoenerImgView.image = senderImg
                cell.SenderProfileImgView.frame =  CGRect(x:cell.SenderCoenerImgView.frame.size.width + cell.SenderCoenerImgView.frame.origin.x , y:cell.frame.size.height - 20  - 30 - 10 , width: 30 , height:30)
                cell.SenderProfileImgView.layer.masksToBounds = true
                cell.SenderProfileImgView.layer.cornerRadius = 15.0
                cell.SenderProfileImgView.image = ProfileImg
                
                cell.senderDateLbl.frame =  CGRect(x:cell.SenderBaseView.frame.size.width - 150  , y: cell.SenderThumbnailImgView.frame.origin.y + cell.SenderThumbnailImgView.frame.size.height + 3, width: 150 , height:17)
                cell.senderDateLbl.textAlignment = .right
                
                
                cell.senderDateLbl.text = dateStr
                cell.senderDateLbl.font = UIFont.systemFont(ofSize: 12)
                cell.senderDateLbl.textColor = UIColor.gray
                
                
                let imageStr =  messgDict["image"] as? String
                let imageUrl = URL(string:imageStr! )
                cell.RecieverThumbnailImgView.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "VideoDefaultImage"), options:.refreshCached)
            //    cell?.RecieverCenterPlayButton.addTarget(self, action: #selector(ChatVC.clickOnPlayVideoButton(sender:)), for: .touchUpInside)
       //         cell.RecieverCenterPlayButton.tag = indexPath.row - 1
                cell.senderCenterPlayButton.isHidden = true
                cell.RecieverCenterPlayButton.isHidden = true
                cell.SenderThumbnailImgView.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "VideoDefaultImage"), options:.refreshCached)
      //          cell?.senderCenterPlayButton.addTarget(self, action: #selector(ChatVC.clickOnPlayVideoButton(sender:)), for: .touchUpInside)
        //        cell.senderCenterPlayButton.tag = indexPath.row - 1
                
                
                //
                cell.SenderBaseView.backgroundColor = hexStringToUIColor(hex: "#e5e5e5")
                cell.senderDateLbl.backgroundColor = hexStringToUIColor(hex: "#e5e5e5")
                
                cell.RecieverBaseView.backgroundColor = hexStringToUIColor(hex: "#73d4ff")
                cell.recieverDateLbl.backgroundColor = hexStringToUIColor(hex: "#73d4ff")
                
                
                let coachDict = messgDict["coach_id"] as! NSDictionary
                let UserDict = messgDict["user_id"] as! NSDictionary
                let coachProfileStr = coachDict["profile_pic"] as! String
                let UserProfileStr = UserDict["profile_pic"] as! String
                let coachId = coachDict["_id"] as! String
                let UserId = UserDict["_id"] as! String
                let senderType = messgDict["type"] as! Int
                let UserIdLogin = getUserId() as String
                var  senderId = "'"
                if senderType == 1 {
                    senderId =  coachId
                }else if senderType == 2 {
                    senderId =  UserId
                }
                
                let profilePicUrl = getProfilePic()
                
                let imageUrl1 = URL(string:profilePicUrl )
                
                if UserIdLogin == senderId {
                    cell.SenderBaseView.isHidden = false
                    cell.SenderCoenerImgView.isHidden = false
                    cell.SenderProfileImgView.isHidden = false
                    cell.RecieverBaseView.isHidden = true
                    cell.RecieverProfileImgView.isHidden = true
                    cell.RecieverCoenerImgView.isHidden = true
                    
                    
                    cell.SenderProfileImgView.sd_setImage(with: imageUrl1, placeholderImage: UIImage(named: "defult_pic"), options:.refreshCached)
                    
                }else {
                    cell.SenderBaseView.isHidden = true
                    cell.SenderCoenerImgView.isHidden = true
                    cell.SenderProfileImgView.isHidden = true
                    cell.RecieverBaseView.isHidden = false
                    cell.RecieverProfileImgView.isHidden = false
                    cell.RecieverCoenerImgView.isHidden = false
                    
                    if isCoach() {
                        let imageUrl = URL(string:UserProfileStr )
                        cell.RecieverProfileImgView.sd_setImage(with: imageUrl1, placeholderImage: UIImage(named: "defult_pic"), options:.refreshCached)
                    }else {
                        let imageUrl = URL(string:coachProfileStr )
                        cell.RecieverProfileImgView.sd_setImage(with: imageUrl1, placeholderImage: UIImage(named: "defult_pic"), options:.refreshCached)
                    }
                }
                //                                cell.RecieverBaseView.backgroundColor = UIColor.green
                //                                cell.SenderBaseView.backgroundColor = UIColor.green
                //                                cell.RecieverBaseView.isHidden = false
                //                                cell.RecieverProfileImgView.isHidden = false
                //                                cell.RecieverCoenerImgView.isHidden = false
                //                                cell.SenderBaseView.isHidden = true
                //                                cell.SenderCoenerImgView.isHidden = true
                //                                cell.SenderProfileImgView.isHidden = true
               
                return cell
                
                
            }  else {
                let cell: TextMsgCellTableViewCell! =  tableView.dequeueReusableCell(withIdentifier: "TextMsgCellTableViewCell") as? TextMsgCellTableViewCell
                
                let ProfileImg = UIImage(named: "user_image")
                let senderImg = UIImage(named: "chat_bg_gray_corner")
                let recieverImg = UIImage(named: "chat_bg_corner")
                
                
                //            let messagearray = messageListArray.object(at: indexPath.row -  1 ) as! NSArray
                //            print(messagearray)
                
                print(messgDict)
                let MessageTxt = messgDict["message"] as! String
                print(MessageTxt)
                let DateStr = messgDict["createOn"] as! String
                let date =  convertStringintoDate(dateStr: DateStr)
                let dateStr = date.getElapsedInterval()
                
                
                cell.SenderTxtView.text =  MessageTxt
                let fixedWidth = self.view.frame.size.width - 80
                cell.SenderTxtView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
                let newSize = cell.SenderTxtView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
                var newFrame = cell.SenderTxtView.frame
                newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
                var txtFldWidth = newSize.width
                
                var txtFldHeight  = newSize.height
                
                if txtFldHeight < 30 {
                    txtFldHeight = 30
                }
                
                if txtFldWidth < 100 {
                    txtFldWidth = 100
                }
                
                
                cell.frame = CGRect(x:0, y: 0, width: self.view.frame.size.width, height:txtFldHeight + 19)
                cell.contentView.frame = CGRect(x:0, y: 0, width: self.view.frame.size.width, height:txtFldHeight + 19)
                cell.BaseView.frame =  CGRect(x:0, y: 0, width: cell.frame.size.width , height:txtFldHeight + 19)
                
                
                cell.selectionStyle = .none
                
                print(txtFldWidth,txtFldHeight)
                
                /********* sender View **************/
                
                cell.SenderBaseView.frame = CGRect(x:0, y: 0, width: cell.BaseView.frame.size.width  , height:txtFldHeight + 19)
                
                
                cell.SenderMsgBaseView.frame = CGRect(x:20, y: 10, width: cell.frame.size.width - 30 , height:txtFldHeight)
                cell.SenderTxtView.frame = CGRect(x:cell.SenderMsgBaseView.frame.size.width - txtFldWidth  - 18 - 30, y: 0, width: txtFldWidth , height:txtFldHeight)
                cell.SenderCoenerImgView.frame = CGRect(x:cell.SenderTxtView.frame.size.width + cell.SenderTxtView.frame.origin.x - 18, y: txtFldHeight - 20, width: 30 , height:15)
                cell.SenderCoenerImgView.image = senderImg
                cell.SenderProfileImgView.frame =  CGRect(x:cell.SenderCoenerImgView.frame.size.width + cell.SenderCoenerImgView.frame.origin.x , y: txtFldHeight - 30, width: 30 , height:30)
                cell.SenderProfileImgView.layer.masksToBounds = true
                cell.SenderProfileImgView.layer.cornerRadius = 15.0
                cell.SenderProfileImgView.image = ProfileImg
                
                cell.senderDateLbl.frame =  CGRect(x:cell.SenderMsgBaseView.frame.size.width - txtFldWidth  - 18 - 10 , y: cell.SenderTxtView.frame.origin.y + cell.SenderTxtView.frame.size.height + 3, width: txtFldWidth , height:17)
                cell.senderDateLbl.textAlignment = .right
                
                let str = String(format:"%@  ", dateStr)
                cell.senderDateLbl.text = str
                cell.senderDateLbl.font = UIFont.systemFont(ofSize: 12)
                cell.senderDateLbl.textColor = UIColor.gray
                
                
                /********* sender View **************/
                
                /********* reciever View **************/
                cell.RecieverBaseView.frame = CGRect(x:0, y: 0, width: cell.BaseView.frame.size.width  , height:txtFldHeight + 19)
                
                cell.RecieverProfileImgView.frame =  CGRect(x:0, y: txtFldHeight - 30, width: 30 , height:30)
                cell.RecieverProfileImgView.layer.masksToBounds = true
                cell.RecieverProfileImgView.layer.cornerRadius = 15.0
                cell.RecieverProfileImgView.image = ProfileImg
                cell.RecieverCoenerImgView.frame = CGRect(x:cell.RecieverProfileImgView.frame.size.width + cell.frame.origin.x, y: txtFldHeight - 20, width: 30 , height:15)
                
                cell.RecieverTxtView.frame = CGRect(x:cell.RecieverCoenerImgView.frame.size.width + cell.RecieverCoenerImgView.frame.origin.x - 18, y: 0, width: txtFldWidth , height:txtFldHeight)
                cell.RecieverCoenerImgView.image = recieverImg
                cell.RecieverMsgBaseView.frame = CGRect(x:10, y: 10, width: cell.frame.size.width - 30 , height:txtFldHeight)
                
                cell.recieverDateLbl.frame =  CGRect(x:cell.RecieverTxtView.frame.origin.x + 10, y: cell.RecieverTxtView.frame.origin.y + cell.RecieverTxtView.frame.size.height + 3, width: txtFldWidth , height:17)
                cell.recieverDateLbl.textAlignment = .left
                let str1 = String(format:"  %@", dateStr)
                cell.recieverDateLbl.text = str1
                cell.recieverDateLbl.font = UIFont.systemFont(ofSize: 12)
                cell.recieverDateLbl.textColor = UIColor.gray
                
                
                /********* reciever View **************/
                
                cell.SenderTxtView.layer.masksToBounds = true
                cell.SenderTxtView.layer.cornerRadius = 5.0
                cell.senderDateLbl.layer.masksToBounds = true
                cell.senderDateLbl.layer.cornerRadius = 5.0
                cell.RecieverTxtView.layer.masksToBounds = true
                cell.RecieverTxtView.layer.cornerRadius = 5.0
                cell.recieverDateLbl.layer.masksToBounds = true
                cell.recieverDateLbl.layer.cornerRadius = 5.0
                
                cell.backgroundColor = UIColor.white
                cell.BaseView.backgroundColor = UIColor.white
                
                cell.SenderMsgBaseView.backgroundColor = UIColor.white
                cell.SenderProfileImgView.backgroundColor = UIColor.white
                cell.RecieverProfileImgView.backgroundColor = UIColor.white
                cell.RecieverCoenerImgView.backgroundColor =  UIColor.white
                
                cell.RecieverMsgBaseView.backgroundColor = UIColor.white
                cell.SenderBaseView.backgroundColor = UIColor.white
                cell.RecieverBaseView.backgroundColor = UIColor.white
                cell.SenderTxtView.backgroundColor = hexStringToUIColor(hex: "#e5e5e5")
                cell.senderDateLbl.backgroundColor = hexStringToUIColor(hex: "#e5e5e5")
                
                cell.RecieverTxtView.backgroundColor = hexStringToUIColor(hex: "#73d4ff")
                cell.recieverDateLbl.backgroundColor = hexStringToUIColor(hex: "#73d4ff")
                cell.RecieverBaseView.isHidden = true
                
                
                let coachDict = messgDict["coach_id"] as! NSDictionary
                let UserDict = messgDict["user_id"] as! NSDictionary
                let coachProfileStr = coachDict["profile_pic"] as! String
                let UserProfileStr = UserDict["profile_pic"] as! String
                let coachId = coachDict["_id"] as! String
                let UserId = UserDict["_id"] as! String
                let senderType = messgDict["type"] as! Int
                let UserIdLogin = getUserId() as String
                var  senderId = "'"
                if senderType == 1 {
                    senderId =  coachId
                }else if senderType == 2 {
                    senderId =  UserId
                }
                
                let profilePicUrl = getProfilePic()
                
                let imageUrl = URL(string:profilePicUrl )
                
                if UserIdLogin == senderId {
                    cell.SenderBaseView.isHidden = false
                    cell.RecieverBaseView.isHidden = true
                    cell.SenderTxtView.text =  MessageTxt
                    
                    cell.SenderProfileImgView.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "defult_pic"), options:.refreshCached)
                    
                }else {
                    cell.SenderBaseView.isHidden = true
                    cell.RecieverBaseView.isHidden = false
                    cell.RecieverTxtView.text =  MessageTxt
                    if isCoach() {
                        let imageUrl = URL(string:UserProfileStr )
                        cell.RecieverProfileImgView.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "defult_pic"), options:.refreshCached)
                    }else {
                        let imageUrl = URL(string:coachProfileStr )
                        cell.RecieverProfileImgView.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "defult_pic"), options:.refreshCached)
                    }
                }
                
                
                
                //            let senderType = messgDict["type"] as! Int
                //            let senderStr = String(senderType)
                //            if senderType == type {
                //                cell.SenderBaseView.isHidden = false
                //                cell.RecieverBaseView.isHidden = true
                //                cell.SenderTxtView.text =  MessageTxt
                //            } else {
                //                cell.SenderBaseView.isHidden = true
                //                cell.RecieverBaseView.isHidden = false
                //                cell.RecieverTxtView.text =  MessageTxt
                //            }
                //
                
                
                
                return cell
                //     return UITableViewCell()
                //  }
            }
            
        
        }
        
    }
    
}

extension MessageController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0{
            return UITableViewAutomaticDimension
        }
        else{
            
            
            if let messageDict = messageListArray[indexPath.row-1] as? NSDictionary {
                if messageDict["image"] != nil  {
                    return 250
                }else if messageDict["video"] != nil  {
                    return 250
                }else if messageDict["message"] != nil{
                    
                    var textView = UITextView()
                    
                    
                    //    let messagearray = messageListArray.object(at: indexPath.row - 1 ) as! NSArray
                    let messgDict  = messageListArray.object(at: indexPath.row - 1 ) as! NSDictionary
                    let MessageTxt = messgDict["message"] as! String
                    textView.text =  MessageTxt
                    let fixedWidth = self.view.frame.size.width - 80
                    textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
                    let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
                    var newFrame = textView.frame
                    newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
                    var txtFldWidth = newSize.width
                    var txtFldHeight  = newSize.height
                    
                    if txtFldHeight < 30 {
                        txtFldHeight = 39
                    }
                    return txtFldHeight + 19
                    //    return UITableViewAutomaticDimension
                }
            }
            
        }
        return UITableViewAutomaticDimension
    }
    
}


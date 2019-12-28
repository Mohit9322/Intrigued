//
//  TextChatVC.swift
//  Intrigued
//
//  Created by Shineweb-solutions on 06/02/18.
//  Copyright © 2018 daniel helled. All rights reserved.
//

import UIKit
import SocketIO
import MagicalRecord
import Foundation
import IQKeyboardManagerSwift
import MobileCoreServices
import MediaPlayer
import AVFoundation
import AVKit
import STZPopupView


class TextChatVC: UIViewController, UITextViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate {

   var headerBaseView: UIView!
   var chatNamelbl: UILabel!
   var typingLbl: UILabel!
   var backBtn: UIButton!
   var infoBtn: UIButton!
  
    @IBOutlet weak var chatTblView: UITableView!
    var chatView: UIView!
   var cameraImgBtn: UIButton!
   var MsgTextView: UITextView!
   var MsgSendBtn: UIButton!
   var replyIcon: UIImageView!
    var PreviewUrl = NSURL()
    
    var manager = SocketManager(socketURL: URL(string: "http://13.228.52.104:3002/")!, config:[.log(true), .compress])
    var   socket : SocketIOClient?
    var getMsgListDict = NSDictionary()
    var coach_id = ""
    var room_Id = ""
    var user_id = ""
    var clientMsgId = ""
    var orderId = ""
    var completeTime = ""
    var type : Int = 0
    var SocketConnection : Int = 0
    var recieverId = ""
    var messageListArray = NSArray()
    var chatMessages = NSMutableArray()
    var userQuestInfo = NSDictionary()
    let refreshControl = UIRefreshControl()
    var pageIndex = Int()
    var pageSize = Int()
     var picker = UIImagePickerController()
    var durationOfChat : Int = 0
    
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
    
    
    var count = 0
    var countDownLabel: UILabel!
    var timer = Timer()
    var ChargePerUnit = ""
    var UserBalance = ""
    
      var CheckTimer : Int = 0
    
      var maximumDurationChatInSec = 0
     var DurationChatAfterAletInSec = 60
    
    
     var AddPaymentPopup = UIView()
     var cancelAddPaymentBtn = UIButton()
     var OkAddPaymentBtn = UIButton()
     var AddPaymentLbl  =  UILabel()
    
    var PaymentTblView: UITableView!
    var manageTblView : Int = 0
    
    var paymentTableIndexSelectedValue : Int = 0
    
    var liveChatUpdateOrderDuration = ""
    var liveChatUpdateTotalPrice  = ""
    var  LiveChatUpdateChatEndTime = ""
    
      var serveiceTaxLiveChat = ""
      var closeChatLiveChat = ""
    
    
     var BackDurationOfChat : Int = 0
    //  var clientMsgId = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        serveiceTaxLiveChat = userQuestInfo["service_tax"] as! String
        closeChatLiveChat =  userQuestInfo["close_chat"] as! String
        
        print(serveiceTaxLiveChat,closeChatLiveChat )
        
  //   infoBtn.addTarget(self, action:#selector(tableViewRefresh(_:)), for: .touchUpInside)
        refreshControl.addTarget(self, action: #selector(tableViewRefresh(_:)), for: .valueChanged)
        chatTblView.refreshControl = refreshControl
        chatTblView.addSubview(refreshControl)
        
         IQKeyboardManager.sharedManager().enable = false
        self.CreateView()
        setDoneOnKeyboard()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    
        SocketConnection = 1
         self.chatTblView.register(UINib(nibName: "TextMsgCellTableViewCell", bundle: nil), forCellReuseIdentifier: "TextMsgCellTableViewCell")
   //     IQKeyboardManager.sharedManager().enable = false
        print(userQuestInfo)
         var msgManagedObjectContext : NSManagedObjectContext?
        msgManagedObjectContext = NSManagedObjectContext()
          var message : ManageMessage?
        message = ManageMessage.mr_createEntity()
       

       let UUIDValue = UIDevice.current.identifierForVendor!.uuidString
        var queryDic = [AnyHashable: Any]()
        queryDic["id"] = getUserId() as String
       queryDic["deviceToken"] = UserDeviceToken
   //     queryDic["deviceToken"] = "74fa04984114ca830f5e5b2f6ffe398dc25595ec5322cd8177b636b7450177ce"
        queryDic["deviceId"] = UUIDValue
        queryDic["deviceType"] = "I"
 
        clientMsgId = UUIDValue
        print(UUIDValue)
        /************ Temp Value *************/
//        let UUIDValue = UIDevice.current.identifierForVendor!.uuidString
//        print(UUIDValue)
//        print(UserDeviceToken)
//        var queryDic = [AnyHashable: Any]()
//        queryDic["id"] = "5a82d8758de9ef02a022bbf4"
//        queryDic["deviceToken"] = "74fa04984114ca830f5e5b2f6ffe398dc25595ec5322cd8177b636b7450177ce"
//       queryDic["deviceId"] = "98701244-5D51-454B-AEBD-08C724FEACB7"
//        queryDic["deviceType"] = "I"
     /*********** Temp Value ************/
        
        print(queryDic)
        orderId = userQuestInfo["_id"] as? String ?? ""
        let CoachDict = userQuestInfo["coach_id"] as! NSDictionary
        if isCoach() {
            let userDict = userQuestInfo["user_id"] as! NSDictionary
            user_id = userDict["_id"] as! String
        }
        else {
            user_id = getUserId()
        }
        coach_id = CoachDict["_id"] as! String
       
        
        print(orderId, coach_id, user_id)
        
        print(getUserId() as String)
        
        if isCoach() {
            recieverId = user_id as! String
            type = 2
             queryDic["type"] = 2
        }else{
            recieverId = coach_id as! String
             type = 1
             queryDic["type"] = 1
        }
 
        print(queryDic)
        
//        queryDic["type"] = "2"
        
        
        var arrayFromDataBase = getChatHistoryFromDataBaseWithRoom(order_Id: orderId) as! NSArray
//
//        print(room_Id)
//        pageSize = 1
//        pageIndex = 0
        
        
        print(userQuestInfo)
        
       
        room_Id  = userQuestInfo["room_id"] as! String
        print(room_Id)
        pageSize = 10
        pageIndex = 0
        
  
        
        if arrayFromDataBase.count == 0 {

            getMsgListDict = ["user_id":getUserId() as String,"room_id":room_Id,"pageIndex": 0,"pageSize":pageSize, "type":type] as NSDictionary
            getChatMessage(request: getMsgListDict)

        }else if arrayFromDataBase.count > 0 {


            for item  in arrayFromDataBase {

                let manageMsg = item as! ManageMessage

                let clientMsgId = manageMsg.value(forKey: "message_ClintId")! as! String
                let message =     manageMsg.value(forKey: "message_Text")! as! String
                 let videoUrl =     manageMsg.value(forKey: "videoUrl")! as! String
                 let videoThumbUrl =     manageMsg.value(forKey: "videoThumbImgUrl")! as! String
                 let messageVideoType  =     manageMsg.value(forKey: "message_type")! as! Int
                let orderId = manageMsg.value(forKey: "msgOrder_Id")! as! String
                let time = manageMsg.value(forKey: "message_Time")! as! String
                let type = manageMsg.value(forKey: "msg_Type")! as! Int


                let MsgId = manageMsg.value(forKey: "message_Id")! as! String
                let room =  manageMsg.value(forKey: "message_RoomId")! as! String


                var UserDict =  NSDictionary()
                let profileImg = manageMsg.value(forKey: "sender_profileImg")! as! String
                let userID = manageMsg.value(forKey: "message_SenderId")! as! String
                UserDict = ["profileImg":profileImg,"user_id":userID,] as NSDictionary


                let InfoDIct = ["client_msg_id":clientMsgId,"message":message,"message_id": MsgId,"order_id":orderId,"room": room,"time": time,"type": type,"userinfo": UserDict,"video_url":videoUrl,"video_thumb": videoThumbUrl,"message_type" : messageVideoType] as NSDictionary


                var msgArray = NSMutableArray()
                msgArray.insert(InfoDIct, at: 0)

                self.chatMessages.add(msgArray)

            }




            self.chatTblView.reloadData()
        }
       
        

        
        print(queryDic)
        
         manager = SocketManager(socketURL: URL(string: "http://13.228.52.104:3002/")!, config:["connectParams": queryDic])
        socket = manager.defaultSocket
        socket = manager.socket(forNamespace: "/advisor")
        socket?.on(clientEvent: .connect) {data, ack in
            print("socket connected")
            print("ravi-->socket connected \(data) \(ack)")
            print("socket connected")

        }
         socket?.connect()
        
       
  chatTblView.register(UINib(nibName: "VideoChatCellTableViewCell", bundle: nil), forCellReuseIdentifier: "VideoChatCellTableViewCell")
       
       
        chatTblView.delegate = self
        chatTblView.dataSource = self
        MsgTextView.delegate = self
        MsgTextView.placeholder = "Write Your message..."
        self.chatTblView.contentInset = UIEdgeInsetsMake(0, 0, 100, 0);
        chatView.layer.cornerRadius = chatView.frame.size.height / 2
        chatView.clipsToBounds = true
        chatView.layer.borderColor = UIColor.lightGray.cgColor
        chatView.layer.borderWidth = 1.0
        chatTblView.estimatedRowHeight = 30
        chatTblView.rowHeight = UITableViewAutomaticDimension
        print(userQuestInfo)
        
        if isCoach() {
        //    type = "1"
            if let userInfo = userQuestInfo["user_id"] as? NSDictionary {
                let userName = (userInfo["fname"] as? String ?? "")  + " " + (userInfo["lname"] as? String ?? "")
                chatNamelbl.text = userName
                user_id = userInfo["_id"] as? String ?? ""
            }
        }
        else{
        //    type = "2"
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
    
    
         addHandlers()
        
       
   
        
       
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        // Do any additional setup after loading the view.
    }
    
    func getChatMessage(request:NSDictionary) {
        
        showProgressIndicator(refrenceView: self.view)
        print(request)
        print(getSessionId())
        WebServices().mainFunctiontoGetDetails(data: request as NSDictionary,serviceType:kCHAT_MESSAGES) { (responseData)  in
            stopProgressIndicator()
            if responseData != nil
            {
                let code = responseData?["code"] as? NSNumber
                print("responseData",responseData ?? "")
                if code == 200{
                    //      stopProgressIndicator()
                    
                    if self.pageIndex == 0 {
                       
                         self.chatMessages.removeAllObjects()
                        
                    }
                    
                    if let messageListArray = responseData?["result"] as? NSArray {
                        
                        for item in messageListArray {
                            
                            let dict = item as! NSDictionary
                            
                            
                            let clientMsgId = dict["client_msg_id"] as! String
                            let message = dict["message"] as! String
                            
                            let orderId = dict["order_id"] as! String
                            let time = dict["created_at"] as! String
                            let type = dict["type"] as! Int
                            
                            let chatDict = dict["chat_id"] as! NSDictionary
                            let MsgId = chatDict["_id"] as! String
                            let room = chatDict["room"] as! String
                            
                            
                            var UserDict =  NSDictionary()
                            if  let userInfo = dict["user_id"] as? NSDictionary {
                                let profileImg = userInfo["profile_pic"] as! String
                                let userID = userInfo["_id"] as! String
                                UserDict = ["profileImg":profileImg,"user_id":userID,] as NSDictionary
                            } else {
                                let profileImg = getProfilePic() as String
                                let userID = getUserId() as String
                                UserDict = ["profileImg":profileImg,"user_id":userID,] as NSDictionary
                            }
                            
                            let videoUrl =     dict["video_url"] as! String
                            let videoThumbUrl =      dict["video_thumb"] as! String
                            let messageVideoType  =     dict["message_type"] as! Int
                            
                            let InfoDIct = ["client_msg_id":clientMsgId,"message":message,"message_id": MsgId,"order_id":orderId,"room": room,"time": time,"type": type,"userinfo": UserDict,"video_url":videoUrl,"video_thumb": videoThumbUrl,"message_type" : messageVideoType] as NSDictionary
                            
                            
                            var msgArray = NSMutableArray()
                            msgArray.insert(InfoDIct, at: 0)
                            
                        //    self.chatMessages.add(msgArray)
                        //    self.chatMessages += msgArray
                            
                          //  self.chatMessages.insert(msgArray, atIndex:0)
                            self.chatMessages.insert(msgArray, at: 0)
                            
                        //    self.chatMessages = msgArray + self.chatMessages
                            
                        }
                        
                    }
                    stopProgressIndicator()
                    if self.chatMessages.count > 0 {
                          self.pageIndex = self.pageIndex + 1
                        let InfoArray = self.chatMessages.object(at: 0) as! NSArray
                        let InfoDict = InfoArray.object(at: 0) as! NSDictionary
                        self.room_Id = InfoDict["room"] as! String
                    }
                    
                    self.chatTblView.reloadData()
                    
                    if self.pageIndex == 0 {
                        
                        self.setLastIndexPath()
                       //  self.pageIndex = self.pageIndex + 1
                    }else {
                        let indexPath = IndexPath(row: 0 , section: 0) as? IndexPath
                        self.chatTblView?.scrollToRow(at: indexPath!, at: UITableViewScrollPosition.bottom, animated: false)
                    }
                    
                   
                } else  if code == 100 {
                    if let message = responseData?["result"] as? String {
                        
                        if message == "No Chat found!" {
                            
                            if self.pageIndex == 0 {
                                self.pageIndex = 0
                            }else {
                                self.pageIndex = self.pageIndex - 1
                            }
                            
                        }
                    }
                     stopProgressIndicator()
                }else {
                    if let message = responseData?["result"] as? String {
                        stopProgressIndicator()
                        //      notifyUser("", message: message , vc: self)
                    }
                    else{
                        // notifyUser("", message: "Something went wrong", vc: self)
                    }
                }
            }
            else{ stopProgressIndicator()}
            
        }
    }
    func setLastIndexPath() {
        let indexPath = IndexPath(row: self.chatMessages.count , section: 0) as? IndexPath
        self.chatTblView?.scrollToRow(at: indexPath!, at: UITableViewScrollPosition.bottom, animated: false)
        
    }
    
    @objc func tableViewRefresh(_ sender: Any) {
     
     
      
       
     
        
        getMsgListDict = ["user_id":getUserId() as String,"room_id":room_Id,"pageIndex": pageIndex,"pageSize":pageSize, "type":type] as NSDictionary
        getChatMessage(request: getMsgListDict)
        
        self.refreshControl.endRefreshing()
    }
    func getChatHistoryFromDataBaseWithRoom(order_Id : String) -> NSArray {
        
        var msgManagedObjectContext : NSManagedObjectContext?
        msgManagedObjectContext       = NSManagedObjectContext.mr_contextForCurrentThread()
        let entityDescription         = NSEntityDescription.entity(forEntityName: "ManageMessage",in:msgManagedObjectContext!)
        let request = NSFetchRequest<NSFetchRequestResult>.init(entityName: "ManageMessage")
        //message_RoomId like %@
        
        
        let predicateFormat           = "msgOrder_Id = %@"
        let predicate                 = NSPredicate(format: predicateFormat,order_Id)
        request.predicate             = predicate
        request.entity                = entityDescription
        var chatArray:NSArray?
        
        do {
            chatArray = try msgManagedObjectContext?.fetch(request) as NSArray?
            
        }
        catch let jsonError as NSError { print(jsonError)
        }
        print(chatArray?.count)
        print(chatArray)
        
        return chatArray!
        
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
        

        
        backBtn = UIButton(frame: CGRect(x:5 , y: 45, width:60 , height: 20))
   //     backBtn.setBackgroundImage(backBtnImg, for: .normal)
        backBtn.setImage(backBtnImg, for: .normal)
      //  backBtn.setTitle("< Back", for: .normal)
        backBtn.titleLabel?.textAlignment = .left
        backBtn.addTarget(self, action:#selector(backBtnPressed(_:)), for: .touchUpInside)
        headerBaseView.addSubview(backBtn)
        
        countDownLabel = UILabel(frame: CGRect(x:backBtn.frame.size.width + backBtn.frame.origin.x , y: 28, width: 100, height: 30))
        countDownLabel.textColor = UIColor.white
        countDownLabel.text = "00:00"
        countDownLabel.textAlignment = .center
        //  countDownLabel.isHidden = true
        countDownLabel.font = UIFont.systemFont(ofSize: 16)
        countDownLabel.isHidden = true
        headerBaseView.addSubview(countDownLabel)
        
        chatNamelbl = UILabel(frame: CGRect(x:(self.view.frame.size.width - 180 )/2  , y: 45, width: 180 , height: 20))
        chatNamelbl.textColor = UIColor.white
        chatNamelbl.textAlignment = .center
        chatNamelbl.backgroundColor = UIColor.clear
        headerBaseView.addSubview(chatNamelbl)
        
        typingLbl = UILabel(frame: CGRect(x:(self.view.frame.size.width - 180 )/2  , y: chatNamelbl.frame.size.height + chatNamelbl.frame.origin.y, width: 180 , height: 20))
        typingLbl.textColor = UIColor.green
        typingLbl.textAlignment = .center
        typingLbl.text = "typing..."
        typingLbl.isHidden = true
        typingLbl.backgroundColor = UIColor.clear
        headerBaseView.addSubview(typingLbl)
        
       
        
        
        infoBtn = UIButton(frame: CGRect(x:self.view.frame.size.width - 50  , y: 34, width:40 , height: 40))
        // infoBtn.setBackgroundImage(infoBtnImg, for: .normal)
        infoBtn.setImage(infoBtnImg, for: .normal)
        infoBtn.addTarget(self, action:#selector(InfoBtnPressed(_:)), for: .touchUpInside)
        headerBaseView.addSubview(infoBtn)
        
    
        chatTblView.frame =  CGRect(x:0 , y:headerBaseView.frame.origin.y + headerBaseView.frame.size.height , width:self.view.frame.size.width , height: self.view.frame.height - (headerBaseView.frame.origin.y + headerBaseView.frame.size.height + 52))
        chatTblView.delegate = self
        chatTblView.dataSource = self
        chatTblView.tag = 1
        self.view.addSubview(chatTblView)
        
        
        chatView = UIView(frame: CGRect(x: 10, y: chatTblView.frame.origin.y + chatTblView.frame.size.height + 1  , width:self.view.frame.size.width - 20, height: 50))
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
      
        
        if isCoach() {
            cameraImgBtn.isHidden = false
        }else {
             cameraImgBtn.frame = CGRect(x:2 , y: 0, width:50 , height: 50)
            cameraImgBtn.isHidden = true
            MsgTextView.frame =  CGRect(x: 10, y: 2  , width:chatView.frame.size.width - 60 - 10, height: chatView.frame.size.height - 4)
            MsgSendBtn.frame =  CGRect(x:chatView.frame.size.width - 52 , y: 0, width:50 , height: 50)
        }
        
        print(self.view.frame.origin.y)
        print(self.view.frame.size.height)
        print(headerBaseView.frame.origin.y)
        print(headerBaseView.frame.size.height)
        print(chatTblView.frame.origin.y)
        print(chatTblView.frame.size.height)
        print(chatView.frame.origin.y)
        print(chatView.frame.size.height)
        
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        //dateFormatter.timeZone = TimeZone(abbreviation: "GMT+0:00") //Current time zone
        dateFormatter.locale = NSLocale.init(localeIdentifier: "en_US_POSIX") as Locale!
        dateFormatter.timeZone = NSTimeZone(name: "GMT")! as TimeZone
        let Currentdate = Date()
        let dateString = dateFormatter.string(from: Currentdate)
        print(dateString)
        
        print(completeTime)
     //   completeTime = "2018-03-07T10:39:05.055Z"
        
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
            chatTblView.frame =  CGRect(x:0 , y:headerBaseView.frame.origin.y + headerBaseView.frame.size.height , width:self.view.frame.size.width , height: self.view.frame.height - (headerBaseView.frame.origin.y + headerBaseView.frame.size.height ))
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
              self.createChoosePaymentSlotPopup()
            ChargePerUnit = userQuestInfo["amount"] as! String
            UserBalance = getUserBalance()
            var ChargeValue : Double?
            var balanceValue : Double?
            ChargeValue = Double(ChargePerUnit)
            balanceValue = Double(UserBalance)
            var duration = userQuestInfo["duration"] as! String
       //     duration = "11"
            durationOfChat = Int(duration)!
        //   durationOfChat = 0
            
            durationOfChat = 60 * durationOfChat
            var chatEndTime = userQuestInfo["chat_end_time"] as! String
            var ChatEndValeInSec = Int(chatEndTime)
            
            var DiffBwChat = Int(durationOfChat - ChatEndValeInSec!)
        //    DiffBwChat = 60
         
            if DiffBwChat == 0 {
                AddPaymentPopup.isHidden = false
                let popupConfig = STZPopupViewConfig()
                popupConfig.dismissTouchBackground = false
                popupConfig.cornerRadius = 10
                
                presentPopupView(AddPaymentPopup, config: popupConfig)
            }else if 0  < DiffBwChat  && DiffBwChat < 61 {
                print("Continue")
                
              
                maximumDurationChatInSec = DiffBwChat
                DurationChatAfterAletInSec = 0
                
            }else {
                if durationOfChat > ChatEndValeInSec! {
                    print("Continue")
                    
                    maximumDurationChatInSec = durationOfChat  - ChatEndValeInSec!
               //    maximumDurationChatInSec = 65
                    
                }else {
                    print("Not continue")
                    
                    AddPaymentPopup.isHidden = false
                    let popupConfig = STZPopupViewConfig()
                    popupConfig.dismissTouchBackground = false
                    popupConfig.cornerRadius = 10
                    
                    presentPopupView(AddPaymentPopup, config: popupConfig)
                    
                    //
                    //                self.MsgTextView.isUserInteractionEnabled = false
                    //                self.cameraImgBtn.isUserInteractionEnabled = false
                    //                // self.replyIcon.isUserInteractionEnabled = false
                    //                self.MsgSendBtn.isUserInteractionEnabled = false
                    //                self.chatView.isHidden = true
                    //                chatTblView.frame =  CGRect(x:0 , y:headerBaseView.frame.origin.y + headerBaseView.frame.size.height , width:self.view.frame.size.width , height: self.view.frame.height - (headerBaseView.frame.origin.y + headerBaseView.frame.size.height ))
                    //
                    //                let alert = UIAlertController(title: "Alert", message: "Not Sufficient Balance", preferredStyle: UIAlertControllerStyle.alert)
                    //                alert.addAction(UIAlertAction(title: "Add Payment", style: .default, handler: { action in
                    //
                    //
                    //
                    //
                    //                    print("Add Amount In your account")
                    //                    print("Push to add balance screen and hit or save count value in live dtatabase")
                    //              /********** To enable chat Again after adding balance in user account ******/
                    ////                    self.MsgTextView.isUserInteractionEnabled = true
                    ////                    self.cameraImgBtn.isUserInteractionEnabled = true
                    ////                    // self.replyIcon.isUserInteractionEnabled = false
                    ////                    self.MsgSendBtn.isUserInteractionEnabled = true
                    ////                    self.chatView.isHidden = false
                    ////
                    ////                    self.chatTblView.frame =  CGRect(x:0 , y:self.self.headerBaseView.frame.origin.y + self.headerBaseView.frame.size.height , width:self.view.frame.size.width , height: self.view.frame.height - (self.headerBaseView.frame.origin.y + self.headerBaseView.frame.size.height + 52))
                    ////                    self.chatView.frame =  CGRect(x: 10, y: self.chatTblView.frame.origin.y + self.chatTblView.frame.size.height + 1  , width:self.view.frame.size.width - 20, height: 50)
                    //
                    //                 /********** To enable chat Again after adding balance in user account ******/
                    //
                    //                }))
                    //
                    //                alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { action in
                    //
                    //
                    //                }))
                    //                self.present(alert, animated: true, completion: nil)
                }
            }
            
        }
     
      
     let orderStatus =    userQuestInfo["order_status"] as! Int
        if orderStatus == 3 {
         
            self.countDownLabel.isHidden = true
            self.chatNamelbl.frame =        CGRect(x:0 , y:self.headerBaseView.frame.origin.y + self.headerBaseView.frame.size.height , width:self.view.frame.size.width , height: self.view.frame.height - (self.headerBaseView.frame.origin.y + self.headerBaseView.frame.size.height + 52))
            self.MsgTextView.resignFirstResponder()
            self.MsgTextView.isUserInteractionEnabled = false
            self.cameraImgBtn.isUserInteractionEnabled = false
            // self.replyIcon.isUserInteractionEnabled = false
            self.MsgSendBtn.isUserInteractionEnabled = false
            self.chatView.isHidden = true
            self.timer.invalidate()
            self.chatTblView.frame =  CGRect(x:0 , y:self.headerBaseView.frame.origin.y + self.headerBaseView.frame.size.height , width:self.view.frame.size.width , height: self.view.frame.height - (self.headerBaseView.frame.origin.y + self.headerBaseView.frame.size.height ))
        }
        
    }
    
    
     @objc func updateForNextThirtySec() {
        
        
      
        
        if(DurationChatAfterAletInSec > 0){
            let minutes = Int(count) / 60
            let seconds = Int(count) % 60
            
            var countStr =  String(format:"%02i:%02i", minutes, seconds)
            print(countStr)
            countDownLabel.text = countStr
            count = count + 1
            DurationChatAfterAletInSec = DurationChatAfterAletInSec - 1
        }else {
            DurationChatAfterAletInSec = 0
            timer.invalidate()
              self.chatNamelbl.frame =        CGRect(x:0 , y:self.headerBaseView.frame.origin.y + self.headerBaseView.frame.size.height , width:self.view.frame.size.width , height: self.view.frame.height - (self.headerBaseView.frame.origin.y + self.headerBaseView.frame.size.height + 52))
            countDownLabel.isHidden = true
            print("save chat duration")
            print(count)
            self.MsgTextView.resignFirstResponder()
             let alert = UIAlertController(title: "Alert", message: "Please Add Amount to continue chat with coach", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                
                self.MsgTextView.isUserInteractionEnabled = false
                self.cameraImgBtn.isUserInteractionEnabled = false
                // self.replyIcon.isUserInteractionEnabled = false
                self.MsgSendBtn.isUserInteractionEnabled = false
                self.chatView.isHidden = true
                self.chatTblView.frame =  CGRect(x:0 , y:self.headerBaseView.frame.origin.y + self.headerBaseView.frame.size.height , width:self.view.frame.size.width , height: self.view.frame.height - (self.headerBaseView.frame.origin.y + self.headerBaseView.frame.size.height ))
                
                
            }))
            self.present(alert, animated: true, completion: nil)
            
        }
       
        
    }
    
    @objc func update() {
     
        let ThirtySecBeforeAlertMAnage = maximumDurationChatInSec - DurationChatAfterAletInSec
        
        if ThirtySecBeforeAlertMAnage  <= count {
              timer.invalidate()
             self.MsgTextView.resignFirstResponder()
           
         
           
            AddPaymentPopup.isHidden = false
          //  presentPopupView(AddPaymentPopup)
            
            let popupConfig = STZPopupViewConfig()
            popupConfig.dismissTouchBackground = false
            popupConfig.cornerRadius = 10
            
            presentPopupView(AddPaymentPopup, config: popupConfig)
            
//             let alert = UIAlertController(title: "Alert", message: "Please Add Amount to continue chat with coach", preferredStyle: UIAlertControllerStyle.alert)
//            alert.addAction(UIAlertAction(title: "Okk", style: .default, handler: { action in
//                print("Add Amount In your account")
//                print("Push to add balance screen and hit or save count value in live dtatabase")
//              self.MsgTextView.resignFirstResponder()
//                self.MsgTextView.isUserInteractionEnabled = false
//                self.cameraImgBtn.isUserInteractionEnabled = false
//                // self.replyIcon.isUserInteractionEnabled = false
//                self.MsgSendBtn.isUserInteractionEnabled = false
//                self.chatView.isHidden = true
//                self.chatTblView.frame =  CGRect(x:0 , y:self.headerBaseView.frame.origin.y + self.headerBaseView.frame.size.height , width:self.view.frame.size.width , height: self.view.frame.height - (self.headerBaseView.frame.origin.y + self.headerBaseView.frame.size.height ))
//
//            }))
//            alert.addAction(UIAlertAction(title: "Continue", style: .default, handler: { action in
//
//                self.MsgTextView.becomeFirstResponder()
//                self.countDownLabel.isHidden = false
//                self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateForNextThirtySec), userInfo: nil, repeats: true)
//
//
//            }))
//            self.present(alert, animated: true, completion: nil)
        }else if maximumDurationChatInSec <= count {
            
        }else {
            let minutes = Int(count) / 60
            let seconds = Int(count) % 60
            
            var countStr =  String(format:"%02i:%02i", minutes, seconds)
            print(countStr)
            countDownLabel.text = countStr
            count = count + 1
        }
        
       
        
        
        
//        if(count > 0){
//
//            let minutes = Int(count) / 60
//            let seconds = Int(count) % 60
//
//            var countStr =  String(format:"%02i:%02i", minutes, seconds)
//            print(countStr)
//            countDownLabel.text = countStr
//            count = count + 1
//
//        }else {
//            timer.invalidate()
////            count = TempCount
//             countDownLabel.text = "00:00"
//            CheckTimer = 0
//        }
//
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
    
        PaymentTblView =  UITableView(frame:CGRect(x: 0, y: AddPaymentLbl.frame.size.height + AddPaymentLbl.frame.origin.y + 5, width:AddPaymentPopup.frame.size.width , height: AddPaymentPopup.frame.size.height - 50 - 35  ))
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
        
        OkAddPaymentBtn = UIButton(frame: CGRect(x:cancelButton.frame.size.width   , y: PaymentTblView.frame.size.height + PaymentTblView.frame.origin.y + 10, width:AddPaymentPopup.frame.size.width/2  , height: 40))
        OkAddPaymentBtn.setTitle("Add Payment", for: .normal)
        OkAddPaymentBtn.tintColor = UIColor.blue
        OkAddPaymentBtn.addTarget(self, action:#selector(AddPaymentOkBtnPressed(_:)), for: .touchUpInside)
        AddPaymentPopup.addSubview(OkAddPaymentBtn)
        
        
    }
    
     @objc func AddPaymentCancelBtnPressed(_ sender: UIButton) {
      
        if   maximumDurationChatInSec == 60 {
            DispatchQueue.main.async(execute: {
                self.dismissPopupView()
                self.countDownLabel.isHidden = true
                self.chatNamelbl.frame =        CGRect(x:0 , y:self.headerBaseView.frame.origin.y + self.headerBaseView.frame.size.height , width:self.view.frame.size.width , height: self.view.frame.height - (self.headerBaseView.frame.origin.y + self.headerBaseView.frame.size.height + 52))
                self.MsgTextView.resignFirstResponder()
                self.MsgTextView.isUserInteractionEnabled = false
                self.cameraImgBtn.isUserInteractionEnabled = false
                // self.replyIcon.isUserInteractionEnabled = false
                self.MsgSendBtn.isUserInteractionEnabled = false
                self.chatView.isHidden = true
                self.timer.invalidate()
                self.chatTblView.frame =  CGRect(x:0 , y:self.headerBaseView.frame.origin.y + self.headerBaseView.frame.size.height , width:self.view.frame.size.width , height: self.view.frame.height - (self.headerBaseView.frame.origin.y + self.headerBaseView.frame.size.height ))
            })
        }else {
            
            DispatchQueue.main.async(execute: {
                self.dismissPopupView()
                self.countDownLabel.isHidden = true
                self.chatNamelbl.frame =        CGRect(x:0 , y:self.headerBaseView.frame.origin.y + self.headerBaseView.frame.size.height , width:self.view.frame.size.width , height: self.view.frame.height - (self.headerBaseView.frame.origin.y + self.headerBaseView.frame.size.height + 52))
                self.MsgTextView.resignFirstResponder()
                self.MsgTextView.isUserInteractionEnabled = false
                self.cameraImgBtn.isUserInteractionEnabled = false
                // self.replyIcon.isUserInteractionEnabled = false
                self.MsgSendBtn.isUserInteractionEnabled = false
                self.chatView.isHidden = true
                self.timer.invalidate()
                self.chatTblView.frame =  CGRect(x:0 , y:self.headerBaseView.frame.origin.y + self.headerBaseView.frame.size.height , width:self.view.frame.size.width , height: self.view.frame.height - (self.headerBaseView.frame.origin.y + self.headerBaseView.frame.size.height ))
            })
        }
        
       
    }
    @objc func AddPaymentOkBtnPressed(_ sender: UIButton) {
        DispatchQueue.main.async(execute: {
            self.dismissPopupView()
         
         })
            print(self.userQuestInfo)
            var coachPrice = self.userQuestInfo["amount"] as! String
           coachPrice =  String(coachPrice.characters.dropFirst())
             let coachpriceValue = Double(coachPrice)
      
            //   let CoachPriceStr:String = String(describing: coachPrice)
            //     let coachpriceValue = Int(CoachPriceStr)
            let coachPricePerTenMin = String(format:"%3.2f",coachpriceValue! * 10)
            let coachPricePerFiftenMin = String(format:"%3.2f",coachpriceValue! * 15)
            let coachPricePerTwentyMin = String(format:"%3.2f",coachpriceValue! * 20)
            let coachPricePerThirtyMin = String(format:"%3.2f",coachpriceValue! * 30)
        
      
        
            var buyCreditAmount = ""
            if self.paymentTableIndexSelectedValue == 0 {
                buyCreditAmount = coachPricePerTenMin
                var DiffBwChat = Int(durationOfChat - count)
                if DiffBwChat == 60 {
                  liveChatUpdateOrderDuration = "11"
                }else {
                     liveChatUpdateOrderDuration = "10"
                }
               
                liveChatUpdateTotalPrice = coachPricePerTenMin
            }else if self.paymentTableIndexSelectedValue == 1 {
                buyCreditAmount = coachPricePerFiftenMin
                var DiffBwChat = Int(durationOfChat - count)
                if DiffBwChat == 60 {
                      liveChatUpdateOrderDuration = "16"
                }else {
                       liveChatUpdateOrderDuration = "15"
                }
             
                liveChatUpdateTotalPrice = coachPricePerFiftenMin
            }else if self.paymentTableIndexSelectedValue == 2{
                buyCreditAmount = coachPricePerTwentyMin
                var DiffBwChat = Int(durationOfChat - count)
                if DiffBwChat == 60 {
                     liveChatUpdateOrderDuration = "21"
                }else {
                     liveChatUpdateOrderDuration = "20"
                }
               
                liveChatUpdateTotalPrice = coachPricePerTwentyMin
            }else if self.paymentTableIndexSelectedValue == 3 {
                buyCreditAmount = coachPricePerThirtyMin
              
                var DiffBwChat = Int(durationOfChat - count)
                if DiffBwChat == 60 {
                      liveChatUpdateOrderDuration = "31"
                }else {
                      liveChatUpdateOrderDuration = "30"
                }
                liveChatUpdateTotalPrice = coachPricePerThirtyMin
            }
        
          let userbalance = getUserBalance() as String
        print(userbalance)
        
        var userBalanceValue = Float(userbalance) ?? 0.0
        var buyAmountValue = Float(buyCreditAmount) ?? 0.0
        
        var userbalanceTempValue = userBalanceValue
         var buyAmountValueTemp = buyAmountValue
        
        if userbalanceTempValue == 0.0 {
            let AddCardListVC = self.storyboard?.instantiateViewController(withIdentifier: "AddCreditCardList") as? AddCreditCardList
            AddCardListVC?.delegate = self
            AddCardListVC?.buyCreditAmount = buyCreditAmount
            self.navigationController?.pushViewController(AddCardListVC!, animated: true)
        }else if userbalanceTempValue >= buyAmountValueTemp {
            
            print("Deduct Balance from wallet completely")
          
            let AmountDiff = Double(userbalanceTempValue - buyAmountValueTemp)
            let AmountToBePaidByUser = String(AmountDiff)
            
            let token = UserDefaults.standard.object(forKey: "deviceToken")
            let userDeviceArray = ["deviceToken": token ?? "","deviceId": appDelegateDeviceId.deviceId ?? "","deviceType": "I"] as [String : Any]
            
            let request = ["user_id": getUserId(), "fname": getFirstName(), "lname":getLastName(), "address":getAddress() ,"longlat":[], "phone_no":getPhoneNo() , "profile_pic":getProfilePic(),"user_devices":[userDeviceArray],
                           "balance" :AmountToBePaidByUser] as [String : Any]
            self.updateUser_CoachesDetails(request: request as NSDictionary, type: kUPDATE_USER_DETAILS)
            
            
        }else  if buyAmountValueTemp > userbalanceTempValue {
            
         let AmountDiff = Double(buyAmountValueTemp - userbalanceTempValue)
            let AmountToBePaidByUser = String(AmountDiff)
            let AddCardListVC = self.storyboard?.instantiateViewController(withIdentifier: "AddCreditCardList") as? AddCreditCardList
            AddCardListVC?.delegate = self
            AddCardListVC?.buyCreditAmount = AmountToBePaidByUser
            self.navigationController?.pushViewController(AddCardListVC!, animated: true)
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
    //    presentPopupView(reviewPopup)
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
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool{
        let currentString: NSString = textView.text! as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: text) as NSString
        
        if textView.tag ==  2 {
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
    @objc func keyboardWillShow(_ notification:Notification) {
    
    if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
       
        
//chatTblView.frame = CGRect(x: chatTblView.frame.origin.x, y: chatTblView.frame.origin.y , width: chatTblView.frame.size.width, height: chatTblView.frame.size.height - keyboardSize.height)
//chatView.frame =  CGRect(x: chatView.frame.origin.x, y: chatTblView.frame.origin.y + chatTblView.frame.size.height + 1, width: chatView.frame.size.width, height: chatView.frame.size.height)
        
    
        self.chatTblView.frame = CGRect(x:0, y: 80 , width: self.chatTblView.frame.size.width, height: self.view.frame.size.height  - (keyboardSize.height + 80 + 52))
        self.chatView.frame = CGRect(x: 10, y:self.view.frame.size.height - (keyboardSize.height + 52) , width: self.view.frame.size.width - 20, height: 52)
        self.chatTblView.reloadData()
        self.setLastIndexPath()
        
        print(self.view.frame.origin.y)
        print(self.view.frame.size.height)
        print(headerBaseView.frame.origin.y)
        print(headerBaseView.frame.size.height)
        print(keyboardSize.height)
        print(chatTblView.frame.origin.y)
        print(chatTblView.frame.size.height)
        print(chatView.frame.origin.y)
        print(chatView.frame.size.height)
       
        print(keyboardSize)
    }
        print("Not success")
        
    }


    @objc func keyboardWillHide(_ notification:Notification) {
    
    if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
     
        self.chatTblView.frame = CGRect(x: self.chatTblView.frame.origin.x, y: 80, width: self.chatTblView.frame.size.width, height: self.view.frame.size.height - (80 + 52) )
        self.chatView.frame =  CGRect(x: 10, y:self.view.frame.size.height - 52 , width: self.view.frame.size.width - 20, height: 52 )
        self.chatTblView.reloadData()
        self.setLastIndexPath()

        
  
        print(self.view.frame.origin.y)
        print(self.view.frame.size.height)
        print(headerBaseView.frame.origin.y)
        print(headerBaseView.frame.size.height)
        print(keyboardSize.height)
        print(chatTblView.frame.origin.y)
        print(chatTblView.frame.size.height)
        print(chatView.frame.origin.y)
        print(chatView.frame.size.height)
        print(keyboardSize)
       
    }
        
         print("Not success")
    }
   
    
    func addHandlers() {
        
        socket?.onAny { ack in
            print("Socket Connected")
            print("ravi-->socket connected  \(ack)")
        }
        //when socket is connected
        socket?.on("connected") { data,ack in
           print("Socket Connected")
            print("ravi-->socket connected \(data) \(ack)")
        }
        
        socket?.on("test_message") { data,ack in
            print("test_message")
            print("ravi-->test_message \(data) \(ack)")
        }
        
        socket?.on("auth_success") { data,ack in
            print("auth_success")
            print("ravi-->socket connected \(data) \(ack)")
        }
        
       
        socket?.on("error") { data,ack in
            
            print("error \(data) \(ack)")
        }
        
        
        socket?.on("isonline") { data, ack in
             print("Socket isonline")
            
        }
        
        socket?.on("user left") { data, ack in
            print("Socket user left")
        }
        
        // when somebody typing
        socket?.on("istyping")   { data, ack in
             print("istyping")
            
            self.chatNamelbl.frame =  CGRect(x:(self.view.frame.size.width - 180 )/2  , y: 35, width: 180 , height: 20)
            self.typingLbl.frame =  CGRect(x:(self.view.frame.size.width - 180 )/2  , y: self.chatNamelbl.frame.size.height + self.chatNamelbl.frame.origin.y, width: 180 , height: 20)
            self.typingLbl.isHidden = false
            
        }
        
        // when stop typing
        socket?.on("stoptyping")  { data, ack in
             print("istyping")
            self.typingLbl.isHidden = true
            self.chatNamelbl.frame =  CGRect(x:(self.view.frame.size.width - 180 )/2  , y: 40, width: 180 , height: 20)
            
        }
        
        // when message edited
        socket?.on("editmsg")  { data, ack in
             print("editmsg")
        }
        // when delivery ack received
        socket?.on("delivery_ack")  { data, ack in
             print("delivery_ack")
        }
        // when read ack received
        socket?.on("read_ack") { data, ack in
            print("read_ack")
        }
        socket?.on("disconnect")   { data, ack in
            
            print("Socket disconnect")
           
            
        }
        
        // when we got messages from other
        socket?.on("handlemessage") { data, ack in

          
            let msgArray = data as NSArray
            print(msgArray)
             let messgDict  = msgArray.object(at: 0) as! NSDictionary
            self.setMessageToDataBase(msgDictDetail: messgDict as NSDictionary)
            var arrayFromDataBase = self.getChatHistoryFromDataBaseWithRoom(order_Id: self.orderId) as! NSArray
            print(arrayFromDataBase.count)
            let userInfoDict = messgDict["userinfo"] as! NSDictionary
            let userIDRecieve = userInfoDict["user_id"] as! String
            
            let userId = getUserId() as String
            print(userIDRecieve)
            if userId == userIDRecieve {
                   self.SocketConnection = 1
                self.room_Id = messgDict["room"] as! String
            }else if userId != userIDRecieve {
                self.SocketConnection = 0
                if (msgArray.count > 0) {
                    
                    self.chatMessages.add(msgArray)
                    print(self.chatMessages)
                    print(self.chatMessages.count)
                    print(msgArray)
                    
  
                    self.chatTblView.reloadData()
                      self.setLastIndexPath()
                    
                }
            }
            print(self.SocketConnection)
            print("msg Recievded")
            
            //IANotificationBar.sharedInstance.showMessage(title: "Hello", description: "Hello This is a Simple Text Message to notify Your User's")
            
            
        }
    
    }
    func setMessageToDataBase(msgDictDetail : NSDictionary)  {
        
        var message : ManageMessage?
         message = ManageMessage.mr_createEntity()
        var msgManagedObjectContext : NSManagedObjectContext?
        msgManagedObjectContext       = NSManagedObjectContext.mr_contextForCurrentThread()
        
        message!.message_ClintId    = msgDictDetail["client_msg_id"] as! String
        message!.message_Text = msgDictDetail["message"] as! String
        message!.msgOrder_Id = msgDictDetail["order_id"] as! String
        message!.msg_Type = msgDictDetail["type"] as! NSObject
        message!.message_RoomId = msgDictDetail["room"] as? String
        message!.message_Time = msgDictDetail["time"] as? String
        
        let userInfoDict = msgDictDetail["userinfo"] as! NSDictionary
        let userSenderID = userInfoDict["user_id"] as! String
        let UserProfileImgUrl = userInfoDict["profileImg"] as! String
        
        message!.sender_profileImg = UserProfileImgUrl
        message!.message_SenderId = userSenderID
        message!.message_RecieverId = recieverId as NSObject
        message!.message_Id =  msgDictDetail["message_id"] as? String
        
        
        message!.videoUrl  =  msgDictDetail["video_url"] as? String
        message!.videoThumbImgUrl = msgDictDetail["video_thumb"] as? String
        message!.message_type =  msgDictDetail["message_type"] as! NSObject
        saveMsgDataInDatabase()
    }
    
    func saveMsgDataInDatabase() {
        
        MagicalRecord.setupCoreDataStack()
        NSManagedObjectContext.mr_contextForCurrentThread().mr_saveToPersistentStoreAndWait()
    }
   
    
    @objc func MsgSendBtnPressed(_ sender: Any) {
       
        let internetCheck = isInternetAvailable()
        
        if internetCheck {
         BackDurationOfChat = 1
              self.pageIndex = 0
            
            if isCoach() {
                
            }else {
                
                if CheckTimer == 0 {
                    
                    CheckTimer = 1
                    countDownLabel.isHidden = false
            
                    self.chatNamelbl.frame =  CGRect(x:(self.view.frame.size.width - 180 )/2  , y: 35, width: 180 , height: 20)
                    self.countDownLabel.frame =  CGRect(x:(self.view.frame.size.width - 180 )/2  , y: self.chatNamelbl.frame.size.height + self.chatNamelbl.frame.origin.y, width: 180 , height: 20)
                    timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(update), userInfo: nil, repeats: true)
                    
                }else {
                    
                }
               
            }
            
            
            if MsgTextView.text.characters.count > 0 {
                
                
                
                if user_id == coach_id {
                    if type == 2 {
                        print("coach is sender and user id is coachid")
                    }
                }else {
                    if type == 1 {
                        print("user is sender ")
                    }
                }
                //  type = "2"
                
                if SocketConnection == 1 {
                    let sendMsgDict = ["user_id":recieverId,
                                       "order_id":orderId,
                                       "type":type,
                                       "message":MsgTextView.text!,
                                       "client_msg_id" :clientMsgId,
                                       "message_type" : 1,
                                       "socket_connection" : 1] as [String : Any]
                    
                    print(sendMsgDict)
                    
                    addDataToChatTableArray(msgDictDetail: sendMsgDict as NSDictionary)
                    
                    //                setMessageToDataBase(msgDictDetail: sendMsgDict as NSDictionary)
                    //                var arrayFromDataBase = getChatHistoryFromDataBaseWithRoom(order_Id: "7897379728")
                    //                print(arrayFromDataBase)
                    //                for i in arrayFromDataBase {
                    //                    if let obj  = i as? ManageMessage {
                    //                        print(obj.value(forKey: "message_ClintId")!)
                    //                        print(obj.value(forKey: "message_From")!)
                    //                    }
                    //                }
                    //
                    socket?.emitWithAck("message",with: [sendMsgDict]).timingOut(after:0, callback: { data in
                        
                        print("send message \(data)")
                    })
                }else if SocketConnection == 0 {
                    let sendMsgDict = ["user_id":recieverId,
                                       "order_id":orderId,
                                       "type":type,
                                       "message":MsgTextView.text!,
                                       "message_type" : 1,
                                       "client_msg_id" :clientMsgId] as [String : Any]
                    print(sendMsgDict)
                    addDataToChatTableArray(msgDictDetail: sendMsgDict as NSDictionary)
                    
                    //                setMessageToDataBase(msgDictDetail: sendMsgDict as NSDictionary)
                    //
                    //                var arrayFromDataBase = getChatHistoryFromDataBaseWithRoom(order_Id: "7897379728")
                    //                print(arrayFromDataBase)
                    //                for i in arrayFromDataBase {
                    //                    if let obj  = i as? ManageMessage {
                    //                        print(obj.value(forKey: "message_ClintId")!)
                    //                        print(obj.value(forKey: "message_From")!)
                    //                    }
                    //                }
                    
                    socket?.emitWithAck("message",with: [sendMsgDict]).timingOut(after:0, callback: { data in
                        
                        print("send message \(data)")
                    })
                }
                
                MsgTextView.text = ""
                
                
            }
        } else {
              notifyUser("", message: "No Internet Connection. Please Check" , vc: self)
        }
        

        
    }
    
    
    func addDataToChatTableArray(msgDictDetail : NSDictionary) {
      
  let MsgType =      msgDictDetail["message_type"] as! Int
        
        if MsgType == 1 {
            let clientMsgId = msgDictDetail["client_msg_id"] as! String
            let message = msgDictDetail["message"] as! String
            
            let orderId = msgDictDetail["order_id"] as! String
            //   let time = dict["created_at"] as! String
            let type = msgDictDetail["type"] as! Int
            
            
            let MsgId = "tempRary message id"
            let room = self.room_Id
            
            
            var UserDict =  NSDictionary()
            
            let profileImg = getProfilePic() as! String
            let userID = getUserId() as! String
            UserDict = ["profileImg":profileImg,"user_id":userID,] as NSDictionary
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
            //dateFormatter.timeZone = TimeZone(abbreviation: "GMT+0:00") //Current time zone
            dateFormatter.locale = NSLocale.init(localeIdentifier: "en_US_POSIX") as Locale!
            dateFormatter.timeZone = NSTimeZone(name: "GMT")! as TimeZone
            let date = Date()
            let dateString = dateFormatter.string(from: date)
            print(dateString)
            
            let InfoDIct = ["client_msg_id":clientMsgId,"message":message,"video_url":"","video_thumb": "","message_id": MsgId,"order_id":orderId,"room": room,"time": dateString,"type": type,"userinfo": UserDict,"message_type" : MsgType] as NSDictionary
            
            
            var msgArray = NSMutableArray()
            msgArray.insert(InfoDIct, at: 0)
            
            self.chatMessages.add(msgArray)
            
            self.chatTblView.reloadData()
            setLastIndexPath()
        } else if MsgType == 2 {
            let clientMsgId = msgDictDetail["client_msg_id"] as! String
            let videoUrl = msgDictDetail["video_url"] as! String
             let videoThumbUrl = msgDictDetail["video_thumb"] as! String
            let orderId = msgDictDetail["order_id"] as! String
            //   let time = dict["created_at"] as! String
            let type = msgDictDetail["type"] as! Int
            
            
            let MsgId = "tempRary message id"
            let room = self.room_Id
            
            
            var UserDict =  NSDictionary()
            
            let profileImg = getProfilePic() as! String
            let userID = getUserId() as! String
            UserDict = ["profileImg":profileImg,"user_id":userID,] as NSDictionary
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
            //dateFormatter.timeZone = TimeZone(abbreviation: "GMT+0:00") //Current time zone
            dateFormatter.locale = NSLocale.init(localeIdentifier: "en_US_POSIX") as Locale!
            dateFormatter.timeZone = NSTimeZone(name: "GMT")! as TimeZone
            let date = Date()
            let dateString = dateFormatter.string(from: date)
            print(dateString)
            
            let InfoDIct = ["client_msg_id":clientMsgId,"message":"","video_url":videoUrl,"video_thumb": videoThumbUrl,"message_id": MsgId,"order_id":orderId,"room": room,"time": dateString,"type": type,"userinfo": UserDict,"message_type" : MsgType] as NSDictionary
            
            
            var msgArray = NSMutableArray()
            msgArray.insert(InfoDIct, at: 0)
            
            self.chatMessages.add(msgArray)
            
            self.chatTblView.reloadData()
            setLastIndexPath()
        }
        
       
    }
    
    
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        self.getChatMessage { (messageInfo) -> Void in
            DispatchQueue.main.async { () -> Void in
             //   self.chatMessages.append(messageInfo)
                //    self.messageListArray.
                print(self.chatMessages)
         //       print(messageInfo)
                self.chatTblView.reloadData()
                self.setLastIndexPath()
            }
    //    }
        
    }
   
    override func viewWillAppear(_ animated: Bool) {
        
      IQKeyboardManager.sharedManager().enable = false
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
    
        
        IQKeyboardManager.sharedManager().enable = true
        
    }
    
    
    func textViewDidChange(_ textView: UITextView) {
        
        if let placeholderLabel = textView.viewWithTag(100) as? UILabel {
            placeholderLabel.isHidden = textView.text.characters.count > 0
        }
    }

    
    @objc func paymentSelectedBtnPressed(_ sender: UIButton) {
        
        paymentTableIndexSelectedValue = sender.tag
        PaymentTblView.reloadData()
        
        
    }
 @objc func cameraImgBtnPressed(_ sender: Any) {
    
   if  isCoach() {
        let actionSheetController = UIAlertController(title: "Record video", message:nil , preferredStyle: .actionSheet)
        
        // actionSheetController.view.tintColor = UIColor.headerBlue
        picker.delegate = self
        let cancelActionButton = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
            
        }
        picker.delegate = self
        cancelActionButton.setValue(UIColor.red, forKey: "titleTextColor")
        
        if isCoach() {
            let videoActionButton = UIAlertAction(title: "Record response video", style: .default) { action -> Void in
                self.openCameraWithVideorecord()
            }
            actionSheetController.addAction(videoActionButton)
        }
        actionSheetController.addAction(cancelActionButton)
        self.present(actionSheetController, animated: true, completion: nil)
   } else {
     notifyUser("", message: "User can not be allowed to send video.", vc: self)
    }
        
    
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]){
        
        picker .dismiss(animated: true, completion: nil)
        let mediaType = info[UIImagePickerControllerMediaType] as! NSString
        
        if mediaType.isEqual(to: kUTTypeMovie as String) {
            
            // Media is a video
            print("record a video")
            //     let videoURL = info[UIImagePickerControllerMediaURL] as! URL
            
            showProgressIndicator(refrenceView: self.view)
            
            let videoURL = info[UIImagePickerControllerMediaURL] as! NSURL
            
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
                        
                   
                        
                        
                        if self.user_id == self.coach_id {
                            if self.type == 2 {
                                print("coach is sender and user id is coachid")
                            }
                        }else {
                            if self.type == 1 {
                                print("user is sender ")
                            }
                        }
                        //  type = "2"
                        
                        if self.SocketConnection == 1 {
                            let sendMsgDict = ["user_id":self.recieverId,
                                               "order_id":self.orderId,
                                               "type":self.type,
                                               "video_url":uploadUrl,
                                               "video_thumb":uploadUrlImage,
                                               "client_msg_id" :self.clientMsgId,
                                               "message_type" : 2,
                                               "socket_connection" : 1] as [String : Any]
                            
                            print(sendMsgDict)
                            
                            self.addDataToChatTableArray(msgDictDetail: sendMsgDict as NSDictionary)
                            
                            
                            self.socket?.emitWithAck("message",with: [sendMsgDict]).timingOut(after:0, callback: { data in
                                
                                print("send message \(data)")
                            })
                        }else if self.SocketConnection == 0 {
                            let sendMsgDict = ["user_id":self.recieverId,
                                               "order_id":self.orderId,
                                               "type":self.type,
                                               "video_url":uploadUrl,
                                               "video_thumb":uploadUrlImage,
                                                "message_type" : 2,
                                               "client_msg_id" :self.clientMsgId] as [String : Any]
                            print(sendMsgDict)
                            self.addDataToChatTableArray(msgDictDetail: sendMsgDict as NSDictionary)
                            
                           
                            
                            self.socket?.emitWithAck("message",with: [sendMsgDict]).timingOut(after:0, callback: { data in
                                
                                print("send message \(data)")
                            })
                        }
                         stopProgressIndicator()
                        print("responseData",responseData ?? "")
                    }
                    else{ stopProgressIndicator()}
                }
                
            }
            else{ stopProgressIndicator()}
        }
    }
    @objc func clickOnPlayVideoButton(sender:UIButton) {
        
        let tagValue =  sender.tag
        let messageArray = chatMessages[tagValue] as? NSArray
        let messageDict = messageArray?.object(at: 0) as! NSDictionary
        
        print("Url Fetched")
        let videoUrl  = messageDict["video_url"] as? String
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
      
        do {
            var imageRef =  try imageGenerator.copyCGImage(at: time1, actualTime: nil)
            let thumbnail = UIImage(cgImage: imageRef)
            return thumbnail
        } catch {
            print(error.localizedDescription)
            print(error.localizedDescription)
            return UIImage(named: "user_icon")
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
                //    presentPopupView(reviewPopup)
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
    func userLoginApi() {
        
        let userDetail = getUserDetails()
        let requestDict = ["user_id":getUserId()] as NSDictionary
        print(requestDict)
        
        showProgressIndicator(refrenceView: self.view)
        WebServices().mainFunctiontoGetDetails(data: requestDict,serviceType:k_USER_Profile) { (responseData)  in
          //  stopProgressIndicator()
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
                        
                        let balance =  resultDict["balance"] as? String ?? ""
                        
                        let userId = resultDict["_id"] as? String ?? ""
                        let lname = resultDict["lname"] as? String ?? ""
                         let fname = resultDict["fname"] as? String ?? ""
                         let longlat = resultDict["longlat"] as? NSArray
                         let address = resultDict["address"] as? String ?? ""
                         let phone_no = resultDict["phone_no"] as? String ?? ""
                         let profile_pic = resultDict["profile_pic"] as? String ?? ""
                       
                        let UserBalanceValue = Double(balance)
                        let LiveChatBlockPrice = Double(self.liveChatUpdateTotalPrice)
                        var UpdateBalanceValue = Double(UserBalanceValue! - LiveChatBlockPrice!)
                        var UpDateBalance = String(UpdateBalanceValue)
                        
                        let token = UserDefaults.standard.object(forKey: "deviceToken")
                        let userDeviceArray = ["deviceToken": token ?? "","deviceId": appDelegateDeviceId.deviceId ?? "","deviceType": "I"] as [String : Any]

                        let request = ["user_id": userId, "fname": fname, "lname":lname, "address":getAddress() ,"longlat":longlat, "phone_no":phone_no , "profile_pic":profile_pic,"user_devices":[userDeviceArray],
                            "balance" :UpDateBalance] as [String : Any]
                        self.updateUser_CoachesDetails(request: request as NSDictionary, type: kUPDATE_USER_DETAILS)
                        
                    }
                }
            }
            else{
                //stopProgressIndicator()
            }
        }
    }
    
    func updateUser_CoachesDetails(request:NSDictionary,type:String) {
        
        stopProgressIndicator()
        showProgressIndicator(refrenceView: self.view)
        WebServices().mainFunctiontoGetDetails(data: request as NSDictionary,serviceType:type) { (responseData)  in
           stopProgressIndicator()
            if responseData != nil
            {
                let code = responseData?["code"] as? NSNumber
                print("responseData",responseData ?? "")
                if code == 200{
                    stopProgressIndicator()
                    
                    guard let resultDict = responseData?["result"] as? NSDictionary else {
                        return
                    }
                    removeUserDetails()
                    saveUserDetails(userDict: resultDict)
                    CloseChatDays = resultDict["close_chat"] as? String ?? ""
                    ServiceTaxValue = resultDict["service_tax"] as? String ?? ""
                    self.updateOrder()
                    
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
    
    func updateOrder() {
        
    
        let liveChatAmount = Double(liveChatUpdateTotalPrice)
      
        var  ServiceTaxValue1 = Double(serveiceTaxLiveChat)
        ServiceTaxValue1 =  100.0 - ServiceTaxValue1!
        let CoachAmountPrice = Double((ServiceTaxValue1! *  liveChatAmount!)/100)
        let CoachAmountPriceStr = String(CoachAmountPrice)
        
//        var  liveChatDuration = Int(liveChatUpdateOrderDuration)
//
//        liveChatDuration = liveChatDuration! + 1
//        liveChatUpdateOrderDuration = String(describing: liveChatDuration)
        
        let sendMsgDict = [ "order_id" : orderId,
                            "duration" : liveChatUpdateOrderDuration,
                            "chat_end_time" : "0",
                            "live_chat_amount" : liveChatUpdateTotalPrice,
                            "coach_amount":CoachAmountPriceStr] as [String : Any]
        
        
      //  showProgressIndicator(refrenceView: self.view)
        WebServices().mainFunctiontoGetDetails(data: sendMsgDict as NSDictionary,serviceType:k_USER_UpdateOrder) { (responseData)  in
            stopProgressIndicator()
            if responseData != nil
            {
                let code = responseData?["code"] as? NSNumber
                print("responseData",responseData ?? "")
                if code == 200{
                      self.CheckTimer = 0
                    self.countDownLabel.text = "00:00"
                    self.chatNamelbl.frame =        CGRect(x:0 , y:self.headerBaseView.frame.origin.y + self.headerBaseView.frame.size.height , width:self.view.frame.size.width , height: self.view.frame.height - (self.headerBaseView.frame.origin.y + self.headerBaseView.frame.size.height + 52))
                    self.countDownLabel.isHidden = true
                    self.count =  0
                    let durationOfChatAgain = Int(self.liveChatUpdateOrderDuration)
                    self.maximumDurationChatInSec = (durationOfChatAgain! * 60) + self.DurationChatAfterAletInSec
                    self.DurationChatAfterAletInSec = 60
                  //  self.maximumDurationChatInSec = 80
                    
                      notifyUser("", message: "Your Payment Succeed. You can Continue With Coach" , vc: self)
                }
            }
            else{
                
                stopProgressIndicator()
                  notifyUser("", message: "" , vc: self)
            }
        }
    }
    @objc func backBtnPressed(_ sender: Any) {
         IQKeyboardManager.sharedManager().enable = true
        if isCoach() {
            MsgTextView.resignFirstResponder()
          //  IQKeyboardManager.sharedManager().enable = true
          //  socket?.disconnect()
            timer.invalidate()
            self.navigationController?.popViewController(animated: true)
        }else {
            if BackDurationOfChat == 1 {
                self.updateOrderBack()
            }else if BackDurationOfChat == 0 {
                MsgTextView.resignFirstResponder()
            //    IQKeyboardManager.sharedManager().enable = true
               // socket?.disconnect()
                timer.invalidate()
                self.navigationController?.popViewController(animated: true)
            }
        }
      
       
    }
   
    
    func updateOrderBack() {
        
        timer.invalidate()
        var ChatEndTieStr = ""
        if liveChatUpdateTotalPrice == "" {
        print("change")
              liveChatUpdateTotalPrice = self.userQuestInfo["live_chat_amount"]  as! String
            let liveChatSec = count
            let MaxChatSec = Int(maximumDurationChatInSec)
            let remaingSec = Int(MaxChatSec - liveChatSec)
            let min = Int(remaingSec /  60)
            let minStr = String(min)
            
              var duration = userQuestInfo["duration"] as! String
            liveChatUpdateOrderDuration = duration
            var chatEndTime = userQuestInfo["chat_end_time"] as! String
            var ChatEndValeInSec = Int(chatEndTime)
            let ChatEndTimeTemp = ChatEndValeInSec! + count
            ChatEndTieStr = String(ChatEndTimeTemp)
            
        }else {
            ChatEndTieStr = String(count)
        }
     
        let liveChatAmount = Double(liveChatUpdateTotalPrice)
        
        var  ServiceTaxValue1 = Double(serveiceTaxLiveChat)
        ServiceTaxValue1 =  100.0 - ServiceTaxValue1!
        let CoachAmountPrice = Double((ServiceTaxValue1! *  liveChatAmount!)/100)
        let CoachAmountPriceStr = String(CoachAmountPrice)
        print( self.maximumDurationChatInSec)
        
        var ChatMin =  self.maximumDurationChatInSec
        var  ChatMinD = Double(ChatMin /  60 )
        var ChatStr  = String(ChatMinD)
//        var  chatSec = Int(self.maximumDurationChatInSec % 60)
//
//        let durationChat = String(format:"%d.%d",ChatMin , chatSec)
//        print(durationChat)
    //   self.maximumDurationChatInSec = 500
        
       
       
        let sendMsgDict = [ "order_id" : orderId,
                            "duration" : liveChatUpdateOrderDuration,
                            "chat_end_time" : ChatEndTieStr,
                            "live_chat_amount" : liveChatUpdateTotalPrice,
                            "coach_amount":CoachAmountPriceStr] as [String : Any]
        
        
          showProgressIndicator(refrenceView: self.view)
        WebServices().mainFunctiontoGetDetails(data: sendMsgDict as NSDictionary,serviceType:k_USER_UpdateOrder) { (responseData)  in
            stopProgressIndicator()
            if responseData != nil
            {
                let code = responseData?["code"] as? NSNumber
                print("responseData",responseData ?? "")
                if code == 200{
                    self.MsgTextView.resignFirstResponder()
              
               //     self.socket?.disconnect()
                    self.timer.invalidate()
                    
                    isFromLiveChatBackBtn = 1
                //    self.navigationController?.popViewController(animated: true)
                    
                    if let viewControllers = self.navigationController?.viewControllers {
                        for viewController in viewControllers {
                            // some process
                            if viewController.isKind(of: HomeTabbarVC.self){
                                if let vc = viewController as? HomeTabbarVC {
                                    
                                    if let viewControllers1 = vc.viewControllers  {
                                        for viewController2 in viewControllers1 {
                                           
                                              if let vc2 = viewController2 as? MySessionsVC {
                                                vc2.segmentControl.selectedSegmentIndex = 1
                                                vc2.viewWillAppear(true)
                                                 self.navigationController?.popViewController(animated: true)
// self.navigationController?.popToViewController(vc, animated: true)
                                            }
                                        }
                                    }
                                    
//                               //     NotificationCenter.default.post(name: NSNotification.Name("getSessionIndex"), object: nil)
//                                    //   vc.selectedIndex = 1
//                                    vc.viewWillAppear(true)
//                                    self.navigationController?.popToViewController(vc, animated: true)
                            //        break
                                }
                            }
                        }
                    }

                    
                    
                    
                }
            }
            else{
                
                stopProgressIndicator()
                notifyUser("", message: "" , vc: self)
            }
        }
    }
    
    func sendMessage(message: String, withNickname nickname: String) {
      //  socket.emit("chatMessage", nickname, message)
    }
   
   
    func sendUserMessage_to_coach(request:NSDictionary) {
        
        self.view.endEditing(true)
        WebServices().mainFunctiontoGetDetails(data: request as NSDictionary,serviceType:kSEND_MESSAGE) { (responseData)  in
            stopProgressIndicator()
            if responseData != nil
            {
                let code = responseData?["code"] as? NSNumber
                print("responseData",responseData ?? "")
                if code == 200{
                    stopProgressIndicator()
                    self.MsgTextView.text = nil
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
                    self.chatTblView.reloadData()
                    
                    self.setLastIndexPath()
                    
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
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
extension TextChatVC : ProfileBalanceDelegate {
    func updateBalance() {
        self.userLoginApi()
     //   self.profileTableView.reloadData()
    }
}
extension TextChatVC : UITableViewDataSource {
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.tag == 2 {
            return 4
        }else{
           return  self.chatMessages.count + 1
        }
        
        
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
            print(userQuestInfo)
            var coachPrice = userQuestInfo["amount"] as! String
          coachPrice =   String(coachPrice.characters.dropFirst())
            //   let CoachPriceStr:String = String(describing: coachPrice)
                 let coachpriceValue = Double(coachPrice)
            let coachPricePerTenMin = String(format:"10 Min / $%3.2f",coachpriceValue! * 10)
            let coachPricePerFiftenMin = String(format:"15 Min / $%3.2f",coachpriceValue! * 15)
            let coachPricePerTwentyMin = String(format:"20 Min / $%3.2f",coachpriceValue! * 20)
            let coachPricePerThirtyMin = String(format:"30 Min / $%3.2f",coachpriceValue! * 30)
            
            
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
            
//
//            if indexPath.row == 0 {
//                cell.paymentValueLbl.text = "1 Min/ $2.99"
//                cell.rightIconBtn.isSelected = true
//            }else if indexPath.row == 1 {
//                cell.paymentValueLbl.text = "10 Min/ $3.99"
//                cell.rightIconBtn.isSelected = false
//            }else if indexPath.row == 2 {
//                cell.paymentValueLbl.text = "30 Min/ $3.99"
//                cell.rightIconBtn.isSelected = false
//            }else if indexPath.row == 3 {
//                cell.paymentValueLbl.text = "1 hr/ $3.99"
//                cell.rightIconBtn.isSelected = false
//            }else if indexPath.row == 4 {
//                cell.paymentValueLbl.text = "2 hr/ $3.99"
//                cell.rightIconBtn.isSelected = false
//            }
//            
            cell.PaymentBtn.addTarget(self, action: #selector(paymentSelectedBtnPressed), for: .touchUpInside)
            
          
            return cell
            
            
        }else {
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
                
                let messagearray = chatMessages.object(at: indexPath.row -  1 ) as! NSArray
                print(messagearray)
                let messgDict  = messagearray.object(at: 0) as! NSDictionary
                let MessageVideoType = messgDict["message_type"] as! Int
                
                if MessageVideoType == 1 {
                    let cell: TextMsgCellTableViewCell! =  tableView.dequeueReusableCell(withIdentifier: "TextMsgCellTableViewCell") as? TextMsgCellTableViewCell
                    
                    let ProfileImg = UIImage(named: "user_image")
                    let senderImg = UIImage(named: "chat_bg_gray_corner")
                    let recieverImg = UIImage(named: "chat_bg_corner")
                    
                    print(self.chatMessages)
                    print(self.chatMessages.count)
                    
                    
                    print(messgDict)
                    let MessageTxt = messgDict["message"] as! String
                    print(MessageTxt)
                    let DateStr = messgDict["time"] as! String
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
                    
                    
                    let userInfoDict = messgDict["userinfo"] as! NSDictionary
                    let profilePicUrl = userInfoDict["profileImg"] as! String
                    
                    
                    let imageUrl = URL(string:profilePicUrl )
                    cell.SenderProfileImgView.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "defult_pic"), options:.refreshCached)
                    cell.RecieverProfileImgView.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "defult_pic"), options:.refreshCached)
                    
                    
                    print(messgDict)
                    print(coach_id)
                    print(user_id)
                    print(recieverId)
                    print(orderId)
                    print(type)
                    
                    
                    let senderType = messgDict["type"] as! Int
                    let senderStr = String(senderType)
                    if senderType == type {
                        cell.SenderBaseView.isHidden = false
                        cell.RecieverBaseView.isHidden = true
                        cell.SenderTxtView.text =  MessageTxt
                    } else {
                        cell.SenderBaseView.isHidden = true
                        cell.RecieverBaseView.isHidden = false
                        cell.RecieverTxtView.text =  MessageTxt
                    }
                    
                    
                    
                    
                    return cell
                    //     return UITableViewCell()
                    //  }
                }else if MessageVideoType == 2 {
                    //         let cell: VideoChatCellTableViewCell! =  tableView.dequeueReusableCell(withIdentifier: "VideoChatCellTableViewCell") as? VideoChatCellTableViewCell
                    
                    
                    //       cell.thumbnailImgView.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "VideoDefaultImage"), options:.refreshCached)
                    //         cell?.centerPlayButton.addTarget(self, action: #selector(ChatVC.clickOnPlayVideoButton(sender:)), for: .touchUpInside)
                    //          cell.centerPlayButton.tag = indexPath.row - 1
                    
                    //      return cell
                    
                    
                    let cell: VideoChatCellTableViewCell! =  tableView.dequeueReusableCell(withIdentifier: "VideoChatCellTableViewCell")
                        as? VideoChatCellTableViewCell
                    
                    let DateStr = messgDict["time"] as! String
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
                    
                    
                    //                let coachDict = messgDict["coach_id"] as! NSDictionary
                    //                let UserDict = messgDict["user_id"] as! NSDictionary
                    //                let coachProfileStr = coachDict["profile_pic"] as! String
                    //                let UserProfileStr = UserDict["profile_pic"] as! String
                    //                let coachId = coachDict["_id"] as! String
                    //                let UserId = UserDict["_id"] as! String
                    //                let senderType = messgDict["type"] as! Int
                    //                let UserIdLogin = getUserId() as String
                    //                var  senderId = "'"
                    //                if senderType == 1 {
                    //                    senderId =  coachId
                    //                }else if senderType == 2 {
                    //                    senderId =  UserId
                    //                }
                    //
                    //                let profilePicUrl = getProfilePic()
                    //
                    //                let imageUrl1 = URL(string:profilePicUrl )
                    //
                    //                if UserIdLogin == senderId {
                    //                    cell.SenderBaseView.isHidden = false
                    //                    cell.SenderCoenerImgView.isHidden = false
                    //                    cell.SenderProfileImgView.isHidden = false
                    //                    cell.RecieverBaseView.isHidden = true
                    //                    cell.RecieverProfileImgView.isHidden = true
                    //                    cell.RecieverCoenerImgView.isHidden = true
                    //
                    //
                    //                    cell.SenderProfileImgView.sd_setImage(with: imageUrl1, placeholderImage: UIImage(named: "defult_pic"), options:.refreshCached)
                    //
                    //                }else {
                    //                    cell.SenderBaseView.isHidden = true
                    //                    cell.SenderCoenerImgView.isHidden = true
                    //                    cell.SenderProfileImgView.isHidden = true
                    //                    cell.RecieverBaseView.isHidden = false
                    //                    cell.RecieverProfileImgView.isHidden = false
                    //                    cell.RecieverCoenerImgView.isHidden = false
                    //
                    //                    if isCoach() {
                    //                        let imageUrl = URL(string:UserProfileStr )
                    //                        cell.RecieverProfileImgView.sd_setImage(with: imageUrl1, placeholderImage: UIImage(named: "defult_pic"), options:.refreshCached)
                    //                    }else {
                    //                        let imageUrl = URL(string:coachProfileStr )
                    //                        cell.RecieverProfileImgView.sd_setImage(with: imageUrl1, placeholderImage: UIImage(named: "defult_pic"), options:.refreshCached)
                    //                    }
                    //                }
                    //
                    
                    let userInfoDict = messgDict["userinfo"] as! NSDictionary
                    let profilePicUrl = userInfoDict["profileImg"] as! String
                    
                    
                    let imageUrl1 = URL(string:profilePicUrl )
                    cell.SenderProfileImgView.sd_setImage(with: imageUrl1, placeholderImage: UIImage(named: "defult_pic"), options:.refreshCached)
                    cell.RecieverProfileImgView.sd_setImage(with: imageUrl1, placeholderImage: UIImage(named: "defult_pic"), options:.refreshCached)
                    
                    let senderType = messgDict["type"] as! Int
                    let senderStr = String(senderType)
                    if senderType == type {
                        cell.SenderBaseView.isHidden = false
                        cell.SenderCoenerImgView.isHidden = false
                        cell.SenderProfileImgView.isHidden = false
                        cell.RecieverBaseView.isHidden = true
                        cell.RecieverProfileImgView.isHidden = true
                        cell.RecieverCoenerImgView.isHidden = true
                    } else {
                        cell.SenderBaseView.isHidden = true
                        cell.SenderCoenerImgView.isHidden = true
                        cell.SenderProfileImgView.isHidden = true
                        cell.RecieverBaseView.isHidden = false
                        cell.RecieverProfileImgView.isHidden = false
                        cell.RecieverCoenerImgView.isHidden = false
                        
                    }
 
                    return cell
                    
                }
                
                
            }
          
            
        }
       return UITableViewCell()

    }
}
extension TextChatVC : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if tableView.tag == 2 {
            return 50
        }else {
            if indexPath.row == 0{
                return UITableViewAutomaticDimension
            }
            else{
                
                
                let messagearray = chatMessages.object(at: indexPath.row - 1 ) as! NSArray
                let messgDict  = messagearray.object(at: 0) as! NSDictionary
                let MessageVideoType = messgDict["message_type"] as! Int
                if MessageVideoType == 1 {
                    let MessageTxt = messgDict["message"] as! String
                    var textView = UITextView()
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
                    
                    
                   
                }else if MessageVideoType == 2 {
                    return 250
                }
              return UITableViewAutomaticDimension
                
            }
      
}
   return UITableViewAutomaticDimension
}

}


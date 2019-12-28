//
//  MySessionsVC.swift
//  DatingAdvice
//
//  Created by daniel helled on 13/09/17.
//  Copyright © 2017 daniel helled. All rights reserved.
//

import UIKit
import STZPopupView

class MySessionsVC: UIViewController,IntriguedDelegate,UITextViewDelegate {
    func moveToScreen(index: NSInteger) {
        
    }
    func moveToAdviserController(index: NSInteger) {
        
    }
    func playAdvisorVideoBtn(index: NSInteger) {
        
    }
    func moveToUserReply(index: NSInteger) {
        
    }
    
    @IBOutlet weak var norecordLbl: UILabel!
    
    @IBOutlet weak var noRecordView: UIView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var sessionTableView: UITableView!
    var sessionArray = NSMutableArray()
    let refreshControl = UIRefreshControl()
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSLog("Launch Options Dict =")
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(MySessionsVC.receivedNotification(fromStripe:)), name: NSNotification.Name("getSessionIndex"), object: nil)
        
        noRecordView.isHidden = true
        if appDelegateDeviceId.isPushReceived == true {
            
        } else {
            NSLog("Launch Options Dict =")
            segmentControl.selectedSegmentIndex = 0
            perform(#selector(reloadMySessionApiHit), with: nil, afterDelay: 0.0)
            
        }
        self.norecordLbl.text =  "You have no pending sessions at this time."
        sessionTableView.estimatedRowHeight = 125
        sessionTableView.rowHeight = UITableViewAutomaticDimension
        segmentControl.translatesAutoresizingMaskIntoConstraints = true
        segmentControl.frame = CGRect(x: segmentControl.frame.origin.x, y: segmentControl.frame.origin.y, width: UIScreen.main.bounds.size.width-20, height: 35);
        refreshControl.addTarget(self, action: #selector(MySessionsVC.refreshList), for: .valueChanged)
        sessionTableView.refreshControl = refreshControl
        sessionTableView.addSubview(refreshControl)
        
        self.CreateReviewPopup()
        
        if isCoach() {
            self.getServiceTax(type: k_GET_COACH_SERVICE_TAX)
        }else {
            self.getServiceTax(type: k_GET_USER_SERVICE_TAX)
        }
        
        // Do any additional setup after loading the view.
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
    @objc func receivedNotification(fromStripe notification: Notification) {
        // NotificationCenter.default.removeObserver(self, name: NSNotification.Name("getSessionIndex"), object: nil)
        perform(#selector(reloadMySessionApiHit), with: nil, afterDelay: 0.0)
        
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
        
        
        let catInfoDict = self.sessionArray.object(at: sender.tag) as! NSDictionary
        print(catInfoDict)
         let InfoDict = catInfoDict["coach_id"] as! NSDictionary
        let firstName =  InfoDict["fname"] as! String
        let lastName =  InfoDict["lname"] as! String
        reviewNameLbl.text = firstName + " " + lastName
        submitButton.tag = sender.tag
        reviewPopup.isHidden = false
        
        let popupConfig = STZPopupViewConfig()
        popupConfig.dismissTouchBackground = false
        popupConfig.cornerRadius = 10
        
        presentPopupView(reviewPopup, config: popupConfig)
        
        
   //     presentPopupView(reviewPopup)
        reviewTxtView.placeholder = "Write Your Review..."
        reviewTxtView.text = ""
        likeBtn.isSelected =  true
        dislikeButton.isSelected =  false
        
        if let reviewInfo = catInfoDict["review"] as? NSDictionary {
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
          
            
            
            let catInfoDict = self.sessionArray.object(at: sender.tag) as! NSDictionary
            print(catInfoDict)
            let InfoDict = catInfoDict["coach_id"] as! NSDictionary
            let coachId =  InfoDict["_id"] as! String
            let orderId =  catInfoDict["_id"] as! String
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
                    self.getUpdatedDetails()
                    
                    
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
        
        print(newString.length)
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
        return true
    }
   
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.applicationIconBadgeNumber = 0
        if appDelegateDeviceId.isPushReceived == true {
            if appDelegateDeviceId.notifyType == 2{
                segmentControl.selectedSegmentIndex = 1
                appDelegateDeviceId.isPushReceived = false
                getUserSessionDetails(type:"1")
                self.sessionTableView.reloadData()
            }
            else if appDelegateDeviceId.notifyType == 5{
                segmentControl.selectedSegmentIndex = 0
                appDelegateDeviceId.isPushReceived = false
                getUserSessionDetails(type:"3")
                self.sessionTableView.reloadData()
            }
            else if appDelegateDeviceId.notifyType == 4{
                segmentControl.selectedSegmentIndex = 2
                appDelegateDeviceId.isPushReceived = false
                getUserSessionDetails(type:"2")
                self.sessionTableView.reloadData()
            }
            else if appDelegateDeviceId.notifyType == 3{
                segmentControl.selectedSegmentIndex = 1
                appDelegateDeviceId.isPushReceived = false
                getUserSessionDetails(type:"1")
                self.sessionTableView.reloadData()
            }
        }
        else{
            
          
            
            if segmentControl.selectedSegmentIndex == 0 {
                segmentControl.selectedSegmentIndex = 0
                perform(#selector(reloadMySessionApiHit), with: nil, afterDelay: 0.0)
            }
            else if segmentControl.selectedSegmentIndex == 1 {
                getUserSessionDetails(type:"1")
            } else if segmentControl.selectedSegmentIndex == 2 {
                getUserSessionDetails(type:"2")
            }
            //getUserSessionDetails(type: "3")
        }
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
   
    @objc private func refreshList() {
        if segmentControl.selectedSegmentIndex == 0 {
            getUserSessionDetails(type: "3")
        }
        else if segmentControl.selectedSegmentIndex == 1 {
            getUserSessionDetails(type:"1")
        } else if segmentControl.selectedSegmentIndex == 2 {
            getUserSessionDetails(type:"2")
        }
    }
    
    
    @objc func reloadMySessionApiHit() {
         segmentControl.selectedSegmentIndex = 0
        getUserSessionDetails(type: "3")
    }
    
    
    //MARK: *********** SEGMENT CONTROL ACTION **************
    @IBAction func segementControlValueChanged(_ sender: Any) {
        sessionArray.removeAllObjects()
        if segmentControl.selectedSegmentIndex == 0 {
            self.norecordLbl.text =  "You have no pending sessions at this time."
            getUserSessionDetails(type:"3")
        }
        else if segmentControl.selectedSegmentIndex == 1 {
            self.norecordLbl.text =  "You have no accepted sessions at this time."
            getUserSessionDetails(type:"1")
        }
        else{
            self.norecordLbl.text =  "You have no completed sessions at this time."
            getUserSessionDetails(type:"2") // used 2 when need to hit complete
        }
    }
    @objc func pressButton(button: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SessionInfoVC") as! SessionInfoVC
        if let dict = sessionArray[button.tag] as? NSDictionary {
            vc.userOrderInfo = dict
        }
        self.navigationController?.pushViewController(vc,animated: true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: ***********INTRIGUED DELEGATE **************
    func getUpdatedDetails() {
        getUserSessionDetails(type:"2")
    }
    
    //MARK:- ************ Hit Api to get coach details ***************
    func getUserSessionDetails(type: String) {
        
        showProgressIndicator(refrenceView: self.view)
        noRecordView.isHidden = true
        self.sessionTableView.isHidden = false
        let request = ["user_id": getUserId(),"type":type] as [String : Any]
        sessionArray.removeAllObjects()
        
        WebServices().mainFunctiontoGetDetails(data: request as NSDictionary,serviceType:kGET_USER_REQUEST) { (responseData)  in
            stopProgressIndicator()
            self.refreshControl.endRefreshing()
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
                    
                    //self.sessionTableView.delegate = self
                    // self.sessionTableView.dataSource = self
                    self.noRecordView.isHidden = true
                    self.sessionTableView.reloadData()
                    
                }
                else{
                    DispatchQueue.main.async(execute: {
                        self.noRecordView.isHidden = false
                    })
                    self.sessionTableView.isHidden = true
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
}

extension MySessionsVC : UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sessionArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: MySessionsCell! =  tableView.dequeueReusableCell(withIdentifier: "MySessionsCell") as? MySessionsCell
        cell.selectionStyle = .none
        cell.infoButton.tag = indexPath.row
        cell.infoButton.addTarget(self, action: #selector(self.pressButton(button:)), for: .touchUpInside)
        if sessionArray.count > 0 {
            if let dict = sessionArray[indexPath.row] as? NSDictionary {
                cell.setupDataOnCell(orderDetails:dict)
            }
        }
        cell?.LeaveReviewBtn.tag = indexPath.row
        cell?.LeaveReviewBtn.addTarget(self, action: #selector(MySessionsVC.LeaveReviewBtn(sender:)), for: .touchUpInside)
        
        return cell
    }
}
extension MySessionsVC : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return 105
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if segmentControl.selectedSegmentIndex == 1 || segmentControl.selectedSegmentIndex == 2 {
           
            let catInfoDict = self.sessionArray.object(at: indexPath.row) as! NSDictionary
            print(catInfoDict)
            let type = catInfoDict["type"] as! Int
            
            if type == 1 {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "MessageController") as! MessageController
                if let dict = sessionArray[indexPath.row] as? NSDictionary {
                    vc.userQuestInfo = dict
                     vc.completeTime = dict["complete_time"] as! String
                    vc.CompleteType = segmentControl.selectedSegmentIndex
                }
                self.navigationController?.pushViewController(vc,animated: true)
            }else if type == 2 {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "MessageController") as! MessageController
                if let dict = sessionArray[indexPath.row] as? NSDictionary {
                    vc.userQuestInfo = dict
                     vc.completeTime = dict["complete_time"] as! String
                      vc.CompleteType = segmentControl.selectedSegmentIndex
                }
                self.navigationController?.pushViewController(vc,animated: true)
            } else if type == 3 {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "TextChatVC") as! TextChatVC
                if let dict = sessionArray[indexPath.row] as? NSDictionary {
                    vc.userQuestInfo = dict
                     vc.completeTime = dict["complete_time"] as! String
                      vc.CompleteType = segmentControl.selectedSegmentIndex
                }
                let catInfoDict = self.sessionArray.object(at: indexPath.row) as! NSDictionary
                vc.room_Id = catInfoDict["room_id"] as! String
                print(vc.userQuestInfo)
                self.navigationController?.pushViewController(vc,animated: true)
            }
            
           
            
//            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ChatVC") as! ChatVC
//            if let dict = sessionArray[indexPath.row] as? NSDictionary {
//                vc.userQuestInfo = dict
//            }
//            self.navigationController?.pushViewController(vc,animated: true)

          
        }
        else{
           
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "SessionInfoVC") as! SessionInfoVC
            if let dict = sessionArray[indexPath.row] as? NSDictionary {
                vc.userOrderInfo = dict
            }
            
            vc.delegate = self
            self.navigationController?.pushViewController(vc,animated: true)
            
            
//            let dateFormatter = DateFormatter()
//            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
//            //dateFormatter.timeZone = TimeZone(abbreviation: "GMT+0:00") //Current time zone
//            dateFormatter.locale = NSLocale.init(localeIdentifier: "en_US_POSIX") as Locale!
//            dateFormatter.timeZone = NSTimeZone(name: "GMT")! as TimeZone
//            let Currentdate = Date()
//            let dateString = dateFormatter.string(from: Currentdate)
//            print(dateString)
//
//            var completeTime = ""
//            if let dict = sessionArray[indexPath.row] as? NSDictionary {
//
//                completeTime = dict["complete_time"] as! String
//            }
//
//            print(completeTime)
//            completeTime = "2018-03-06T10:39:05.055Z"
//
//            let dateFormatter1 = DateFormatter()
//            dateFormatter1.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
//            dateFormatter1.locale = NSLocale.init(localeIdentifier: "en_US_POSIX") as Locale!
//            dateFormatter1.timeZone = NSTimeZone(name: "GMT")! as TimeZone
//            let CompleteDate = dateFormatter1.date(from: completeTime)
//
//            let calendar = NSCalendar.current
//            let components = calendar.dateComponents([.day], from: CompleteDate!, to: Currentdate)
//
//            print(components.day)
//            print(getUserChatClosedDays())
//            let closedChatDaystr = getUserChatClosedDays()
//            let closedChatDays = Int(closedChatDaystr) as! Int
//            let interval = components.day as! Int
//
//            if interval > closedChatDays {
//
//                let vc = self.storyboard?.instantiateViewController(withIdentifier: "SessionInfoVC") as! SessionInfoVC
//                if let dict = sessionArray[indexPath.row] as? NSDictionary {
//                    vc.userOrderInfo = dict
//                }
//
//                vc.delegate = self
//                self.navigationController?.pushViewController(vc,animated: true)
//
//            }else {
//                let catInfoDict = self.sessionArray.object(at: indexPath.row) as! NSDictionary
//                print(catInfoDict)
//                let type = catInfoDict["type"] as! Int
//
//
//                if type ==  1 {
//                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "MessageController") as! MessageController
//                    if let dict = sessionArray[indexPath.row] as? NSDictionary {
//                        vc.userQuestInfo = dict
//                        print(dict)
//                        vc.completeTime = dict["complete_time"] as! String
//                    }
//                    print( vc.userQuestInfo)
//
//                    self.navigationController?.pushViewController(vc,animated: true)
//                }else if type ==  2 {
//                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "MessageController") as! MessageController
//                    if let dict = sessionArray[indexPath.row] as? NSDictionary {
//                        vc.userQuestInfo = dict
//                        vc.completeTime = dict["complete_time"] as! String
//                    }
//                    self.navigationController?.pushViewController(vc,animated: true)
//                } else if type == 3 {
//                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "TextChatVC") as! TextChatVC
//                    if let dict = sessionArray[indexPath.row] as? NSDictionary {
//                        vc.userQuestInfo = dict
//                        vc.completeTime = dict["complete_time"] as! String
//                    }
//                    print(vc.userQuestInfo)
//                    let catInfoDict = self.sessionArray.object(at: indexPath.row) as! NSDictionary
//                    vc.room_Id = catInfoDict["room_id"] as! String
//                    self.navigationController?.pushViewController(vc,animated: true)
//                }
//            }
            
           
        }
        
    }
}


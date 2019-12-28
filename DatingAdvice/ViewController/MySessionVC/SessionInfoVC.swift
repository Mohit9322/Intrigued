//
//  SessionInfoVC.swift
//  Intrigued
//
//  Created by daniel helled on 19/09/17.
//  Copyright © 2017 daniel helled. All rights reserved.
//

import UIKit
import STZPopupView

class SessionInfoVC: UIViewController,UITextViewDelegate {
    @IBOutlet weak var sessionInfoTableView: UITableView!
    var userOrderInfo = NSDictionary()
    var coach_Info = NSDictionary()
    var order_Status = Int()
    var islikeUnlike = Int()
    var orderId = ""
    var coachId = ""
    var userId = ""
    var reviewId = ""
    var checkEdit = Bool()
    var images_Array = NSArray()
    weak var delegate: IntriguedDelegate?
    @IBOutlet weak var view_AddReview: UIView!
    @IBOutlet weak var btn_like: UIButton!
    @IBOutlet weak var btn_dislike: UIButton!
    @IBOutlet weak var reviewTextView: UITextView!
    
    
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
    
 //   var checkEdit = Bool()
  //  var reviewId = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        islikeUnlike = 1
        view_AddReview.isHidden = true
        btn_like.isSelected = true
        
        showInitialValueOnView()
        
        sessionInfoTableView.estimatedRowHeight = 50
        sessionInfoTableView.rowHeight = UITableViewAutomaticDimension
        view_AddReview.layer.borderWidth = 0.2
        view_AddReview.layer.borderColor = UIColor.lightGray.cgColor
        view_AddReview.layer.cornerRadius = 5.0
        view_AddReview.layer.shadowColor = UIColor.lightGray.cgColor
        view_AddReview.layer.shadowOffset = CGSize(width: 5.0, height: 5.0)
        view_AddReview.layer.shadowRadius = 5.0
        view_AddReview.layer.shadowOpacity = 5.0
        view_AddReview.layer.masksToBounds = false
        // Do any additional setup after loading the view.
        
        
        sessionInfoTableView.register(UINib(nibName: "UserQuestionImageCell", bundle: nil), forCellReuseIdentifier: "UserQuestionImageCell")
        print(userOrderInfo)
        if let imageArray =  userOrderInfo["images"] as? NSArray  {
            images_Array = imageArray
        }
        
       self.CreateReviewPopup()
    }
    func CreateReviewPopup()  {
        
       
        
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
        
        
       
        let InfoDict = userOrderInfo["coach_id"] as! NSDictionary
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
        likeBtn.isSelected =  true
        dislikeButton.isSelected =  false
        
        if let reviewInfo = userOrderInfo["review"] as? NSDictionary {
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
            
            
            
          
            let InfoDict = userOrderInfo["coach_id"] as! NSDictionary
            let coachId =  InfoDict["_id"] as! String
            let orderId =  userOrderInfo["_id"] as! String
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
                    self.delegate?.getUpdatedDetails()
                    
                    
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
        self.sessionInfoTableView.contentInset = UIEdgeInsetsMake(-35, 0, 0, 0);
    }
    
    func showInitialValueOnView() {
     //   reviewTextView.delegate = self
      //  reviewTextView.placeholder = "Write a review"
        
        if let coachInfo = userOrderInfo["coach_id"] as? NSDictionary {
            coach_Info = coachInfo
            coachId = coachInfo["_id"] as? String ?? ""
        }
        if let status = userOrderInfo["order_status"] as? Int {
            order_Status = status
        }
        
        if let user_id = userOrderInfo["user_id"] as? String {
            userId = user_id
        }
        orderId = userOrderInfo["_id"] as? String ?? ""
        
        if let reviewInfo = userOrderInfo["review"] as? NSDictionary {
            checkEdit = true
            reviewId = reviewInfo["_id"] as? String ?? ""
           // reviewTxtView.text = reviewInfo["review"] as? String ?? ""
            if let isLike = reviewInfo["isLike"] as? NSNumber{
                if isLike == 1 {
                    btn_like.isSelected = true
                    btn_dislike.isSelected = false
                }
                else{
                    btn_like.isSelected = false
                    btn_dislike.isSelected = true
                }
            }
            
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        if let placeholderLabel = textView.viewWithTag(100) as? UILabel {
            placeholderLabel.isHidden = textView.text.characters.count > 0
        }
    }
    //MARK:- **************** UIBUTTON ACTION **************
    @IBAction func backButtonAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @objc func clickOnRatingButton(sender:UIButton) {
       // showAnimate()
        let InfoDict = userOrderInfo["coach_id"] as! NSDictionary
        let firstName =  InfoDict["fname"] as! String
        let lastName =  InfoDict["lname"] as! String
        reviewNameLbl.text = firstName + " " + lastName
        submitButton.tag = sender.tag
        reviewPopup.isHidden = false
        
        let popupConfig = STZPopupViewConfig()
        popupConfig.dismissTouchBackground = false
        popupConfig.cornerRadius = 10
        
        presentPopupView(reviewPopup, config: popupConfig)
        
       // presentPopupView(reviewPopup)
        reviewTxtView.placeholder = "Write Your Review..."
        reviewTxtView.text = ""
        likeBtn.isSelected =  true
        dislikeButton.isSelected =  false
        
        if let reviewInfo = userOrderInfo["review"] as? NSDictionary {
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
    
    @IBAction func likeButtonAction(_ sender: UIButton) {
        if sender.isSelected {
            return
        }
        else{
            sender.isSelected = true
            islikeUnlike = 1
            btn_dislike.isSelected = false
        }
    }
    @IBAction func dislikeButtonAction(_ sender: UIButton) {
        if sender.isSelected {
            return
        }
        else{
            sender.isSelected = true
            islikeUnlike = 2
            btn_like.isSelected = false
        }
    }
    @IBAction func submitButtonAction(_ sender: Any) {
        
//        if checkEdit {
//            let request = ["review_id":reviewId, "isLike": islikeUnlike, "review":reviewTextView.text] as [String : Any]
//            add_EditReviewToCoach(request: request as NSDictionary, requestType: kEDIT_REVIEW)
//        }
//        else{
//            let request = ["user_id":userId, "coach_id": coachId,  "order_id":orderId, "isLike": islikeUnlike,"review":reviewTextView.text] as [String : Any]
//            add_EditReviewToCoach(request: request as NSDictionary, requestType: kADD_REVIEW)
//        }
        
    }
    @IBAction func closeButtonAction(_ sender: Any) {
      //  removeAnimate()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- **************** SHOW & HIDE View with Animation **************
//    func showAnimate()
//    {
//
//        view_AddReview.isHidden = false
//        self.view_AddReview.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
//        self.view_AddReview.alpha = 0.0
//        UIView.animate(withDuration: 0.25, animations: {
//            self.view_AddReview.alpha = 1.0
//            self.view_AddReview.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
//        })
//    }
//
//
//    func removeAnimate()
//    {
//        UIView.animate(withDuration: 0.25, animations: {
//            self.view_AddReview.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
//            self.view_AddReview.alpha = 0.0
//        }, completion: {(finished : Bool) in
//            if(finished)
//            {
//                self.view_AddReview.isHidden = true
//
//            }
//        })
//    }
    
//    //MARK:- **************** Add & Edit review **************
//    func add_EditReviewToCoach(request:NSDictionary , requestType : String) {
//        showProgressIndicator(refrenceView: self.view)
//
//        WebServices().mainFunctiontoGetDetails(data: request as NSDictionary,serviceType:requestType) { (responseData)  in
//            stopProgressIndicator()
//            if responseData != nil
//            {
//                let code = responseData?["code"] as? NSNumber
//                print("responseData",responseData ?? "")
//                if code == 200{
//                    stopProgressIndicator()
//                    ///// update dict /////////
//                    //                    if let reviewInfo = self.userOrderInfo["review"] as? NSDictionary {
//                    //                        var dict = [String: Any]()
//                    //                        dict["_id"] = self.reviewId
//                    //                        dict["review"] = self.reviewTextView.text ?? ""
//                    //                        dict["isLike"] = self.islikeUnlike
//                    //                    }
//                    ///////////////////////////
//                    if let message = responseData?["result"] as? String {
//                        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: UIAlertControllerStyle.alert)
//                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
//                            self.navigationController?.popViewController(animated: true)
//                        }))
//                        self.present(alert, animated: true, completion: nil)
//                        //notifyUser("", message: message , vc: self)
//                    }
//                    self.reviewTextView.text = nil
//              //      self.removeAnimate()
//                    self.delegate?.getUpdatedDetails()
//
//
//                }
//                else {
//
//                    if let message = responseData?["result"] as? String {
//                        notifyUser("", message: message , vc: self)
//                    }
//                    else{
//                        // notifyUser("", message: "Something went wrong", vc: self)
//                    }
//                }
//            }
//            else{ stopProgressIndicator()}
//
//        }
//    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
extension SessionInfoVC: UITableViewDataSource {
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if images_Array.count > 0 {
            return 5
        }
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            if order_Status == 3 {
                let cell: SessionInfoCell! =  tableView.dequeueReusableCell(withIdentifier: "SessionInfoCell") as? SessionInfoCell
                cell.selectionStyle = .none
                cell.showDetailsonView(orderDetails: userOrderInfo)
                cell?.btn_Addreview.tag = indexPath.row
                cell?.btn_Addreview.addTarget(self, action: #selector(SessionInfoVC.clickOnRatingButton(sender:)), for: .touchUpInside)
                if checkEdit {
                    cell.btn_Addreview.setTitle("Edit a review", for: .normal)
                }
                else{
                    cell.btn_Addreview.setTitle("Write a review", for: .normal)
                }
                
                return cell
            }
            else{
                let cell: PendingSessionInfoCell! =  tableView.dequeueReusableCell(withIdentifier: "PendingSessionInfoCell") as? PendingSessionInfoCell
                cell.selectionStyle = .none
                cell.showDetailsonView(orderDetails: userOrderInfo)
                cell.selectionStyle = .none
                return cell
            }
        }
        else if indexPath.section == 4 {
            let cell: UserQuestionImageCell! =  tableView.dequeueReusableCell(withIdentifier: "UserQuestionImageCell") as? UserQuestionImageCell
            cell.selectionStyle = .none
            cell.setupDetailsonView(imageArray:images_Array)
            cell.selectionStyle = .none
            return cell
        }
        else  {
            let cell: AboutAdvisorCell! =  tableView.dequeueReusableCell(withIdentifier: "AboutAdvisorCell") as? AboutAdvisorCell
            
            if indexPath.section == 1{
                cell.lbl_aboutAdvisor.text = coach_Info["about"] as? String ?? ""
            }
//            else if indexPath.section == 2 {
//                cell.lbl_aboutAdvisor.text =  coach_Info["about_services"] as? String ?? ""
//            }
            else if indexPath.section == 2 {
                cell.lbl_aboutAdvisor.text =  userOrderInfo["title"] as? String ?? ""
            }
            else if indexPath.section == 3 {
                cell.lbl_aboutAdvisor.text =  userOrderInfo["question"] as? String ?? ""
            }

            cell.selectionStyle = .none
            return cell
        }
        
    }
}

extension SessionInfoVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0{
            if order_Status == 3 {
                return 260
            }
            else {
                return 170
            }
        }
        else  {
            return UITableViewAutomaticDimension
        }
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 40))
        let header_lbl = UILabel(frame: CGRect(x: 10, y: 0, width: 200, height: 40))
        if section == 1{
            header_lbl.text = "About Me"
        }
//        else if section == 2{
//            header_lbl.text = "About My Services"
//        }
        
        else if section == 2{
            header_lbl.text = "Description"
        }
        else if section == 3{
            header_lbl.text = "My Question"
        } else if section == 4 {
                    header_lbl.text = "Uploaded Imgaes"
                }
        header_lbl.font = UIFont(name: "OpenSans-Bold", size: 17.0)
        headerView.addSubview(header_lbl)
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 10))
        headerView.backgroundColor = UIColor.white
        return headerView
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat{
        if section == 0 {
            return 0
        }
        return 40
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
}

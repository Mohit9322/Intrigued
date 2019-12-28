//
//  AdvisorDetailsVC.swift
//  Intrigued
//
//  Created by daniel helled on 18/09/17.
//  Copyright © 2017 daniel helled. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer
import AVKit

class AdvisorDetailsVC: UIViewController,UIGestureRecognizerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    @IBOutlet weak var lbl_titleName: UILabel!
    @IBOutlet weak var advisorTableView: UITableView!
    var advisorDetails = NSDictionary()
    var pricingArray = NSMutableArray()
    var directStatus = "0"
    var rush_directStatus = "0"
    var livechatStatus = "0"
    var reviewsArray = NSArray()
    var review_Count = 0
    var CoachAvg_response = "0"
    var CoachTimely_response = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        advisorTableView.estimatedRowHeight = 35
        advisorTableView.rowHeight = UITableViewAutomaticDimension
        print(advisorDetails)
        
        let userName = (advisorDetails["fname"] as? String ?? "")  + " " + (advisorDetails["lname"] as? String ?? "")
        lbl_titleName.text = userName
        print(advisorDetails)
        if let direct_Status = advisorDetails["direct_Status"] as? Int {
            
            directStatus = String(describing: direct_Status)
            if direct_Status == 1{
                pricingArray.add(0)
            }
        }
        
        if let rush_direct_Status = advisorDetails["rush_direct_Status"] as? Int {
            if rush_direct_Status == 1{
                pricingArray.add(1)
            }
            rush_directStatus =  String(describing: rush_direct_Status)
        }
        
        if let livechat_Status = advisorDetails["livechat_Status"] as? Int {
            if livechat_Status == 1{
                pricingArray.add(2)
            }
            livechatStatus =  String(describing: livechat_Status)
        }
        
        if let reviewInfo = advisorDetails["reviews"] as? NSArray {
            reviewsArray = reviewInfo
        }
        if let reviewCount = advisorDetails["reviews_count"] as? NSNumber {
            self.review_Count = reviewCount as? Int ?? 0
        }
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        print(pricingArray)
        advisorTableView.register(UINib(nibName: "CoachesCategoryCell", bundle: nil), forCellReuseIdentifier: "CoachesCategoryCell")
        advisorTableView.register(UINib(nibName: "AdvisorProfileDetailTableCell", bundle: nil), forCellReuseIdentifier: "AdvisorProfileDetailTableCell")
        
        self.CoachResponsTimeApi()
        
        // Do any additional setup after loading the view.
    }
    func CoachResponsTimeApi() {
        
        let CoachId = advisorDetails["_id"] as? String ?? ""
        
        showProgressIndicator(refrenceView: self.view)
        let requestDict = ["coach_id":CoachId] as NSDictionary
        print(requestDict)
        print(getSessionId())
        print(getUserId())
        WebServices().mainFunctiontoGetDetails(data: requestDict,serviceType:k_USER_RESPONSETIME) { (responseData)  in
            stopProgressIndicator()
            if responseData != nil
            {
                let code = responseData?["code"] as? NSNumber
                print("responseData",responseData ?? "")
                if code == 200{
                   
                    self.CoachAvg_response =  String(describing: responseData?["avg_response"] as! NSNumber)
                    self.CoachTimely_response =  String(describing: responseData?["timely_response"] as! NSNumber)
                    print(self.CoachTimely_response,self.CoachTimely_response)
                    self.advisorTableView.reloadData()
                }else if code == 100 {
                    if let message = responseData?["result"] as? String {
                        notifyUser("", message: message , vc: self)
                    }
                }
            }else{
                stopProgressIndicator()
            }
        }
    }
    
    

    override func viewWillAppear(_ animated: Bool) {
        self.advisorTableView.contentInset = UIEdgeInsetsMake(-35, 0, 0, 0);
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @objc func clickOnOrderButton(_ sender: UIButton){
        
        
        var commType = ""
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "UserSendMessageVc") as! UserSendMessageVc
        
        
        if sender.tag == 0{
            if directStatus == "1"{
                commType = "1"
            }
            
        }else if sender.tag == 1{
            if rush_directStatus == "1"{
                commType = "2"
            }
        }else if  sender.tag == 2{
            if livechatStatus == "1"{
                commType = "3"
            }
        }
        vc.communicationType = commType
        vc.advisor_Details = advisorDetails
        self.navigationController?.pushViewController(vc,animated: true)
    }
    @objc func viewAllButtonAction(){
        if self.review_Count == 0 {
            
        }else{
            let ReviewVc = self.storyboard?.instantiateViewController(withIdentifier: "ReviewsListVC") as! ReviewsListVC
            ReviewVc.advisor_Details = advisorDetails
            //ReviewVc.reviewsArray = reviewsArray
            self.navigationController?.pushViewController(ReviewVc, animated: true)
            //pushView(viewController: self, identifier: "ReviewsListVC")
        }
    }
    @objc func didTapLabelDemo(sender: UITapGestureRecognizer)
    {
        print("you tapped label \(sender)")
        let videoUrl  = advisorDetails["coach_video"] as? String
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
    @objc func playVideo(_ sender: UIButton){
        print("you tapped label \(sender)")
        let videoUrl  = advisorDetails["coach_video"] as? String
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

extension AdvisorDetailsVC: UITableViewDataSource {
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 2 {
            return pricingArray.count
        }
        else if section == 4 {
            return reviewsArray.count
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            let cell: AdvisorProfileDetailTableCell! =  tableView.dequeueReusableCell(withIdentifier: "AdvisorProfileDetailTableCell") as? AdvisorProfileDetailTableCell
            let text = advisorDetails["about"] as! String
            var textView = UITextView()
            
            textView.text =  text
            let fixedWidth = self.view.frame.size.width - 25
            textView.font = UIFont.systemFont(ofSize: 14)
            textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
            let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
            var newFrame = textView.frame
            newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
            var txtFldWidth = newSize.width
            var cellHeight  = newSize.height
            if cellHeight < 70 {
                cellHeight =  310
            }else {
             cellHeight =   cellHeight + 310 - 35
            }
            cell.frame = CGRect(x:0, y:0 , width:self.view.frame.size.width , height:cellHeight)
            cell.contentView.frame = CGRect(x:0, y:0 , width:self.view.frame.size.width , height:cellHeight)
           cell.bottomDetailBaseView.frame =  CGRect(x:0, y: cell.coachProfileImgView.frame.size.height, width: self.view.frame.size.width, height:cellHeight - cell.coachProfileImgView.frame.size.height)
            cell.coachDesc.frame =  CGRect(x:10, y: cell.RatingBaseView.frame.size.height + cell.RatingBaseView.frame.origin.y, width: self.view.frame.size.width - 25, height:cell.bottomDetailBaseView.frame.size.height - (cell.RatingBaseView.frame.size.height + cell.RatingBaseView.frame.origin.y  ))
          
            print(advisorDetails)
            //                let cell: ProfileDetailsCell! =  tableView.dequeueReusableCell(withIdentifier: "ProfileDetailsCell") as? ProfileDetailsCell
            cell.selectionStyle = .none
            //       let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            //           target: self, action: #selector(didTapLabelDemo))
            //                tap.delegate = self
            //  cell.thumbnailImgView.addGestureRecognizer(tap)
            cell.centerPlayButton.addTarget(self, action:#selector(playVideo(_:)), for: .touchUpInside)
            cell.setupDetailsonView(coachesDetails: advisorDetails)
     cell.coachDesc.font  =  UIFont.systemFont(ofSize: 14)
//            cell.backgroundColor = UIColor.red
//            cell.bottomDetailBaseView.backgroundColor = UIColor.green
//            cell.coachDesc.backgroundColor = UIColor.yellow
            return cell
        }
        else if indexPath.section == 1 {
            let cell: ExpertiseCell! = tableView.dequeueReusableCell(withIdentifier: "ExpertiseCell") as? ExpertiseCell
      //      cell.setupDetailsonView(coachesDetails: advisorDetails)
            
         //   CoachAvg_response = "0.0192"
           let coachAvgResponseValue =  Double(CoachAvg_response)
           
            if coachAvgResponseValue! < 1.00 {
                CoachAvg_response =  "1"
            }
            cell.lbl_avgResponse.text = CoachAvg_response + " " +  "hours"
            cell.lbl_timelyResponse.text = CoachTimely_response + "%"
           
            
            cell?.selectionStyle = .none
            
            
            return cell!
        }
            
        else if indexPath.section == 2 {
            let cell: CommunicationPlansCell! =  tableView.dequeueReusableCell(withIdentifier: "CommunicationPlansCell") as? CommunicationPlansCell
            cell.selectionStyle = .none
            cell.lbl_plan.font = UIFont(name: "OpenSans-Semibold", size: 14.0)
            let index = pricingArray[indexPath.row] as? Int
            cell.lbl_planInfo.lineBreakMode = .byWordWrapping
            cell.lbl_planInfo.numberOfLines = 2
            if index == 0{
                cell.lbl_plan.text = "Direct Message"
                cell.lbl_planInfo.text = "Response Delivered within 24 hours"
                cell.planImage.image = UIImage.init(named: "mail_icon")
                
            }
            else if index == 1 {
                cell.lbl_plan.text = "Rush Direct Message"
                cell.lbl_plan.font = UIFont(name: "OpenSans-SemiboldItalic", size: 14.0)
                cell.lbl_plan.textColor = UIColor.lightGreen
                cell.lbl_planInfo.text =  "Response Delivered within 60 mins"
                cell.planImage.image = UIImage.init(named: "rush_mail_icon")
            }
            else{
                cell.lbl_plan.text = "Live Chat"
                cell.lbl_planInfo.text = "Live Messaging"
                let livechatStatus = advisorDetails["livechat_Status"] as! Bool
                if livechatStatus  {
                    cell.planImage.image = UIImage.init(named: "live_chat_icon")
                }else {
                    cell.planImage.image = UIImage.init(named: "live_chat_icon")
                }
                
            }
            
            cell.setUpData(coachesDetails: advisorDetails,index:index!)
            cell.orderButton.tag = indexPath.row
            //                cell.orderButton.addTarget(self, action: #selector(clickOnOrderButton), for: .touchUpInside)
            cell.orderButton.addTarget(self, action:#selector(clickOnOrderButton(_:)), for: .touchUpInside)
            
            //}
            
            return cell
        }
            //            else if indexPath.section == 3 {
            //                let cell: AboutAdvisorCell! =  tableView.dequeueReusableCell(withIdentifier: "AboutAdvisorCell") as? AboutAdvisorCell
            //                cell.lbl_aboutAdvisor.text = advisorDetails["about"] as? String
            //                return cell
            //            }
            //            else if indexPath.section == 4 {
            //                let cell: AboutAdvisorCell! =  tableView.dequeueReusableCell(withIdentifier: "AboutAdvisorCell") as? AboutAdvisorCell
            //                cell.lbl_aboutAdvisor.text = advisorDetails["about_services"] as? String
            //                return cell
            //            }
        else if indexPath.section == 3 {
            
            let cell: CoachesCategoryCell! =  tableView.dequeueReusableCell(withIdentifier: "CoachesCategoryCell") as? CoachesCategoryCell
            cell.selectionStyle = .none
            if let categoryArray =  advisorDetails["categories"] as? NSArray {
                cell.updateCategoryDetails(catArray: categoryArray, isEdit: false)
            }
            return cell
        }
        else{
            let cell: ReviewsDetailsCell! =  tableView.dequeueReusableCell(withIdentifier: "ReviewsDetailsCell") as? ReviewsDetailsCell
            if let reviewDict = reviewsArray[indexPath.row] as? NSDictionary{
                cell.showDetailsonView(reviewDetails:reviewDict)
            }
            let userName = (advisorDetails["fname"] as? String ?? "") + " " + (advisorDetails["lname"] as? String ?? "")
            //let userName = (advisorDetails["fname"] as? String ?? "")
            cell.lbl_userName.text = userName
            return cell
        }
    }
}

extension AdvisorDetailsVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0{
            
            let text = advisorDetails["about"] as! String
            var textView = UITextView()
            
            textView.text =  text
            let fixedWidth = self.view.frame.size.width - 25
            textView.font = UIFont.systemFont(ofSize: 14)
            textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
            let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
            var newFrame = textView.frame
            newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
            var txtFldWidth = newSize.width
            var txtFldHeight  = newSize.height
            if txtFldHeight < 70 {
                return 310
            }
            return txtFldHeight + 310 - 35
        }
        else if indexPath.section == 1{
            return 115
        }
        else if indexPath.section == 2{
            return 60
            
        }
        else if indexPath.section == 3{
            return 100
        }
        else  {
            return UITableViewAutomaticDimension
        }
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 40))
        let header_lbl = UILabel(frame: CGRect(x: 10, y: 0, width: 200, height: 40))
        if section == 1{
            header_lbl.text = "Response Time"
        }
        else if section == 2{
            header_lbl.text = "Plans"
        }
            //            else if section == 3{
            //                header_lbl.text = "About Me"
            //            }
            //            else if section == 4{
            //                header_lbl.text = "About My Services"
            //            }
        else if section == 3{
            header_lbl.text = "Expertise"
        }
        else if section == 4{
            let cell: ViewAllReviewHeaderCell! =  tableView.dequeueReusableCell(withIdentifier: "ViewAllReviewHeaderCell") as? ViewAllReviewHeaderCell
            //cell.lbl_reviewCount.text = "(" + review_Count + ") " + "Reviews"
            cell.btn_viewAll.isHidden = true
            cell.lbl_reviewCount.text  = "(\(review_Count ?? 0))" + "Reviews"
            
            if review_Count == 0 {
                cell.btn_viewAll.isHidden = true
            }
            else {
                cell.btn_viewAll.isHidden = false
                cell.btn_viewAll.addTarget(self, action: #selector(viewAllButtonAction), for: .touchUpInside)
            }
            return cell.contentView
        }
        header_lbl.font = UIFont(name: "OpenSans-Bold", size: 18.0)
        headerView.addSubview(header_lbl)
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat{
        if section == 0{
            return 0
        }
        return 40
    }
    
}




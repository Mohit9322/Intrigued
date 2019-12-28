//
//  CoachesVC.swift
//  DatingAdvice
//
//  Created by daniel helled on 13/09/17.
//  Copyright © 2017 daniel helled. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer
import AVKit

class CoachesVC: UIViewController,IntriguedDelegate {
    func getUpdatedDetails() {
        
    }
    
    
    @IBOutlet weak var coachesTableView: UITableView!
    @IBOutlet weak var search_txtField: UITextField!
    @IBOutlet weak var searchBg_view: UIView!
    
    @IBOutlet weak var btn_search: UIButton!
    var coachListArray = NSMutableArray()
    var notifyType:Int?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBg_view.layer.cornerRadius = 5.0
        searchBg_view.clipsToBounds = true
        search_txtField.delegate = self
        self.coachesTableView.contentInset = UIEdgeInsetsMake(-20, 0, 0, 0);
        
        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
          //getCoachDetails()
        if appDelegateDeviceId.isPushReceived == true {
            
            self.perform(#selector(handlePushLaunch), with: nil, afterDelay: 1.0)
        } else{
            getCoachDetails()
        }
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.view.endEditing(false)
    }
    @IBAction func filterButtonAction(_ sender: Any) {
        showActionSheet()
    }
    
    @IBAction func searchButtonAction(_ sender: Any) {
    }
    
    @objc func clickOnFooterButton() {
        pushView_ToFilterAdvisor(viewController: self, identifier: "AllAdvisorsVC", type: "3", filter: false)
    }
    
    @objc func pressButton(button: UIButton) {
        pushView(viewController: self, identifier: "AdvisorDetailsVC")
    }
    
    @objc func clickOnOrderButton(sender:UIButton) {
        //   movetoAddOrder(advisorIndex:sender.tag)
        moveToAdviserController(index: sender.tag)
    }
    
    func movetoAddOrder(advisorIndex:Int){
        var directStatus = Int()
        var rushdirectStatus = Int()
        var liveChatStatus = Int()
        var commType = ""
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "UserSendMessageVc") as! UserSendMessageVc
        if let dict = coachListArray[advisorIndex] as? NSDictionary {
            vc.coachId = dict["_id"] as? String ?? ""
            
            if let direct_Status = dict["direct_Status"] as? Int {
                directStatus =  direct_Status
            }
            
            if let rush_direct_Status = dict["rush_direct_Status"] as? Int {
                rushdirectStatus =  rush_direct_Status
            }
            
            if let livechat_Status = dict["livechat_Status"] as? Int {
                liveChatStatus = livechat_Status
            }
            
            if directStatus == 1{
                commType = "1"
            }
            else if rushdirectStatus == 1{
                commType = "2"
            }
            else if liveChatStatus == 1{
                commType = "3"
            }
            vc.communicationType = commType
            //   vc.advisor_Details = dict
        }
        self.navigationController?.pushViewController(vc,animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- *************** SHOW ACTION SHEET & METHODS ******************
    func showActionSheet(){
        let actionSheetController = UIAlertController(title: nil, message: "Select a filter", preferredStyle: .actionSheet)
        actionSheetController.view.tintColor = UIColor.headerBlue
        
        //        let hourDeliveryActionButton = UIAlertAction(title: "1-Hour Delivery", style: .default) { action -> Void in
        //            pushView_ToFilterAdvisor(viewController: self, identifier: "AllAdvisorsVC", type: "4", advisorListsArray:self.coachListArray, filter: true)
        //        }
        let directMsgActionButton = UIAlertAction(title: "Direct Message", style: .default) { action -> Void in
            pushView_ToFilterAdvisor(viewController: self, identifier: "AllAdvisorsVC", type: "1", filter: true)
        }
        let rushDirectMsgActionButton = UIAlertAction(title: "Rush Direct Message", style: .default) { action -> Void in
            pushView_ToFilterAdvisor(viewController: self, identifier: "AllAdvisorsVC", type: "2", filter: true)
        }
        //        let livechatActionButton = UIAlertAction(title: "Live Chat", style: .default) { action -> Void in
        //            pushView_ToFilterAdvisor(viewController: self, identifier: "AllAdvisorsVC", type: "3", advisorListsArray:self.coachListArray, filter: true)
        //        }
        let cancelActionButton = UIAlertAction(title: "All Advisors", style: .cancel) { action -> Void in
            pushView_ToFilterAdvisor(viewController: self, identifier: "AllAdvisorsVC", type: "3", filter: false)
        }
        cancelActionButton.setValue(UIColor.red, forKey: "titleTextColor")
        //  actionSheetController.addAction(hourDeliveryActionButton)
        actionSheetController.addAction(directMsgActionButton)
        actionSheetController.addAction(rushDirectMsgActionButton)
        // actionSheetController.addAction(livechatActionButton)
        actionSheetController.addAction(cancelActionButton)
        self.present(actionSheetController, animated: true, completion: nil)
    }
    
    //MARK:- ************ Navigate Delegate ***************
    func moveToScreen(index: NSInteger){
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AdvisorDetailsVC") as! AdvisorDetailsVC
        if let dict = coachListArray[index] as? NSDictionary {
            vc.advisorDetails = dict
        }
        self.navigationController?.pushViewController(vc,animated: true)
    }
    
    func moveToUserReply(index: NSInteger) {
        movetoAddOrder(advisorIndex:index)
        
    }
    func moveToAdviserController(index: NSInteger) {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AdvisorDetailsVC") as! AdvisorDetailsVC
        if let dict = coachListArray[index] as? NSDictionary {
            vc.advisorDetails = dict
        }
        
        self.navigationController?.pushViewController(vc,animated: true)
    }
    
    func playAdvisorVideoBtn(index: NSInteger) {
        
        
        let messageDict = coachListArray[index] as? NSDictionary
        print("Url Fetched")
        let videoUrl  = messageDict!["coach_video"] as? String
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
    //MARK:- ************ Hit Api to get coach details ***************
    
    func getCoachDetails() {
        
        showProgressIndicator(refrenceView: self.view)
        let request = ["user_id": getUserId()] as [String : Any]
        
        print(request)
        WebServices().mainFunctiontoGetDetails(data: request as NSDictionary,serviceType:kGET_Coach_User_LISTING) { (responseData)  in
            stopProgressIndicator()
            if responseData != nil
            {
                let code = responseData?["code"] as? NSNumber
                print("responseData",responseData ?? "")
                if code == 200{
                    stopProgressIndicator()
                    guard let resultArray = responseData?["result"] as? NSArray else {
                        return
                    }
                    self.coachListArray = resultArray.mutableCopy() as! NSMutableArray
                    self.coachesTableView.delegate = self
                    self.coachesTableView.dataSource = self
                    self.coachesTableView.reloadData()
                    
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
    
    
    
    
    
    
    //when app launched through push first time
    @objc func handlePushLaunch()
    {
        
        if appDelegateDeviceId.isPushReceived == true {
            //let notifDict = appDelegateDeviceId.notifDict
            NSLog("-------------appDelegateDeviceId.tabbarVC ")
            //            if let params = notifDict?["param1"] as? [String:Any] {
            //                if let type = params["type"] as? Int {
            //                    self.notifyType = type
            //                }
            //            }
            if appDelegateDeviceId.tabbarVC == nil
            {
                NSLog("RAvi----appDelegateDeviceId.tabbarVC ")
                return
            }
            if appDelegateDeviceId.notifyType == 2 {
                NSLog("RAvi----got push type 2")
                appDelegateDeviceId.tabbarVC?.selectedIndex = 1
                _ = appDelegateDeviceId.tabbarVC?.viewControllers?[1] as? UINavigationController
            }
            else if appDelegateDeviceId.notifyType == 5 {
                NSLog("Launch Options Dict ")
                appDelegateDeviceId.tabbarVC?.selectedIndex = 1
                _ = appDelegateDeviceId.tabbarVC?.viewControllers?[1] as? UINavigationController
            }
            else if appDelegateDeviceId.notifyType == 4 {
                appDelegateDeviceId.tabbarVC?.selectedIndex = 1
                _ = appDelegateDeviceId.tabbarVC?.viewControllers?[1] as? UINavigationController
            }
            else if appDelegateDeviceId.notifyType == 3 {
                appDelegateDeviceId.tabbarVC?.selectedIndex = 1
                _ = appDelegateDeviceId.tabbarVC?.viewControllers?[1] as? UINavigationController
            }
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

extension CoachesVC : UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        else if section == 1 {
            return 1
        }
        if coachListArray.count > 1 {
             return 2
        }else {
           return 1
        }
       
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 2{
            let cell: HighestRatedCell! =  tableView.dequeueReusableCell(withIdentifier: "HighestRatedCell") as? HighestRatedCell
            cell.selectionStyle = .none
            if let dict = coachListArray[indexPath.row] as? NSDictionary {
                cell.setUpData(coachesDetails: dict)
            }
            cell?.orderButton.tag = indexPath.row
            cell?.orderButton.addTarget(self, action: #selector(AdvisorCollectionView.clickOnOrderButton(sender:)), for: .touchUpInside)
            
            return cell
        }else{
            let cell: RecommendedCell! =  tableView.dequeueReusableCell(withIdentifier: "RecommendedCell") as? RecommendedCell
            cell.selectionStyle = .none
            cell.setUpData(coachesArray: coachListArray)
            cell.advisor_collectionView.delegate = self
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 50))
        let header_lbl = UILabel(frame: CGRect(x: 15, y: 0, width: 200, height: 50))
        if section == 0{
            header_lbl.text = "Recommended"
        }
        else if section == 1{
            header_lbl.text = "Trending"
        }
        else if section == 2{
            header_lbl.text = "Highest Rated"
        }
        header_lbl.font = UIFont.boldSystemFont(ofSize: 18)
        headerView.addSubview(header_lbl)
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
}


extension CoachesVC : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        if indexPath.section == 2{
            return 110
        }
        else{
            return 345
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat{
        return 50
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 2 {
            return 50
        }
        else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 50))
        let footer_button = UIButton(frame: CGRect(x: 15, y: 0, width: 200, height: 50))
        
        if section == 2 {
            footer_button.setTitle("View All", for: .normal)
            footer_button.setTitleColor(UIColor.black, for: .normal)
            footer_button.addTarget(self, action: #selector(clickOnFooterButton), for: .touchUpInside)
            footer_button.titleLabel?.font = UIFont(name: "OpenSans-Bold", size: 16.0)!
        }
        
        footer_button.center = headerView.center
        headerView.addSubview(footer_button)
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AdvisorDetailsVC") as! AdvisorDetailsVC
        if let dict = coachListArray[indexPath.row] as? NSDictionary {
            vc.advisorDetails = dict
        }
        
        self.navigationController?.pushViewController(vc,animated: true)
    }
}
extension CoachesVC : UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        pushView_ToFilterAdvisor(viewController: self, identifier: "AllAdvisorsVC", type: "3", filter: false)
    }
}


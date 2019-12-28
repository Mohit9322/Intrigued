 //
 //  CoachesProfileVC.swift
 //  Intrigued
 //
 //  Created by daniel helled on 06/10/17.
 //  Copyright © 2017 daniel helled. All rights reserved.
 //
 
 import UIKit
 import AVFoundation
 import MediaPlayer
 import AVKit
 
 class CoachesProfileVC: UIViewController {
    @IBOutlet weak var profileTableView: UITableView!
    
    var stripe_connected  = false
    var stripe_Detailsdic = NSDictionary()
    var isStripeUpdated = false
    
    @IBOutlet weak var stripe_lbl: UILabel!
    @IBOutlet weak var stripe_btn: UIButton!
    @IBOutlet weak var StripeConnectHeight: NSLayoutConstraint!
    
    var pricingArray = NSMutableArray()
    var Stripe_Profile_Dict = [String:Any]()
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCellNib()
        setupStripeStatus()
        self.profileTableView.contentInset = UIEdgeInsetsMake(-35, 0, 0, 0);
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        pricingArray.removeAllObjects()
        if getDirect_Status() == 1 {
            pricingArray.add(0)
        }
        if getRushDirect_Status() == 1 {
            pricingArray.add(1)
        }
        if getlivechat_Status() == 1 {
            pricingArray.add(2)
        }
        profileTableView.reloadData()
        setupStripeStatus()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func registerCellNib(){
        
        profileTableView.register(UINib(nibName: "CoachesCategoryCell", bundle: nil), forCellReuseIdentifier: "CoachesCategoryCell")
        profileTableView.register(UINib(nibName: "CoachesPricingCell", bundle: nil), forCellReuseIdentifier: "CoachesPricingCell")
        profileTableView.register(UINib(nibName: "CoachesAddAboutCell", bundle: nil), forCellReuseIdentifier: "CoachesAddAboutCell")
        profileTableView.register(UINib(nibName: "AddUserAddressCell", bundle: nil), forCellReuseIdentifier: "AddUserAddressCell")
        profileTableView.register(UINib(nibName: "EditIntroVideo", bundle: nil), forCellReuseIdentifier: "EditIntroVideo")
    }
    
    @IBAction func editCoachesProfileAction(_ sender: Any) {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "EditUserProfileVC") as? EditUserProfileVC
        vc?.isfromCoach = true
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    func setupStripeStatus(){
        //get status from service_provider and then setup here
        
        let userDetail = getUserDetails()
        
        //checking for approved profile //ravi 01Feb2018
        guard let profile  = userDetail["stripe_connect"] as? NSDictionary  else {return }
        let stripe_deauthorized = userDetail["stripe_deauthorized"] as? Bool
        let stripe_user_id = profile["stripe_user_id"] as? String
        
        if stripe_deauthorized == false && stripe_user_id != nil && stripe_user_id != "" {
            stripe_connected = true
        }else{
            stripe_connected = false
        }
        if stripe_user_id != nil && stripe_user_id != "" {
            UserDefaults.standard.set(stripe_user_id, forKey: "StripeConnectId") //save it
        }
        setupStripeLabel()
    }
    
    
    
    
    //MARK: *************** SetUp Stripe connect *********************
    //    func setupStripeStatus(){
    //
    //        let stripe_UserId = getUserStripe_CustomerId()
    //        print(stripe_UserId)
    //        if getUserStripe_CustomerId() != "" {
    //            //let stripe_deauthorized = profile["stripe_deauthorized"] as? String
    //            //let stripe_user_id = profile["stripe_user_id"] as? String
    //            stripe_connected = true
    //            UserDefaults.standard.set(getUserStripe_CustomerId(), forKey: "StripeConnectId") //save it
    //        } else{
    //            stripe_connected = false
    //        }
    //        setupStripeLabel()
    //    }
    
    
    
    
    func updateStripeStatus(){
        //update status to service_provider
        setupStripeLabel()
        
        isStripeUpdated = true
        //update service_provider deteils too
        if stripe_connected {
            //connect
            
        }else {
            //disconnect
        }
    }
    
    
    func setupStripeLabel(){
        let indexPath = IndexPath(row: 3, section: 0)
        let cell = profileTableView.cellForRow(at: indexPath) as? SettingCell
        
        DispatchQueue.main.async(execute: {
            if self.stripe_connected {
                cell?.connect_stripe_button.isSelected = true
                //cell?.stripe_lbl.text = "Disconnect your Account" //ravi 22Feb2018
                
            }else{
                cell?.connect_stripe_button.isSelected = false
                //cell?.stripe_lbl.text = "Please create your account"
            }
            
        })
    }
    
    
    //MARK: UIButton Action ************
    @IBAction func stripe_connectAction(_ sender: Any){
        if stripe_connected {
            //disconnect from stripe
            disconnectToStripe()
        }else{
            //connect to stripe
            connectToStripe()
        }
    }
    
    
    
    func connectToStripe(){
        NotificationCenter.default.addObserver(self, selector: #selector(CoachesProfileVC.receivedNotification(fromStripe:)), name: NSNotification.Name("stripeConnect"), object: nil)
        
        let STRIPE_CONNECT_URL_ = "\(STRIPE_CONNECT)\(STRIPE_CLIENT_ID)&redirect_uri=\(STRIPE_REDIRECT_URI)"
        let stripeConnectURL = URL(string: STRIPE_CONNECT_URL_)
        if UIApplication.shared.canOpenURL(stripeConnectURL!) {
            UIApplication.shared.openURL(stripeConnectURL!)
        }
    }
    
    
    func disconnectToStripe(){
        
        appDelegateRef.showIndicator()
        let stripeAccountId = UserDefaults.standard.object(forKey: "StripeConnectId") as? String
        let parameters = [
            "client_id" : STRIPE_CLIENT_ID,
            "stripe_user_id" : stripeAccountId ?? ""
        ]
        
        StripeConnection.disconnectCustomerStripeAccountToMerchantAccount(withParameters: parameters, requestCompletionWithResponse: {(_ response: Any, _ message: String) -> Void in
            appDelegateRef.hideIndicator()
            if (message == SUCCESS_MESSAGE) {
                UserDefaults.standard.set(nil, forKey: "StripeConnectId")
                showAlerView(title: "Success!", message: "You have successfully disconnected with merchant account", self1: self)
                //disconnected
                self.sendStripeDisConnectDetails()
            }
            else {
                let alertTitle = response as? String ?? ""
                showAlerView(title: message, message: alertTitle, self1: self)
                //CommonClass.showTSMessageError(message, withTitle: alertTitle, andVC: self)
            }
        })
    }
    
    
    
    
    @objc func receivedNotification(fromStripe notification: Notification) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("stripeConnect"), object: nil)
        appDelegateRef.showIndicator()
        let tokenCode = notification.object as? String
        let infoDict = [
            "client_id" : STRIPE_CLIENT_ID,
            "client_secret" : STRIPE_SECRET_KEY,
            "grant_type" : "authorization_code",
            "code" : tokenCode ?? ""
        ]
        
        StripeConnection.addYourAccountToMerchantAccount(withParameters: infoDict, requestCompletionWithResponse: {(_ response: Any, _ message: String) -> Void in
            if (message == SUCCESS_MESSAGE) {
                appDelegateRef.hideIndicator()
                //connected
                //here we need to hit service to send this data on server for connect stripe
                self.sendStripeConnectDetails(response)
            }
            else {
                appDelegateRef.hideIndicator()
                let alertTitle = response as? String ?? ""
                showAlerView(title: message, message: alertTitle, self1: self)
                //CommonClass.showTSMessageError(message, withTitle: alertTitle, andVC: self)
            }
        })
    }
    
    
    
    
    func sendStripeConnectDetails(_ response: Any) {
        
        stripe_Detailsdic = (response as? NSDictionary)!
        
        let request = ["coach_id":getUserId(),"stripe_connect": response] as [String : Any]
        /*
         "stripe_connect": {
         "stripe_user_id": "sasasasasasa",
         "livemode": true,
         "token_type": "bearer",
         "refresh_token": "sasasasasasasa",
         "scope": "read_write",
         "stripe_publishable_key": "sasasasasa",
         "access_token": "sasas"
         }
         */
        
        //ravi 06Feb2018 remove indicator from here
        WebServices().POSTFunctiontoGetDetails(data: request as NSDictionary ,serviceType:kSTRIPE_CONNECT, showIndicator: false) { (responseData)  in
            
            if responseData != nil {
                
                print("responseData",responseData ?? "")
                guard let responseDict = responseData?["result"] as? NSDictionary else {return }
                let code = responseData?["code"] as? NSNumber
                if code == 200{
                    
                    self.Stripe_Profile_Dict = responseDict as? [String : Any] ?? [:]
                    saveUserDetails(userDict: self.Stripe_Profile_Dict as NSDictionary)
                    //var message = self.Stripe_Profile_Dict["message"] as? String ?? ""
                    //showAlerView(title: "Success!", message: "your account is connected", self1: self)
                    self.stripe_connected = true
                    let stripeDict = self.Stripe_Profile_Dict["stripe_connect"] as? [String:Any]
                    UserDefaults.standard.set(stripeDict!["stripe_user_id"], forKey: "StripeConnectId") //save it
                    self.setupStripeLabel()
                    self.updateStripeStatus()
                }
                else {
                    let message = responseDict["message"] as? String ?? ""
                    showAlerView(title: "", message: message, self1: self)
                    //CommonClass.showTSMessageError(nil, withTitle: message, andVC: self)
                }
            }
        }
    }
    
    func sendStripeDisConnectDetails() {
        
        //ravi 06Feb2018 remove indicator from here
        WebServices().POSTFunctiontoWO_Body(serviceType: kSTRIPE_DISCONNECT, showIndicator: false) { (responseData)  in
            if responseData != nil {
                
                print("responseData",responseData ?? "")
                guard let responseDict = responseData?["result"] as? NSDictionary else {return }
                let code = responseData?["code"] as? NSNumber
                if code == 200{
                    // guard let result  = responseDict["result"] as? NSMutableDictionary  else {return }
                    self.Stripe_Profile_Dict = responseDict as? [String : Any] ?? [:]
                    saveUserDetails(userDict: self.Stripe_Profile_Dict as NSDictionary)
                    
                    self.stripe_connected = false
                    UserDefaults.standard.set(nil, forKey: "StripeConnectId") //save it
                    
                    self.setupStripeLabel()
                    self.updateStripeStatus()
                    
                }
                else {
                    let message = responseDict["message"] as? String ?? ""
                    showAlerView(title: "", message: message, self1: self)
                    //CommonClass.showTSMessageError(nil, withTitle: message, andVC: self)
                }
            }
        }
    }
    @objc func EditIntroductionideoBtnAction(_ sender: Any) {
        
        print("Play Video")
        let videoUrl  = getIntroVideoUrl() as String
        print(videoUrl)
        
        if videoUrl == "" {
            if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)){
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "VideoCameraVc") as! VideoCameraVc
                self.navigationController?.pushViewController(vc, animated: true)
                
            }else{
                notifyUser("", message: "Your device doesn't support camera", vc: self)
            }
        }else {
            let imageUrl = URL(string:videoUrl )
            
            let player = AVPlayer(url: imageUrl!)
            let playerViewController = AVPlayerViewController()
            playerViewController.player = player
            self.present(playerViewController, animated: true)
            {
                playerViewController.player!.play()
            }
        }
       
        
    }
 }
 
 extension CoachesProfileVC: UITableViewDataSource {
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // return 5
        let videourl = getIntroVideoUrl() as String
        print(videourl)
        
        if videourl == "" {
            return 5
        }else {
            return 5
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let videourl = getIntroVideoUrl() as String
        print(videourl)
        
        if videourl == "" {
            if section == 4{
                return 3
            }
            else if section == 0{
                return 5
            }
            return 1
        } else {
            if section == 4{
                return 3
            }
            else if section == 0{
                return 5
            }
            return 1
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let videourl = getIntroVideoUrl() as String
        print(videourl)
        
        if videourl == "" {
            if indexPath.section == 0 {
                if indexPath.row == 0 {
                    let cell: CoachesProfileInfoCell! =  tableView.dequeueReusableCell(withIdentifier: "CoachesProfileInfoCell") as? CoachesProfileInfoCell
                    cell.selectionStyle = .none
                    var imageStr = getProfilePic() as String
                    //     imageStr = ""
                    let imageUrl = URL(string: imageStr)
                    
                    if imageStr == "" {
                        cell.user_image.isHidden = true
                        cell.userProfileNameLbl.isHidden = false
                        let firstNameStr = getFirstName() as String
                        cell.userProfileNameLbl.text = String(firstNameStr.prefix(1))
                    }else {
                        cell.user_image.isHidden = false
                        cell.userProfileNameLbl.isHidden = true
                    }
                    
                    var totalEarn = getTotalEarning() as String
                    
                    print(totalEarn)
                    if totalEarn == "" {
                        totalEarn = "0.00"
                    }else {
                     
                        let ToatalEarnValue = Double(totalEarn)
                        totalEarn = String(format:"%.2f", ToatalEarnValue!)
                        

                   
                    }
                    
                    cell.lbl_totalCredit.text = "$" + totalEarn
                  
                    
                    cell.user_image.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "defult_pic"), options:.refreshCached)
                    cell.lbl_userName.text = getFirstName() + " " + getLastName()
                    cell.lbl_totalCredit.font = UIFont.systemFont(ofSize: 17)
                    cell.lbl_userName.font = UIFont.systemFont(ofSize: 17)
                    return cell
                }
                else if indexPath.row == 4 {
                    let cell: AddUserAddressCell! =  tableView.dequeueReusableCell(withIdentifier: "AddUserAddressCell") as? AddUserAddressCell
                    cell.selectionStyle = .none
                    cell.tf_address.text = getAddress()
                    cell.tf_address.font = UIFont.systemFont(ofSize: 17)
                    return cell
                }
                else{
                    let cell: SettingCell! =  tableView.dequeueReusableCell(withIdentifier: "SettingCell") as? SettingCell
                    cell.selectionStyle = .none
                    cell.view_passcode.isHidden = true
                    cell.view_inApppurch.isHidden = true  // hide inapp purchase view
                    cell.view_BottomSepartor.isHidden = true
                    cell.lbl_details.isHidden = false
                    cell.next_icon.isHidden = true
                    cell.lbl_SettingTitle.textColor = UIColor.settingBlue
                    
                    if indexPath .row == 1{
                        cell.lbl_SettingTitle.text = "Email"
                        cell.lbl_details.text = getUserEmail()
                    }
                    else if indexPath .row == 2 {
                        cell.lbl_SettingTitle.text = "Phone"
                        cell.lbl_details.text = getPhoneNo()
                    }
                    else if indexPath.row == 3 {
                        cell.view_inApppurch.isHidden = false
                        cell.view_BottomSepartor.isHidden = false
                    }
                    
                    cell.lbl_SettingTitle.font = UIFont.systemFont(ofSize: 17)
                    cell.lbl_details.font = UIFont.systemFont(ofSize: 17)
                    
                    return cell
                    
                }
                
            } else if indexPath.section == 1 {
                let cell: EditIntroVideo! =  tableView.dequeueReusableCell(withIdentifier: "EditIntroVideo") as? EditIntroVideo
                cell.selectionStyle = .none
                cell.EditLbl.text = "Add introduction video"
                 cell.EditLbl.font = UIFont.systemFont(ofSize: 17)
                cell.EditVideoBtn.addTarget(self, action: #selector(EditIntroductionideoBtnAction), for: .touchUpInside)
                
                return cell
            }else if indexPath.section == 3 {
                let cell: CoachesCategoryCell! =  tableView.dequeueReusableCell(withIdentifier: "CoachesCategoryCell") as? CoachesCategoryCell
                cell.selectionStyle = .none
                print(getCategoryArray())
                cell.updateCategoryDetails(catArray: getCategoryArray(), isEdit: false)
                return cell
            }
            else if indexPath.section == 4 {
                let cell: CoachesPricingCell! =  tableView.dequeueReusableCell(withIdentifier: "CoachesPricingCell") as? CoachesPricingCell
                cell.selectionStyle = .none
                cell.pricingModeBtn.tag = indexPath.row
                cell.tf_Price.tag = indexPath.row
                cell.tf_Price.isUserInteractionEnabled = false
                
                print(pricingArray)
                
                if pricingArray.contains(indexPath.row) {
                    cell.pricingModeBtn.isSelected = true
                    cell.rightCheckMark.isHidden = false
                    
                }
                else{
                    cell.pricingModeBtn.isSelected = false
                    cell.rightCheckMark.isHidden = true
                }
                cell.lbl_permsg.text = "Per msg"
                if indexPath.row == 0 {
                    cell.pricingModeBtn.setTitle("Direct Message", for: .normal)
                    cell.tf_Price.text = getDirectPrice()
                }
                else if indexPath.row == 1 {
                    cell.pricingModeBtn.setTitle("Rush Direct Message", for: .normal)
                    cell.tf_Price.text = getRushDirectPrice()
                }
                else{
                    cell.pricingModeBtn.setTitle("Live chat", for: .normal)
                    cell.lbl_permsg.text = "Per min"
                    cell.tf_Price.text = getLiveChatPrice()
                }
                cell.lbl_permsg.font = UIFont.systemFont(ofSize: 17)
                cell.tf_Price.font = UIFont.systemFont(ofSize: 17)
                cell.pricingModeBtn.titleLabel?.font = UIFont.systemFont(ofSize: 17)
                return cell
            }
            else{
                let cell: CoachesAddAboutCell! =  tableView.dequeueReusableCell(withIdentifier: "CoachesAddAboutCell") as? CoachesAddAboutCell
                cell.textView_abou.tag = indexPath.section
                cell.textView_abou.isEditable = false
                cell.textView_abou.isUserInteractionEnabled = false
                cell.textView_abou.textColor = .black
                cell.textView_abou.font = UIFont.systemFont(ofSize: 17)
                if indexPath.section == 2 {
                    cell.textView_abou.text = getAboutDetail()
                }
                else{
                    cell.textView_abou.text = getAbout_services()
                }
                cell.selectionStyle = .none
                return cell
            }
        } else {
            
            if indexPath.section == 0 {
                if indexPath.row == 0 {
                    let cell: CoachesProfileInfoCell! =  tableView.dequeueReusableCell(withIdentifier: "CoachesProfileInfoCell") as? CoachesProfileInfoCell
                    cell.selectionStyle = .none
                    var imageStr = getProfilePic() as String
                    //     imageStr = ""
                    let imageUrl = URL(string: imageStr)
                    
                    if imageStr == "" {
                        cell.user_image.isHidden = true
                        cell.userProfileNameLbl.isHidden = false
                        let firstNameStr = getFirstName() as String
                        cell.userProfileNameLbl.text = String(firstNameStr.prefix(1))
                    }else {
                        cell.user_image.isHidden = false
                        cell.userProfileNameLbl.isHidden = true
                    }
                    
                    var totalEarn = getTotalEarning() as String
                    
                    print(totalEarn)
                    if totalEarn == "" {
                        totalEarn = "0.00"
                    }else {
                        
                        let ToatalEarnValue = Double(totalEarn)
                        totalEarn = String(format:"%.2f", ToatalEarnValue!)
                    }
                    
                    
                    cell.lbl_totalCredit.text = "$" + totalEarn
                    cell.user_image.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "defult_pic"), options:.refreshCached)
                    cell.lbl_userName.text = getFirstName() + " " + getLastName()
                    cell.lbl_totalCredit.font = UIFont.systemFont(ofSize: 17)
                    cell.lbl_userName.font = UIFont.systemFont(ofSize: 17)
                    
                    return cell
                }
                else if indexPath.row == 4 {
                    let cell: AddUserAddressCell! =  tableView.dequeueReusableCell(withIdentifier: "AddUserAddressCell") as? AddUserAddressCell
                    cell.selectionStyle = .none
                    cell.tf_address.text = getAddress()
                    cell.tf_address.font = UIFont.systemFont(ofSize: 17)
                    return cell
                }
                else{
                    let cell: SettingCell! =  tableView.dequeueReusableCell(withIdentifier: "SettingCell") as? SettingCell
                    cell.selectionStyle = .none
                    cell.view_passcode.isHidden = true
                    cell.view_inApppurch.isHidden = true  // hide inapp purchase view
                    cell.view_BottomSepartor.isHidden = true
                    cell.lbl_details.isHidden = false
                    cell.next_icon.isHidden = true
                    cell.lbl_SettingTitle.textColor = UIColor.settingBlue
                    
                    if indexPath .row == 1{
                        cell.lbl_SettingTitle.text = "Email"
                        cell.lbl_details.text = getUserEmail()
                    }
                    else if indexPath .row == 2 {
                        cell.lbl_SettingTitle.text = "Phone"
                        cell.lbl_details.text = getPhoneNo()
                    }
                    else if indexPath.row == 3 {
                        cell.view_inApppurch.isHidden = false
                        cell.view_BottomSepartor.isHidden = false
                    }
                    
                    cell.lbl_SettingTitle.font = UIFont.systemFont(ofSize: 17)
                    cell.lbl_details.font = UIFont.systemFont(ofSize: 17)
                    
                    return cell
                    
                }
                
            } else if indexPath.section == 1 {
                let cell: EditIntroVideo! =  tableView.dequeueReusableCell(withIdentifier: "EditIntroVideo") as? EditIntroVideo
                cell.selectionStyle = .none
                cell.EditLbl.text = "show introduction video"
                cell.EditLbl.font = UIFont.systemFont(ofSize: 17)
                cell.EditVideoBtn.addTarget(self, action: #selector(EditIntroductionideoBtnAction), for: .touchUpInside)
                
                return cell
            }else if indexPath.section == 3 {
                let cell: CoachesCategoryCell! =  tableView.dequeueReusableCell(withIdentifier: "CoachesCategoryCell") as? CoachesCategoryCell
                cell.selectionStyle = .none
                cell.updateCategoryDetails(catArray: getCategoryArray(), isEdit: false)
                return cell
            }
            else if indexPath.section == 4 {
                let cell: CoachesPricingCell! =  tableView.dequeueReusableCell(withIdentifier: "CoachesPricingCell") as? CoachesPricingCell
                cell.selectionStyle = .none
                cell.pricingModeBtn.tag = indexPath.row
                cell.tf_Price.tag = indexPath.row
                cell.tf_Price.isUserInteractionEnabled = false
                
                print(pricingArray)
                
                if pricingArray.contains(indexPath.row) {
                    cell.pricingModeBtn.isSelected = true
                    cell.rightCheckMark.isHidden = false
                    
                }
                else{
                    cell.pricingModeBtn.isSelected = false
                    cell.rightCheckMark.isHidden = true
                }
                cell.lbl_permsg.text = "Per msg"
                if indexPath.row == 0 {
                    cell.pricingModeBtn.setTitle("Direct Message", for: .normal)
                    cell.tf_Price.text = getDirectPrice()
                }
                else if indexPath.row == 1 {
                    cell.pricingModeBtn.setTitle("Rush Direct Message", for: .normal)
                    cell.tf_Price.text = getRushDirectPrice()
                }
                else{
                    cell.pricingModeBtn.setTitle("Live chat", for: .normal)
                    cell.lbl_permsg.text = "Per min"
                    cell.tf_Price.text = getLiveChatPrice()
                }
                
                cell.lbl_permsg.font = UIFont.systemFont(ofSize: 17)
                cell.tf_Price.font = UIFont.systemFont(ofSize: 17)
                cell.pricingModeBtn.titleLabel?.font = UIFont.systemFont(ofSize: 17)
                
                return cell
            }
            else{
                let cell: CoachesAddAboutCell! =  tableView.dequeueReusableCell(withIdentifier: "CoachesAddAboutCell") as? CoachesAddAboutCell
                cell.textView_abou.tag = indexPath.section
                cell.textView_abou.isEditable = false
                cell.textView_abou.isUserInteractionEnabled = false
                cell.textView_abou.textColor = .black
                cell.textView_abou.font = UIFont.systemFont(ofSize: 17)
                if indexPath.section == 2{
                    cell.textView_abou.text = getAboutDetail()
                }
                else{
                    cell.textView_abou.text = getAbout_services()
                }
                cell.selectionStyle = .none
                return cell
            }
        }
    }
    
    
    
 }
 
 extension CoachesProfileVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let videourl = getIntroVideoUrl() as String
        
        if videourl == "" {
            
            if indexPath.section == 0{
                if indexPath.row == 0{
                    return 120
                }
                else if indexPath.row == 4{
                    return 85
                }
                return 50
            }
                            else if indexPath.section == 1{
                                return 50
                            }
            else if indexPath.section == 4{
                return 50
            }else if indexPath.section == 2 {
                let text = getAboutDetail()
                var textView = UITextView()
                
                textView.text =  text
                textView.font = UIFont.systemFont(ofSize: 17)
                let fixedWidth = self.view.frame.size.width - 30
                textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
                let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
                var newFrame = textView.frame
                newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
                var txtFldWidth = newSize.width
                var txtFldHeight  = newSize.height
                //                if txtFldHeight < 90 {
                //                    return 100
                //                }
                return txtFldHeight + 10
            }
            
            return 100
        } else {
            if indexPath.section == 0{
                if indexPath.row == 0{
                    return 120
                }
                else if indexPath.row == 4{
                    return 85
                }
                return 50
            }
            else if indexPath.section == 1{
                return 50
            }
            else if indexPath.section == 4{
                return 50
            }else if indexPath.section == 2 {
                let text = getAboutDetail()
                var textView = UITextView()
                
                textView.text =  text
                textView.font = UIFont.systemFont(ofSize: 17)
                let fixedWidth = self.view.frame.size.width - 30
                textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
                let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
                var newFrame = textView.frame
                newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
                var txtFldWidth = newSize.width
                var txtFldHeight  = newSize.height
                //                if txtFldHeight < 90 {
                //                    return 100
                //                }
                return txtFldHeight + 10
            }
            
            return 100
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 40))
        let header_lbl = UILabel(frame: CGRect(x: 15, y: 0, width: 200, height: 40))
        headerView.backgroundColor = UIColor.clear
        
        let videourl = getIntroVideoUrl() as String
        
        if videourl == "" {
            if section == 0{
            }
                            else if section == 1{
                                header_lbl.text = "INTRODUCTION VIDEO"
                            }
            else if section == 2{
                header_lbl.text = "ABOUT ME"
            }
                //        else if section == 2{
                //            header_lbl.text = "ABOUT MY SERVICES"
                //        }
                
            else if section == 3{
                header_lbl.text = "EXPERTISE"
            }
            else if section == 4{
                header_lbl.text = "PRICING"
            }
            header_lbl.font = UIFont(name: "OpenSans-Bold", size: 14.0)
            headerView.addSubview(header_lbl)
            
            return headerView
        }else {
            if section == 0{
            }
            else if section == 1{
                header_lbl.text = "INTRODUCTION VIDEO"
            }
            else if section == 2{
                header_lbl.text = "ABOUT ME"
            }
                //        else if section == 2{
                //            header_lbl.text = "ABOUT MY SERVICES"
                //        }
            else if section == 3{
                header_lbl.text = "EXPERTISE"
            }
            else if section == 4{
                header_lbl.text = "PRICING"
            }
            header_lbl.font = UIFont.boldSystemFont(ofSize: 18)
            headerView.addSubview(header_lbl)
            
            return headerView
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat{
        if section == 0{
            return 0
        }
        return 40
    }
    
 }

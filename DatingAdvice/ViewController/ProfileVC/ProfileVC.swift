//
//  ProfileVC.swift
//  Intrigued
//
//  Created by daniel helled on 28/09/17.
//  Copyright © 2017 daniel helled. All rights reserved.
//

import UIKit
import SDWebImage
class ProfileVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var profileTableView: UITableView!
    var detailsArray = NSArray()
    var transactionArray = NSArray()
    var price:Float?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.userLoginApi()
        self.AllTransactionApi()
        
        detailsArray = ["Profile","Email", "Password","Address", "in App Purchases","Your current amount"]
        profileTableView.register(UINib(nibName: "BuyTableViewCell", bundle: nil), forCellReuseIdentifier: "BuyTableViewCell")
        profileTableView.register(UINib(nibName: "UserTransactionHistoryCell", bundle: nil), forCellReuseIdentifier: "UserTransactionHistoryCell")
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        // profileTableView.reloadData()
        self.userLoginApi()
        self.AllTransactionApi()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        profileTableView.reloadData()
    }
    @IBAction func backButtonAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func editButtonAction(_ sender: Any) {
        pushView(viewController: self, identifier: "EditUserProfileVC")
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @objc func clickOnBuyButton(sender:UIButton){
        
        //1. Create the alert controller.
        let alert = UIAlertController(title: "Buy Credit", message: "Enter the Amount", preferredStyle: .alert)
        
        //2. Add the text field. You can configure it however you need.
        alert.addTextField { (textField) in
            textField.delegate = self
            textField.placeholder = "Please enter the amount"
            textField.textAlignment = .center
            textField.keyboardType = UIKeyboardType.decimalPad
        }
        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "Confirm", style: .destructive, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
            
            let AddCardListVC = self.storyboard?.instantiateViewController(withIdentifier: "AddCreditCardList") as? AddCreditCardList
            AddCardListVC?.delegate = self
            AddCardListVC?.buyCreditAmount = textField?.text ?? ""
            self.navigationController?.pushViewController(AddCardListVC!, animated: true)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let nString = textField.text as NSString?
        let newString = nString?.replacingCharacters(in: range, with: string)
        let n = Decimal(string: newString ?? "")
        let value = n?.significantFractionalDecimalDigits
        let DoubleValue = (newString as NSString?)?.intValue ?? 0
        
        if DoubleValue >= 999999 || value == 3 {
            return false
        }
        return true
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
                        self.price = Float(balance)
                        print(self.price ?? 0.0)
                        self.profileTableView.reloadData()
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
    
    
    //MARK: ************ Payment Transaction History ***************
    func AllTransactionApi() {
        
        let requestDict = ["user_id":getUserId(),
                           "pageNo": 1,
                           ] as NSDictionary
        print(requestDict)
        showProgressIndicator(refrenceView: self.view)
        WebServices().mainFunctiontoGetDetails(data: requestDict,serviceType:kTransaction_KEY) { (responseData)  in
            stopProgressIndicator()
            if responseData != nil
            {
                let code = responseData?["code"] as? NSNumber
                print("responseData",responseData ?? "")
                if code == 200{
                    guard let resultArray = responseData?["result"] as? NSMutableArray else {
                        return
                    }
                    self.transactionArray = resultArray
                    self.profileTableView.reloadData()
                    
                }
            }
        }
    }
    
    
}


extension ProfileVC : ProfileBalanceDelegate {
    func updateBalance() {
        self.userLoginApi()
        self.profileTableView.reloadData()
    }
}

extension ProfileVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        }
        else if section == 1 {
            return 1
        }
        else if section == 2 {
            return self.transactionArray.count
        }
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: SettingCell! =  tableView.dequeueReusableCell(withIdentifier: "SettingCell") as? SettingCell
        cell.selectionStyle = .none
        // cell.view_passcode.isHidden = true
        cell.lbl_SettingTitle.textColor = UIColor.black
        cell.lbl_details.isHidden = true
        // cell.view_inApppurch.isHidden = true  // hide inapp purchase view
        cell.view_BottomSepartor.isHidden = true
        
        if indexPath.section == 0 {
            
            if indexPath.row == 0 {
                let cell: UserProfileCell! =  tableView.dequeueReusableCell(withIdentifier: "UserProfileCell") as? UserProfileCell
                cell.lbl_userName.text = getFirstName() + " " + getLastName()
             
                
                let imageStr = getProfilePic() as String
                //     imageStr = ""
                let imageUrl = URL(string: imageStr)
                
                if imageStr == "" {
                    cell.user_image.isHidden = true
                    cell.UserProfileLbl.isHidden = false
                    let firstNameStr = getFirstName() as String
                    cell.UserProfileLbl.text = String(firstNameStr.prefix(1))
                }else {
                    cell.user_image.isHidden = false
                    cell.UserProfileLbl.isHidden = true
                }
                
                
                cell.user_image.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "defult_pic"), options:.refreshCached)
                return cell
            }
            else {
                cell.lbl_details.isHidden = false
                //cell.next_icon.isHidden = true
                cell.lbl_SettingTitle.textColor = UIColor.settingBlue
                cell.lbl_SettingTitle.text = detailsArray[indexPath.row] as? String
                
                if indexPath .row == 1{
                    cell.lbl_details.text = getUserEmail()
                }
                cell.backgroundColor = UIColor.green
            }
            
        }
        else if indexPath.section == 1 {
            if indexPath.row == 0 {
                let cell: BuyTableViewCell! =  tableView.dequeueReusableCell(withIdentifier: "BuyTableViewCell") as? BuyTableViewCell
                if self.price == 0.00 || self.price == 0.0 || self.price == 0 {
                    cell.creditValue.text = "$0.00"
                }
                else {
                    if self.price == nil{
                        cell.creditValue.text = "$0.00"
                    } else{
                        cell.creditValue.text = "$\(self.price ?? 0.00)"
                    }
                }
                cell.buyButton_btn.addTarget(self, action: #selector(clickOnBuyButton(sender:)), for:.touchUpInside)
                cell.selectionStyle = .none
                return cell
            }
        }
        else {
            //if indexPath.row == 0 {
            let cell:UserTransactionHistoryCell = (tableView.dequeueReusableCell(withIdentifier: "UserTransactionHistoryCell") as? UserTransactionHistoryCell)!
            if let dict = self.transactionArray[indexPath.row] as? NSDictionary {
                cell.setUpTransactionHistory(orderDetails:dict)
            }
            cell.selectionStyle = .none
            return cell
            //}
        }
        return cell
    }
}


extension ProfileVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            if indexPath.row == 0{
                return 100
            }
            else{
                return 50
            }
        }
        else if indexPath.section == 1 {
            return 50
        }
        else if indexPath.section == 2{
            return 65
        }
        else {
            return 60
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 40))
        let header_lbl = UILabel(frame: CGRect(x: 15, y: 0, width: 200, height: 40))
        headerView.backgroundColor = UIColor.clear
        if section == 0{
            headerView.backgroundColor = UIColor.white
        }
        else if section == 1{
            header_lbl.text = "BUY CREDITS"
        }
        else if section == 2 {
            header_lbl.text = "Transaction History"
        }
        
        header_lbl.font = UIFont(name: "OpenSans-Bold", size: 16.0)
        headerView.addSubview(header_lbl)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat{
        if section == 0 {
            return 15
        }
        return 40
    }
    
    
}


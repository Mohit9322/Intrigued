//
//  CoachRequestUserProfileVC.swift
//  Intrigued
//
//  Created by SWS on 10/10/17.
//  Copyright © 2017 daniel helled. All rights reserved.
//

import UIKit

class CoachRequestUserProfileVC: UIViewController {

    @IBOutlet weak var infoTableView: UITableView!
    var userOrderInfo = NSDictionary()
    var images_Array = NSArray()
    var reviewDetails = ""
    var orderId = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        infoTableView.estimatedRowHeight = 50
        infoTableView.rowHeight = UITableViewAutomaticDimension
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        
        
       infoTableView.register(UINib(nibName: "UserQuestionImageCell", bundle: nil), forCellReuseIdentifier: "UserQuestionImageCell")
        print(userOrderInfo)
        if let imageArray =  userOrderInfo["images"] as? NSArray  {
            images_Array = imageArray
        }
      //  let orderStr = userOrderInfo["_id"] as! String
        orderId = userOrderInfo["_id"] as! String
        print(orderId)
        self.getReviewDetail()
       
        // Do any additional setup after loading the view.
    }

    func getReviewDetail()  {
        
         showProgressIndicator(refrenceView: self.view)
         let request = ["order_id": orderId] as [String : Any]
           print(orderId)
        WebServices().mainFunctiontoGetDetails(data: request as NSDictionary,serviceType:kGET_COACH_REVIEW) { (responseData)  in
            stopProgressIndicator()
         
            if responseData != nil
            {
                let code = responseData?["code"] as? NSNumber
                print("responseData",responseData ?? "")
                if code == 200{
                    stopProgressIndicator()
                    
                    let dict  = responseData?["result"] as? NSDictionary
                    self.reviewDetails = dict!["review"] as! String
                    self.infoTableView.reloadData()
                    guard let resultArray = responseData?["result"] as? NSMutableArray else {
                        
                        
                        return
                    }
                 
                    
                }
                else{
                    
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
    @IBAction func backButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
extension CoachRequestUserProfileVC: UITableViewDataSource {
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if images_Array.count > 0 {
            if reviewDetails == "" {
              return 4
            }else {
               return 5
            }
           
        }
        if reviewDetails == "" {
            return 3
        }else {
            return 4
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
         if images_Array.count > 0 {
            
            if indexPath.section == 0 {
                let cell: UserRequestInfoCell! =  tableView.dequeueReusableCell(withIdentifier: "UserRequestInfoCell") as? UserRequestInfoCell
                cell.selectionStyle = .none
                print(userOrderInfo)
                cell.setupDataOnCell(orderDetails:userOrderInfo)
                let created_date =  userOrderInfo["accept_time"] as? String
                let date =  convertStringintoDate(dateStr: created_date!)
                
                cell.paymentDate.text = date.getCreatedDate()
                return cell
            }
            else if indexPath.section == 3 {
                let cell: UserQuestionImageCell! =  tableView.dequeueReusableCell(withIdentifier: "UserQuestionImageCell") as? UserQuestionImageCell
                cell.selectionStyle = .none
                cell.setupDetailsonView(imageArray:images_Array)
                return cell
            }
            else{
                let cell: AboutAdvisorCell! =  tableView.dequeueReusableCell(withIdentifier: "AboutAdvisorCell") as? AboutAdvisorCell
                if indexPath.section == 1{
                    cell.lbl_aboutAdvisor.text = userOrderInfo["title"] as? String ?? ""
                }
                else if  indexPath.section == 2 {
                    cell.lbl_aboutAdvisor.text =  userOrderInfo["question"] as? String ?? ""
                }else {
                    print(reviewDetails)
                    cell.lbl_aboutAdvisor.text =  reviewDetails
                }
                
                
                cell.selectionStyle = .none
                return cell
            }
            
         }else {
            if reviewDetails == "" {
                if indexPath.section == 0 {
                    let cell: UserRequestInfoCell! =  tableView.dequeueReusableCell(withIdentifier: "UserRequestInfoCell") as? UserRequestInfoCell
                    cell.selectionStyle = .none
                    print(userOrderInfo)
                    cell.setupDataOnCell(orderDetails:userOrderInfo)
                    let created_date =  userOrderInfo["accept_time"] as? String
                    let date =  convertStringintoDate(dateStr: created_date!)
                    
                    cell.paymentDate.text = date.getCreatedDate()
                    return cell
                }
                else if indexPath.section == 3 {
                    let cell: UserQuestionImageCell! =  tableView.dequeueReusableCell(withIdentifier: "UserQuestionImageCell") as? UserQuestionImageCell
                    cell.selectionStyle = .none
                    cell.setupDetailsonView(imageArray:images_Array)
                    return cell
                }
                else{
                    let cell: AboutAdvisorCell! =  tableView.dequeueReusableCell(withIdentifier: "AboutAdvisorCell") as? AboutAdvisorCell
                    if indexPath.section == 1{
                        cell.lbl_aboutAdvisor.text = userOrderInfo["title"] as? String ?? ""
                    }
                    else if  indexPath.section == 2 {
                        cell.lbl_aboutAdvisor.text =  userOrderInfo["question"] as? String ?? ""
                    }else {
                        print(reviewDetails)
                        cell.lbl_aboutAdvisor.text =  reviewDetails
                    }
                    
                    
                    cell.selectionStyle = .none
                    return cell
                }
            }else {
                if indexPath.section == 0 {
                    let cell: UserRequestInfoCell! =  tableView.dequeueReusableCell(withIdentifier: "UserRequestInfoCell") as? UserRequestInfoCell
                    cell.selectionStyle = .none
                    print(userOrderInfo)
                    cell.setupDataOnCell(orderDetails:userOrderInfo)
                    let created_date =  userOrderInfo["accept_time"] as? String
                    let date =  convertStringintoDate(dateStr: created_date!)
                    
                    cell.paymentDate.text = date.getCreatedDate()
                    return cell
                }
                else if indexPath.section == 4 {
                    let cell: UserQuestionImageCell! =  tableView.dequeueReusableCell(withIdentifier: "UserQuestionImageCell") as? UserQuestionImageCell
                    cell.selectionStyle = .none
                    cell.setupDetailsonView(imageArray:images_Array)
                    return cell
                }
                else{
                    let cell: AboutAdvisorCell! =  tableView.dequeueReusableCell(withIdentifier: "AboutAdvisorCell") as? AboutAdvisorCell
                    if indexPath.section == 1{
                        cell.lbl_aboutAdvisor.text = userOrderInfo["title"] as? String ?? ""
                    }
                    else if  indexPath.section == 2 {
                        cell.lbl_aboutAdvisor.text =  userOrderInfo["question"] as? String ?? ""
                    }else {
                        print(reviewDetails)
                        cell.lbl_aboutAdvisor.text =  reviewDetails
                    }
                    
                    
                    cell.selectionStyle = .none
                    return cell
                }
            }
           
        }
      
  return UITableViewCell()
    
}
}

extension CoachRequestUserProfileVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0{
                return 320
            
        }
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 40))
        let header_lbl = UILabel(frame: CGRect(x: 15, y: 0, width: 200, height:40))
        headerView.backgroundColor = UIColor.clear
        if section == 0{
        }
   
            if images_Array.count > 0 {
               if section == 1{
                    header_lbl.text = "USER DESCRIPTION"
                }
                else if section == 2{
                    header_lbl.text = "USER QUESTION"
                } else if section == 3 {
                    header_lbl.text = "UPLOADED IMAGES"
               }else if section == 4{
                header_lbl.text = "USER REVIEW"
                }
            }else {
                if section == 1{
                    header_lbl.text = "USER DESCRIPTION"
                }
                else if section == 2{
                    header_lbl.text = "USER QUESTION"
                } else if section == 3{
                    header_lbl.text = "USER REVIEW"
                }
        }
      
       
        
        header_lbl.font = UIFont(name: "OpenSans-Bold", size: 14.0)
        headerView.addSubview(header_lbl)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat{
        if section == 0 {
            return 0
        }
        return 40
    }
    
}

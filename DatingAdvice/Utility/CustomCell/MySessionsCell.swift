//
//  MySessionsCell.swift
//  DatingAdvice
//
//  Created by daniel helled on 13/09/17.
//  Copyright © 2017 daniel helled. All rights reserved.
//

import UIKit

class MySessionsCell: UITableViewCell {

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var view_container: UIView!
    @IBOutlet weak var lbl_displayName: UILabel!
    @IBOutlet weak var lbl_userName: UILabel!
    @IBOutlet weak var lbl_description: UILabel!
    @IBOutlet weak var lbl_sessionDate: UILabel!
    @IBOutlet weak var lbl_PostcreatedDate: UILabel!
    @IBOutlet weak var lbl_OrderStatus: UILabel!
    @IBOutlet weak var sessionView: UIView!
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var LeaveReviewBtn: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.view_container.layer.cornerRadius = 12.0
        self.view_container.layer.borderWidth = 1.0
        self.view_container.layer.borderColor = UIColor.clear.cgColor
        self.view_container.layer.masksToBounds = true
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 4.0)
        self.layer.shadowRadius = 2.0
        self.layer.shadowOpacity = 1.0
        self.layer.masksToBounds = false
       //  LeaveReviewBtn.titleLabel?.textColor = UIColor.green
        
        LeaveReviewBtn.titleLabel?.textColor = hexStringToUIColor(hex: "1d7399")
 
        LeaveReviewBtn.tintColor = hexStringToUIColor(hex: "1d7399")
        // Initialization code
        
    }

    func setupDataOnCell(orderDetails:NSDictionary){
        if let coachInfo = orderDetails["coach_id"] as? NSDictionary {
            let userName = (coachInfo["fname"] as? String ?? "")  + " " + (coachInfo["lname"] as? String ?? "")
            lbl_userName.text = userName
            if let profile_pic = coachInfo["profile_pic"] as? String  {
                let imageUrl = URL(string:profile_pic )
                userImage.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "AdvisorProfileImg"), options:.refreshCached)
            }
            if let categories = coachInfo["categories"] as? NSArray {
                lbl_displayName.text =  getCategoryList(array: categories)
            }
        }
        lbl_description.text = orderDetails["title"]as? String ?? ""
        if let created_date = orderDetails["createOn"] as? String {
              let date =  convertStringintoDate(dateStr: created_date)
            
            lbl_sessionDate.text = date.getCreatedDate()
              let dateStr = date.getElapsedInterval()
              lbl_PostcreatedDate.text = dateStr
        }
        
        if let status = orderDetails["order_status"] as? Int {
            
            if status == 0  {
                  lbl_OrderStatus.isHidden = false
                sessionView.isHidden = true
                lbl_OrderStatus.text = "Pending"
                 lbl_OrderStatus.font = UIFont.systemFont(ofSize: 13)
                 lbl_OrderStatus.textColor = UIColor.lightOrange
                LeaveReviewBtn.isHidden = true
            }else if status == 1 {
                sessionView.isHidden = false
                 lbl_OrderStatus.isHidden = true
                lbl_OrderStatus.isHidden = true
                lbl_OrderStatus.text = "Decline"
                 lbl_OrderStatus.font = UIFont.systemFont(ofSize: 13)
                lbl_OrderStatus.textColor = UIColor.red
                LeaveReviewBtn.isHidden = true
            }
            else if status == 2 {
                sessionView.isHidden = true
                 lbl_OrderStatus.isHidden = false
                lbl_OrderStatus.text = "Decline"
                lbl_OrderStatus.textColor = UIColor.red
                 lbl_OrderStatus.font = UIFont.systemFont(ofSize: 13)
                LeaveReviewBtn.isHidden = true
            }else if status == 3 {
                sessionView.isHidden = true
                lbl_OrderStatus.textColor = UIColor.black
               
              lbl_OrderStatus.isHidden = false
                if let reviewInfo = orderDetails["review"] as? NSDictionary {
                      LeaveReviewBtn.isHidden = true
                }else {
                      LeaveReviewBtn.isHidden = false
                }
                
             //   lbl_OrderStatus.backgroundColor = UIColor.red
                if let created_date = orderDetails["complete_time"] as? String {
                    let date =  convertStringintoDate(dateStr: created_date)
                    let dateStr = date.getCreatedDate()
                    lbl_OrderStatus.text = "Completed" + " " + date.getCreatedDate()
                    lbl_OrderStatus.font = UIFont.systemFont(ofSize: 10)
                  
                }
                
                
                    
                }
                
            }else{
                sessionView.isHidden = false
                LeaveReviewBtn.isHidden = true
            }
        }
        
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

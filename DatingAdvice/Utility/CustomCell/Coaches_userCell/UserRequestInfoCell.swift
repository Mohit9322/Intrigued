//
//  UserRequestInfoCell.swift
//  Intrigued
//
//  Created by daniel helled on 13/10/17.
//  Copyright © 2017 daniel helled. All rights reserved.
//

import UIKit

class UserRequestInfoCell: UITableViewCell {

    @IBOutlet weak var user_image: UIImageView!
    @IBOutlet weak var lbl_userName: UILabel!
    @IBOutlet weak var lbl_priceMode: UILabel!
    @IBOutlet weak var lbl_sessionExpire: UILabel!
    @IBOutlet weak var lbl_price: UILabel!
    @IBOutlet weak var lbl_sessionDate: UILabel!
    @IBOutlet weak var planImage: UIImageView!
    @IBOutlet weak var lbl_responseTime: UILabel!
    @IBOutlet weak var paymentDate: UILabel!
    @IBOutlet weak var orderStatusLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        user_image.setRounded()
        // Initialization code
    }
    func setupDataOnCell(orderDetails:NSDictionary){
        
        print(orderDetails)
        
//        let orderStatus = orderDetails["order_status"] as? Int
//        if orderStatus == 0 {
//            orderStatusLbl.text = "Pending"
//        }else if orderStatus == 1 {
//            orderStatusLbl.text = "Accepted"
//        }else if orderStatus == 2 {
//            orderStatusLbl.text = "Decline"
//        }else if orderStatus == 3 {
//            orderStatusLbl.text = "Complete"
//        }
        if let userInfo = orderDetails["user_id"] as? NSDictionary {
            let userName = (userInfo["fname"] as? String ?? "")  + " " + (userInfo["lname"] as? String ?? "")
            lbl_userName.text = userName
            if let profile_pic = userInfo["profile_pic"] as? String  {
                let imageUrl = URL(string:profile_pic )
                user_image.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "defult_pic"), options:.refreshCached)
            }
        }
        let created_date =  orderDetails["accept_time"] as? String
        let date =  convertStringintoDate(dateStr: created_date!)
        let date1 = date.addingTimeInterval(TimeInterval(24.0 * 60.0 * 60.0))
        print(date1.getCreatedDate())
        self.lbl_sessionDate.text = date1.getCreatedDate()
       
        if let type  = orderDetails["type"] as? Int {
            if type == 1{
                lbl_priceMode.text = "Direct Message"
                lbl_responseTime.text = "Response Delivered within 24 hours"
                planImage.image = UIImage.init(named: "mail_icon")
                if let coachInfo = orderDetails["coach_id"] as? NSDictionary {
                    lbl_price.text = coachInfo["direct_price"] as? String ?? ""
                }
            }
            else if type == 2 {
                lbl_priceMode.text = "Rush Direct Message"
                lbl_responseTime.font = UIFont(name: "OpenSans-SemiboldItalic", size: 12.0)
                lbl_responseTime.textColor = UIColor.lightGreen
                lbl_responseTime.text =  "Response Delivered within 60 mins"
                planImage.image = UIImage.init(named: "rush_mail_icon")
                if let coachInfo = orderDetails["coach_id"] as? NSDictionary {
                    lbl_price.text = coachInfo["rush_direct_price"] as? String ?? ""
                }
            }
            else{
                lbl_priceMode.text = "Live Chat"
                lbl_responseTime.text = "Live Messaging"
                planImage.image = UIImage.init(named: "live_chat_icon")
                if let coachInfo = orderDetails["coach_id"] as? NSDictionary {
                    lbl_price.text = coachInfo["livechat_price"] as? String ?? ""
                }
            }
        }
        
    }
    func setupEarningDataOnCell(orderDetails:NSDictionary){
          print(orderDetails)
      
        if let userInfo = orderDetails["user_id"] as? NSDictionary {
            let userName = (userInfo["fname"] as? String ?? "")  + " " + (userInfo["lname"] as? String ?? "")
            lbl_userName.text = userName
            if let profile_pic = userInfo["profile_pic"] as? String  {
                let imageUrl = URL(string:profile_pic )
                user_image.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "defult_pic"), options:.refreshCached)
            }
        }
        
        let orderDict = orderDetails["order_id"] as? NSDictionary
        let created_date =  orderDict!["accept_time"] as? String
//        let orderStatus = orderDict!["order_status"] as? Int
//        if orderStatus == 0 {
//            orderStatusLbl.text = "Pending"
//        }else if orderStatus == 1 {
//            orderStatusLbl.text = "Accepted"
//        }else if orderStatus == 2 {
//            orderStatusLbl.text = "Decline"
//        }else if orderStatus == 3 {
//            orderStatusLbl.text = "Complete"
//        }
        let date =  convertStringintoDate(dateStr: created_date!)
        let date1 = date.addingTimeInterval(TimeInterval(24.0 * 60.0 * 60.0))
        print(date1.getCreatedDate())
        self.lbl_sessionDate.text = date1.getCreatedDate()
        
        if let type  = orderDetails["payment_type"] as? Int {
            if type == 1{
                lbl_priceMode.text = "Direct Message"
                lbl_responseTime.text = "Response Delivered within 24 hours"
                planImage.image = UIImage.init(named: "mail_icon")
                if let coachInfo = orderDetails["coach_id"] as? NSDictionary {
                    
             var paymentStr =   orderDetails["payment"] as? String ?? ""
                    paymentStr = "$" + paymentStr
                    lbl_price.text = paymentStr
                }
            }
            else if type == 2 {
                lbl_priceMode.text = "Rush Direct Message"
                lbl_responseTime.font = UIFont(name: "OpenSans-SemiboldItalic", size: 12.0)
                lbl_responseTime.textColor = UIColor.lightGreen
                lbl_responseTime.text =  "Response Delivered within 60 mins"
                planImage.image = UIImage.init(named: "rush_mail_icon")
                if let coachInfo = orderDetails["coach_id"] as? NSDictionary {
                    var paymentStr =   orderDetails["payment"] as? String ?? ""
                    paymentStr = "$" + paymentStr
                    lbl_price.text = paymentStr
                }
            }
            else{
                lbl_priceMode.text = "Live Chat"
                lbl_responseTime.text = "Live Messaging"
                planImage.image = UIImage.init(named: "live_chat_icon")
                if let coachInfo = orderDetails["coach_id"] as? NSDictionary {
                    var paymentStr =   orderDetails["payment"] as? String ?? ""
                    paymentStr = "$" + paymentStr
                    lbl_price.text = paymentStr
                }
            }
        }
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

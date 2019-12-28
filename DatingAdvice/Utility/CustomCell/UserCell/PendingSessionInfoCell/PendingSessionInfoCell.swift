//
//  PendingSessionInfoCell.swift
//  Intrigued
//
//  Created by daniel helled on 27/10/17.
//  Copyright © 2017 daniel helled. All rights reserved.
//

import UIKit

class PendingSessionInfoCell: UITableViewCell {

    @IBOutlet weak var user_image: UIImageView!
    @IBOutlet weak var lbl_coachName: UILabel!
    @IBOutlet weak var lbl_category: UILabel!
    @IBOutlet weak var lbl_priceMode: UILabel!
    @IBOutlet weak var lbl_sessionExpire: UILabel!
    @IBOutlet weak var lbl_sessionDate: UILabel!
    @IBOutlet weak var planImage: UIImageView!
    @IBOutlet weak var lbl_responseTime: UILabel!
    @IBOutlet weak var lbl_OrderStatus: UILabel!
    @IBOutlet weak var sessionView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.user_image.setRounded()
    }
    func showDetailsonView(orderDetails:NSDictionary) {
        
        print(orderDetails)
        
        let created_date =  orderDetails["accept_time"] as? String
        let date =  convertStringintoDate(dateStr: created_date!)
        let date1 = date.addingTimeInterval(TimeInterval(24.0 * 60.0 * 60.0))
        print(date1.getCreatedDate())
        self.lbl_sessionDate.text = date1.getCreatedDate()
        
        if let userInfo = orderDetails["coach_id"] as? NSDictionary {
            let userName = (userInfo["fname"] as? String ?? "")  + " " + (userInfo["lname"] as? String ?? "")
            lbl_coachName.text = userName
            if let categories = userInfo["categories"] as? NSArray {
                lbl_category.text =  getCategoryList(array: categories)
            }
            if let profile_pic = userInfo["profile_pic"] as? String  {
                let imageUrl = URL(string:profile_pic )
                user_image.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "defult_pic"), options:.refreshCached)
            }
        }
        
        if let type  = orderDetails["type"] as? Int {
            if type == 1{
                lbl_priceMode.text = "Direct Message"
                lbl_responseTime.text = "Response Delivered within 24 hours"
                planImage.image = UIImage.init(named: "mail_icon")
            }
            else if type == 2 {
                lbl_priceMode.text = "Rush Direct Message"
                lbl_responseTime.font = UIFont(name: "OpenSans-SemiboldItalic", size: 12.0)
                lbl_responseTime.textColor = UIColor.lightGreen
                lbl_responseTime.text =  "Response Delivered within 60 mins"
                planImage.image = UIImage.init(named: "rush_mail_icon")
            }
            else{
                lbl_priceMode.text = "Live Chat"
                lbl_responseTime.text = "Live Messaging"
                planImage.image = UIImage.init(named: "live_chat_icon")
            }
        }
        
        if let status = orderDetails["order_status"] as? Int {
            
            if status == 0  {
                sessionView.isHidden = true
                lbl_OrderStatus.text = "Pending"
                lbl_OrderStatus.textColor = UIColor.lightOrange
            }
            else if status == 2 {
                sessionView.isHidden = true
                lbl_OrderStatus.text = "Decline"
                lbl_OrderStatus.textColor = UIColor.red
            }
            else{
                sessionView.isHidden = false
            }
        }
        
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

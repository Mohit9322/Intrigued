//
//  CoachesSessionCell.swift
//  Intrigued
//
//  Created by daniel helled on 06/10/17.
//  Copyright © 2017 daniel helled. All rights reserved.
//

import UIKit

class CoachesSessionCell: UITableViewCell {
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var view_container: UIView!
    @IBOutlet weak var requesView: UIView!
    @IBOutlet weak var lbl_userName: UILabel!
    @IBOutlet weak var lbl_description: UILabel!
    @IBOutlet weak var btn_accept: UIButton!
    @IBOutlet weak var btn_decline: UIButton!
    @IBOutlet var LblQuestion: UILabel!
    @IBOutlet weak var InfoBtnRequest: UIButton!
    @IBOutlet weak var ReviewBaseView: UIView!
    @IBOutlet weak var completeDateLbl: UILabel!
    @IBOutlet weak var LeaveReviewBtn: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        self.view_container.layer.cornerRadius = 12.0
//        self.view_container.layer.borderWidth = 1.0
//        self.view_container.layer.borderColor = UIColor.clear.cgColor
//        self.view_container.layer.masksToBounds = true
       
        self.view_container.layer.shadowColor = UIColor.lightGray.cgColor
        self.view_container.layer.shadowOffset = CGSize(width: 0, height: 4.0)
        self.view_container.layer.shadowRadius = 2.0
        self.view_container.layer.shadowOpacity = 1.0
        self.view_container.layer.masksToBounds = false
        
        userImage.setRounded()
        // Initialization code
    }

    func setupDataOnCell(orderDetails:NSDictionary){
        
        print(orderDetails)
        if let userInfo = orderDetails["user_id"] as? NSDictionary {
            let userName = (userInfo["fname"] as? String ?? "")  + " " + (userInfo["lname"] as? String ?? "")
            lbl_userName.text = userName
            if let profile_pic = userInfo["profile_pic"] as? String  {
                let imageUrl = URL(string:profile_pic )
                userImage.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "defult_pic"), options:.refreshCached)
            }
        }
        
        let  strDesc:String = orderDetails["title"]as? String ?? ""
        let strQuestion:String = orderDetails["question"]as? String ?? ""
        lbl_description.text = orderDetails["title"]as? String ?? ""
        LblQuestion.text = orderDetails["question"]as? String ?? ""
        
        if let created_date = orderDetails["complete_time"] as? String {
            let date =  convertStringintoDate(dateStr: created_date)
             let dateStr = date.getCreatedDate()
            completeDateLbl.text = "Completed On" + " " + date.getCreatedDate()
           
        }
        
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

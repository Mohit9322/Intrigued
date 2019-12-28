//
//  HighestRatedCell.swift
//  DatingAdvice
//
//  Created by daniel helled on 15/09/17.
//  Copyright © 2017 daniel helled. All rights reserved.
//

import UIKit

class HighestRatedCell: UITableViewCell {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var user_image: UIImageView!
    @IBOutlet weak var lbl_userName: UILabel!
    @IBOutlet weak var lbl_userDetails: UILabel!
    @IBOutlet weak var lbl_like: UILabel!
    @IBOutlet weak var lbl_dislike: UILabel!
    @IBOutlet weak var orderButton: UIButton!
    @IBOutlet weak var lbl_response: UILabel!
    @IBOutlet weak var lbl_average: UILabel!
  
    override func awakeFromNib() {
        super.awakeFromNib()
        self.containerView.layer.cornerRadius = 12.0
        self.containerView.layer.borderWidth = 1.0
        self.containerView.layer.borderColor = UIColor.clear.cgColor
        self.containerView.layer.masksToBounds = true
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 4.0)
        self.layer.shadowRadius = 2.0
        self.layer.shadowOpacity = 1.0
        self.layer.masksToBounds = false
        
//        self.lbl_userName.font = UIFont.systemFont(ofSize: 18)
//        self.lbl_userDetails.font = UIFont.systemFont(ofSize: 17)
//        self.lbl_like.font = UIFont.systemFont(ofSize: 17)
//        self.lbl_dislike.font = UIFont.systemFont(ofSize: 17)
//        self.lbl_response.font = UIFont.systemFont(ofSize: 17)
//        self.lbl_average.font = UIFont.systemFont(ofSize: 17)
      }
    
    func setUpData(coachesDetails:NSDictionary){
        
        print(coachesDetails)
        var directStatus = Int()
        var rushdirectStatus = Int()
        var liveChatStatus = Int()
        
        let userName = (coachesDetails["fname"] as? String ?? "")  + " " + (coachesDetails["lname"] as? String ?? "")
        lbl_userName.text = userName
        if let categories = coachesDetails["categories"] as? NSArray {
            lbl_userDetails.text =  getCategoryList(array: categories)
        }
        //lbl_userDetails.text = coachesDetails["about"] as? String ?? ""
        if let profile_pic = coachesDetails["profile_pic"] as? String  {
            let imageUrl = URL(string:profile_pic )
            user_image.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "AdvisorProfileImg"), options:.refreshCached)
        }
        if let likes = coachesDetails["likes"] as? NSNumber {
            lbl_like.text = String(describing: likes)
        }
        if let dislikes = coachesDetails["dislikes"] as? NSNumber {
            lbl_dislike.text = String(describing: dislikes)
        }
        if let avgResponse = coachesDetails["avg_response"] as? NSNumber {
            lbl_average.text = String(describing: avgResponse)
        }
        if let timely_response = coachesDetails["timely_response"] as? NSNumber {
            lbl_response.text = String(describing: timely_response) + "%"
        }
        
       
        if let direct_Status = coachesDetails["direct_Status"] as? Int {
           directStatus =  direct_Status
        }
        
        if let rush_direct_Status = coachesDetails["rush_direct_Status"] as? Int {
            rushdirectStatus =  rush_direct_Status
        }

        if let livechat_Status = coachesDetails["livechat_Status"] as? Int {
            liveChatStatus = livechat_Status
        }
        
      
        if directStatus == 1{
            var direct_Price =  (coachesDetails["direct_price"] as? String ?? "")
            if direct_Price.hasPrefix("$") { // true
                direct_Price.remove(at: direct_Price.startIndex)
            }
            direct_Price = direct_Price.replacingOccurrences(of: ".00", with: "")
            orderButton.setTitle(("Order $" + direct_Price), for: .normal)
        }
        else if rushdirectStatus == 1{
            var rush_direct_Price =  (coachesDetails["rush_direct_price"] as? String ?? "")
            if rush_direct_Price.hasPrefix("$") { // true
                rush_direct_Price.remove(at: rush_direct_Price.startIndex)
            }
            rush_direct_Price = rush_direct_Price.replacingOccurrences(of: ".00", with: "")
            orderButton.setTitle(("Order $" + rush_direct_Price), for: .normal)
        }
        else if liveChatStatus == 1{
            var liveChat_Price = (coachesDetails["livechat_price"] as? String ?? "")
            if liveChat_Price.hasPrefix("$") { // true
                liveChat_Price.remove(at: liveChat_Price.startIndex)
            }
            liveChat_Price = liveChat_Price.replacingOccurrences(of: ".00", with: "")
            orderButton.setTitle(("Order $" + liveChat_Price), for: .normal)
        }
        
    }
    //MARK: *********** FILTER WORKING DIRECT PRICE -- RUSH DIRECT ************
    func setUpAdvisorFilterData(coachesDetails:NSDictionary,filterType:String){
        //        var directStatus = Int()
        //        var rushdirectStatus = Int()
        //        var liveChatStatus = Int()
        let directPrice = "1"
        let rushPrice = "2"
        let allAdvisorPrice = "3"
        
        let userName = (coachesDetails["fname"] as? String ?? "")  + " " + (coachesDetails["lname"] as? String ?? "")
        lbl_userName.text = userName
        if let categories = coachesDetails["categories"] as? NSArray {
            lbl_userDetails.text =  getCategoryList(array: categories)
        }
        if let profile_pic = coachesDetails["profile_pic"] as? String  {
            let imageUrl = URL(string:profile_pic )
            user_image.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "AdvisorProfileImg"), options:.refreshCached)
        }
        if let likes = coachesDetails["likes"] as? NSNumber {
            lbl_like.text = String(describing: likes)
        }
        if let dislikes = coachesDetails["dislikes"] as? NSNumber {
            lbl_dislike.text = String(describing: dislikes)
        }
        if let avgResponse = coachesDetails["avg_response"] as? NSNumber {
            lbl_average.text = String(describing: avgResponse)
        }
        if let timely_response = coachesDetails["timely_response"] as? NSNumber {
            lbl_response.text = String(describing: timely_response) + "%"
        }
        
        if directPrice == filterType {
            var direct_Price =  (coachesDetails["direct_price"] as? String ?? "")
            if direct_Price.hasPrefix("$") { // true
                direct_Price.remove(at: direct_Price.startIndex)
            }
            direct_Price = direct_Price.replacingOccurrences(of: ".00", with: "")
            orderButton.setTitle(("Order $" + direct_Price), for: .normal)
        }
        else if rushPrice == filterType {
            var rush_direct_Price =  (coachesDetails["rush_direct_price"] as? String ?? "")
            if rush_direct_Price.hasPrefix("$") { // true
                rush_direct_Price.remove(at: rush_direct_Price.startIndex)
            }
            rush_direct_Price = rush_direct_Price.replacingOccurrences(of: ".00", with: "")
            orderButton.setTitle(("Order $" + rush_direct_Price), for: .normal)
        }
        else if allAdvisorPrice == filterType {
            var liveChat_Price = (coachesDetails["livechat_price"] as? String ?? "")
            if liveChat_Price.hasPrefix("$") { // true
                liveChat_Price.remove(at: liveChat_Price.startIndex)
            }
            liveChat_Price = liveChat_Price.replacingOccurrences(of: ".00", with: "")
            orderButton.setTitle(("Order $" + liveChat_Price), for: .normal)
        }
    }
    
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

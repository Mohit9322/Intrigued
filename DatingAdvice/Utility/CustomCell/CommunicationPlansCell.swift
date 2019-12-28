//
//  CommunicationPlansCell.swift
//  Intrigued
//
//  Created by daniel helled on 18/09/17.
//  Copyright © 2017 daniel helled. All rights reserved.
//

import UIKit

class CommunicationPlansCell: UITableViewCell {
   @IBOutlet weak var lbl_plan: UILabel!
   @IBOutlet weak var lbl_planInfo: UILabel!
   @IBOutlet weak var planImage: UIImageView!
   @IBOutlet weak var orderButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setUpData(coachesDetails:NSDictionary,index:Int){
    
    var directStatus = Int()
    var rushdirectStatus = Int()
    var liveChatStatus = Int()
        
        print(coachesDetails)
    
    if let direct_Status = coachesDetails["direct_Status"] as? Int {
        directStatus =  direct_Status
    }
    
    if let rush_direct_Status = coachesDetails["rush_direct_Status"] as? Int {
        rushdirectStatus =  rush_direct_Status
    }
    
    if let livechat_Status = coachesDetails["livechat_Status"] as? Int {
        liveChatStatus = livechat_Status
    }
    
    
    if index == 0{
        var direct_Price =  (coachesDetails["direct_price"] as? String ?? "")
        if direct_Price.hasPrefix("$") { // true
            direct_Price.remove(at: direct_Price.startIndex)
        }
        direct_Price = direct_Price.replacingOccurrences(of: ".00", with: "")
        orderButton.setTitle(("Order $" + direct_Price), for: .normal)
    }
    else if index == 1{
        var rush_direct_Price =  (coachesDetails["rush_direct_price"] as? String ?? "")
        if rush_direct_Price.hasPrefix("$") { // true
            rush_direct_Price.remove(at: rush_direct_Price.startIndex)
        }
        rush_direct_Price = rush_direct_Price.replacingOccurrences(of: ".00", with: "")
        orderButton.setTitle(("Order $" + rush_direct_Price), for: .normal)
    }
     else {
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

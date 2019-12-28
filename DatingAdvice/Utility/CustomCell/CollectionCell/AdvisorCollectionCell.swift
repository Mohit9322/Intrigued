//
//  AdvisorCollectionCell.swift
//  DatingAdvice
//
//  Created by daniel helled on 15/09/17.
//  Copyright © 2017 daniel helled. All rights reserved.
//

import UIKit

class AdvisorCollectionCell: UICollectionViewCell {

    @IBOutlet weak var VideoBaseView: UIView!
    @IBOutlet weak var thumbnailImgView: UIImageView!
    @IBOutlet weak var VideoPlayButton: UIButton!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var advisor_profileimage: UIImageView!
    @IBOutlet weak var user_image: UIImageView!
    @IBOutlet weak var lbl_userName: UILabel!
    @IBOutlet weak var lbl_userDetails: UILabel!
    @IBOutlet weak var lbl_like: UILabel!
    @IBOutlet weak var lbl_dislike: UILabel!
    @IBOutlet weak var orderButton: UIButton!
    @IBOutlet weak var lbl_response: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.containerView.layer.cornerRadius = 15.0
        self.containerView.layer.borderWidth = 1.0
        self.containerView.layer.borderColor = UIColor.clear.cgColor
        self.containerView.layer.masksToBounds = true
       
        let videoIconImg = UIImage(named: "VideoPlayImg")
        VideoPlayButton.setBackgroundImage(videoIconImg, for: .normal)
        
        self.advisor_profileimage.clipsToBounds = true
        self.advisor_profileimage.contentMode = .scaleAspectFill
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 4.0)
        self.layer.shadowRadius = 2.0
        self.layer.shadowOpacity = 1.0
        self.layer.masksToBounds = false
        self.user_image.setRounded()
        //self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.containerView.layer.cornerRadius).cgPath
        // Initialization code
    }
    
    @IBAction func orderButtonAction(_ sender: Any) {
        
        
    }
    
    func setUpData(coachesDetails:NSDictionary){
        var directStatus = Int()
        var rushdirectStatus = Int()
        var liveChatStatus = Int()
         print(coachesDetails)
        let userName = (coachesDetails["fname"] as? String ?? "") + " "  + (coachesDetails["lname"] as? String ?? "")
        lbl_userName.text = userName
        if let categories = coachesDetails["categories"] as? NSArray {
            
            var  experttText = getCategoryList(array: categories)
            print(experttText)
            experttText = "Expertise: " + experttText
            print(experttText)
            lbl_userDetails.text =  experttText
        }
        //lbl_userDetails.text = coachesDetails["about"] as? String ?? ""
        if let profile_pic = coachesDetails["profile_pic"] as? String  {
            
            if profile_pic == "" {
                self.advisor_profileimage.clipsToBounds = false
                self.advisor_profileimage.contentMode = .scaleAspectFit
            }else{
                self.advisor_profileimage.clipsToBounds = true
                self.advisor_profileimage.contentMode = .scaleAspectFill
            }
            
            let imageUrl = URL(string:profile_pic )
            advisor_profileimage.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "AdvisorProfileImg"), options:.refreshCached)
        }
        
        if let likes = coachesDetails["likes"] as? NSNumber {
            lbl_like.text = String(describing: likes)
        }
        if let dislikes = coachesDetails["dislikes"] as? NSNumber {
            lbl_dislike.text = String(describing: dislikes)
        }
        if let timely_response = coachesDetails["timely_response"] as? NSNumber {
            lbl_response.text = String(describing: timely_response) + "% Responses"
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
        
        
        if let coachVideos = coachesDetails["coach_video"] as? String {
           VideoBaseView.isHidden = false
            VideoBaseView.isUserInteractionEnabled =  false
            advisor_profileimage.isHidden = true
            
            advisor_profileimage.isUserInteractionEnabled = false
            let imageUrl = URL(string:(coachesDetails["coach_video_thumb"] as? String)! )
            thumbnailImgView.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "AdvisorProfileImg"), options:.refreshCached)
            #imageLiteral(resourceName: "VideoPlayImg")
        }else{
            VideoBaseView.isHidden = true
            advisor_profileimage.isHidden = false
           
        }
        
       
       
    }
}

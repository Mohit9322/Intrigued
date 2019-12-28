//
//  ReviewsDetailsCell.swift
//  Intrigued
//
//  Created by daniel helled on 18/09/17.
//  Copyright © 2017 daniel helled. All rights reserved.
//

import UIKit

class ReviewsDetailsCell: UITableViewCell {
    @IBOutlet weak var lbl_userName: UILabel!
    @IBOutlet weak var lbl_reviewDetials: UILabel!
    @IBOutlet weak var like_unlikeImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        // Initialization code
    }
    
    
    //// From ReviewList Vc
    func showReviewDetailsView(reviewArray:NSDictionary) {
        if let userId = reviewArray["user_id"] as? [String:Any] {
            let userName = (userId["fname"] as? String ?? "") + " " + (userId["lname"] as? String ?? "")
            lbl_userName.text = userName
        }
        
        // if let reviewInfo = orderDetails["reviews"] as? NSDictionary {
        lbl_reviewDetials.text = reviewArray["review"] as? String ?? ""
        if let isLike = reviewArray["isLike"] as? NSNumber{
            if isLike == 1 {
                like_unlikeImage.image = UIImage.init(named: "like_btn")
            }
            else{
                like_unlikeImage.image = UIImage.init(named: "dislike_btn")
            }
        }
        //}
    }
    
    
    /// From Advisor Detail cell
    func showDetailsonView(reviewDetails:NSDictionary){
        
        lbl_reviewDetials.text = reviewDetails["review"] as? String ?? ""
        if let isLike = reviewDetails["isLike"] as? NSNumber{
            if isLike == 1 {
                like_unlikeImage.image = UIImage.init(named: "like_btn")
            }
            else{
                like_unlikeImage.image = UIImage.init(named: "dislike_btn")
            }
        }
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

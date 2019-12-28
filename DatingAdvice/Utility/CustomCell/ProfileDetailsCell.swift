//
//  ProfileDetailsCell.swift
//  Intrigued
//
//  Created by daniel helled on 18/09/17.
//  Copyright © 2017 daniel helled. All rights reserved.
//

import UIKit

class ProfileDetailsCell: UITableViewCell {
    @IBOutlet weak var user_image: UIImageView!
    @IBOutlet weak var lbl_userName: UILabel!
    @IBOutlet weak var lbl_userDetails: UILabel!
    @IBOutlet weak var lbl_like: UILabel!
    @IBOutlet weak var lbl_dislike: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.user_image.setRounded()
        // Initialization code
    }

    func setupDetailsonView(coachesDetails:NSDictionary){
        
        let userName = (coachesDetails["fname"] as? String ?? "") + "  " + (coachesDetails["lname"] as? String ?? "")
        lbl_userName.text = userName
        lbl_userDetails.text = coachesDetails["about"] as? String ?? ""
        if let profile_pic = coachesDetails["profile_pic"] as? String  {
            let imageUrl = URL(string:profile_pic )
            user_image.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "defult_pic"), options:.refreshCached)
        }
        if let likes = coachesDetails["likes"] as? NSNumber {
            lbl_like.text = String(describing: likes)
        }
        if let dislikes = coachesDetails["dislikes"] as? NSNumber {
            lbl_dislike.text = String(describing: dislikes)
        }
        
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

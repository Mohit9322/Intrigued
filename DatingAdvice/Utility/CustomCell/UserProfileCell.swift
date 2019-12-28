//
//  UserProfileCell.swift
//  Intrigued
//
//  Created by daniel helled on 28/09/17.
//  Copyright © 2017 daniel helled. All rights reserved.
//

import UIKit

class UserProfileCell: UITableViewCell {
    @IBOutlet weak var user_image: UIImageView!
    @IBOutlet weak var lbl_userName: UILabel!
    
    @IBOutlet weak var UserProfileLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        user_image.setRounded()
        self.selectionStyle = .none
        self.backgroundColor = UIColor.white
        UserProfileLbl.layer.masksToBounds =  true
        UserProfileLbl.layer.cornerRadius = 37.5
        UserProfileLbl.textColor = UIColor.white
        UserProfileLbl.backgroundColor = hexStringToUIColor(hex: "#1d7399")
        UserProfileLbl.textAlignment = .center
        UserProfileLbl.font = UIFont.boldSystemFont(ofSize: 37)
        
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

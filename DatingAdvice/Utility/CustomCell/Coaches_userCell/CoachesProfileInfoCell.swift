//
//  CoachesProfileInfoCell.swift
//  Intrigued
//
//  Created by daniel helled on 09/10/17.
//  Copyright © 2017 daniel helled. All rights reserved.
//

import UIKit

class CoachesProfileInfoCell: UITableViewCell {
    @IBOutlet weak var user_image: UIImageView!
    @IBOutlet weak var lbl_userName: UILabel!
    @IBOutlet weak var lbl_totalCredit: UILabel!
    @IBOutlet weak var userProfileNameLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        user_image.setRounded()
        userProfileNameLbl.layer.masksToBounds =  true
        userProfileNameLbl.layer.cornerRadius = 50.0
        userProfileNameLbl.textColor = UIColor.white
        userProfileNameLbl.backgroundColor = hexStringToUIColor(hex: "#1d7399")
        userProfileNameLbl.textAlignment = .center
        userProfileNameLbl.font = UIFont.boldSystemFont(ofSize: 50)
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

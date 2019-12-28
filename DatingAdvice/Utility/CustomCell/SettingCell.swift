//
//  SettingCell.swift
//  DatingAdvice
//
//  Created by daniel helled on 13/09/17.
//  Copyright © 2017 daniel helled. All rights reserved.
//

import UIKit

class SettingCell: UITableViewCell {
    
    @IBOutlet weak var next_icon: UIImageView!
    @IBOutlet weak var view_BottomSepartor: UIView!
    @IBOutlet weak var view_inApppurch: UIView!
    @IBOutlet weak var view_passcode: UIView!
    @IBOutlet weak var view_Logout: UIView!
    @IBOutlet weak var lbl_SettingTitle: UILabel!
    @IBOutlet weak var lbl_details: UILabel!
    @IBOutlet weak var lbl_passcode: UILabel!
     @IBOutlet weak var switchOn_Off: UISwitch!
    @IBOutlet weak var switchView: UIView!
    @IBOutlet weak var connect_stripe_button: UIButton!
    @IBOutlet weak var stripe_lbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

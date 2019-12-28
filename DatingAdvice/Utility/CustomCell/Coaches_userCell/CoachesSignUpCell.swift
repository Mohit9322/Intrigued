//
//  CoachesSignUpCell.swift
//  Intrigued
//
//  Created by daniel helled on 04/10/17.
//  Copyright © 2017 daniel helled. All rights reserved.
//

import UIKit

class CoachesSignUpCell: UITableViewCell {
    @IBOutlet weak var userImage: UIImageView!
    
    @IBOutlet weak var userNameProfileLbl: UILabel!
    @IBOutlet weak var EditBtn: UIButton!
    @IBOutlet weak var Tf_Fristname: UITextField!
    @IBOutlet weak var phoneLbl: UILabel!
    @IBOutlet weak var Tf_Secondname: UITextField!
    @IBOutlet weak var Tf_emailid: UITextField!
    @IBOutlet weak var Tf_phoneNo: UITextField!
    @IBOutlet weak var Btn_profilepic: UIButton!
    @IBOutlet weak var phoneBaseView: UIView!
    override func awakeFromNib() {
    
        super.awakeFromNib()
        userImage.setRounded()
        userNameProfileLbl.layer.masksToBounds =  true
        userNameProfileLbl.layer.cornerRadius = 50.0
        userNameProfileLbl.textColor = UIColor.white
        userNameProfileLbl.backgroundColor = hexStringToUIColor(hex: "#1d7399")
        userNameProfileLbl.textAlignment = .center
        userNameProfileLbl.font = UIFont.boldSystemFont(ofSize: 50)
       
        
        // Initialization code
    }
  
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

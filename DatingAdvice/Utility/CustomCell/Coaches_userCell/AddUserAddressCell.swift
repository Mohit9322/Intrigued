//
//  AddUserAddressCell.swift
//  Intrigued
//
//  Created by daniel helled on 05/10/17.
//  Copyright © 2017 daniel helled. All rights reserved.
//

import UIKit

class AddUserAddressCell: UITableViewCell {
  @IBOutlet weak var tf_address: UITextField!
    @IBOutlet weak var addressBtn: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

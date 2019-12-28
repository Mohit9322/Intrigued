//
//  BuyTableViewCell.swift
//  Intrigued
//
//  Created by SWS on 01/02/18.
//  Copyright © 2018 daniel helled. All rights reserved.
//

import UIKit

class BuyTableViewCell: UITableViewCell {

    @IBOutlet weak var buyButton_btn: UIButton!
    @IBOutlet weak var creditValue: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

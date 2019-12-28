//
//  SelectCardCell.swift
//  Intrigued
//
//  Created by SWS on 01/02/18.
//  Copyright © 2018 daniel helled. All rights reserved.
//

import UIKit

class SelectCardCell: UITableViewCell {

    @IBOutlet weak var cardNumber_lbl: UILabel!
    @IBOutlet weak var card_type_image: UIImageView!
    @IBOutlet weak var select_image: UIImageView!
    @IBOutlet weak var card_brand_lbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

//
//  ViewAllReviewHeaderCell.swift
//  Intrigued
//
//  Created by daniel helled on 31/10/17.
//  Copyright © 2017 daniel helled. All rights reserved.
//

import UIKit

class ViewAllReviewHeaderCell: UITableViewCell {

    @IBOutlet weak var lbl_reviewCount: UILabel!
    @IBOutlet weak var btn_viewAll: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

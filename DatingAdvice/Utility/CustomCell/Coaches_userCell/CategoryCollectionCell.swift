//
//  CategoryCollectionCell.swift
//  Intrigued
//
//  Created by daniel helled on 05/10/17.
//  Copyright © 2017 daniel helled. All rights reserved.
//

import UIKit

class CategoryCollectionCell: UICollectionViewCell {

    @IBOutlet weak var categoryImage: UIImageView!
    @IBOutlet weak var categoryName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        categoryImage.setRounded()
        // Initialization code
    }

}

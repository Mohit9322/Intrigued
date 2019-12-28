//
//  UserQuestionImageCell.swift
//  Intrigued
//
//  Created by daniel helled on 02/11/17.
//  Copyright © 2017 daniel helled. All rights reserved.
//

import UIKit

class UserQuestionImageCell: UITableViewCell {
    @IBOutlet weak var imageView1: UIImageView!
    @IBOutlet weak var imageView2: UIImageView!
    @IBOutlet weak var imageView3: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        imageView1.setCornerRadius(radius: 2.0)
        imageView2.setCornerRadius(radius: 2.0)
        imageView3.setCornerRadius(radius: 2.0)
        // Initialization code
    }

    func setupDetailsonView(imageArray:NSArray) {
        imageView1.isHidden = true
        imageView2.isHidden = true
        imageView3.isHidden = true
        var index = 0
        if imageArray.count > 0 {
            for imageStr in imageArray {
                let imageUrl = URL(string:imageStr as? String ?? ""  )
                if index == 0 {
                    imageView1.isHidden = false
                    imageView1.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "defult_pic"), options:.refreshCached)
                }
                if index == 1 {
                    imageView2.isHidden = false
                    imageView2.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "defult_pic"), options:.refreshCached)
                }
                if index == 2 {
                    imageView3.isHidden = false
                    imageView3.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "defult_pic"), options:.refreshCached)
                }
                index = index + 1
            }
        }
       
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

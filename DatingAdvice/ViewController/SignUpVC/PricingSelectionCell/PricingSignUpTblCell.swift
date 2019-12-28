//
//  PricingSignUpTblCell.swift
//  Intrigued
//
//  Created by Shineweb-solutions on 12/02/18.
//  Copyright © 2018 daniel helled. All rights reserved.
//

import UIKit

class PricingSignUpTblCell: UITableViewCell {

    var BaseView = UIView()
     var VerticalNarroewLineView = UIView()
    var ChatTypeBtn = UIButton()
    var PriceTxtFieldBaseView = UIView()
    var priceLbl = UILabel()
    var priceTxtFld = UITextField()
    var rightImgView = UIImageView()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        BaseView = UIView()
        self.contentView.addSubview(BaseView)
        
        rightImgView = UIImageView()
       var rightImg = UIImage(named: "right_mark")!
        rightImgView.image = rightImg
        BaseView.addSubview(rightImgView)
        ChatTypeBtn = priceModeBtn()
         BaseView.addSubview(ChatTypeBtn)
        PriceTxtFieldBaseView = UIView()
        VerticalNarroewLineView = UIView()
        VerticalNarroewLineView.backgroundColor = UIColor.lightGray
        BaseView.addSubview(VerticalNarroewLineView)
        BaseView.addSubview(PriceTxtFieldBaseView)
        priceLbl = UILabel()
        priceTxtFld.textAlignment = .center
        priceTxtFld = UITextField()
        PriceTxtFieldBaseView.addSubview(priceLbl)
        PriceTxtFieldBaseView.addSubview(priceTxtFld)
        
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

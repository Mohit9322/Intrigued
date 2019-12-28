//
//  AddPaymentLiveChatCellTableViewCell.swift
//  Intrigued
//
//  Created by Shineweb-solutions on 23/03/18.
//  Copyright © 2018 daniel helled. All rights reserved.
//

import UIKit

class AddPaymentLiveChatCellTableViewCell: UITableViewCell {
  var BaseView = UIView()
    var rightIconBtn = UIButton()
    var paymentValueLbl = UILabel()
    var PaymentBtn = UIButton()
     var rightImg = UIImage(named: "right_mark")!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        BaseView = UIView()
        self.contentView.addSubview(BaseView)

        rightIconBtn = UIButton()
        rightIconBtn.isUserInteractionEnabled = false
        rightIconBtn.setImage(rightImg, for: .selected)
        rightIconBtn.setImage(nil, for: .normal)
        BaseView.addSubview(rightIconBtn)
        
        paymentValueLbl = UILabel()
         paymentValueLbl.isUserInteractionEnabled = false
        BaseView.addSubview(paymentValueLbl)
        
        PaymentBtn = UIButton()
        BaseView.addSubview(PaymentBtn)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

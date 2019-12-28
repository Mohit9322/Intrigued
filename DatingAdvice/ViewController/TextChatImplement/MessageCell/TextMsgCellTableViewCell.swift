//
//  TextMsgCellTableViewCell.swift
//  Intrigued
//
//  Created by Shineweb-solutions on 16/02/18.
//  Copyright © 2018 daniel helled. All rights reserved.
//

import UIKit

class TextMsgCellTableViewCell: UITableViewCell {

    var BaseView = UIView()
    var RecieverBaseView = UIView()
    var RecieverMsgBaseView = UIView()
    var RecieverTxtView =  UITextView()
    var RecieverCoenerImgView = UIImageView()
    var RecieverProfileImgView = UIImageView()
    var SenderBaseView = UIView()
     var SenderMsgBaseView = UIView()
    var SenderTxtView =  UITextView()
    var SenderCoenerImgView = UIImageView()
    var SenderProfileImgView = UIImageView()
   var senderDateLbl = UILabel()
    var recieverDateLbl = UILabel()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        BaseView = UIView()
        self.contentView.addSubview(BaseView)
        
       RecieverBaseView = UIView()
       self.BaseView.addSubview(RecieverBaseView)
        
        RecieverMsgBaseView = UIView()
        RecieverBaseView.addSubview(RecieverMsgBaseView)
        
      
        
        RecieverCoenerImgView = UIImageView()
        RecieverMsgBaseView.addSubview(RecieverCoenerImgView)
        
        RecieverProfileImgView = UIImageView()
        RecieverMsgBaseView.addSubview(RecieverProfileImgView)
        
        RecieverTxtView = UITextView()
        RecieverTxtView.isUserInteractionEnabled = false
        RecieverMsgBaseView.addSubview(RecieverTxtView)
        
        recieverDateLbl = UILabel()
        RecieverBaseView.addSubview(recieverDateLbl)
        
        SenderBaseView = UIView()
        self.BaseView.addSubview(SenderBaseView)
        
      
        SenderMsgBaseView = UIView()
        SenderBaseView.addSubview(SenderMsgBaseView)
        
        
        
        SenderCoenerImgView = UIImageView()
        SenderMsgBaseView.addSubview(SenderCoenerImgView)
        
        SenderProfileImgView = UIImageView()
        SenderMsgBaseView.addSubview(SenderProfileImgView)
      
        SenderTxtView = UITextView()
        SenderTxtView.isUserInteractionEnabled = false
        SenderMsgBaseView.addSubview(SenderTxtView)
        
        senderDateLbl = UILabel()
        SenderBaseView.addSubview(senderDateLbl)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

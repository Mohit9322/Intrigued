//
//  VideoChatCellTableViewCell.swift
//  Intrigued
//
//  Created by Shineweb-solutions on 30/01/18.
//  Copyright © 2018 daniel helled. All rights reserved.
//

import UIKit
import AVFoundation

class VideoChatCellTableViewCell: UITableViewCell {
    var baseView:UIView = UIView()
   
  
    var RecieverBaseView = UIView()
    var RecieverThumbnailImgView:UIImageView = UIImageView()
    var RecieverCenterPlayButton:UIButton = UIButton()
    var RecieverCoenerImgView = UIImageView()
    var RecieverProfileImgView = UIImageView()
    var recieverDateLbl = UILabel()
    
    var SenderBaseView = UIView()
    var SenderThumbnailImgView:UIImageView = UIImageView()
    var senderCenterPlayButton:UIButton = UIButton()
    var SenderCoenerImgView = UIImageView()
    var SenderProfileImgView = UIImageView()
    var senderDateLbl = UILabel()
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width

        let videoIconImg = UIImage(named: "VideoPlayImg")
        
        baseView = UIView()
     //   baseView = UIView(frame: CGRect(x: 10, y: 10, width:screenWidth - 20, height: self.frame.size.height -  20))
        baseView.backgroundColor = UIColor.white
        baseView.isUserInteractionEnabled = true
        baseView.layer.masksToBounds = true
        baseView.layer.cornerRadius =   5.0
        self.contentView.addSubview(baseView)
        
    
        
        RecieverProfileImgView = UIImageView()
        baseView.addSubview(RecieverProfileImgView)
        
        
        RecieverCoenerImgView = UIImageView()
        baseView.addSubview(RecieverCoenerImgView)
        
        RecieverBaseView = UIView()
        RecieverBaseView.layer.masksToBounds = true
        RecieverBaseView.layer.cornerRadius =   5.0
        self.baseView.addSubview(RecieverBaseView)
        
        RecieverThumbnailImgView = UIImageView()
        RecieverThumbnailImgView.isUserInteractionEnabled = true
        RecieverThumbnailImgView.layer.masksToBounds = true
        RecieverThumbnailImgView.layer.cornerRadius = 5.0
        RecieverBaseView.addSubview(RecieverThumbnailImgView)
        
        RecieverCenterPlayButton = UIButton()
        RecieverCenterPlayButton.setBackgroundImage(videoIconImg, for: .normal)
        RecieverThumbnailImgView.addSubview(RecieverCenterPlayButton)
        
        recieverDateLbl = UILabel()
        RecieverBaseView.addSubview(recieverDateLbl)
        
      
      
       
        SenderProfileImgView = UIImageView()
        baseView.addSubview(SenderProfileImgView)
        
        SenderCoenerImgView = UIImageView()
        baseView.addSubview(SenderCoenerImgView)
        
        SenderBaseView = UIView()
        SenderBaseView.layer.masksToBounds = true
        SenderBaseView.layer.cornerRadius =   5.0
        self.baseView.addSubview(SenderBaseView)
        
        SenderThumbnailImgView = UIImageView()
        SenderThumbnailImgView.isUserInteractionEnabled = true
        SenderThumbnailImgView.layer.masksToBounds = true
        SenderThumbnailImgView.layer.cornerRadius = 5.0
        SenderBaseView.addSubview(SenderThumbnailImgView)
        
        senderCenterPlayButton = UIButton()
        senderCenterPlayButton.setBackgroundImage(videoIconImg, for: .normal)
        SenderThumbnailImgView.addSubview(senderCenterPlayButton)
        
        senderDateLbl = UILabel()
        SenderBaseView.addSubview(senderDateLbl)
        
       
        
     
  //      thumbnailImgView = UIImageView()
    //    thumbnailImgView = UIImageView(frame: CGRect(x: self.baseView.frame.size.width - 182, y: 0, width: 170, height: self.baseView.frame.size.height))
//        thumbnailImgView.isUserInteractionEnabled = true
//        thumbnailImgView.layer.masksToBounds = true
//        thumbnailImgView.layer.cornerRadius = 5.0
//        self.baseView.addSubview(thumbnailImgView)
        
    //    centerPlayButton = UIButton(frame: CGRect(x: (170 - 40)/2, y: ((self.baseView.frame.size.height) - 40)/2, width: 40, height: 40))
//        centerPlayButton.setBackgroundImage(videoIconImg, for: .normal)
//        self.thumbnailImgView.addSubview(centerPlayButton)
        
        self.selectionStyle = .none
        
//        self.backgroundColor = UIColor.green
//        self.contentView.backgroundColor = UIColor.white
//        baseView.backgroundColor = UIColor.red
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

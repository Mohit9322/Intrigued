//
//  MessageCell.swift
//  Intrigued
//
//  Created by daniel helled on 19/09/17.
//  Copyright © 2017 daniel helled. All rights reserved.
//

import UIKit

class MessageCell: UITableViewCell {

    
    @IBOutlet weak var receiverView: UIView!
    @IBOutlet weak var receiver_messageView: UIView!
    @IBOutlet weak var lbl_receiverMsg: UILabel!
    @IBOutlet weak var receiver_UserImage: UIImageView!
    
  //  @IBOutlet weak var senderView: UIView!
   // @IBOutlet weak var sender_messageView: UIView!
  //  @IBOutlet weak var lbl_senderMsg: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        receiver_messageView.layer.cornerRadius = 5
        receiver_UserImage.setRounded()
        // Initialization code
    }
    func setupDetailsonView(detailsDict:NSDictionary) {
        if let userInfo = detailsDict["user_id"] as? NSDictionary {
            if let profile_pic = userInfo["profile_pic"] as? String  {
                let imageUrl = URL(string:profile_pic )
                receiver_UserImage.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "defult_pic"), options:.refreshCached)
            }
        }
        lbl_receiverMsg.text = detailsDict["message"]as? String ?? ""
  
    }
  
  
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}

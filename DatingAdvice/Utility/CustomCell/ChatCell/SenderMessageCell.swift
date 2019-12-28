//
//  SenderMessageCell.swift
//  Intrigued
//
//  Created by daniel helled on 19/09/17.
//  Copyright © 2017 daniel helled. All rights reserved.
//

import UIKit

class SenderMessageCell: UITableViewCell {

    @IBOutlet weak var senderView: UIView!
    @IBOutlet weak var sender_messageView: UIView!
    @IBOutlet weak var lbl_senderMsg: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        sender_messageView.layer.cornerRadius = 5
        // Initialization code
    }
    
    func showSenderDetailsonView(detailsDict:NSDictionary) {
        
        lbl_senderMsg.text = detailsDict["message"]as? String ?? ""
    }
   
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

//
//  ChatImageCell.swift
//  Intrigued
//
//  Created by daniel helled on 17/10/17.
//  Copyright © 2017 daniel helled. All rights reserved.
//

import UIKit

class ChatImageCell: UITableViewCell {
    @IBOutlet weak var receiverView: UIView!
    @IBOutlet weak var receiver_messageView: UIView!
    @IBOutlet weak var receiver_UserImage: UIImageView!
    @IBOutlet weak var message_imageView: UIImageView!
    @IBOutlet weak var msgTxtView: UITextView!
    
    @IBOutlet weak var recieverNameLBl: UILabel!
    @IBOutlet weak var senderView: UIView!
    @IBOutlet weak var sender_messageView: UIView!
    @IBOutlet weak var sender_msg_imageView: UIImageView!
    @IBOutlet weak var senderMsgTextView: UITextView!
    
    @IBOutlet weak var senderProfileImgView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        receiver_messageView.layer.cornerRadius = 5
        receiver_UserImage.setRounded()
        recieverNameLBl.layer.masksToBounds = true
        recieverNameLBl.layer.cornerRadius = 17.5
     
        message_imageView.setCornerRadius(radius: 3.0)
        
        senderMsgTextView.backgroundColor = hexStringToUIColor(hex: "#e5e5e5")
        senderView.backgroundColor = UIColor.white
        sender_messageView.backgroundColor = hexStringToUIColor(hex: "#e5e5e5")
        sender_msg_imageView.backgroundColor = hexStringToUIColor(hex: "#e5e5e5")
      
        sender_messageView.layer.cornerRadius = 5
        
       senderProfileImgView.setRounded()
     //   sender_msg_imageView.setCornerRadius(radius: 3.0)
        // Initialization code
    }
    func setupDetailsonView(detailsDict:NSDictionary) {
        receiverView.isHidden = false
        senderView.isHidden = true
        
        let coachDict = detailsDict["coach_id"] as! NSDictionary
        let UserDict = detailsDict["user_id"] as! NSDictionary
        let coachProfileStr = coachDict["profile_pic"] as! String
        let UserProfileStr = UserDict["profile_pic"] as! String
       
      
        
        print(detailsDict)
        if let userInfo = detailsDict["user_id"] as? NSDictionary {
            if let profile_pic = userInfo["profile_pic"] as? String  {
                
                if  isCoach() {
                     let imageUrl = URL(string:UserProfileStr )
                    receiver_UserImage.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "defult_pic"), options:.refreshCached)
                    msgTxtView.isHidden = true

                    
                }else {
                    let imageUrl = URL(string:coachProfileStr )
                    receiver_UserImage.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "defult_pic"), options:.refreshCached)
                    msgTxtView.isHidden = true
                }
                
               
                
                
            }
        }
        if isCoach(){
            let userIdDict = detailsDict["coach_id"] as? NSDictionary
            var fname =  userIdDict!["fname"]as? String ?? ""
            var lname = userIdDict!["lname"]as? String ?? ""
            lname = lname.characters.first?.description ?? ""
            fname = fname.characters.first?.description ?? ""
            fname = fname + lname
            recieverNameLBl.text = fname
            }else{
            let userIdDict = detailsDict["user_id"] as? NSDictionary
            var fname =  userIdDict!["fname"]as? String ?? ""
            var lname = userIdDict!["lname"]as? String ?? ""
            lname = lname.characters.first?.description ?? ""
            fname = fname.characters.first?.description ?? ""
            fname = fname + lname
            recieverNameLBl.text = fname
            }
        
        if let imageStr =  detailsDict["image"] as? String  {
             let imageUrl = URL(string:imageStr )
          
          
            message_imageView.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "defult_pic"), options:.refreshCached)
             message_imageView.isHidden = false
            msgTxtView.isHidden = true
            
            msgTxtView.isHidden = true
        }else if let imageStr1 =  detailsDict["video"] as? String{
            print("Video Url")
           
//            let imageUrl = URL(string:imageStr1 )
//            let urlStr = imageUrl?.absoluteString
//
//            message_imageView.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "defult_pic"), options:.refreshCached)
//            DispatchQueue.global(qos: .background).async {
//                print("This is run on the background queue")
//                var imageVideoThumbnail:UIImage = self.createThumbnailOfVideoFromFileURL(videoURL: urlStr!)!
//                DispatchQueue.main.async {
//                    print("This is run on the main queue, after the previous code in outer block")
//                    self.message_imageView.image = imageVideoThumbnail
//                }
//            }
            
            
        } else{
           
            message_imageView.isHidden = true
            msgTxtView.isHidden = false
            msgTxtView.text = detailsDict["message"] as? String
        }
        
    
        
    }
    
    func showSenderDetailsonView(detailsDict:NSDictionary) {
        
        receiverView.isHidden = true
        senderView.isHidden = false
        let userIdDict = detailsDict["coach_id"] as? NSDictionary
        let userProfilepic = userIdDict!["profile_pic"] as? String
        if  var userProfilepic = userIdDict!["profile_pic"] as? String  {
             userProfilepic = getProfilePic() as String
            let imageUrl = URL(string:userProfilepic )
            senderProfileImgView.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "defult_pic"), options:.refreshCached)
            
        }
        
        if let imageStr =  detailsDict["image"] as? String  {
            let imageUrl = URL(string:imageStr )
           
            sender_msg_imageView.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "defult_pic"), options:.refreshCached)
          //r  senderProfileImgView.isHidden = false
            
            senderMsgTextView.isHidden = true
        }else if let imageStr =  detailsDict["video"] as? String{
            
        } else{
          //  senderProfileImgView.isHidden = true
            senderMsgTextView.isHidden = false
            senderMsgTextView.text = detailsDict["message"] as? String
            
        }
        
    }
   
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

//
//  UserQuestionsChatCell.swift
//  
//
//  Created by daniel helled on 13/10/17.
//

import UIKit

class UserQuestionsChatCell: UITableViewCell {
    @IBOutlet weak var receiverView: UIView!
    @IBOutlet weak var receiver_messageView: UIView!
    @IBOutlet weak var lbl_receiverMsg: UILabel!
    @IBOutlet weak var lbl_receiverMsgTitle: UILabel!
    @IBOutlet weak var receiver_UserImage: UIImageView!
    @IBOutlet weak var imageView1: UIImageView!
    @IBOutlet weak var imageView2: UIImageView!
    @IBOutlet weak var imageView3: UIImageView!
    @IBOutlet weak var imageBgView: UIView!
    @IBOutlet weak var imagebgHghtConstraint: NSLayoutConstraint!
    @IBOutlet weak var NameLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        receiver_messageView.layer.cornerRadius = 5
        
        receiver_UserImage.setRounded()
        NameLbl.layer.masksToBounds = true
        NameLbl.layer.cornerRadius = 17.5
        imageView1.setCornerRadius(radius: 2.0)
        imageView2.setCornerRadius(radius: 2.0)
        imageView3.setCornerRadius(radius: 2.0)
        // Initialization code
    }

    func setupDetailsonView(detailsDict:NSDictionary) {
         imageView1.isHidden = true
         imageView2.isHidden = true
         imageView3.isHidden = true
         imageBgView.isHidden = false
        print(detailsDict)
        var index = 0
        
        if isCoach() {
            if let userInfo = detailsDict["user_id"] as? NSDictionary {
                if let profile_pic = userInfo["profile_pic"] as? String  {
                    let  imageUrl = URL(string:profile_pic )
                   
                    receiver_UserImage.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "defult_pic"), options:.refreshCached)
                }
            }
        } else {
            let   profile_pic = getProfilePic()
            let  imageUrl = URL(string:profile_pic )
            receiver_UserImage.sd_setImage(with: imageUrl , placeholderImage: UIImage(named: "defult_pic"), options:.refreshCached)
        }
       
        lbl_receiverMsgTitle.text = detailsDict["title"]as? String ?? ""
        lbl_receiverMsg.text =  detailsDict["question"]as? String ?? ""
        let  dict : NSDictionary
         if isCoach() {
            dict  =  (detailsDict["user_id"]as? NSDictionary)!
         }else{
            dict  =  (detailsDict["coach_id"]as? NSDictionary)!
        }
        
        var fname =  dict["fname"]as? String ?? ""
        var lname = dict["lname"]as? String ?? ""
        lname = lname.characters.first?.description ?? ""
        fname = fname.characters.first?.description ?? ""
        fname = fname + lname
        NameLbl.text = fname
        if let imageArray =  detailsDict["images"] as? NSArray  {
            if imageArray.count == 0 {
                imageBgView.isHidden = true
                imagebgHghtConstraint.constant = 0
            }
            else{
             
                
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
        else{
            
        }
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

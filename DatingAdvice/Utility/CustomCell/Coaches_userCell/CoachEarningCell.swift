//
//  CoachEarningCell.swift
//  Intrigued
//
//  Created by SWS on 09/10/17.
//  Copyright © 2017 daniel helled. All rights reserved.
//

import UIKit


class CoachEarningCell: UITableViewCell {

    @IBOutlet weak var view_Container: UIView!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var email_lbl: UILabel!
    @IBOutlet weak var message_lbl: UILabel!
    @IBOutlet weak var dollerPrice_lbl: UILabel!
    @IBOutlet weak var date_lbl: UILabel!
  
    var serviceTaxDoubleValue = 0.0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.view_Container.layer.cornerRadius = 12.0
        self.view_Container.layer.borderWidth = 1.0
        self.view_Container.layer.borderColor = UIColor.clear.cgColor
        self.view_Container.layer.masksToBounds = true
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 4.0)
        self.layer.shadowRadius = 2.0
        self.layer.shadowOpacity = 1.0
        self.layer.masksToBounds = false
        userImage.setRounded()
        self.selectionStyle = .none
        
    }
    func setupDetailsonView(detailsDict:NSDictionary) {
       
        print(detailsDict)
     
        let userDict =  detailsDict["user_id"] as! NSDictionary
        let userFirstName = userDict["fname"] as! String
        let userlastName = userDict["lname"] as! String
        let userEmail = userDict["email"] as! String
        let userProfilePic = userDict["profile_pic"] as! String
        var paymentPrice =  detailsDict["payment"] as! String
        let dateStr =  detailsDict["createOn"] as! String
        let paymentType =  detailsDict["payment_type"] as! Int
        var ChatType = ""
        if paymentType ==  1 {
            ChatType = "Direct Message"
        }else if paymentType == 2 {
            ChatType = "Rush Direct Message"
        }else if paymentType == 3 {
            ChatType = "Live Chat"
        }
      
            let  imageUrl = URL(string:userProfilePic )
            
            userImage.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "defult_pic"), options:.refreshCached)
        userName.text = userFirstName + " " +  userlastName
        email_lbl.text = userEmail
        message_lbl.text = ChatType
       
//        var serviceTaxDoubleValue = 0.0
//        let serviceTax  = getUserServiceTax() as String
//        if let serviceTaxValue = Double(serviceTax) {
//            serviceTaxDoubleValue = serviceTaxValue
//        }
//
       
      //  paymentPrice = String(paymentPrice.characters.dropFirst())
        
   //   direct_Price.replacingOccurrences(of: ".00", with: "")
        paymentPrice = paymentPrice.replacingOccurrences(of: "$", with: "")
       
        
        let priceDouble = Double(paymentPrice)
        let priceStr =    String(format:"%.2f", priceDouble!)
//        let serviceTax  = getUserServiceTax() as String
//        var serviceTaxValue = Double(serviceTax)
                let serviceTax  = detailsDict["service_tax"] as? String ?? ""
                if let serviceTaxValue = Double(serviceTax) {
                    serviceTaxDoubleValue = serviceTaxValue
                }
        var priceValue = Double(priceStr)
        
        priceValue = ((priceValue! * (100 - serviceTaxDoubleValue)) / 100)
        dollerPrice_lbl.text = "$"  + String(format:"%.2f", priceValue!)
      
        let date =  convertStringintoDate(dateStr: dateStr)
        print(date.getCreatedDate())
          date_lbl.text = date.getCreatedDate()
     

    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

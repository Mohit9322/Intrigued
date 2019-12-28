//
//  CoachesPricingCell.swift
//  Intrigued
//
//  Created by daniel helled on 04/10/17.
//  Copyright © 2017 daniel helled. All rights reserved.
//

import UIKit

class CoachesPricingCell: UITableViewCell,UIPickerViewDelegate,UIPickerViewDataSource,UITextFieldDelegate {
    @IBOutlet weak var lbl_permsg: UILabel!
    @IBOutlet weak var rightCheckMark: UIImageView!
    @IBOutlet weak var pricingModeBtn: UIButton!
    @IBOutlet weak var tf_Price: UITextField!
    var priceArray = NSMutableArray()
    var directMsg = NSMutableArray()
    var rushDelivery = NSMutableArray()
    var liveChat = NSMutableArray()
    var activeField : UITextField!
    override func awakeFromNib() {
        super.awakeFromNib()
        tf_Price.delegate = self
        let pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource  = self
        tf_Price.inputView = pickerView
        let limit = 9.99
        let interval = 1.0
        for rangeArray in stride(from: 1.99, through: limit, by: interval) {
            directMsg.add(rangeArray)
        }
        for rangeArray in stride(from: 3.99, through: 14.99, by: interval) {
            rushDelivery.add(rangeArray)
        }
        for rangeArray in stride(from: 0.99, through: 4.99, by: interval) {
            liveChat.add(rangeArray)
        }

        priceArray = directMsg

        // Initialization code
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        activeField = textField
//        switch textField.tag
//        {
//        case 0:
//            priceArray = directMsg
//            break;
//        case 1:
//            priceArray = rushDelivery
//            break;
//        case 2:
//             priceArray = liveChat
//            break;
//        default:
//            // do nothing
//            break;
//        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
   func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
       
        if activeField.tag == 0 {
            return directMsg.count
        }
        else if activeField.tag == 1 {
            return rushDelivery.count
        }
        else{
            return liveChat.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if activeField.tag == 0 {
            let priceStr = String(describing: directMsg[row])
            return "$" + priceStr
        }
        else if activeField.tag == 1 {
            let priceStr = String(describing: rushDelivery[row])
            return "$" + priceStr
        }
        else{
            let priceStr = String(describing: liveChat[row])
            return "$" + priceStr
        }
       
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    
        if activeField.tag == 0 {
          

            let str:String = "$" + String(describing: directMsg[row])
         PricingDictManage["DirectPricing"] = str
            print(PricingDictManage)
             tf_Price.text = PricingDictManage["DirectPricing"]
        }
        else if activeField.tag == 1 {
          
            let str:String = "$" + String(describing: rushDelivery[row])
            PricingDictManage["RushDirectPricing"] = str
            print(PricingDictManage)
             tf_Price.text = PricingDictManage["RushDirectPricing"]
        }
        else{
            
            let str:String = "$" + String(describing: liveChat[row])
            PricingDictManage["LiveChatPricing"] = str
            print(PricingDictManage)
             tf_Price.text = PricingDictManage["LiveChatPricing"]
        }
    }
}

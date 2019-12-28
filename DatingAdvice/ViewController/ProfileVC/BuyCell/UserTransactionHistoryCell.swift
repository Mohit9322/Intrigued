//
//  UserTransactionHistoryCell.swift
//  Intrigued
//
//  Created by SWS on 22/02/18.
//  Copyright © 2018 daniel helled. All rights reserved.
//

import UIKit

class UserTransactionHistoryCell: UITableViewCell {
    
    @IBOutlet weak var titleName: UILabel!
    @IBOutlet weak var date_time_lbl: UILabel!
    @IBOutlet weak var amount_lbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    func setUpTransactionHistory(orderDetails:NSDictionary) {
        
        amount_lbl.text = "$\(orderDetails["amount"] as? Float ?? 0)"
        
        if let created_date = orderDetails["createOn"] as? String {
            let date =  convertStringintoDate(dateStr: created_date)
            date_time_lbl.text = date.getCreatedDate()
        }
        let transaction_type = orderDetails["transaction_type"] as? Int ?? 0
        if transaction_type == 1 {
           titleName.text = ""
        }
        else {
            titleName.text = "Purchase Services"
        }
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}



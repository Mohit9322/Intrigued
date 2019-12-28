//
//  ExpertiseCell.swift
//  Intrigued
//
//  Created by daniel helled on 19/09/17.
//  Copyright © 2017 daniel helled. All rights reserved.
//

import UIKit
import CircleProgressView

class ExpertiseCell: UITableViewCell {

    @IBOutlet weak var lbl_timelyResponse: UILabel!
    @IBOutlet weak var lbl_avgResponse: UILabel!
    @IBOutlet var progressView: CircleProgressView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func setupDetailsonView(coachesDetails:NSDictionary){
        if let avgResponse = coachesDetails["avg_response"] as? NSNumber {
            lbl_avgResponse.text = String(describing: avgResponse) + " " +  "hours"
        }
        if let timely_response = coachesDetails["timely_response"] as? NSNumber {
            lbl_timelyResponse.text = String(describing: timely_response) + "%"
        }
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

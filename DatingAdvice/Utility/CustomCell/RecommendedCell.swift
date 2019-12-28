//
//  RecommendedCell.swift
//  DatingAdvice
//
//  Created by daniel helled on 15/09/17.
//  Copyright © 2017 daniel helled. All rights reserved.
//

import UIKit

class RecommendedCell: UITableViewCell {
@IBOutlet weak var advisor_collectionView: AdvisorCollectionView!
   
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func setUpData(coachesArray:NSMutableArray){
        advisor_collectionView.setUpDataOfCollection(coachesArray: coachesArray)
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

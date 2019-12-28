//
//  AdvisorCollectionView.swift
//  DatingAdvice
//
//  Created by daniel helled on 15/09/17.
//  Copyright © 2017 daniel helled. All rights reserved.
//

import UIKit

class AdvisorCollectionView: UIView,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
  
 @IBOutlet weak var collectionView: UICollectionView!
    weak var delegate: IntriguedDelegate?
    var coachesListArray = NSMutableArray()
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.register(UINib(nibName: "AdvisorCollectionCell", bundle:nil), forCellWithReuseIdentifier: "AdvisorCollectionCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        // Initialization code
    }
    
    @objc func clickOnOrderButton(sender:UIButton) {
        self.delegate?.moveToAdviserController(index: sender.tag)
     //   self.delegate?.moveToUserReply(index: sender.tag)
    }
    @objc func clickOnVideoPlayButton(sender:UIButton) {
       self.delegate?.playAdvisorVideoBtn(index: sender.tag)
    }
    func setUpDataOfCollection(coachesArray:NSMutableArray){
        coachesListArray = coachesArray
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section:Int)->Int{
        return coachesListArray.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath:IndexPath)->UICollectionViewCell {
        
        let  cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AdvisorCollectionCell", for : indexPath as IndexPath) as? AdvisorCollectionCell
        let dict1 = coachesListArray[indexPath.row] as? NSDictionary
        if let dict = coachesListArray[indexPath.row] as? NSDictionary {
            cell?.setUpData(coachesDetails: dict)
        }
        cell?.orderButton.tag = indexPath.row
        cell?.VideoPlayButton.tag = indexPath.row
        if let coachVideos = dict1!["coach_video"] as? String {
            
        }
        
        cell?.orderButton.addTarget(self, action: #selector(AdvisorCollectionView.clickOnOrderButton(sender:)), for: .touchUpInside)
        cell?.VideoPlayButton.addTarget(self, action: #selector(AdvisorCollectionView.clickOnVideoPlayButton(sender:)), for: .touchUpInside)
        return cell!
    }
    

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //let widthSize = self.view.frame.size.width
        return CGSize(width: SCREEN_WIDTH-30, height: 345)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        print("Select Cell")
       
        self.delegate?.moveToAdviserController(index: indexPath.item)
        
    }
   
    
}

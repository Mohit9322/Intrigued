//
//  CoachesCategoryCell.swift
//  Intrigued
//
//  Created by daniel helled on 04/10/17.
//  Copyright © 2017 daniel helled. All rights reserved.
//

import UIKit

class CoachesCategoryCell: UITableViewCell,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout  {

    @IBOutlet weak var collectionView: UICollectionView!
    var categoryArray = NSArray()
    var categoryImageArray = NSArray()
    var catHighImageArray = NSArray()
    var coachesCategoryArray = NSMutableArray()
    var isEditDetails = Bool()
      var BasicCategoryArray = NSMutableArray()
    
    override func awakeFromNib() {
        super.awakeFromNib()
      //  categoryArray = ["Tarot Reading","Psychic Reading","Relationship Coaching","Palm Reading"]
          categoryArray = ["Single","New Relationship","Long Term"]
        collectionView.register(UINib(nibName: "CategoryCollectionCell", bundle:nil), forCellWithReuseIdentifier: "CategoryCollectionCell")
        collectionView.delegate = self 
        collectionView.dataSource = self
//        categoryImageArray = ["tarot_reading_unselect","psychic_reading_unsel", "relationship_reading_unselect", "palm_reading_unselect"]
//        catHighImageArray = ["tarot_reading_select","psychic_reading_sel","relationship_reading_select","palm_reading_select"]
        
        categoryImageArray = ["tarot_reading_unselect","psychic_reading_unsel", "relationship_reading_unselect"]
        catHighImageArray = ["tarot_reading_select","psychic_reading_sel","relationship_reading_select"]
        
        // Initialization code
    }

    func updateCategoryDetails(catArray:NSArray, isEdit:Bool){
        isEditDetails = isEdit
        coachesCategoryArray = catArray.mutableCopy() as! NSMutableArray
        if  isEditDetails == false{
            categoryArray = catArray
        }
       
        collectionView.reloadData()
    }
    func setupData(isEdit:Bool){
         isEditDetails = isEdit
        collectionView.reloadData()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section:Int)->Int
    {
        print(categoryArray.count)
        print(categoryArray)
        return categoryArray.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath:IndexPath)->UICollectionViewCell
    {
        
        let  cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCollectionCell", for : indexPath as IndexPath) as? CategoryCollectionCell
        
        self.BasicCategoryArray = getCategoryList() as! NSMutableArray
         print(self.BasicCategoryArray)
        
        var singleCatSelecctedImgStr = ""
         var LongTermCatSelecctedImgStr = ""
         var NewRelationshipCatSelecctedImgStr = ""
         var singleCatUnSelecctedImgStr = ""
         var NewRelCatUnSelecctedImgStr = ""
         var LongTermCatUnSelecctedImgStr = ""
        
        for dictCatDetail in self.BasicCategoryArray {
            
            let catDetail = dictCatDetail as! NSDictionary
         let catName =  catDetail["name"] as! NSString
            if catName == "Single" {
                singleCatSelecctedImgStr = (catDetail["catColorImage"] as! NSString) as String
                singleCatUnSelecctedImgStr = (catDetail["catSimpleImage"] as! NSString) as String

            }else if catName == "Long Term" {
                LongTermCatSelecctedImgStr = (catDetail["catColorImage"] as! NSString) as String
                LongTermCatUnSelecctedImgStr = (catDetail["catSimpleImage"] as! NSString) as String
                
            }else if  catName == "New Relationship" {
                NewRelationshipCatSelecctedImgStr = (catDetail["catColorImage"] as! NSString) as String
                NewRelCatUnSelecctedImgStr = (catDetail["catSimpleImage"] as! NSString) as String
            }
    
        }

        
        let catName = categoryArray[indexPath.row] as? String ?? ""
          var imageName = ""
          var selimageName = ""
        
        cell?.categoryName.text = catName
          if catName == "Single" {
            imageName = singleCatUnSelecctedImgStr
            selimageName = singleCatSelecctedImgStr
        }else if catName == "Long Term" {
            
            imageName = LongTermCatUnSelecctedImgStr
            selimageName = LongTermCatSelecctedImgStr
        }else if  catName == "New Relationship" {
            
            imageName = NewRelCatUnSelecctedImgStr
            selimageName = NewRelationshipCatSelecctedImgStr
        }
        
        
         let imageUrlUnselected = URL(string:imageName )
         let imageUrlSelected = URL(string:selimageName )
        
        
//        let imageName = categoryImageArray[indexPath.row] as? String ?? ""
//        cell?.categoryImage.image = UIImage(named:imageName )
//        let selimageName = catHighImageArray[indexPath.row] as? String ?? ""
//        cell?.categoryImage.highlightedImage = UIImage(named:selimageName )
        
        if coachesCategoryArray.contains(catName) {
            cell?.categoryImage.isHighlighted = true
            cell?.categoryName.isHighlighted = true
        }
        else{
              cell?.categoryImage.isHighlighted = false
              cell?.categoryName.isHighlighted = false
        }
        if  isEditDetails == false{ /// to disable from profile
            cell?.isUserInteractionEnabled = false
         }
         cell?.categoryImage.sd_setImage(with: imageUrlSelected, placeholderImage: UIImage(named: "tarot_reading_unselect"), options:.refreshCached)
        
     //    cell?.categoryName.font = UIFont.systemFont(ofSize: 17)
        
        
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
       
        if  isEditDetails == false{
            return
        }
        
        let catName = categoryArray[indexPath.row] as? String ?? ""
        if coachesCategoryArray.contains(catName) {
            coachesCategoryArray.remove(catName)
        }
        else{
            coachesCategoryArray.add(catName)
        }
        collectionView.reloadItems(at: [indexPath])
        print(coachesCategoryArray)
    }
    
   
}

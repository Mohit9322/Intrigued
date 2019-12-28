//
//  AdvisorProfileDetailTableCell.swift
//  Intrigued
//
//  Created by Shineweb-solutions on 01/02/18.
//  Copyright © 2018 daniel helled. All rights reserved.
//

import UIKit
import AVFoundation

class AdvisorProfileDetailTableCell: UITableViewCell {
    
    var centerPlayButton:UIButton = UIButton()
     var thumbnailImgView:UIImageView = UIImageView()
     var bottomDetailBaseView:UIView = UIView()
    var userNameLbl:UILabel = UILabel()
    var  coachDesc = UITextView()
     var RatingBaseView:UIView = UIView()
    var LikeImgView:UIImageView = UIImageView()
    var DislikeImgView:UIImageView = UIImageView()
    var LikeTxtFld:UITextField = UITextField()
    var DislikeTxtFld:UITextField = UITextField()
    
    
    
    var coachProfileImgView:UIImageView = UIImageView()
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.white
        self.selectionStyle =  .none
         let screenSize = UIScreen.main.bounds
        
        let tempCoachProfileImg = UIImage(named: "advisor_Image")
         let videoIconImg = UIImage(named: "VideoPlayImg")
        let likeImg = UIImage(named: "green_like")
        let DislikeImg = UIImage(named: "red_dislike")
        coachProfileImgView = UIImageView(frame: CGRect(x:0, y: 0, width: screenSize.width, height:230))
       coachProfileImgView.image = UIImage(named: "defult_pic")
        coachProfileImgView.clipsToBounds =  true
        coachProfileImgView.contentMode = .scaleAspectFill
        
      //  coachProfileImgView.autoresizingMask = [.flexibleWidth, .flexibleHeight, .flexibleBottomMargin, .flexibleRightMargin, .flexibleLeftMargin, .flexibleTopMargin]
        self.addSubview(coachProfileImgView)
        
        
        thumbnailImgView = UIImageView(frame: CGRect(x:0, y: 0, width: screenSize.width, height:230))
        thumbnailImgView.isUserInteractionEnabled = true
        thumbnailImgView.layer.masksToBounds = true
        thumbnailImgView.isHidden = true
        self.addSubview(thumbnailImgView)
        
       
        
        centerPlayButton = UIButton(frame: CGRect(x: ((self.thumbnailImgView.frame.size.width) - 40)/2, y: ((self.thumbnailImgView.frame.size.height) - 40)/2, width: 40, height: 40))
        centerPlayButton.setBackgroundImage(videoIconImg, for: .normal)
        self.thumbnailImgView.addSubview(centerPlayButton)
        
        bottomDetailBaseView = UIView(frame: CGRect(x:0, y: coachProfileImgView.frame.size.height, width: screenSize.width, height:310 - coachProfileImgView.frame.size.height))
        bottomDetailBaseView.isUserInteractionEnabled = true
       bottomDetailBaseView.backgroundColor = UIColor.white
       self.addSubview(bottomDetailBaseView)
        
        userNameLbl = UILabel(frame: CGRect(x:10, y: 5, width: screenSize.width - 150, height:30))
        userNameLbl.text = "Name"
        userNameLbl.textColor = UIColor.black
        userNameLbl.textAlignment = .left
    //    bottomDetailBaseView.addSubview(userNameLbl)
        
        RatingBaseView = UIView(frame: CGRect(x:  10, y: 5, width: 130, height:30))
        bottomDetailBaseView.addSubview(RatingBaseView)
        
        LikeImgView = UIImageView(frame: CGRect(x:0, y: 7.5, width: 15, height:15))
        LikeImgView.isUserInteractionEnabled = true
        LikeImgView.layer.masksToBounds = true
        LikeImgView.image = likeImg
        RatingBaseView.addSubview(LikeImgView)
        
        LikeTxtFld = UITextField(frame: CGRect(x:LikeImgView.frame.size.width
             + LikeImgView.frame.origin.x + 4, y: 0, width: 30, height:30))
        LikeTxtFld.text = "23"
        LikeTxtFld.textColor = UIColor.black
         LikeTxtFld.textAlignment = .left
        LikeTxtFld.isUserInteractionEnabled = false
        RatingBaseView.addSubview(LikeTxtFld)
        
        DislikeImgView = UIImageView(frame: CGRect(x:LikeTxtFld.frame.size.width
            + LikeTxtFld.frame.origin.x + 4, y: 7.5, width: 15, height:15))
        DislikeImgView.isUserInteractionEnabled = true
        DislikeImgView.layer.masksToBounds = true
        DislikeImgView.image = DislikeImg
        RatingBaseView.addSubview(DislikeImgView)
        
        DislikeTxtFld = UITextField(frame: CGRect(x:DislikeImgView.frame.size.width
            + DislikeImgView.frame.origin.x + 4, y: 0, width: 30, height:30))
        DislikeTxtFld.isUserInteractionEnabled = false
        DislikeTxtFld.textColor = UIColor.black
        DislikeTxtFld.textAlignment = .left
        RatingBaseView.addSubview(DislikeTxtFld)
        
        coachDesc = UITextView(frame: CGRect(x:10, y: RatingBaseView.frame.size.height + RatingBaseView.frame.origin.y, width: screenSize.width - 25, height:bottomDetailBaseView.frame.size.height - (RatingBaseView.frame.size.height + RatingBaseView.frame.origin.y  )))
        coachDesc.textColor = UIColor.black
        coachDesc.backgroundColor = UIColor.white
        coachDesc.font = coachDesc.font?.withSize(14)
     //   coachDesc.text = "dhskjahdkjh dskhaskjdhkjasd askjdhkashdkabs dkadhakjsdbasd asdkashdkasd adahdkjasd asdashdasd dhaksda sdhdhad "
        coachDesc.isUserInteractionEnabled = false
        bottomDetailBaseView.addSubview(coachDesc)
        
//        bottomDetailBaseView.backgroundColor = UIColor.red
//        RatingBaseView.backgroundColor = UIColor.green
//        coachDesc.backgroundColor = UIColor.yellow
//        self.backgroundColor = UIColor.gray
        // Initialization code
    }
    
    func setupDetailsonView(coachesDetails:NSDictionary){
        
        let userName = (coachesDetails["fname"] as? String ?? "") + "  " + (coachesDetails["lname"] as? String ?? "")
        self.userNameLbl.text = userName
        self.coachDesc.text = coachesDetails["about"] as? String ?? ""
        if let profile_pic = coachesDetails["profile_pic"] as? String  {
          let imageUrl = URL(string:profile_pic )
           
            
           
            if (imageUrl != nil) {

            //    DispatchQueue.global(qos: .background).async {
//                    print("This is run on the background queue")
//                    let data = try? Data(contentsOf: imageUrl!)
//                    let imageOriginal = UIImage(data: data!) as! UIImage
//                    var imageToSet =  self.resizeImage(image: imageOriginal, targetSize: CGSize(width: self.frame.size.width, height: 265 - 70))
//
//                    let fileManager = FileManager.default
//                    let str = "\(String(describing: imageToSet)).jpeg"
//                    let path = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("\(String(describing: imageToSet)).jpeg")
//                    let imageData = UIImageJPEGRepresentation(imageToSet, 1.0)
//                    let imageSize: Int = imageData!.count
//                    print("size of image in KB: %f ", Double(imageSize) / 1024.0)
//                    fileManager.createFile(atPath: path as String, contents: imageData, attributes: nil)
//                    let fileUrl = URL(fileURLWithPath: path)
//                //    DispatchQueue.main.async {
//                        self.coachProfileImgView.sd_setImage(with: fileUrl, placeholderImage: UIImage(named: "defult_pic"), options:.refreshCached)
//                        print("This is run on the main queue, after the previous code in outer block")
//               //     }
//          //     }

               
                
                
                coachProfileImgView.clipsToBounds =  true
                coachProfileImgView.contentMode = .scaleAspectFill
          self.coachProfileImgView.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "AdvisorProfileImg"), options:.refreshCached)
                //coachProfileImgView.contentMode = .scaleAspectFit

            }else {
            
                
               
//                var imageToSet =  self.resizeImage(image: UIImage(named: "defult_pic")!, targetSize: CGSize(width: self.frame.size.width, height: 265 - 70))
//
//                let fileManager = FileManager.default
//                let str = "\(String(describing: imageToSet)).jpeg"
//                let path = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("\(String(describing: imageToSet)).jpeg")
//                let imageData = UIImageJPEGRepresentation(imageToSet, 0.5)
//                let imageSize: Int = imageData!.count
//                print("size of image in KB: %f ", Double(imageSize) / 1024.0)
//                fileManager.createFile(atPath: path as String, contents: imageData, attributes: nil)
//                let fileUrl = URL(fileURLWithPath: path)
//                 coachProfileImgView.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "defult_pic"), options:.refreshCached)
//                 //coachProfileImgView.contentMode = .scaleAspectFit
                coachProfileImgView.clipsToBounds =  true
                coachProfileImgView.contentMode = .scaleAspectFill
                self.coachProfileImgView.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "AdvisorProfileImg"), options:.refreshCached)
               
            }  
            
        }
       
        if let likes = coachesDetails["likes"] as? NSNumber {
            LikeTxtFld.text = String(describing: likes)
        }
        if let dislikes = coachesDetails["dislikes"] as? NSNumber {
            DislikeTxtFld.text = String(describing: dislikes)
        }
        if let videoThumb = coachesDetails["coach_video_thumb"] as? String {
           coachProfileImgView.isHidden = true
           thumbnailImgView.isHidden = false
            let imageUrl = URL(string:videoThumb )
            thumbnailImgView.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "AdvisorProfileImg"), options:.refreshCached)
            centerPlayButton.isHidden = false
            
            
        }
        
    }
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: targetSize.width, height: targetSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(targetSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
      
        
        return newImage!
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

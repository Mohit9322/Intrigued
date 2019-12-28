//
//  ChooseVideoPreviewVC.swift
//  Intrigued
//
//  Created by Shineweb-solutions on 13/02/18.
//  Copyright © 2018 daniel helled. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer
import AVKit
import MobileCoreServices

@objc public  class ChooseVideoPreviewVC: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    @IBOutlet weak var HeaderBaseView: UIView!
    @IBOutlet weak var HeaderLbl: UILabel!
    @IBOutlet weak var backBtn: UIButton!
     var centerPlayButton:UIButton = UIButton()
     var UploadVideoBtn:UIButton = UIButton()
     var picker = UIImagePickerController()
  //  let VideoUrl:URL
   @objc var videoURl = NSURL()
    var PreviewUrl = NSURL()
    @objc var coachDetails : NSDictionary = NSDictionary()
    var directMessage = ""
    var rushDirectMessage = ""
    var liveChat = ""
    var profilePicUrl = ""
    var firstName = ""
    var lastName = ""
    var phoneNumber = ""
    var user_address = ""
    var uploadUrl = ""
    var flag = Bool()
    var aboutyou = "Write here 1000 character"
    var aboutcategory = "Write here 500 character"
    var locationArray = NSArray()
    var isfromCoach = Bool()
    var categoryArray = NSMutableArray()
    var pricingArray = NSMutableArray()
    
    var direct_Status = "0"
    var rush_direct_Status = "0"
    var livechat_Status = "0"
    var isPaused = true
    var playerViewController = AVPlayerViewController()
    
     var preViewImgView = UIImageView()
    
    var flashIconUnselectedImg: UIImage = UIImage()
      var videoPlayImg: UIImage = UIImage()
      var videoPauseImg: UIImage = UIImage()
    var flashIconSelectedImg: UIImage = UIImage()
    var flashBtnManageSelected:String = String()
    var cancelBtn:UIButton = UIButton()
    var videoPlayBtn:UIButton = UIButton()
    var submitBtn:UIButton = UIButton()
    var changeFlashBtn:UIButton = UIButton()
    var openGalleryBtn:UIButton = UIButton()
    var changeCameraMode:UIButton = UIButton()
    var bottomLayerBaseView:UIView = UIView()
  
    var HeaderTopLayerBaseView:UIView = UIView()
    @objc var count = Int()
    var countDownLabel: UILabel!
    var timer = Timer()
    var manageCountLbl = Int()
    var TempCount = Int()
    
    var player: AVPlayer?
    override public func viewDidLoad() {
        super.viewDidLoad()
        count = count - 1
        manageCountLbl = 0
        TempCount = count
                var thumbnialImg = self.createThumbnailOfVideoFromFileURL(videoURL: videoURl.absoluteString!) as! UIImage
        let imageData1 = UIImageJPEGRepresentation(thumbnialImg, 1.0)
        let imageSize1: Int = imageData1!.count
         print("size of before compression image in KB: %f ", Double(imageSize1) / 1024.0)
                thumbnialImg = thumbnialImg.resizeWithWidth(width: 200)!
                let fileManager = FileManager.default
                let str = "\(String(describing: thumbnialImg)).jpeg"
                let path1 = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("\(String(describing: thumbnialImg)).jpeg")
                let imageData = UIImageJPEGRepresentation(thumbnialImg, 1.0)
                let imageSize: Int = imageData!.count
                print("size of image after in KB: %f ", Double(imageSize) / 1024.0)
                fileManager.createFile(atPath: path1 as String, contents: imageData, attributes: nil)
                let fileUrl = URL(fileURLWithPath: path1)

          PreviewUrl = fileUrl as NSURL
//
        // get the path string for the video from assets
        
        
        // convert the path string to a url
        let videoUrl = self.videoURl as URL
        
        // initialize the video player with the url
        self.player = AVPlayer(url: videoUrl)
        
        // create a video layer for the player
        let layer: AVPlayerLayer = AVPlayerLayer(player: self.player)
        
        // make the layer the same size as the container view
        layer.frame = self.view.bounds
        
        // make the video fill the layer as much as possible while keeping its aspect size
        layer.videoGravity = AVLayerVideoGravity.resizeAspectFill
       
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerItemDidReachEnd(notification:)),
                                               name: Notification.Name.AVPlayerItemDidPlayToEndTime,
                                               object: self.player?.currentItem)
        // add the layer to the container view
        
        self.view.layer.addSublayer(layer)
   //      self.player?.play()
        
 
        
        HeaderTopLayerBaseView.frame = CGRect(x:0, y: 0, width: self.view.frame.size.width, height: 80)
        HeaderTopLayerBaseView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        self.view.addSubview(HeaderTopLayerBaseView)
        
        countDownLabel = UILabel(frame: CGRect(x:(HeaderTopLayerBaseView.frame.size.width - 200)/2 , y: 30, width: 200, height: 30))
        countDownLabel.textColor = UIColor.white
        
        countDownLabel.text = String(format:"00:%02i", count)
        countDownLabel.textAlignment = .center
        countDownLabel.font = UIFont.systemFont(ofSize: 20)
        HeaderTopLayerBaseView.addSubview(countDownLabel)
        
      
        
        bottomLayerBaseView.frame = CGRect(x:0, y: self.view.frame.size.height - 100, width: self.view.frame.size.width, height: 100)
        bottomLayerBaseView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        self.view.addSubview(bottomLayerBaseView)
        
        flashIconUnselectedImg = UIImage(named: "flash_off")!
        flashIconSelectedImg = UIImage(named: "flash_off")!
        videoPlayImg = UIImage(named: "RecordedvideoPlay")!
        videoPauseImg = UIImage(named: "RecordedVideoPause")!
        cancelBtn = UIButton(frame: CGRect(x: 10 , y: 30, width: 100, height: 40))
   
        cancelBtn.backgroundColor =  UIColor.clear
        cancelBtn.setTitle("Re-record", for: .normal)
        cancelBtn.titleLabel?.textAlignment = .left
        cancelBtn.setTitleColor(UIColor.white, for: .normal)
        cancelBtn.addTarget(self, action: #selector(chooseOtherVideo(sender:)), for: .touchUpInside)
        self.bottomLayerBaseView.addSubview(cancelBtn)
        
        videoPlayBtn = UIButton(frame: CGRect(x: (self.view.frame.size.width - 70 )/2 , y: 15, width: 70, height: 70))
        videoPlayBtn.setImage(videoPlayImg, for: .normal)
        videoPlayBtn.setImage(videoPauseImg, for: .selected)
        videoPlayBtn.backgroundColor =  UIColor.clear
         videoPlayBtn.isSelected = false
        videoPlayBtn.addTarget(self, action: #selector(PlayAndPauseVideo(sender:)), for: .touchUpInside)
        self.bottomLayerBaseView.addSubview(videoPlayBtn)
        
        
        submitBtn = UIButton(frame: CGRect(x: self.view.frame.size.width - 90 , y: 30, width: 80, height: 40))
    //    submitBtn.setImage(#imageLiteral(resourceName: "flashOutline"), for: UIControlState())
        submitBtn.backgroundColor =  UIColor.clear
        submitBtn.setTitle("Save", for: .normal)
        submitBtn.titleLabel?.textAlignment = .right
        submitBtn.setTitleColor(UIColor.white, for: .normal)
        submitBtn.addTarget(self, action: #selector(uploadVideoButton(sender:)), for: .touchUpInside)
        self.bottomLayerBaseView.addSubview(submitBtn)
        


        // Do any additional setup after loading the view.
    }
    @objc func update() {
        
        if(count > 0){
            //     let minutes = String(count / 60)
            //  let seconds = String(count % 60)
            let minutes = Int(count) / 60
            let seconds = Int(count) % 60
           
            var countStr =  String(format:"%02i:%02i", minutes, seconds)
            print(countStr)
            countDownLabel.text = countStr
            count = count - 1
            
        }else {
            timer.invalidate()
            count = TempCount
           countDownLabel.text = String(format:"00:%02i", TempCount)
         
        }
    }
    @objc func playerItemDidReachEnd(notification: Notification) {
        if let playerItem: AVPlayerItem = notification.object as? AVPlayerItem {
            playerItem.seek(to: kCMTimeZero, completionHandler: nil)
         //   self.player?.play()
            print("video ended")
            self.player?.pause()
            videoPlayBtn.isSelected = false
            timer.invalidate()
            isPaused = true
            count = TempCount
            countDownLabel.text = String(format:"00:%02i", TempCount)
        }
    }
    override public func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.player?.pause()
         count = TempCount
        timer.invalidate()
        self.player  = nil
    }
    @objc func PlayAndPauseVideo(sender:UIButton) {
       
        if let button = sender as? UIButton {
            if button.isSelected {
                // set deselected
                self.player?.pause()
                button.isSelected = false
                timer.invalidate()
                isPaused = true
            } else {
                // set selected
                
                if isPaused{
                     timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(update), userInfo: nil, repeats: true)
                    isPaused = false
                } else {
                    timer.invalidate()
                    isPaused = true
                }
                self.player?.play()
                
                button.isSelected = true
            }
        }
        
    }
    
    @objc func chooseOtherVideo(sender:UIButton) {
        self.navigationController?.popViewController(animated: true)
      
    }
    @objc func choosePreviewImageBtnPressed(sender:UIButton) {
        
        self.openGallary()
      
    }
    @objc func uploadVideoButton(sender:UIButton) {
        // self.player?.pause()
         self.uploadIntroDuctionVideoToAmazon(url: videoURl as URL)
    }
    func openGallary(){
        
        
        if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary)){
            picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            
            picker.delegate = self

            self .present(picker, animated: true, completion: nil)
        }else{
            notifyUser("", message: "Your device doesn't support camera", vc: self)
        }
    }
    
    //MARK:UIImagePickerControllerDelegate
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]){
        
        picker .dismiss(animated: true, completion: nil)
        let mediaType = info[UIImagePickerControllerMediaType] as! NSString
        
        if mediaType.isEqual(to: kUTTypeImage as String) {
            
            // Media is an image
            print("Capture Image")
            var image = info[UIImagePickerControllerOriginalImage] as? UIImage //userProfileImage.image
            image = image?.resizeWithWidth(width: 200)!
            let fileManager = FileManager.default
            let str = "\(String(describing: image)).jpeg"
            let path = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("\(String(describing: image)).jpeg")
            let imageData = UIImageJPEGRepresentation(image!, 0.5)
            let imageSize: Int = imageData!.count
            print("size of image in KB: %f ", Double(imageSize) / 1024.0)
            fileManager.createFile(atPath: path as String, contents: imageData, attributes: nil)
            let fileUrl = URL(fileURLWithPath: path)
            
            PreviewUrl = fileUrl as NSURL
            preViewImgView.sd_setImage(with: PreviewUrl as URL, placeholderImage: UIImage(named: "AdvisorProfileImg"), options:.refreshCached)
            
           
            
        }
        
        
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController){
        print("picker cancel.")
        picker .dismiss(animated: true, completion: nil)
    }
    @objc func clickOnPlayVideoButton(sender:UIButton) {
        
     
      
        print("Url Fetched")
        let videoUrl  = videoURl.absoluteString
        print(videoUrl)
        let imageUrl = URL(string:videoUrl! )
        
        let player = AVPlayer(url: imageUrl!)
      
        playerViewController.player = player
        self.present(playerViewController, animated: true)
        {
            self.playerViewController.player!.play()
        }
    }
    @IBAction func backBtnPressed(_ sender: Any) {
        
        self.player = nil
        self.player?.pause()
        timer.invalidate()
         self.navigationController?.popViewController(animated: true)
    }
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func uploadIntroDuctionVideoToAmazon(url : URL)  {
        
     //   showProgressIndicator(refrenceView: self.view)
        appDelegateRef.showTitleIndicator()
        
        guard let data = NSData(contentsOf: url as URL) else {
            return
        }
        
        self.player?.pause()
        timer.invalidate()
        
        print("File size before compression: \(Double(data.length / 1024)) kb")
        let compressedURL = NSURL.fileURL(withPath: NSTemporaryDirectory() + NSUUID().uuidString + ".m4v")
        compressVideo(inputURL: url , outputURL: compressedURL) { (exportSession) in
            guard let session = exportSession else {
                return
            }
            
            switch session.status {
            case .unknown:
                break
            case .waiting:
                break
            case .exporting:
                break
            case .completed:
                guard let compressedData = NSData(contentsOf: compressedURL) else {
                    return
                }
                print("File size after compression: \(Double(compressedData.length / 1024)) kb")
                self.uploadVideo(url: compressedURL)
                
                
            case .failed:
                break
            case .cancelled:
                break
            }
        }
        
        
    }
    override public var prefersStatusBarHidden: Bool {
        return true
    }
    
    func uploadVideo(url : URL) {
        
       
        let videoURL = url as NSURL
      
        let videoData = NSData(contentsOf: videoURL as URL)
        let path = try! FileManager.default.url(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask, appropriateFor: nil, create: false)
        let newPath = path.appendingPathComponent("/videoFileName.mp4")
        do {
            try videoData?.write(to: newPath)
        } catch {
            print(error)
        }

        WebServices().uploadVideoonServer(imageURL: newPath){ (responseData)  in
            //   stopProgressIndicator()
            if responseData != nil{
                let uploadUrl = responseData!
     
                WebServices().uploadImageonServer(imageURL: self.PreviewUrl as URL){ (responseData)  in
              //      stopProgressIndicator()
                    if responseData != nil{
                        let uploadUrlImage = responseData!
                        
                        appDelegateRef.hideIndicator()
                        /***************  edit profile Image ************/
                        self.showCoachPofileDetials()
//                        self.rushDirectMessage = PricingDictManage["RushDirectPricing"] as! String
//                        self.liveChat = PricingDictManage["LiveChatPricing"] as! String
//                        self.directMessage = PricingDictManage["DirectPricing"] as! String
                        print(self.coachDetails)
                        if ((self.coachDetails["longlat"] as? NSArray) != nil) {
                            self.locationArray = (self.coachDetails["longlat"] as? NSArray)!
                            self.categoryArray = (self.coachDetails["categories"] as? NSMutableArray)!
                            self.profilePicUrl = (self.coachDetails["profile_pic"] as? String)!
                        }else {
                            print("mohit")
                        }
                        print(self.categoryArray)
                        print(self.locationArray)
                        print(self.profilePicUrl)
                        
                        let request = ["user_id": getUserId(),
                                       "fname": self.firstName,
                                       "lname":self.lastName,
                                       "address":self.user_address ,
                                       "longlat":self.locationArray,
                                       "phone_no":self.phoneNumber,
                                       "profile_pic": self.profilePicUrl ,
                                       "about_services": self.aboutcategory,
                                       "about":self.aboutyou,
                                       "categories":self.categoryArray,
                                       "direct_price":self.directMessage,
                                       "rush_direct_price":self.rushDirectMessage,
                                       "livechat_price":self.liveChat,
                                       "direct_Status":self.direct_Status,
                                       "rush_direct_Status":self.rush_direct_Status,
                                       "livechat_Status":self.livechat_Status,
                                       "coach_video":uploadUrl,
                                       "coach_video_thumb":uploadUrlImage] as [String : Any]
                        
                        
//                        let request = ["user_id": getUserId(),
//                                       "coach_video":uploadUrl,
//                                       "coach_video_thumb":uploadUrlImage] as [String : Any]
                        self.updateUser_CoachesDetails(request: request as NSDictionary, type: kUPDATE_COACH_DETAILS)
                        /************* edit profile image ***********/
                        
                        
                        
                        print("responseData",responseData ?? "")
                    }
                    else{ stopProgressIndicator()}
                }
                
            }
            else{ stopProgressIndicator()}
        }
    }
    func compressVideo(inputURL: URL, outputURL: URL, handler:@escaping (_ exportSession: AVAssetExportSession?)-> Void) {
        
        
        
        let urlAsset = AVURLAsset(url: inputURL, options: nil)
        guard let exportSession = AVAssetExportSession(asset: urlAsset, presetName: AVAssetExportPresetLowQuality) else {//ravi 23Mar2018
            handler(nil)
            
            return
        }
        
        exportSession.outputURL = outputURL
        exportSession.outputFileType = AVFileType.mp4
        exportSession.shouldOptimizeForNetworkUse = true
        exportSession.exportAsynchronously { () -> Void in
            handler(exportSession)
        }
    }
    func showCoachPofileDetials() {
        
        
        firstName = getFirstName()
        lastName = getLastName()
        profilePicUrl = getProfilePic()
        phoneNumber = getPhoneNo()
        uploadUrl = getProfilePic()
        user_address = getAddress()
        locationArray = getLocationPoint()
        print(categoryArray)
        categoryArray = getCategoryArray() as! NSMutableArray
        var array = getCategoryArray()
        print(array)
        print(categoryArray)
        aboutyou = getAboutDetail()
        aboutcategory = getAbout_services()
        directMessage = getDirectPrice()
        rushDirectMessage = getRushDirectPrice()
        liveChat = getLiveChatPrice()
        if getDirect_Status() == 1 {
            pricingArray.add(0)
            direct_Status = "1"
        }
        
        if getRushDirect_Status() == 1 {
            pricingArray.add(1)
            rush_direct_Status = "1"
        }
        if getlivechat_Status() == 1 {
            pricingArray.add(2)
            livechat_Status = "1"
        }
        print("pricingArray",pricingArray)
    }
    func createThumbnailOfVideoFromFileURL(videoURL: String) -> UIImage? {
        
        
        
        var asset = AVAsset(url: URL(string: videoURL)!)
        var imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        var time1: CMTime = CMTimeMakeWithSeconds(0.0, 600)
        time1.value = 0 as? CMTimeValue ?? CMTimeValue()
        var error: Error? = nil
        var actualTime = CMTime()
        //   var imageRef = (try? imageGenerator.copyCGImage(at: time1, actualTime: nil)) as? CGImage
        do {
            var imageRef =  try imageGenerator.copyCGImage(at: time1, actualTime: nil)
            // var thumbnail = UIImage(cgImage: imageRef as? CGImage ?? CGImage())
            let thumbnail = UIImage(cgImage: imageRef)
            return thumbnail
        } catch {
            print(error.localizedDescription)
            print(error.localizedDescription)
            return UIImage(named: "user_icon")
        }
        
        
    }
    
    func updateUser_CoachesDetails(request:NSDictionary,type:String) {
        
        WebServices().mainFunctiontoGetDetails(data: request as NSDictionary,serviceType:type) { (responseData)  in
            //   stopProgressIndicator()
            if responseData != nil
            {
                let code = responseData?["code"] as? NSNumber
                print("responseData",responseData ?? "")
                if code == 200{
                    stopProgressIndicator()
                    
                    guard let resultDict = responseData?["result"] as? NSDictionary else {
                        return
                    }
                    removeUserDetails()
                    saveUserDetails(userDict: resultDict)
                    appDelegateRef.hideIndicator()
                    if let viewControllers = self.navigationController?.viewControllers {
                        for viewController in viewControllers {
                            // some process
                            
                              if viewController.isKind(of: CoachesTabbarVC.self){
                                
                                let coahesTabBarVc = viewController as! CoachesTabbarVC
                                let viewControllersCoaches = coahesTabBarVc.viewControllers
                                for coachProfileVc in viewControllersCoaches! {
                                   
                                     if coachProfileVc.isKind(of: CoachesProfileVC.self){
                                        
                                        let coachProfileViewCont = coachProfileVc as! CoachesProfileVC
                                        coachProfileViewCont.profileTableView.reloadData()
                                        
                            }
                          }
                        }
                      }
                    }
                    
                    if let viewControllers = self.navigationController?.viewControllers {
                        for viewController in viewControllers {
                           
                            if viewController.isKind(of: EditUserProfileVC.self){
                                if let vc = viewController as? EditUserProfileVC {
                                    //   vc.selectedIndex = 1;
                                    
                                    vc.editTbl_view.reloadData()
                                    self.navigationController?.popToViewController(vc, animated: true)
                                    break
                                }
                                
                            }
                        }
                        
                    }
                    
                    if let viewControllers = self.navigationController?.viewControllers {
                        for viewController in viewControllers {
                             if viewController.isKind(of: CoachesTabbarVC.self){
                                
                                let coahesTabBarVc = viewController as! CoachesTabbarVC
                                let viewControllersCoaches = coahesTabBarVc.viewControllers
                                for coachProfileVc in viewControllersCoaches! {
                                  
                                    if coachProfileVc.isKind(of: CoachesProfileVC.self){
                                        if let vc = coachProfileVc as? CoachesProfileVC {
                                            vc.profileTableView.reloadData()
                                    self.navigationController?.popToViewController(coahesTabBarVc, animated: true)
                                            break
                                        }
                                    }
                                }
                           
                                
                            }
                        }
                        
                    }

                    
                    
                    if firstTimeCoachSignUp == "YES" {
                                                    firstTimeCoachSignUp = "YES"
                                                     pushView(viewController: self, identifier: "CoachesTabbarVC")
                                                }
                    
                    
                    
                }
                else {
                    if let message = responseData?["result"] as? String {
                        notifyUser("", message: message , vc: self)
                    }
                    else{
                        // notifyUser("", message: "Something went wrong", vc: self)
                    }
                }
            }
            else{ stopProgressIndicator()}
            
        }
    }
    

}

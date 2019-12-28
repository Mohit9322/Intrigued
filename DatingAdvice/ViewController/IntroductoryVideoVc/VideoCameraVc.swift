/*Copyright (c) 2016, Andrew Walz.

Redistribution and use in source and binary forms, with or without modification,are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the
documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS
BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. */


import UIKit

class VideoCameraVc: SwiftyCamViewController, SwiftyCamViewControllerDelegate {
    
    
    @IBOutlet weak var captureButton: SwiftyRecordButton!
    @IBOutlet weak var flipCameraButton: UIButton!
    @IBOutlet weak var flashButton: UIButton!
    var flashIconUnselectedImg: UIImage = UIImage()
    var flashIconSelectedImg: UIImage = UIImage()
    var flashBtnManageSelected = Bool()
      var CameraModeManageSelected = Bool()
    var cancelBtn:UIButton = UIButton()
    var changeFlashBtn:UIButton = UIButton()
    var openGalleryBtn:UIButton = UIButton()
    var CaptureVideoOrImageBtn: SwiftyRecordButton!
    var changeCameraMode:UIButton = UIButton()
    var bottomLayerBaseView:UIView = UIView()
   var fromCoachSignUp = ""
    var coachDetails : NSDictionary = NSDictionary()
   
     var whiteVideoRecorBigBtn:UIButton = UIButton()
     var RedVideoRecordVideoRecordBtn:UIButton = UIButton()
    var whiteVideoBtnImg: UIImage = UIImage()
    var RedStopBtnImg: UIImage = UIImage()
    var redPlayBtnImg: UIImage = UIImage()
      var RcordingVideoManage = Bool()
    
    @IBOutlet weak var topHeaderBaseView: UIView!
    @IBOutlet weak var skipBtn: UIButton!
    @IBOutlet weak var backBtn: UIButton!
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
    var categoryArray = NSArray()
    var pricingArray = NSMutableArray()
   
    var direct_Status = "0"
    var rush_direct_Status = "0"
    var livechat_Status = "0"
    var count = 59
    var countDownLabel: UILabel!
    var timer = Timer()
    
	override func viewDidLoad() {
		super.viewDidLoad()
        videoGravity = .resizeAspectFill
		cameraDelegate = self
		maximumVideoDuration = 60.0
        shouldUseDeviceOrientation = true
        allowAutoRotate = true
        audioEnabled = true
        videoQuality = .high
      
   //   SwiftyCamViewController.VideoQuality.high

        self.flashButton.isHidden = true
        self.flipCameraButton.isHidden = true
        self.captureButton.isHidden = true
        
        if fromCoachSignUp == "YES" {
            self.skipBtn.setTitle("Skip", for: .normal)
        }else {
            self.skipBtn.setTitle("Cancel", for: .normal)
        }
        
        print(coachDetails)
        self.customizedCamera()
	}

	override var prefersStatusBarHidden: Bool {
		return true
	}

    @IBAction func BackBtnPressed(_ sender: Any) {
      
    }
    @IBAction func skipBtnPressed(_ sender: Any) {
       
        
    
        if fromCoachSignUp == "YES" {
            fromCoachSignUp = "NO"
              pushView(viewController: self, identifier: "CoachesTabbarVC")
        }else {
            self.navigationController?.popViewController(animated: true)
        }
        
    }
    override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
        captureButton.delegate = self
	}
    func customizedCamera() {
    
        
        topHeaderBaseView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        bottomLayerBaseView.frame = CGRect(x:0, y: self.view.frame.size.height - 100, width: self.view.frame.size.width, height: 100)
        bottomLayerBaseView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        self.view.addSubview(bottomLayerBaseView)
        
        let changeCameraModeIconImg = UIImage(named: "camera_rotate_icon")
        changeCameraMode = UIButton(frame: CGRect(x: 20 , y: 33, width: 40, height: 34))
        self.CameraModeManageSelected = true
        changeCameraMode.setBackgroundImage(changeCameraModeIconImg, for: .normal)
        changeCameraMode.addTarget(self, action: #selector(changeCameraModeButton(button:)), for: .touchUpInside)
        self.bottomLayerBaseView.addSubview(changeCameraMode)
        
        flashIconUnselectedImg = UIImage(named: "flash_off")!
        flashIconSelectedImg = UIImage(named: "flash_on")!
        changeFlashBtn = UIButton(frame: CGRect(x: self.view.frame.size.width - 60 , y: 33, width: 40, height: 34))
        changeFlashBtn.setImage(#imageLiteral(resourceName: "flashOutline"), for: UIControlState())
        changeFlashBtn.addTarget(self, action: #selector(flashButton(button:)), for: .touchUpInside)
        flashBtnManageSelected = false
        self.bottomLayerBaseView.addSubview(changeFlashBtn)
        
        
        whiteVideoBtnImg = UIImage(named: "WhiteVideoBtn")!
        RedStopBtnImg = UIImage(named: "stopVideoBtn")!
        redPlayBtnImg = UIImage(named: "PlayVideoBtn")!
        
       
        whiteVideoRecorBigBtn = UIButton(frame: CGRect(x: (self.view.frame.size.width -  80)/2 , y: 10, width: 80, height: 80))
        whiteVideoRecorBigBtn.setBackgroundImage(RedStopBtnImg, for: .normal)
        whiteVideoRecorBigBtn.layer.masksToBounds = true
        whiteVideoRecorBigBtn.layer.cornerRadius = 40.0
        whiteVideoRecorBigBtn.addTarget(self, action: #selector(captureImgOrVideoButton(button:)), for: .touchUpInside)
        self.bottomLayerBaseView.addSubview(whiteVideoRecorBigBtn)
       
        RcordingVideoManage = false
        
        countDownLabel = UILabel(frame: CGRect(x:10 , y: 28, width: 100, height: 30))
        countDownLabel.textColor = UIColor.white
        countDownLabel.text = "00:00"
        countDownLabel.textAlignment = .left
      //  countDownLabel.isHidden = true
        countDownLabel.font = UIFont.systemFont(ofSize: 20)
        self.view.addSubview(countDownLabel)
        
        
    }
    
    @objc func captureImgOrVideoButton(button: UIButton) {
        
         RcordingVideoManage = !RcordingVideoManage
      
        if RcordingVideoManage == true {
          print("Video is recoeding")
              whiteVideoRecorBigBtn.setBackgroundImage(redPlayBtnImg, for: .normal)
          
            startVideoRecording()
            
        } else {
            
            print("stop Video")
              whiteVideoRecorBigBtn.setBackgroundImage(RedStopBtnImg, for: .normal)
        
            stopVideoRecording()
        }
        
        
    }
    
    @objc func update() {
        
        if(count > 0){
           
            let minutes = Int(count) / 60
            let seconds = Int(count) % 60
            
            var countStr =  String(format:"%02i:%02i", minutes, seconds)
            print(countStr)
            countDownLabel.text = countStr
            count = count - 1
        }else {
            timer.invalidate()
            whiteVideoRecorBigBtn.setBackgroundImage(RedStopBtnImg, for: .normal)
            
            countDownLabel.text = "00:00"
            RcordingVideoManage = !RcordingVideoManage
            stopVideoRecording()
        }
    }
    @objc func CancelButton(button: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    @objc func flashButton(button: UIButton) {
        
       flashBtnManageSelected = !flashBtnManageSelected
        
        if flashBtnManageSelected == true {
            print("Flash On")
            toggleTorch(on: true)
            changeFlashBtn.setImage(#imageLiteral(resourceName: "flash"), for: .normal)
        } else {
             print("Flash Off")
            toggleTorch(on: false)
            changeFlashBtn.setImage(#imageLiteral(resourceName: "flashOutline"), for: .normal)
        }
        

    }
    func toggleTorch(on: Bool) {
        guard let device = AVCaptureDevice.default(for: AVMediaType.video)
            else {return}
        
        if device.hasTorch {
            do {
                try device.lockForConfiguration()
                
                if on == true {
                    device.torchMode = .on
                } else {
                    device.torchMode = .off
                }
                
                device.unlockForConfiguration()
            } catch {
                print("Torch could not be used")
            }
        } else {
            print("Torch is not available")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        count = 59
        countDownLabel.isHidden = true
        countDownLabel.text = "00:00"
    }
    @objc func OpenGaleryButton(button: UIButton) {
        
    }
    @objc func changeCameraModeButton(button: UIButton) {
        
        switchCamera()
        CameraModeManageSelected = !CameraModeManageSelected
        
        if CameraModeManageSelected == true {
            print("Rear Mode")
             self.changeFlashBtn.isHidden = false
        } else {
            print("Front Mode")
            toggleTorch(on: false)
             flashBtnManageSelected = !flashBtnManageSelected
          changeFlashBtn.setImage(#imageLiteral(resourceName: "flashOutline"), for: UIControlState())
            self.changeFlashBtn.isHidden = true
            
        }
        
        
    }
    
	func swiftyCam(_ swiftyCam: SwiftyCamViewController, didTake photo: UIImage) {
        
        notifyUser("", message: "Please Hold to Record Video." , vc: self)
	}

	func swiftyCam(_ swiftyCam: SwiftyCamViewController, didBeginRecordingVideo camera: SwiftyCamViewController.CameraSelection) {
		print("Did Begin Recording")
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(update), userInfo: nil, repeats: true)
        
    countDownLabel.isHidden = false
      
        changeFlashBtn.isHidden = true
        changeCameraMode.isHidden = true
        
	//	CaptureVideoOrImageBtn.growButton()
		UIView.animate(withDuration: 0.00, animations: {
			self.flashButton.alpha = 0.0
			self.flipCameraButton.alpha = 0.0
		})
	}
//    func update() {
//        if(count > 0) {
//            print(count)
//            //count = count -  1
//            print(count)
//            timer.invalidate()
//            // countDownLabel.text = String(count--)
//        }
//        print(count)
//        count = count -  1
//        let aStr = String(format: "00:%d",count)
//        countDownLabel.text = aStr
//        print(count)
//    }
   
	func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFinishRecordingVideo camera: SwiftyCamViewController.CameraSelection) {
		print("Did finish Recording")
	//	CaptureVideoOrImageBtn.shrinkButton()
		UIView.animate(withDuration: 0.05, animations: {
			self.flashButton.alpha = 1.0
			self.flipCameraButton.alpha = 1.0
		})
	}

	func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFinishProcessVideoAt url: URL) {
	//	let newVC = VideoViewController(videoURL: url)
        
    //    self.uploadIntroDuctionVideoToAmazon(url: url)
         timer.invalidate()
        toggleTorch(on: false)
     
        changeFlashBtn.setImage(#imageLiteral(resourceName: "flashOutline"), for: UIControlState())
        if CameraModeManageSelected == true {
            print("Rear Mode")
            self.changeFlashBtn.isHidden = false
        } else {
            print("Front Mode")
            self.changeFlashBtn.isHidden = true
            
        }
        
       
        changeCameraMode.isHidden = false
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ChooseVideoPreviewVC") as! ChooseVideoPreviewVC
       // vc. = newsObj
        print(self.coachDetails)
        vc.coachDetails = self.coachDetails
        vc.videoURl = url as NSURL
        vc.count = 59 - self.count
        print(url)
        print(vc.videoURl)
        navigationController?.pushViewController(vc,animated: true)
        
        print("Did finish Recording")
		//self.present(newVC, animated: true, completion: nil)
	}

    func uploadIntroDuctionVideoToAmazon(url : URL)  {
        
         showProgressIndicator(refrenceView: self.view)
        
        guard let data = NSData(contentsOf: url as URL) else {
            return
        }
        
        print("File size before compression: \(Double(data.length / 1024)) mb")
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
                 print("File size after compression: \(Double(compressedData.length / 1024)) mb")
                self.uploadVideo(url: compressedURL)
                
               
            case .failed:
                break
            case .cancelled:
                break
            }
        }
        
 
    }
    
 
    func uploadVideo(url : URL) {
        
        let videoURL = url as NSURL
        //  let videoURL = info[UIImagePickerControllerMediaURL] as! NSURL
        let videoData = NSData(contentsOf: videoURL as URL)
        let path = try! FileManager.default.url(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask, appropriateFor: nil, create: false)
        let newPath = path.appendingPathComponent("/videoFileName.mp4")
        do {
            try videoData?.write(to: newPath)
        } catch {
            print(error)
        }
        
        //        }
        var thumbnialImg = self.createThumbnailOfVideoFromFileURL(videoURL: newPath.absoluteString) as! UIImage
        
        thumbnialImg = thumbnialImg.resizeWithWidth(width: 200)!
        let fileManager = FileManager.default
        let str = "\(String(describing: thumbnialImg)).jpeg"
        let path1 = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("\(String(describing: thumbnialImg)).jpeg")
        let imageData = UIImageJPEGRepresentation(thumbnialImg, 0.5)
        let imageSize: Int = imageData!.count
        print("size of image in KB: %f ", Double(imageSize) / 1024.0)
        fileManager.createFile(atPath: path1 as String, contents: imageData, attributes: nil)
        let fileUrl = URL(fileURLWithPath: path1)
        
        
                WebServices().uploadVideoonServer(imageURL: newPath){ (responseData)  in
                    //   stopProgressIndicator()
                    if responseData != nil{
                        let uploadUrl = responseData!
        
        
        
                        WebServices().uploadImageonServer(imageURL: fileUrl){ (responseData)  in
                            stopProgressIndicator()
                            if responseData != nil{
                                let uploadUrlImage = responseData!
        
                                /***************  edit profile Image ************/
                                self.showCoachPofileDetials()
                                self.rushDirectMessage = PricingDictManage["RushDirectPricing"] as! String
                                self.liveChat = PricingDictManage["LiveChatPricing"] as! String
                                self.directMessage = PricingDictManage["DirectPricing"] as! String
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
        guard let exportSession = AVAssetExportSession(asset: urlAsset, presetName: AVAssetExportPresetMediumQuality) else {
            handler(nil)
            
            return
        }
        
        exportSession.outputURL = outputURL
        exportSession.outputFileType = AVFileType.mov
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
        categoryArray = getCategoryArray() as! NSMutableArray
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
                   
                    let alert = UIAlertController(title: "Alert", message: "Introduction Video Uploaded Successfully.", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { action in
                        print("TouchID")
                         pushView(viewController: self, identifier: "CoachesTabbarVC")
//                         self.navigationController?.popViewController(animated: true)
                    }))
                    
                    self.present(alert, animated: true, completion: nil)
                   
                    
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
    
   
   
//    func getThumbnailForVideoNamed(_ videoName: String, ofType videoType: String) -> UIImage {
//        let url: String? = Bundle.main.path(forResource: videoName, ofType: videoType)
//        let videoURL = URL(fileURLWithPath: url ?? "")
//        let asset1 = AVURLAsset(url: videoURL, options: nil)
//        let generate1 = AVAssetImageGenerator(asset: asset1)
//        generate1.appliesPreferredTrackTransform = true
//        var err: Error? = nil
//        let time: CMTime = CMTimeMake(1, 2)
//        let oneRef = (try? generate1.copyCGImage(at: time, actualTime: nil))
//        let thumbNailImage = UIImage(cgImage: oneRef as? CGImage ?? CGImage())
//        return thumbNailImage
//    }
	func swiftyCam(_ swiftyCam: SwiftyCamViewController, didSwitchCameras camera: SwiftyCamViewController.CameraSelection) {
		print(camera)
	}
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFailToRecordVideo error: Error) {
        print(error)
    }

    @IBAction func cameraSwitchTapped(_ sender: Any) {
        switchCamera()
    }
    
    @IBAction func toggleFlashTapped(_ sender: Any) {
        flashEnabled = !flashEnabled
        
        if flashEnabled == true {
            flashButton.setImage(#imageLiteral(resourceName: "flash"), for: UIControlState())
        } else {
            flashButton.setImage(#imageLiteral(resourceName: "flashOutline"), for: UIControlState())
        }
    }
}


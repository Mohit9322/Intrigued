//
//  CustomCameraNew.swift
//  Intrigued
//
//  Created by Shineweb-solutions on 15/03/18.
//  Copyright © 2018 daniel helled. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
let NextLevelAlbumTitle = "NextLevel"
class CustomCameraNew: UIViewController {
    @IBOutlet weak var HeaderLbl: UILabel!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!

    var flashIconUnselectedImg: UIImage = UIImage()
    var flashIconSelectedImg: UIImage = UIImage()
    var flashBtnManageSelected = Bool()
    var CameraModeManageSelected = Bool()
    var changeFlashBtn:UIButton = UIButton()
    var changeCameraMode:UIButton = UIButton()
    var bottomLayerBaseView:UIView = UIView()
    var fromCoachSignUp = ""
    var count = 60
    var countDownLabel: UILabel!
    var timer = Timer()
    
    var whiteVideoRecorBigBtn:UIButton = UIButton()
   
    var whiteVideoBtnImg: UIImage = UIImage()
    var RedStopBtnImg: UIImage = UIImage()
    var redPlayBtnImg: UIImage = UIImage()
    var RcordingVideoManage = Bool()
    
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
    var coachDetails : NSDictionary = NSDictionary()
    
    var direct_Status = "0"
    var rush_direct_Status = "0"
    var livechat_Status = "0"
    
    
    internal var previewView: UIView?
    internal var gestureView: UIView?
    internal var controlDockView: UIView?
    internal var focusView: FocusIndicatorView?
    
     internal var photoTapGestureRecognizer: UITapGestureRecognizer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        self.view.backgroundColor = UIColor.black
        self.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        let screenBounds = UIScreen.main.bounds
        
        // preview
        self.previewView = UIView(frame: CGRect(x:0  , y: 80, width: self.view.frame.size.width, height: self.view.frame.size.height - 80))
      
        if let previewView = self.previewView {
            previewView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            previewView.backgroundColor = UIColor.black
            NextLevel.shared.previewLayer.frame = CGRect(x:0  , y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height - 80)
            previewView.layer.addSublayer(NextLevel.shared.previewLayer)
            self.view.addSubview(previewView)
        }
        
        let nextLevel = NextLevel.shared
        nextLevel.delegate = self
        nextLevel.deviceDelegate = self
        nextLevel.flashDelegate = self
        nextLevel.videoDelegate = self
        nextLevel.photoDelegate = self
        
        // video configuration
        nextLevel.videoConfiguration.bitRate = 2000000
        nextLevel.videoConfiguration.scalingMode = AVVideoScalingModeResizeAspectFill
        
        // audio configuration
        nextLevel.audioConfiguration.bitRate = 96000
        
      self.customizedCamera()
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NextLevel.shared.stop()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
      
        count = 60
        countDownLabel.isHidden = true
        countDownLabel.text = "00:00"
        let nextLevel = NextLevel.shared
        if nextLevel.authorizationStatus(forMediaType: AVMediaType.video) == .authorized &&
            nextLevel.authorizationStatus(forMediaType: AVMediaType.audio) == .authorized {
            do {
                try nextLevel.start()
            } catch {
                print("NextLevel, failed to start camera session")
            }
        } else {
            nextLevel.requestAuthorization(forMediaType: AVMediaType.video)
            nextLevel.requestAuthorization(forMediaType: AVMediaType.audio)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func customizedCamera() {
        
        
        
        let unlockLbl = UILabel(frame: CGRect(x:(self.view.frame.size.width - 200)/2 , y: 95, width: 200, height: 30))
        unlockLbl.textColor = UIColor.white
        unlockLbl.text = "Introduction Video"
        unlockLbl.textAlignment = .center
        //    self.view.addSubview(unlockLbl)
        
        
        bottomLayerBaseView.frame = CGRect(x:0, y: self.view.frame.size.height - 100, width: self.view.frame.size.width, height: 100)
        bottomLayerBaseView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        self.view.addSubview(bottomLayerBaseView)
        
        
        let changeCameraModeIconImg = UIImage(named: "camera_rotate_icon")
        changeCameraMode = UIButton(frame: CGRect(x: 20 , y: 33, width: 40, height: 34))
        //  changeCameraMode.layer.masksToBounds = true
        self.CameraModeManageSelected = true
        //  changeCameraMode.layer.cornerRadius = 20.0
        changeCameraMode.setBackgroundImage(changeCameraModeIconImg, for: .normal)
        changeCameraMode.addTarget(self, action: #selector(changeCameraModeButton(button:)), for: .touchUpInside)
        self.bottomLayerBaseView.addSubview(changeCameraMode)
        
        flashIconUnselectedImg = UIImage(named: "flash_off")!
        flashIconSelectedImg = UIImage(named: "flash_on")!
        changeFlashBtn = UIButton(frame: CGRect(x: self.view.frame.size.width - 60 , y: 33, width: 40, height: 34))
        //   changeFlashBtn.setBackgroundImage(flashIconUnselectedImg, for: .normal)
        changeFlashBtn.setImage(#imageLiteral(resourceName: "flashOutline"), for: UIControlState())
        changeFlashBtn.addTarget(self, action: #selector(flashButton(button:)), for: .touchUpInside)
        flashBtnManageSelected = false
        self.bottomLayerBaseView.addSubview(changeFlashBtn)
        
        
        whiteVideoBtnImg = UIImage(named: "WhiteVideoBtn")!
        RedStopBtnImg = UIImage(named: "stopVideoBtn")!
        redPlayBtnImg = UIImage(named: "PlayVideoBtn")!
        
        
        whiteVideoRecorBigBtn = UIButton(frame: CGRect(x: (self.view.frame.size.width -  80)/2 , y: 10, width: 80, height: 80))
        //      whiteVideoRecorBigBtn.setImage(whiteVideoBtnImg, for: .normal )
        whiteVideoRecorBigBtn.setBackgroundImage(RedStopBtnImg, for: .normal)
        whiteVideoRecorBigBtn.layer.masksToBounds = true
        whiteVideoRecorBigBtn.layer.cornerRadius = 40.0
        whiteVideoRecorBigBtn.addTarget(self, action: #selector(captureImgOrVideoButton(button:)), for: .touchUpInside)
        self.bottomLayerBaseView.addSubview(whiteVideoRecorBigBtn)
        
        RcordingVideoManage = false
        
        
        countDownLabel = UILabel(frame: CGRect(x:10 , y: 95, width: 100, height: 30))
        countDownLabel.textColor = UIColor.white
        countDownLabel.text = "00:00"
        countDownLabel.textAlignment = .center
        countDownLabel.isHidden = true
        countDownLabel.font = UIFont.systemFont(ofSize: 20)
        self.view.addSubview(countDownLabel)
        
        
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
            whiteVideoRecorBigBtn.setBackgroundImage(RedStopBtnImg, for: .normal)
            
            countDownLabel.text = "00:00"
            RcordingVideoManage = !RcordingVideoManage
            self.endCapture()
        }
    }
    @objc func captureImgOrVideoButton(button: UIButton) {
        
    

        RcordingVideoManage = !RcordingVideoManage
        
        if RcordingVideoManage == true {
            print("Video is recoeding")
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(update), userInfo: nil, repeats: true)
            
            countDownLabel.isHidden = false
            
            changeFlashBtn.isHidden = true
            changeCameraMode.isHidden = true
            whiteVideoRecorBigBtn.setBackgroundImage(redPlayBtnImg, for: .normal)
            //    RedVideoRecordVideoRecordBtn.setImage(redPlayBtnImg, for: UIControlState())
          self.startCapture()
            
        } else {
            
            print("stop Video")
            whiteVideoRecorBigBtn.setBackgroundImage(RedStopBtnImg, for: .normal)
            //      RedVideoRecordVideoRecordBtn.setImage(RedStopBtnImg, for: UIControlState())
             //   NextLevel.shared.pause()
            self.pauseCapture()
            self.endCapture()
        }
        
      
    }
    @objc func changeCameraModeButton(button: UIButton) {
         NextLevel.shared.flipCaptureDevicePosition()
        
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
    @IBAction func skipBtnPressed(_ sender: Any) {
        
        
          self.navigationController?.popViewController(animated: true)
//        if fromCoachSignUp == "YES" {
//            fromCoachSignUp = "NO"
//            pushView(viewController: self, identifier: "CoachesTabbarVC")
//        }else {
//            self.navigationController?.popViewController(animated: true)
//        }
        
    }
}
extension CustomCameraNew {
    
    internal func startCapture() {
      //  self.photoTapGestureRecognizer?.isEnabled = false
        UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseInOut, animations: {
       //     self.recordButton?.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        }) { (completed: Bool) in
        }
       NextLevel.shared.record()
        
    }
    
    internal func pauseCapture() {
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseOut, animations: {
          //  self.recordButton?.transform = .identity
        }) { (completed: Bool) in
        }
        NextLevel.shared.pause()
    }
    
    internal func endCapture() {
        self.photoTapGestureRecognizer?.isEnabled = true
       NextLevel.shared.stop()
        ////////////
        
           showProgressIndicator(refrenceView: self.view)
        if let session = NextLevel.shared.session {
            
            //..
            
            // undo
            session.removeLastClip()
            
            // various editing operations can be done using the NextLevelSession methods
            
            // export
            session.mergeClips(usingPreset: AVAssetExportPresetMediumQuality, completionHandler: { (url: URL?, error: Error?) in
                if let mergeUrl = url {
                    
                    print(mergeUrl)
                    let videoURL = mergeUrl as! NSURL
                    print(videoURL)
                    
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            let vc = storyboard.instantiateViewController(withIdentifier: "ChooseVideoPreviewVC") as! ChooseVideoPreviewVC
                            // vc. = newsObj
                            print(self.coachDetails)
                            vc.coachDetails = self.coachDetails
                    let fileUrl = NSURL(string: videoURL.absoluteString!)
                            print(fileUrl?.absoluteString)
                            print(fileUrl)
                    
                     stopProgressIndicator()
                    
                            vc.videoURl = fileUrl!
                            self.navigationController?.pushViewController(vc,animated: true)
                    
                    let videoData = NSData(contentsOf: videoURL as URL)
                    print(videoData)
                    
                
                    
                    //
                } else if let saveUrl = error {
                     print(saveUrl)
//                    let videoURL = saveUrl as! NSURL
//                    print(videoURL)
                     stopProgressIndicator()
                    
                    
                //    let videoData = NSData(contentsOf: videoURL as URL)
                 //   print(videoData)
                }
            })
            
            //..
            
        }
        return
        ///////////
        if let session = NextLevel.shared.session {
         //   self.saveVideo(withURL: (NextLevel.shared.session?.url)!)
            print(session.clips.count )
            print(NextLevel.shared.session?.url)
            let videoURL = NextLevel.shared.session?.url as! NSURL
            print(videoURL)
            
            
            
            let videoData = NSData(contentsOf: videoURL as URL)
            print(videoData)
            let path = try! FileManager.default.url(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask, appropriateFor: nil, create: false)
            let newPath = path.appendingPathComponent("/videoFileName.mp4")
            do {
                try videoData?.write(to: newPath)
            } catch {
                print(error)
            }
            
        }
        
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
        
        //
        changeCameraMode.isHidden = false
//        let videoUrl1 = NextLevel.shared.session?.url?.absoluteString as! String
//        let url = NextLevel.shared.session?.url as! URL
//        print(url)
//
//        let newString = videoUrl1.replacingOccurrences(of: "file://", with: "", options: .literal, range: nil) as String
//        let fileUrl = Foundation.URL(string: newString)
//        print(fileUrl)
//
//        let videoData = NSData(contentsOf: url)
//        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
//        let documentsDirectory: AnyObject = paths[0] as AnyObject
//      //  let dataPath = documentsDirectory.appendingPathComponent("/vid1.mp4")
//
//        videoData?.write(toFile: url.absoluteString, atomically: false)
//
//        guard let data = NSData(contentsOf: fileUrl as! URL) else {
//         //   return
//
//            return
//
//        }
//
//        print("File size before compression: \(Double(data.length / 1024)) kb")
//        let videoUrl = NextLevel.shared.session?.url as! URL
//        self.saveVideo(withURL: videoUrl)
//
        
        
        
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let vc = storyboard.instantiateViewController(withIdentifier: "ChooseVideoPreviewVC") as! ChooseVideoPreviewVC
//        // vc. = newsObj
//        print(self.coachDetails)
//        vc.coachDetails = self.coachDetails
//        let fileUrl = NSURL(string: videoUrl1)
//        print(fileUrl?.absoluteString)
//        print(fileUrl)
//
//        print(videoUrl1)
//
//        vc.videoURl = fileUrl!
//        navigationController?.pushViewController(vc,animated: true)

     
        
        if let session = NextLevel.shared.session {
//
            if session.clips.count > 1 {
                NextLevel.shared.session?.mergeClips(usingPreset: AVAssetExportPresetHighestQuality, completionHandler: { (url: URL?, error: Error?) in
                    if let videoUrl = url {
                        print(videoUrl)
                        self.saveVideo(withURL: videoUrl)
                    } else if let _ = error {
                        print("failed to merge clips at the end of capture \(String(describing: error))")
                    }
                })
            } else if let videoUrl = NextLevel.shared.session?.lastClipUrl {
                 print(videoUrl)
                self.saveVideo(withURL: videoUrl)
            } else {
                // prompt that the video has been saved
                let alertController = UIAlertController(title: "Video Capture", message: "Not enough video captured!", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            }

        }
        
        
        
//        /////////
//        var fileManager: FileManager = FileManager()
//        do
//        {
//            let fileList: NSArray = try! fileManager.contentsOfDirectory(atPath: "\(NSTemporaryDirectory())") as! NSArray
//
//            var filesStr: NSMutableString = NSMutableString(string: "Files in Documents folder \n")
//            for s in fileList {
//                filesStr.appendFormat("%@", s as! String)
//            }
//        }
//        catch {
//
//        }
//
//
//        ////////
//
    }
    
    internal func saveVideo(withURL url: URL) {
        PHPhotoLibrary.shared().performChanges({
            let albumAssetCollection = self.albumAssetCollection(withTitle: NextLevelAlbumTitle)
            if albumAssetCollection == nil {
                let changeRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: NextLevelAlbumTitle)
                let _ = changeRequest.placeholderForCreatedAssetCollection
            }}, completionHandler: { (success1: Bool, error1: Error?) in
                if let albumAssetCollection = self.albumAssetCollection(withTitle: NextLevelAlbumTitle) {
                    PHPhotoLibrary.shared().performChanges({
                        if let assetChangeRequest = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url) {
                            let assetCollectionChangeRequest = PHAssetCollectionChangeRequest(for: albumAssetCollection)
                            let enumeration: NSArray = [assetChangeRequest.placeholderForCreatedAsset!]
                            assetCollectionChangeRequest?.addAssets(enumeration)
                        }
                    }, completionHandler: { (success2: Bool, error2: Error?) in
                        if success2 == true {
                            // prompt that the video has been saved
                            let alertController = UIAlertController(title: "Video Saved!", message: "Saved to the camera roll.", preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                            alertController.addAction(okAction)
                            self.present(alertController, animated: true, completion: nil)
                        } else {
                            // prompt that the video has been saved
                            let alertController = UIAlertController(title: "Oops!", message: "Something failed!", preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                            alertController.addAction(okAction)
                            self.present(alertController, animated: true, completion: nil)
                        }
                    })
                }
        })
    }
}

extension CustomCameraNew: NextLevelDelegate {
    
    // permission
    func nextLevel(_ nextLevel: NextLevel, didUpdateAuthorizationStatus status: NextLevelAuthorizationStatus, forMediaType mediaType: AVMediaType) {
        print("NextLevel, authorization updated for media \(mediaType) status \(status)")
        if nextLevel.authorizationStatus(forMediaType: AVMediaType.video) == .authorized &&
            nextLevel.authorizationStatus(forMediaType: AVMediaType.audio) == .authorized {
            do {
                try nextLevel.start()
            } catch {
                print("NextLevel, failed to start camera session")
            }
        } else if status == .notAuthorized {
            // gracefully handle when audio/video is not authorized
            print("NextLevel doesn't have authorization for audio or video")
        }
    }
    
    // configuration
    func nextLevel(_ nextLevel: NextLevel, didUpdateVideoConfiguration videoConfiguration: NextLevelVideoConfiguration) {
    }
    
    func nextLevel(_ nextLevel: NextLevel, didUpdateAudioConfiguration audioConfiguration: NextLevelAudioConfiguration) {
    }
    
    // session
    func nextLevelSessionWillStart(_ nextLevel: NextLevel) {
        print("nextLevelSessionWillStart")
    }
    
    func nextLevelSessionDidStart(_ nextLevel: NextLevel) {
        print("nextLevelSessionDidStart")
    }
    
    func nextLevelSessionDidStop(_ nextLevel: NextLevel) {
        print("nextLevelSessionDidStop")
        
    }
    
    // interruption
    func nextLevelSessionWasInterrupted(_ nextLevel: NextLevel) {
    }
    
    
    
    func nextLevelSessionInterruptionEnded(_ nextLevel: NextLevel) {
    }
    
    // mode
    func nextLevelCaptureModeWillChange(_ nextLevel: NextLevel) {
    }
    
    func nextLevelCaptureModeDidChange(_ nextLevel: NextLevel) {
    }
    
}
extension CustomCameraNew {
    
    internal func handlePhotoTapGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer) {
        // play system camera shutter sound
        AudioServicesPlaySystemSoundWithCompletion(SystemSoundID(1108), nil)
        NextLevel.shared.capturePhotoFromVideo()
    }
    
    @objc internal func handleFocusTapGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer) {
        let tapPoint = gestureRecognizer.location(in: self.previewView)
        
        if let focusView = self.focusView {
            var focusFrame = focusView.frame
            focusFrame.origin.x = CGFloat((tapPoint.x - (focusFrame.size.width * 0.5)).rounded())
            focusFrame.origin.y = CGFloat((tapPoint.y - (focusFrame.size.height * 0.5)).rounded())
            focusView.frame = focusFrame
            
            self.previewView?.addSubview(focusView)
            focusView.startAnimation()
        }
        
        let adjustedPoint = NextLevel.shared.previewLayer.captureDevicePointConverted(fromLayerPoint: tapPoint)
        NextLevel.shared.focusExposeAndAdjustWhiteBalance(atAdjustedPoint: adjustedPoint)
    }
    
}
extension CustomCameraNew: NextLevelPhotoDelegate {
    
    // photo
    func nextLevel(_ nextLevel: NextLevel, willCapturePhotoWithConfiguration photoConfiguration: NextLevelPhotoConfiguration) {
    }
    
    func nextLevel(_ nextLevel: NextLevel, didCapturePhotoWithConfiguration photoConfiguration: NextLevelPhotoConfiguration) {
    }
    
    func nextLevel(_ nextLevel: NextLevel, didProcessPhotoCaptureWith photoDict: [String : Any]?, photoConfiguration: NextLevelPhotoConfiguration) {
        
        if let dictionary = photoDict,
            let photoData = dictionary[NextLevelPhotoJPEGKey] {
            
            PHPhotoLibrary.shared().performChanges({
                
                let albumAssetCollection = self.albumAssetCollection(withTitle: NextLevelAlbumTitle)
                if albumAssetCollection == nil {
                    let changeRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: NextLevelAlbumTitle)
                    let _ = changeRequest.placeholderForCreatedAssetCollection
                }
                
            }, completionHandler: { (success1: Bool, error1: Error?) in
                
                if success1 == true {
                    if let albumAssetCollection = self.albumAssetCollection(withTitle: NextLevelAlbumTitle) {
                        PHPhotoLibrary.shared().performChanges({
                            if let data = photoData as? Data,
                                let photoImage = UIImage(data: data) {
                                let assetChangeRequest = PHAssetChangeRequest.creationRequestForAsset(from: photoImage)
                                let assetCollectionChangeRequest = PHAssetCollectionChangeRequest(for: albumAssetCollection)
                                let enumeration: NSArray = [assetChangeRequest.placeholderForCreatedAsset!]
                                assetCollectionChangeRequest?.addAssets(enumeration)
                            }
                        }, completionHandler: { (success2: Bool, error2: Error?) in
                            if success2 == true {
                                let alertController = UIAlertController(title: "Photo Saved!", message: "Saved to the camera roll.", preferredStyle: .alert)
                                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                                alertController.addAction(okAction)
                                self.present(alertController, animated: true, completion: nil)
                            }
                        })
                    }
                } else if let _ = error1 {
                    print("failure capturing photo from video frame \(String(describing: error1))")
                }
                
            })
        }
        
    }
    
    func nextLevel(_ nextLevel: NextLevel, didProcessRawPhotoCaptureWith photoDict: [String : Any]?, photoConfiguration: NextLevelPhotoConfiguration) {
    }
    
    func nextLevelDidCompletePhotoCapture(_ nextLevel: NextLevel) {
    }
    
}
// MARK: - NextLevelVideoDelegate

extension CustomCameraNew: NextLevelVideoDelegate {
    
    // video zoom
    func nextLevel(_ nextLevel: NextLevel, didUpdateVideoZoomFactor videoZoomFactor: Float) {
    }
    
    // video frame processing
    func nextLevel(_ nextLevel: NextLevel, willProcessRawVideoSampleBuffer sampleBuffer: CMSampleBuffer, onQueue queue: DispatchQueue) {
    }
    
    @available(iOS 11.0, *)
    func nextLevel(_ nextLevel: NextLevel, willProcessFrame frame: AnyObject, pixelBuffer: CVPixelBuffer, timestamp: TimeInterval, onQueue queue: DispatchQueue) {
    }
    
    // enabled by isCustomContextVideoRenderingEnabled
    func nextLevel(_ nextLevel: NextLevel, renderToCustomContextWithImageBuffer imageBuffer: CVPixelBuffer, onQueue queue: DispatchQueue) {
    }
    
    // video recording session
    func nextLevel(_ nextLevel: NextLevel, didSetupVideoInSession session: NextLevelSession) {
        print("didSetupVideoInSession")
    }
    
    func nextLevel(_ nextLevel: NextLevel, didSetupAudioInSession session: NextLevelSession) {
         print("didSetupAudioInSession")
    }
    
    func nextLevel(_ nextLevel: NextLevel, didStartClipInSession session: NextLevelSession) {
          print("didStartClipInSession")
    }
    
    func nextLevel(_ nextLevel: NextLevel, didCompleteClip clip: NextLevelClip, inSession session: NextLevelSession) {
         print("didCompleteClip")
    }
    
    func nextLevel(_ nextLevel: NextLevel, didAppendVideoSampleBuffer sampleBuffer: CMSampleBuffer, inSession session: NextLevelSession) {
         print("didAppendVideoSampleBuffer")
    }
    
    func nextLevel(_ nextLevel: NextLevel, didAppendAudioSampleBuffer sampleBuffer: CMSampleBuffer, inSession session: NextLevelSession) {
         print("didAppendAudioSampleBuffer")
    }
    
    func nextLevel(_ nextLevel: NextLevel, didAppendVideoPixelBuffer pixelBuffer: CVPixelBuffer, timestamp: TimeInterval, inSession session: NextLevelSession) {
         print("didAppendVideoPixelBuffer")
    }
    
    func nextLevel(_ nextLevel: NextLevel, didSkipVideoPixelBuffer pixelBuffer: CVPixelBuffer, timestamp: TimeInterval, inSession session: NextLevelSession) {
        print("didSkipVideoPixelBuffer")
    }
    
    
    func nextLevel(_ nextLevel: NextLevel, didSkipVideoSampleBuffer sampleBuffer: CMSampleBuffer, inSession session: NextLevelSession) {
        
         print("didSkipVideoSampleBuffer")
    }
    
    func nextLevel(_ nextLevel: NextLevel, didSkipAudioSampleBuffer sampleBuffer: CMSampleBuffer, inSession session: NextLevelSession) {
        print("didSkipAudioSampleBuffer")
    }
    
    func nextLevel(_ nextLevel: NextLevel, didCompleteSession session: NextLevelSession) {
        // called when a configuration time limit is specified
         print("didCompleteSession")
        self.endCapture()
    }
    
    // video frame photo
    
    func nextLevel(_ nextLevel: NextLevel, didCompletePhotoCaptureFromVideoFrame photoDict: [String : Any]?) {
         print("didCompletePhotoCaptureFromVideoFrame")
        if let dictionary = photoDict,
            let photoData = dictionary[NextLevelPhotoJPEGKey] {
            
            PHPhotoLibrary.shared().performChanges({
                
                let albumAssetCollection = self.albumAssetCollection(withTitle: NextLevelAlbumTitle)
                if albumAssetCollection == nil {
                    let changeRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: NextLevelAlbumTitle)
                    let _ = changeRequest.placeholderForCreatedAssetCollection
                }
                
            }, completionHandler: { (success1: Bool, error1: Error?) in
                
                if success1 == true {
                    if let albumAssetCollection = self.albumAssetCollection(withTitle: NextLevelAlbumTitle) {
                        PHPhotoLibrary.shared().performChanges({
                            if let data = photoData as? Data,
                                let photoImage = UIImage(data: data) {
                                let assetChangeRequest = PHAssetChangeRequest.creationRequestForAsset(from: photoImage)
                                let assetCollectionChangeRequest = PHAssetCollectionChangeRequest(for: albumAssetCollection)
                                let enumeration: NSArray = [assetChangeRequest.placeholderForCreatedAsset!]
                                assetCollectionChangeRequest?.addAssets(enumeration)
                            }
                        }, completionHandler: { (success2: Bool, error2: Error?) in
                            if success2 == true {
                                let alertController = UIAlertController(title: "Photo Saved!", message: "Saved to the camera roll.", preferredStyle: .alert)
                                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                                alertController.addAction(okAction)
                                self.present(alertController, animated: true, completion: nil)
                            }
                        })
                    }
                } else if let _ = error1 {
                    print("failure capturing photo from video frame \(String(describing: error1))")
                }
                
            })
            
        }
        
    }
    
}
// MARK: - NextLevelFlashDelegate

extension CustomCameraNew: NextLevelFlashAndTorchDelegate {
    
    func nextLevelDidChangeFlashMode(_ nextLevel: NextLevel) {
    }
    
    func nextLevelDidChangeTorchMode(_ nextLevel: NextLevel) {
    }
    
    func nextLevelFlashActiveChanged(_ nextLevel: NextLevel) {
    }
    
    func nextLevelTorchActiveChanged(_ nextLevel: NextLevel) {
    }
    
    func nextLevelFlashAndTorchAvailabilityChanged(_ nextLevel: NextLevel) {
    }
    
}
extension CustomCameraNew: NextLevelDeviceDelegate {
    
    // position, orientation
    func nextLevelDevicePositionWillChange(_ nextLevel: NextLevel) {
    }
    
    func nextLevelDevicePositionDidChange(_ nextLevel: NextLevel) {
    }
    
    func nextLevel(_ nextLevel: NextLevel, didChangeDeviceOrientation deviceOrientation: NextLevelDeviceOrientation) {
    }
    
    // format
    func nextLevel(_ nextLevel: NextLevel, didChangeDeviceFormat deviceFormat: AVCaptureDevice.Format) {
    }
    
    // aperture
    func nextLevel(_ nextLevel: NextLevel, didChangeCleanAperture cleanAperture: CGRect) {
    }
    
    // focus, exposure, white balance
    func nextLevelWillStartFocus(_ nextLevel: NextLevel) {
    }
    
    func nextLevelDidStopFocus(_  nextLevel: NextLevel) {
        if let focusView = self.focusView {
            if focusView.superview != nil {
                focusView.stopAnimation()
            }
        }
    }
    
    func nextLevelWillChangeExposure(_ nextLevel: NextLevel) {
    }
    
    func nextLevelDidChangeExposure(_ nextLevel: NextLevel) {
        if let focusView = self.focusView {
            if focusView.superview != nil {
                focusView.stopAnimation()
            }
        }
    }
    
    func nextLevelWillChangeWhiteBalance(_ nextLevel: NextLevel) {
    }
    
    func nextLevelDidChangeWhiteBalance(_ nextLevel: NextLevel) {
    }
    
}
extension CustomCameraNew {
    
    internal func albumAssetCollection(withTitle title: String) -> PHAssetCollection? {
        let predicate = NSPredicate(format: "localizedTitle = %@", title)
        let options = PHFetchOptions()
        options.predicate = predicate
        let result = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: options)
        if result.count > 0 {
            return result.firstObject
        }
        return nil
    }
    
}


//
//  ChatVC.swift
//  Intrigued
//
//  Created by daniel helled on 18/09/17.
//  Copyright © 2017 daniel helled. All rights reserved.
//

import UIKit
import MobileCoreServices
import AVFoundation
import MediaPlayer
import AVKit

class ChatVC: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextViewDelegate {

    @IBOutlet weak var chatView: UIView!
    @IBOutlet weak var message_TxtField: UITextView!
    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var lbl_userNameTitle: UILabel!
    var picker = UIImagePickerController()
    var userQuestInfo = NSDictionary()
    var coach_id = ""
    var user_id = ""
    var orderId = ""
    var type = ""
    var serveiceTaxLiveChat = ""
    var closeChatLiveChat = ""
    
    var messageListArray = NSArray()
      var PreviewUrl = NSURL()
   // @objc func uploadImage_Video(_: )
    override func viewDidLoad() {
        super.viewDidLoad()
      
         chatTableView.register(UINib(nibName: "VideoChatCellTableViewCell", bundle: nil), forCellReuseIdentifier: "VideoChatCellTableViewCell")
        
        message_TxtField.delegate = self
        message_TxtField.placeholder = "Write Your message..."
        self.chatTableView.contentInset = UIEdgeInsetsMake(0, 0, 100, 0);
        chatView.layer.cornerRadius = chatView.frame.size.height / 2
        chatView.clipsToBounds = true
        chatView.layer.borderColor = UIColor.lightGray.cgColor
        chatView.layer.borderWidth = 1.0
        chatTableView.estimatedRowHeight = 30
        chatTableView.rowHeight = UITableViewAutomaticDimension
        print(userQuestInfo)
        if isCoach() {
            type = "1"
            if let userInfo = userQuestInfo["user_id"] as? NSDictionary {
                let userName = (userInfo["fname"] as? String ?? "")  + " " + (userInfo["lname"] as? String ?? "")
                lbl_userNameTitle.text = userName
                 user_id = userInfo["_id"] as? String ?? ""
              }
        }
        else{
            type = "2"
            if let userId = userQuestInfo["user_id"] as? String {
                 user_id = userId
            }
            
            if let coachInfo = userQuestInfo["coach_id"] as? NSDictionary {
                let userName = (coachInfo["fname"] as? String ?? "")  + " " + (coachInfo["lname"] as? String ?? "")
                lbl_userNameTitle.text = userName
            }
        }
        orderId = userQuestInfo["_id"] as? String ?? ""
        if let coachInfo = userQuestInfo["coach_id"] as? NSDictionary{
           coach_id = coachInfo["_id"] as? String ?? ""
        }
        getListofmessage()
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true

        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.uploadImage_Video(_:)), name: NSNotification.Name(rawValue: "ImageVideoUploadNotification"), object: nil)
        
        // handle notification
       
    }
    func textViewDidChange(_ textView: UITextView) {
        
        if let placeholderLabel = textView.viewWithTag(100) as? UILabel {
            placeholderLabel.isHidden = textView.text.characters.count > 0
        }
    }
    
    
    @IBAction func sendMessageBtnAction(_ sender: Any) {
        let requestDict = ["user_id": user_id,
                       "coach_id":coach_id,
                       "order_id":orderId,
                       "type":type,
                       "message":message_TxtField.text ?? ""] as [String : Any]
        sendUserMessage_to_coach(request: requestDict as NSDictionary)
    }
    
    @IBAction func infoButtonAction(_ sender: Any) {
        if isCoach() {
             let vc = self.storyboard?.instantiateViewController(withIdentifier: "CoachRequestUserProfileVC") as! CoachRequestUserProfileVC
             vc.userOrderInfo = userQuestInfo
             self.navigationController?.pushViewController(vc,animated: true)
        }
        else{
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "SessionInfoVC") as! SessionInfoVC
            vc.userOrderInfo = userQuestInfo
            self.navigationController?.pushViewController(vc,animated: true)
        }
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func sendImageBtnAction(_ sender: Any) {
    
        /*****************   testVideo Upload  **********/
        
//        let urlpath     = Bundle.main.path(forResource: "testVideo", ofType: "mp4")
//        let url         = NSURL.fileURL(withPath: urlpath!)
//        print(url.absoluteString)
//
//
//
//        videoData?.writeToFile(dataPath, atomically: false)
//
//            showProgressIndicator(refrenceView: self.view)
//            WebServices().uploadVideoonServer(imageURL: url){ (responseData)  in
//                stopProgressIndicator()
//                if responseData != nil{
//                    let uploadUrl = responseData!
//                    let requestDict = ["user_id": self.user_id,
//                                       "coach_id":self.coach_id,
//                                       "order_id":self.orderId,
//                                       "type":self.type,
//                                       "image":uploadUrl] as [String : Any]
//                    self.sendUserMessage_to_coach(request: requestDict as NSDictionary)
//                    print("responseData",responseData ?? "")
//                }
//                else{ stopProgressIndicator()}
//            }
/*****************   testVideo Upload  **********/

     //   pushView(viewController: self, identifier: "CustomCameraVC")
        
//        let nextViewController: CustomCameraVC = CustomCameraVC(nibName: "CustomCameraVC", bundle: nil)
//        self.navigationController?.pushViewController(nextViewController, animated: true)
        
        
      
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let viewController2 = storyboard.instantiateViewController(withIdentifier: "CustomCameraVc")
//
//        self.present(viewController2, animated: true, completion: nil)
        
/*****************   action sheet for video upload   **********/
        
        let actionSheetController = UIAlertController(title: "Choose Image", message:nil , preferredStyle: .actionSheet)

        // actionSheetController.view.tintColor = UIColor.headerBlue

        let galleryButton = UIAlertAction(title: "Gallery", style: .default) { action -> Void in
            self.openGallary()
        }
        let cameraButton = UIAlertAction(title: "Capture A Image", style: .default) { action -> Void in
            self.openCameraWithImageCaputure()
        }


        let cancelActionButton = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in

        }
        picker.delegate = self
        cancelActionButton.setValue(UIColor.red, forKey: "titleTextColor")
        actionSheetController.addAction(galleryButton)
        actionSheetController.addAction(cameraButton)
          if isCoach() {
            let videoActionButton = UIAlertAction(title: "Record A Video", style: .default) { action -> Void in
                self.openCameraWithVideorecord()
            }
              actionSheetController.addAction(videoActionButton)
        }

        actionSheetController.addAction(cancelActionButton)
        self.present(actionSheetController, animated: true, completion: nil)

        /*****************   action sheet for video upload   **********/
        
    }
   
    func openCameraWithVideorecord(){
        
        if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)){
            picker.sourceType = UIImagePickerControllerSourceType.camera
            //   picker.mediaTypes =  [kUTTypeImage as String]
            //      picker.mediaTypes =  [kUTTypeVideo as String]
           
            picker.mediaTypes = [kUTTypeMovie as String]
    //      picker.mediaTypes = [kUTTypeVideo as String]
            picker.delegate = self
            picker.videoMaximumDuration = 10.0
            picker.allowsEditing = false
            picker.cameraCaptureMode = .video
            picker.modalPresentationStyle = .fullScreen
            self .present(picker, animated: true, completion: nil)
        }else{
            notifyUser("", message: "Your device doesn't support camera", vc: self)
        }
    }
   
    
    func openCameraWithImageCaputure(){
        
       
        if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)){
            picker.sourceType = UIImagePickerControllerSourceType.camera
            picker.mediaTypes =  [kUTTypeImage as String]
            
            picker.delegate = self
            picker.videoMaximumDuration = 10.0
            picker.allowsEditing = false
            picker.modalPresentationStyle = .fullScreen
            self .present(picker, animated: true, completion: nil)
        }else{
            notifyUser("", message: "Your device doesn't support camera", vc: self)
        }
    }
    
    func openGallary(){
        picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
       
        self.present(picker, animated: true, completion: nil)
    }
    
    //MARK:UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]){
       
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
            
           
            
            showProgressIndicator(refrenceView: self.view)
            WebServices().uploadImageonServer(imageURL: fileUrl){ (responseData)  in
                stopProgressIndicator()
                if responseData != nil{
                    let uploadUrl = responseData!
                    let requestDict = ["user_id": self.user_id,
                                       "coach_id":self.coach_id,
                                       "order_id":self.orderId,
                                       "type":self.type,
                                       "image":uploadUrl] as [String : Any]
                    self.sendUserMessage_to_coach(request: requestDict as NSDictionary)
                    print("responseData",responseData ?? "")
                }
                else{ stopProgressIndicator()}
            }
            
        } else if mediaType.isEqual(to: kUTTypeMovie as String) {
            
            // Media is a video
            print("record a video")
       //     let videoURL = info[UIImagePickerControllerMediaURL] as! URL
            
            showProgressIndicator(refrenceView: self.view)
           
            let videoURL = info[UIImagePickerControllerMediaURL] as! NSURL
            
            var thumbnialImg = self.createThumbnailOfVideoFromFileURL(videoURL: videoURL.absoluteString!) as! UIImage
            
            thumbnialImg = thumbnialImg.resizeWithWidth(width: 200)!
            let fileManager = FileManager.default
            let str = "\(String(describing: thumbnialImg)).jpeg"
            let path1 = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("\(String(describing: thumbnialImg)).jpeg")
            let imageData = UIImageJPEGRepresentation(thumbnialImg, 0.5)
            let imageSize: Int = imageData!.count
            print("size of image in KB: %f ", Double(imageSize) / 1024.0)
            fileManager.createFile(atPath: path1 as String, contents: imageData, attributes: nil)
            let fileUrl = URL(fileURLWithPath: path1)
            
            PreviewUrl = fileUrl as NSURL
            
            uploadIntroDuctionVideoToAmazon(url: videoURL as URL)
            

            
        }
   
      
    }
    
    func uploadIntroDuctionVideoToAmazon(url : URL)  {
        
        //   showProgressIndicator(refrenceView: self.view)
      //  appDelegateRef.showTitleIndicator()
        guard let data = NSData(contentsOf: url as URL) else {
            return
        }
        
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
        
        //        }
        
        
        
        
        WebServices().uploadVideoonServer(imageURL: newPath){ (responseData)  in
            //   stopProgressIndicator()
            if responseData != nil{
                let uploadUrl = responseData!
                
                
                
                WebServices().uploadImageonServer(imageURL: self.PreviewUrl as URL){ (responseData)  in
                    //      stopProgressIndicator()
                    if responseData != nil{
                        let uploadUrlImage = responseData!
                        let requestDict = ["user_id": self.user_id,
                                           "coach_id":self.coach_id,
                                           "order_id":self.orderId,
                                           "type":self.type,
                                           "video":uploadUrl,
                                           "video_thumb":uploadUrlImage] as [String : Any]
                        
                        self.sendUserMessage_to_coach(request: requestDict as NSDictionary)
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
    
    func createThumbnailOfVideoFromFileURL(videoURL: String) -> UIImage? {
        
        let asset = AVAsset(url: URL(string: videoURL)!)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
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
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController){
        print("picker cancel.")
        picker .dismiss(animated: true, completion: nil)
    }
    
    @objc func uploadImage_Video(_ notification: NSNotification){
   
        if let dict = notification.userInfo as NSDictionary? {
            if let id = dict["image"] as? UIImage{
                // do something with your image
                let image = id.resizeWithWidth(width: 200)!
                let fileManager = FileManager.default
                let path = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("\(String(describing: image)).jpeg")
                let imageData = UIImageJPEGRepresentation(image, 0.5)
                let imageSize: Int = imageData!.count
                print("size of image in KB: %f ", Double(imageSize) / 1024.0)
                fileManager.createFile(atPath: path as String, contents: imageData, attributes: nil)
                let fileUrl = URL(fileURLWithPath: path)
                
                showProgressIndicator(refrenceView: self.view)
                WebServices().uploadImageonServer(imageURL: fileUrl){ (responseData)  in
                    stopProgressIndicator()
                    if responseData != nil{
                        let uploadUrl = responseData!
                        let requestDict = ["user_id": self.user_id,
                                           "coach_id":self.coach_id,
                                           "order_id":self.orderId,
                                           "type":self.type,
                                           "image":uploadUrl] as [String : Any]
                        self.sendUserMessage_to_coach(request: requestDict as NSDictionary)
                        print("responseData",responseData ?? "")
                    }
                    else{ stopProgressIndicator()}
                }
            }
        }
 
       
    }
    
   
    
    func sendUserMessage_to_coach(request:NSDictionary) {
        
        self.view.endEditing(true)
        WebServices().mainFunctiontoGetDetails(data: request as NSDictionary,serviceType:kSEND_MESSAGE) { (responseData)  in
            stopProgressIndicator()
            if responseData != nil
            {
                let code = responseData?["code"] as? NSNumber
                print("responseData",responseData ?? "")
                if code == 200{
                    stopProgressIndicator()
                    self.message_TxtField.text = nil
                    self.getListofmessage()
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
   
    func setLastIndexPath() {
        let indexPath = IndexPath(row: self.messageListArray.count , section: 0) as? IndexPath
        self.chatTableView?.scrollToRow(at: indexPath!, at: UITableViewScrollPosition.bottom, animated: true)
        
    }
    func getListofmessage() {
        
        let request = ["order_id":orderId] as [String : Any]
        
        showProgressIndicator(refrenceView: self.view)
        print(request)
        WebServices().mainFunctiontoGetDetails(data: request as NSDictionary,serviceType:kMESSAGE_LIST) { (responseData)  in
            stopProgressIndicator()
            if responseData != nil
            {
                let code = responseData?["code"] as? NSNumber
                print("responseData",responseData ?? "")
                if code == 200{
                    stopProgressIndicator()
                    guard let result = responseData?["result"] as? NSMutableArray else {
                        return
                    }
                    self.messageListArray = result
                     self.chatTableView.reloadData()
                    self.setLastIndexPath()
                     stopProgressIndicator()
                  
                }
                else {
                    if let message = responseData?["result"] as? String {
                       // notifyUser("", message: message , vc: self)
                    }
                    else{
                        // notifyUser("", message: "Something went wrong", vc: self)
                    }
                }
            }
            else{ stopProgressIndicator()}
            
        }
    }
    func estimatedHeightOfLabel(text: String, sizeTextview: CGSize) -> CGFloat {
        
        let size = sizeTextview
        
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        let attributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 15)]
        
        let rectangleHeight = String(text).boundingRect(with: size, options: options, attributes: attributes, context: nil).height
        
        return rectangleHeight
    }
    @objc func clickOnPlayVideoButton(sender:UIButton) {
       
        let tagValue =  sender.tag
        let messageDict = messageListArray[tagValue] as? NSDictionary
        print("Url Fetched")
        let videoUrl  = messageDict!["video"] as? String
        print(videoUrl)
        let imageUrl = URL(string:videoUrl! )
       
        let player = AVPlayer(url: imageUrl!)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        self.present(playerViewController, animated: true)
        {
            playerViewController.player!.play()
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

   

}




extension ChatVC: UITableViewDataSource {
   
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
 
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  self.messageListArray.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            
            if isCoach() {
                let cell: UserQuestionsChatCell! =  tableView.dequeueReusableCell(withIdentifier: "UserQuestionsChatCell") as? UserQuestionsChatCell
                cell.selectionStyle = .none
                cell.setupDetailsonView(detailsDict:userQuestInfo)
                return cell
            } else {
                let cell: UserQuestionSenderCell! =  tableView.dequeueReusableCell(withIdentifier: "UserQuestionSenderCell") as? UserQuestionSenderCell
                cell.selectionStyle = .none
                cell.chatBgGrayCorner.backgroundColor = UIColor.clear
                cell.receiver_messageView.backgroundColor = hexStringToUIColor(hex: "#e5e5e5")
                cell.setupDetailsonView(detailsDict:userQuestInfo)
                return cell
            }
            
           
        }
        else{
              guard let messageDict = messageListArray[indexPath.row-1] as? NSDictionary else {
                  return UITableViewCell()
              }
         let type  = messageDict["type"] as? Int
               if let type  = messageDict["type"] as? Int {
             let userIdDict = messageDict["user_id"] as? NSDictionary
                let userProfilepic = userIdDict!["profile_pic"] as? String
                if !(userProfilepic?.isEmpty)!  {
                     let video1 = messageDict["video"] as? String
                    print(video1)
                    if (messageDict["video"] as? String) != nil{
                        let cell: VideoChatCellTableViewCell! =  tableView.dequeueReusableCell(withIdentifier: "VideoChatCellTableViewCell") as? VideoChatCellTableViewCell
                        
                        let videoThumbUrl  = messageDict["video_thumb"] as? String
                        let imageUrl = URL(string:videoThumbUrl! )
              //        cell.thumbnailImgView.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "AdvisorProfileImg"), options:.refreshCached)
            //            cell?.centerPlayButton.addTarget(self, action: #selector(ChatVC.clickOnPlayVideoButton(sender:)), for: .touchUpInside)
            //            cell.centerPlayButton.tag = indexPath.row - 1
                        
                        return cell
                    }else{
                        let cell: ChatImageCell! =  tableView.dequeueReusableCell(withIdentifier: "ChatImageCell") as? ChatImageCell
                        cell.msgTxtView.isEditable = false
                        cell.senderMsgTextView.isEditable = false
                        if let dict = messageListArray[indexPath.row-1] as? NSDictionary {
                            if isCoach() {
                                if type == 1 {
                                    
                                    cell.showSenderDetailsonView(detailsDict:dict)
                                    
                                }
                                else{
                                    cell.setupDetailsonView(detailsDict:dict)
                                }
                            }
                            else{
                                if type == 2 {
                                    cell.showSenderDetailsonView(detailsDict:dict)
                                    
                                }
                                else{
                                    cell.setupDetailsonView(detailsDict:dict)
                                }
                            }
                        }
                        cell.selectionStyle = .none
                        return cell
                    }
                    
                    
                         }
                         else{
                             let cell: MessageCell! =  tableView.dequeueReusableCell(withIdentifier: "MessageCell") as? MessageCell
                             if let dict = messageListArray[indexPath.row-1] as? NSDictionary {
                                if isCoach() {
                                    if type == 1 {
                                        
                                        let cell: SenderMessageCell! =  tableView.dequeueReusableCell(withIdentifier: "SenderMessageCell") as? SenderMessageCell
                                         cell.showSenderDetailsonView(detailsDict:dict)
                                         cell.selectionStyle = .none
                                        return cell
                                    }
                                    else{
                                        cell.setupDetailsonView(detailsDict:dict)
                                    }
                                }
                                else{
                                    if type == 2 {
                                        let cell: SenderMessageCell! =  tableView.dequeueReusableCell(withIdentifier: "SenderMessageCell") as? SenderMessageCell
                                        cell.showSenderDetailsonView(detailsDict:dict)
                                        cell.selectionStyle = .none
                                        return cell
                                    }
                                    else{
                                        cell.setupDetailsonView(detailsDict:dict)
                                    }
                                }
                             }
                          cell.selectionStyle = .none
                          return cell
                      }
                }
            return UITableViewCell()
        }
    }
}


extension ChatVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0{
           return UITableViewAutomaticDimension
        }
        else{
            if let messageDict = messageListArray[indexPath.row-1] as? NSDictionary {
                if messageDict["image"] != nil  {
                    return 250
                }else if messageDict["video"] != nil  {
                    return 145
                }else if messageDict["message"] != nil{
                    
                    let messageDict = messageListArray[indexPath.row - 1] as? NSDictionary
                    let msgStr = messageDict!["message"] as? String
                    let height =       self.estimatedHeightOfLabel(text:msgStr!, sizeTextview: CGSize(width:self.view.frame.size.width - 100, height: CGFloat.greatestFiniteMagnitude))
                     return height + 35
                //    return UITableViewAutomaticDimension
                }
            }
        }
        return UITableViewAutomaticDimension
    }
   
    
}

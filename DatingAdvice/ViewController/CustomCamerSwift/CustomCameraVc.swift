
//
//  CustomCameraVc.swift
//  Intrigued
//
//  Created by Shineweb-solutions on 02/02/18.
//  Copyright © 2018 daniel helled. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer
import AVKit
import MobileCoreServices

class CustomCameraVc: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate, AVCapturePhotoCaptureDelegate {

   
    var captureSession = AVCaptureSession();
    var sessionOutput = AVCapturePhotoOutput();
    var sessionOutputSetting = AVCapturePhotoSettings(format: [AVVideoCodecKey:AVVideoCodecJPEG]);
     var previewLayer = AVCaptureVideoPreviewLayer();
     var currentCaptureDevice: AVCaptureDevice?
   
    
    
     var picker = UIImagePickerController()
    var flashIconUnselectedImg: UIImage = UIImage()
    var flashIconSelectedImg: UIImage = UIImage()
    var flashBtnManageSelected:String = String()
     var cancelBtn:UIButton = UIButton()
     var changeFlashBtn:UIButton = UIButton()
     var openGalleryBtn:UIButton = UIButton()
     var CaptureVideoOrImageBtn:UIButton = UIButton()
     var changeCameraMode:UIButton = UIButton()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.red
      

        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
//        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInDuoCamera, AVCaptureDevice.DeviceType.builtInTelephotoCamera,AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.unspecified)
//        for device in (deviceDiscoverySession.devices) {
//            if(device.position == AVCaptureDevice.Position.front){
//                do{
//                    let input = try AVCaptureDeviceInput(device: device)
//                    if(captureSession.canAddInput(input)){
//                        captureSession.addInput(input);
//                        
//                        if(captureSession.canAddOutput(sessionOutput)){
//                            captureSession.addOutput(sessionOutput);
//                            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession);
//                            previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill;
//                            previewLayer.connection?.videoOrientation = AVCaptureVideoOrientation.portrait;
//                            captureSession.startRunning()
//                            previewLayer.frame = self.view.bounds
//                            self.view.layer.addSublayer(previewLayer);
//                            self.customizedCamera()
//                        }
//                    }
//                }
//                catch{
//                    print("exception!");
//                }
//            }
//    }
    }
    
   
    
    func customizedCamera() {
       
        cancelBtn = UIButton(frame: CGRect(x: 20, y: 20, width: 60, height: 40))
        cancelBtn.setTitle("Cancel", for: .normal)
        cancelBtn.setTitleColor(UIColor.white, for: .normal)
        cancelBtn.backgroundColor = UIColor.clear
        cancelBtn.addTarget(self, action: #selector(CancelButton(button:)), for: .touchUpInside)
        self.view.addSubview(cancelBtn)
        
        flashIconUnselectedImg = UIImage(named: "flash_off")!
        flashIconSelectedImg = UIImage(named: "flash_off")!
        changeFlashBtn = UIButton(frame: CGRect(x: self.view.frame.size.width - 60 , y: 20, width: 40, height: 40))
        changeFlashBtn.setBackgroundImage(flashIconUnselectedImg, for: .normal)
        changeFlashBtn.addTarget(self, action: #selector(flashButton(button:)), for: .touchUpInside)
        flashBtnManageSelected = "NO"
        self.view.addSubview(changeFlashBtn)
        
        let galleryIconImg = UIImage(named: "gallary_icon.png")
        openGalleryBtn = UIButton(frame: CGRect(x: 20 , y: self.view.frame.size.height - 60, width: 40, height: 40))
        openGalleryBtn.layer.masksToBounds = true
        openGalleryBtn.layer.cornerRadius = 20.0
        openGalleryBtn.setBackgroundImage(galleryIconImg, for: .normal)
        openGalleryBtn.addTarget(self, action: #selector(OpenGaleryButton(button:)), for: .touchUpInside)
        self.view.addSubview(openGalleryBtn)
        
        let captureImgOrVideoIconImg = UIImage(named: "gallary_icon.png")
        CaptureVideoOrImageBtn = UIButton(frame: CGRect(x: (self.view.frame.size.width -  40)/2 , y: self.view.frame.size.height - 60, width: 40, height: 40))
        CaptureVideoOrImageBtn.layer.masksToBounds = true
        CaptureVideoOrImageBtn.layer.cornerRadius = 20.0
        CaptureVideoOrImageBtn.setBackgroundImage(captureImgOrVideoIconImg, for: .normal)
        CaptureVideoOrImageBtn.addTarget(self, action: #selector(captureImgOrVideoButton(button:)), for: .touchUpInside)
        self.view.addSubview(CaptureVideoOrImageBtn)
        
        let changeCameraModeIconImg = UIImage(named: "camera_rotate_icon")
        changeCameraMode = UIButton(frame: CGRect(x: self.view.frame.size.width -  60 , y: self.view.frame.size.height - 60, width: 40, height: 40))
        changeCameraMode.layer.masksToBounds = true
        changeCameraMode.layer.cornerRadius = 20.0
        changeCameraMode.setBackgroundImage(changeCameraModeIconImg, for: .normal)
        changeCameraMode.addTarget(self, action: #selector(changeCameraModeButton(button:)), for: .touchUpInside)
        self.view.addSubview(changeCameraMode)
        
    }
    @objc func CancelButton(button: UIButton) {
         self.dismiss(animated: true, completion: nil)
    }
    @objc func flashButton(button: UIButton) {
        
        if flashBtnManageSelected ==  "NO" {
            flashBtnManageSelected = "YES"
             changeFlashBtn.setBackgroundImage(flashIconSelectedImg, for: .normal)
            guard let device = AVCaptureDevice.default(for: AVMediaType.video)
                else {return}
            
            if device.hasTorch {
                do {
                    try device.lockForConfiguration()
                    
                        device.torchMode = .on
                    device.unlockForConfiguration()
                } catch {
                    print("Torch could not be used")
                }
            } else {
                print("Torch is not available")
            }
        }else if flashBtnManageSelected == "YES" {
          flashBtnManageSelected = "NO"
          changeFlashBtn.setBackgroundImage(flashIconUnselectedImg, for: .normal)
   
            guard let device = AVCaptureDevice.default(for: AVMediaType.video)
                else {return}
            
            if device.hasTorch {
                do {
                    try device.lockForConfiguration()
                     device.torchMode = .off
                    device.unlockForConfiguration()
                } catch {
                    print("Torch could not be used")
                }
            } else {
                print("Torch is not available")
            }
        }
    }
    @objc func OpenGaleryButton(button: UIButton) {
        
    }
    @objc func changeCameraModeButton(button: UIButton) {
        
       
    }
   
    
    func getBackCamera() -> AVCaptureDevice{
        return AVCaptureDevice.default(for: .video)!
    }
    
    @objc func captureImgOrVideoButton(button: UIButton) {
        
    }
    
    
    func openGalleryWithVideorecord(){
        
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            print("Button capture")
            
            picker.delegate = self
            picker.sourceType = .savedPhotosAlbum;
            picker.allowsEditing = false
            
            self.present(picker, animated: true, completion: nil)
        }else{
            notifyUser("", message: "Your device doesn't support camera", vc: self)
        }
    }
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: NSDictionary!){
        self.dismiss(animated: true, completion: { () -> Void in
            
        })
        
       
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

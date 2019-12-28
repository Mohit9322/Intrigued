//
//  CustomCameraVC.m
//  Pawpular
//
//  Created by Shine Wave Solutions on 31/05/17.
//  Copyright © 2017 IBCMobile. All rights reserved.
//

#define kDefaultMinZoomFactor 1
#define kDefaultMaxZoomFactor 4
#define VIDEO_FOLDER @"VideoFolder"

#import "CustomCameraVC.h"
#import "AAPLPreviewView.h"
//#import <SCRecorder/SCRecorder.h>
#import "Checking.h"
#import "Intrigued-Swift.h"
#import <MobileCoreServices/UTCoreTypes.h>

@import MediaPlayer;
@import AssetsLibrary;
#define kDefaultMinZoomFactor 1
#define kDefaultMaxZoomFactor 4

@import Photos;

static void * CapturingStillImageContext = &CapturingStillImageContext;
static void * SessionRunningContext = &SessionRunningContext;

typedef NS_ENUM( NSInteger, AVCamSetupResult ) {
    AVCamSetupResultSuccess,
    AVCamSetupResultCameraNotAuthorized,
    AVCamSetupResultSessionConfigurationFailed
};


@interface CustomCameraVC ()<UIGestureRecognizerDelegate,AVCaptureFileOutputRecordingDelegate,UIAlertViewDelegate>
{
    AVCaptureVideoPreviewLayer *_previewLayer;
    
    // related with pinch guesture
    UIPinchGestureRecognizer *pinchZoomGesture;
    CGFloat zoomAtStart;
    
    NSString *fromPage;
    
    NSString *postType;
    BOOL isRecordingStopped;
    NSMutableArray* urlArray;
    float preLayerWidth;
    float preLayerHeight;
    float preLayerHWRate;
    UIVisualEffectView *blurEffectView;
    UIImagePickerController * img_picker;
    
    BOOL isCameraON;
    BOOL isImagePickerOpened; //ravi 28Mar
    
    BOOL isFrontCamera;
    UIButton *changeFlashBtn;
    BOOL CameraModeManageSelected;
    BOOL flashBtnManageSelected;
    BOOL RcordingVideoManage;
    //permission handler setup
    IBOutlet UIView *view_access;
    IBOutlet UIButton *btn_microphone;
    IBOutlet UIButton *btn_camera;
    UIButton *whiteVideoRecorBigBtn;
    UILabel *countLbl;
    int count;
    NSTimer *timer;
    UIButton *changeCameraMode;
}

@property (weak, nonatomic) IBOutlet UIView *topHeaderView;
@property (weak, nonatomic) IBOutlet UIView *bottomLayerBaseView;

@property (strong, nonatomic) NSURL * content_url;
@property (strong, nonatomic) NSURL * thumb_url;
@property (strong, nonatomic) NSURL * aws_content_url;

@property (nonatomic, weak) IBOutlet AAPLPreviewView *previewView;
@property (weak, nonatomic) IBOutlet ShuterView *view_shutter;
@property (weak, nonatomic) IBOutlet UIButton *btn_flash_onoff;
@property (weak, nonatomic) IBOutlet UIButton *btn_cancel;
@property (weak, nonatomic) IBOutlet UIButton *btn_upback;
@property (weak, nonatomic) IBOutlet UIButton *btn_library;

@property (weak, nonatomic) IBOutlet UIView *view_container;

// Session management.
//@property (nonatomic) dispatch_queue_t sessionQueue;
@property (nonatomic) AVCaptureDeviceInput *videoDeviceInput;
@property (nonatomic) AVCaptureMovieFileOutput *movieFileOutput;
@property (nonatomic) AVCaptureStillImageOutput *stillImageOutput;

// Utilities.
@property (nonatomic) AVCamSetupResult setupResult;
@property (nonatomic, getter=isSessionRunning) BOOL sessionRunning;
@property (nonatomic) UIBackgroundTaskIdentifier backgroundRecordingID;
//  @property (nonatomic, strong)  UIButton *changeFlashBtn;


// var CameraModeManageSelected = Bool()


@end

@implementation CustomCameraVC

#pragma mark --------------- View Life cycle Methods --------------------

- (void)viewDidLoad {
    
    _coachDetails = [[NSDictionary alloc]init];
    _fromCoachSignUp = [[NSString alloc]init];
    
    [super viewDidLoad];
     [self createView ];
    
    self.bottomLayerBaseView.alpha  = 0.5;
    self.bottomLayerBaseView.backgroundColor = [UIColor blackColor];
    
    _btn_flash_onoff.hidden = YES;
    _btn_cancel.hidden = YES;
    _btn_upback.hidden = YES;
    _btn_library.hidden = YES;
    btn_camera.hidden = YES;
    _view_shutter.hidden =  YES;
    
    isCameraON =NO;
    isImagePickerOpened =NO;
    isFrontCamera=YES; //not show front camera first
    self.flashImageView.hidden=YES;
    
    _bottombackImageView.hidden = YES; //remove black shadow from bottom
    
    [self demonstrateInputSelection];
    
    [self createVideoFolderIfNotExist];
    
    //sumit Nov7 to remove extra space from top
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    pinchZoomGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchToZoom:)];
    [self.view addGestureRecognizer:pinchZoomGesture];
    
    // set shutter delegate
    self.view_shutter.delegate = self;
    
    // Communicate with the session and other session objects on this queue.
    self.sessionQueue = dispatch_queue_create( "session queue", DISPATCH_QUEUE_SERIAL );
    
    
    
    
    //sumit 17 Dec. due to tap gesture on switch camera while video recording
    UITapGestureRecognizer *tapGesture1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeCamera:)];
    tapGesture1.numberOfTapsRequired = 1;
    [self.switchCameraView addGestureRecognizer:tapGesture1];
    
    // [self addBlurrEffect];
    
    //By default set camera set up success
    self.setupResult = AVCamSetupResultSuccess;
    
    preLayerWidth = self.previewView.frame.size.width;
    preLayerHeight = self.previewView.frame.size.height;
    preLayerHWRate =preLayerHeight/preLayerWidth;
    
    
    //Avanish 27 Jan
    
    // Check video authorization status. Video access is required and audio access is optional.
    // If audio access is denied, audio is not recorded during movie recording.
    switch ( [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo] )
    {
        case AVAuthorizationStatusAuthorized:
        {
            // The user has previously granted access to the camera.
            break;
        }
        case AVAuthorizationStatusNotDetermined:
        {
            // The user has not yet been presented with the option to grant video access.
            // We suspend the session queue to delay session setup until the access request has completed to avoid
            // asking the user for audio access if video access is denied.
            // Note that audio access will be implicitly requested when we create an AVCaptureDeviceInput for audio during session setup.
            dispatch_suspend( self.sessionQueue );
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^( BOOL granted ) {
                if ( ! granted ) {
                    self.setupResult = AVCamSetupResultCameraNotAuthorized;
                }
                else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self notifyToStartCamera];
                    });
                }
                dispatch_resume( self.sessionQueue );
            }];
            break;
        }
        default:
        {
            // The user has previously denied access.
            self.setupResult = AVCamSetupResultCameraNotAuthorized;
            break;
        }
    }
    
    AVAudioSessionRecordPermission permissionStatus = [[AVAudioSession sharedInstance] recordPermission];
    
    switch (permissionStatus) {
        case AVAudioSessionRecordPermissionUndetermined:{
                        [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
                            // CALL YOUR METHOD HERE - as this assumes being called only once from user interacting with permission alert!
                            if (granted) {
                                // Microphone enabled code
                                dispatch_async(dispatch_get_main_queue(), ^{
                                     [self notifyToStartCamera];
                                });
                               
                            }
                            else {
                                // Microphone disabled code
                               
                            }
                        }];
            break;
        }
        default:
          
            break;
    }
    
    
    
    // Setup the capture session.
    // In general it is not safe to mutate an AVCaptureSession or any of its inputs, outputs, or connections from multiple threads at the same time.
    // Why not do all of this on the main queue?
    dispatch_async( self.sessionQueue, ^{
        [self configureCameraSession];
        [self fetchAndSetLastImagefromLibrary];
    } );
  
}
- (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}
-(void)createView {
   
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    backBtn.frame = CGRectMake(10, 30, 25, 32);
    [backBtn setBackgroundImage:[UIImage imageNamed:@"flwer_icon"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(headerflowerBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
//    [_topHeaderView addSubview:backBtn];
//    hexStringToUIColor(hex: "#34a0ce")
    
  //  _topHeaderView.backgroundColor = [self colorFromHexString:@"#1d7399" ];
    
        _topHeaderView.backgroundColor = [UIColor clearColor];
    
    UILabel *introLbl = [[UILabel alloc]initWithFrame:CGRectMake(((_topHeaderView.frame.size.width - 150)/2), 25, 150, 30)];
    introLbl.text = @"Introduction Video";
    introLbl.textAlignment = UITextAlignmentCenter;
    introLbl.textColor = [UIColor whiteColor];
    introLbl.font = [UIFont systemFontOfSize:18];
    [_topHeaderView addSubview:introLbl];
    
    UIButton *skipBtn  = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    skipBtn.frame = CGRectMake(_topHeaderView.frame.size.width - 70, 30, 50, 22);
    [skipBtn setTitle:@"Cancel" forState:UIControlStateNormal];
    [skipBtn setTintColor:[UIColor whiteColor]];
    [skipBtn addTarget:self action:@selector(skipBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_topHeaderView addSubview:skipBtn];
    
    
    countLbl = [[UILabel alloc]initWithFrame:CGRectMake(20, 30, 100, 30)];
    countLbl.text = @"00:00";
    countLbl.font = [UIFont systemFontOfSize:18];
    countLbl.textAlignment = UITextAlignmentLeft;
    countLbl.textColor = [UIColor whiteColor];
    countLbl.hidden = YES;
    count = 59;
    [self.previewView addSubview:countLbl];
    
    
   
    
    changeCameraMode  = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    changeCameraMode.frame = CGRectMake(20, 33, 40, 34);
    [changeCameraMode setBackgroundImage:[UIImage imageNamed:@"camera_rotate_icon"] forState:UIControlStateNormal];
    CameraModeManageSelected = true ;
    [changeCameraMode addTarget:self action:@selector(changeCameraModeButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomLayerBaseView addSubview:changeCameraMode];

    
    changeFlashBtn  = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    changeFlashBtn.frame = CGRectMake(_bottomLayerBaseView.frame.size.width - 60, 33, 40, 34);
    [changeFlashBtn setBackgroundImage:[UIImage imageNamed:@"flash_off"] forState:UIControlStateNormal];
    flashBtnManageSelected = false;
    changeFlashBtn.hidden = YES;
    [changeFlashBtn addTarget:self action:@selector(flashButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomLayerBaseView addSubview:changeFlashBtn];
    
    
//    whiteVideoBtnImg = UIImage(named: "WhiteVideoBtn")!
//    RedStopBtnImg = UIImage(named: "stopVideoBtn")!
//    redPlayBtnImg = UIImage(named: "PlayVideoBtn")!
    
    
    
   whiteVideoRecorBigBtn  = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    whiteVideoRecorBigBtn.frame = CGRectMake((_topHeaderView.frame.size.width -  80)/2, 10, 80, 80);
    [whiteVideoRecorBigBtn setBackgroundImage:[UIImage imageNamed:@"stopVideoBtn"] forState:UIControlStateNormal];
    whiteVideoRecorBigBtn.layer.masksToBounds = YES;
    whiteVideoRecorBigBtn.layer.cornerRadius  =  40.0;
    [whiteVideoRecorBigBtn addTarget:self action:@selector(captureImgOrVideoButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomLayerBaseView addSubview:whiteVideoRecorBigBtn];
    
    RcordingVideoManage = false;
    
    if ([self.fromCoachSignUp isEqualToString:@"YES"]){
        [skipBtn setTitle:@"Skip" forState:UIControlStateNormal];
    }else {
         [skipBtn setTitle:@"Cancel" forState:UIControlStateNormal];
    }
    
}
-(void)onTick:(NSTimer *)timer {
   
    if(count > 0){
        //     let minutes = String(count / 60)
        //  let seconds = String(count % 60)
        int minutes = count / 60;
        int seconds =  count % 60;
        
        NSString *countstr = [NSString stringWithFormat:@"%02i:%02i",minutes, seconds];
       
        NSLog(countstr);
        countLbl.text = countstr;
        count = count - 1;
    }else {
        [timer invalidate];
        [whiteVideoRecorBigBtn setBackgroundImage:[UIImage imageNamed:@"stopVideoBtn" ] forState:UIControlStateNormal];
        countLbl.text = @"00:00";
        //      RedVideoRecordVideoRecordBtn.setImage(RedStopBtnImg, for: UIControlState())
        [self stopRecordingVideo ];
      
    }
}
-(void)captureImgOrVideoButton:(id)sender
{
    
    RcordingVideoManage = !RcordingVideoManage;
    
    if (RcordingVideoManage) {
//        print("Video is recoeding")
//        whiteVideoRecorBigBtn.setBackgroundImage(redPlayBtnImg, for: .normal);
        [whiteVideoRecorBigBtn setBackgroundImage:[UIImage imageNamed:@"PlayVideoBtn" ] forState:UIControlStateNormal];
        timer = [NSTimer scheduledTimerWithTimeInterval: 1.0
                                                      target: self
                                                    selector:@selector(onTick:)
                                                    userInfo: nil repeats:YES];
        
        countLbl.hidden = false;
        
        changeFlashBtn.hidden = true;
        changeCameraMode.hidden = true;
        
        //    RedVideoRecordVideoRecordBtn.setImage(redPlayBtnImg, for: UIControlState())
         [self startRecordingVideo];
        
    } else {
        
      
         [whiteVideoRecorBigBtn setBackgroundImage:[UIImage imageNamed:@"stopVideoBtn" ] forState:UIControlStateNormal];
        //      RedVideoRecordVideoRecordBtn.setImage(RedStopBtnImg, for: UIControlState())
        changeFlashBtn.hidden = false;
        changeCameraMode.hidden = false;
        [self stopRecordingVideo ];
    }
   
}

-(void)flashButtonPressed:(id)sender
{
    
    flashBtnManageSelected = !flashBtnManageSelected;
     AVCaptureDevice * device = self.videoDeviceInput.device;
    
    if ( [device hasTorch] && [device hasFlash] ) {
        [device lockForConfiguration:nil];
        
        if ( flashBtnManageSelected ) {
            
            device.torchMode = AVCaptureTorchModeOn;
            device.flashMode = AVCaptureFlashModeOn;
            [changeFlashBtn setBackgroundImage:[UIImage imageNamed:@"flash_on"] forState:UIControlStateNormal];
            
        }else{
            device.torchMode = AVCaptureTorchModeOff;
            device.flashMode = AVCaptureFlashModeOff;
            [changeFlashBtn setBackgroundImage:[UIImage imageNamed:@"flash_off"] forState:UIControlStateNormal];
        }
        
        [device unlockForConfiguration];
    }
    
}
-(void)changeCameraModeButton:(id)sender
{
    dispatch_async( self.sessionQueue, ^{
        AVCaptureDevice *currentVideoDevice = self.videoDeviceInput.device;
        AVCaptureDevicePosition preferredPosition = AVCaptureDevicePositionUnspecified;
        AVCaptureDevicePosition currentPosition = currentVideoDevice.position;
        
        switch ( currentPosition )
        {
            case AVCaptureDevicePositionUnspecified:{
                preferredPosition = AVCaptureDevicePositionBack;
                isFrontCamera=NO;
                dispatch_async( dispatch_get_main_queue(), ^{
                    self.flashImageView.hidden=NO;
                    changeFlashBtn.hidden = YES;
                     flashBtnManageSelected = false;
                } );
            }
                break;
            case AVCaptureDevicePositionFront:{
                preferredPosition = AVCaptureDevicePositionBack;
                isFrontCamera=NO;
                dispatch_async( dispatch_get_main_queue(), ^{
                    self.flashImageView.hidden=NO;
                     changeFlashBtn.hidden = NO;
                     flashBtnManageSelected = false;
                } );
            }
                break;
            case AVCaptureDevicePositionBack://ravi
                dispatch_async( dispatch_get_main_queue(), ^{
                    [self.flashImageView setImage:[UIImage imageNamed:@"flash_off.png"]];
                    self.btn_flash_onoff.selected = NO;//ravi 21Dec
                    self.flashImageView.hidden=YES;
                    [changeFlashBtn setBackgroundImage:[UIImage imageNamed:@"flash_off.png"] forState:UIControlStateNormal];
                    changeFlashBtn.hidden = YES;
                    flashBtnManageSelected = true;
                    
                } );
                
                preferredPosition = AVCaptureDevicePositionFront;
                isFrontCamera=YES;
                break;
        }
        
        AVCaptureDevice *videoDevice = [CustomCameraVC deviceWithMediaType:AVMediaTypeVideo preferringPosition:preferredPosition];
        AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:nil];
        
        [self.session beginConfiguration];
        
        // Remove the existing device input first, since using the front and back camera simultaneously is not supported.
        [self.session removeInput:self.videoDeviceInput];
        
        if ( [self.session canAddInput:videoDeviceInput] ) {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureDeviceSubjectAreaDidChangeNotification object:currentVideoDevice];
            
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subjectAreaDidChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:videoDevice];
            
            
            [self.session addInput:videoDeviceInput];
            self.videoDeviceInput = videoDeviceInput;
        }
        else {
            [self.session addInput:self.videoDeviceInput];
        }
        //ravi
        //        AVCaptureConnection *connection = [self.movieFileOutput connectionWithMediaType:AVMediaTypeVideo];
        //        if ( connection.isVideoStabilizationSupported ) {
        //            connection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeAuto;
        //        }
        //
        //        if (preferredPosition == AVCaptureDevicePositionFront) {
        //            self.session.sessionPreset = AVCaptureSessionPresetPhoto; //TODO
        //        }
        //        else {
        //            self.session.sessionPreset = AVCaptureSessionPreset1920x1080; //TODO
        //        }
        
        
        [self.session commitConfiguration];
        
    } );
}
-(void)skipBtnPressed:(id)sender
{
    if ([_fromCoachSignUp isEqualToString: @"YES"]) {
        _fromCoachSignUp = @"NO";
     //   pushView(viewController: self, identifier: "CoachesTabbarVC")
        UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
          CoachesTabbarVC * controller = [storyboard instantiateViewControllerWithIdentifier:@"CoachesTabbarVC"];
        [self.navigationController pushViewController:controller animated:NO];
    }else {
       
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    
    
}
-(void)headerflowerBtnPressed:(id)sender
{
    
}
-(BOOL)prefersStatusBarHidden{
    return YES;
}

//-(void) setUpImagePicker
//{
//    img_picker = [[UIImagePickerController alloc] init];
//    
//    img_picker.delegate = self;
//    //picker.mediaTypes = @[(NSString *)kUTTypeMovie, (NSString *)kUTTypeImage];//ravi 31May
//    img_picker.allowsEditing = NO;
//    img_picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
//    
//}

-(void)removeBlurrEffect {
    CATransition *transition = [CATransition animation];
    transition.duration = 0.5;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    transition.type = kCATransitionFade;
    [blurEffectView.layer addAnimation:transition forKey:kCATransition];
    [blurEffectView removeFromSuperview];
    blurEffectView = nil;
}

-(void)addBlurrEffect {
    if (!UIAccessibilityIsReduceTransparencyEnabled()) {
        
        self.view.backgroundColor = [UIColor clearColor];
        
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        blurEffectView.frame = self.view.bounds;
        blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [self.previewView addSubview:blurEffectView];
    } else {
        self.previewView.backgroundColor = [UIColor blackColor];
    }
}


//ravi 11Apr
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //swipe right pop navigation stuff ravi 16May
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.hidden = YES;
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    
    
   

    isCameraON =NO;//ravi
    #if TARGET_OS_SIMULATOR
        //Simulator
    #else
        [self notifyToStartCamera];
    #endif

    
//    //once we back from image or somewhere else then restart camera from here
//    if(isImagePickerOpened ==YES){
//        isImagePickerOpened=NO;
//        isCameraON =NO;//ravi
//        [self notifyToStartCamera];
//    }
}
//ravi 11Apr
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    
}
-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
#if TARGET_OS_SIMULATOR
    
    //Simulator
    
#else
    
    [self switchOffFlash];
    [self notifyToOffCamera];
#endif
    
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
#if TARGET_OS_SIMULATOR
    
    //Simulator
    
#else
    
    dispatch_async( self.sessionQueue, ^{
        if ( self.setupResult == AVCamSetupResultSuccess ) {
            [self.session stopRunning];
            [self removeObservers];
            self.btn_flash_onoff.selected = NO;//ravi 21Dec
            self.flashImageView.image = [UIImage imageNamed:@"flash_off"];//ravi 21Dec
            
            //            [[NSNotificationCenter defaultCenter] addObserver:self
            //                                                     selector:@selector(doneButtonClick:)
            //                                                         name:MPMoviePlayerPlaybackDidFinishNotification
            //                                                       object:nil];
        }
    } );
#endif
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark --------------------- Load and start camera methods ---------------------

#pragma mark --------------------- Private Methods --------------------------

-(void)fetchAndSetLastImagefromLibrary {
    // to set the last recent image
    PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
    fetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
    PHFetchResult *fetchResult = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:fetchOptions];
    PHAsset *lastAsset = [fetchResult lastObject];
    [[PHImageManager defaultManager] requestImageForAsset:lastAsset
                                               targetSize:self.btn_library.bounds.size
                                              contentMode:PHImageContentModeAspectFill
                                                  options:PHImageRequestOptionsVersionCurrent
                                            resultHandler:^(UIImage *result, NSDictionary *info) {
                                                
                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                    if (result == nil) {
                                                        self.galleryImageView.image = [UIImage imageNamed:@"gallary_icon.png"];
                                                    }
                                                    else
                                                    {
                                                        //[self.galleryImageView setImage:result];
                                                    }
                                                    self.galleryImageView.layer.cornerRadius = self.galleryImageView.frame.size.width/2;
                                                    self.galleryImageView.layer.masksToBounds = YES;
                                                    self.galleryImageView.layer.borderWidth = 1.0f;
                                                    self.galleryImageView.layer.borderColor = [UIColor whiteColor].CGColor;
                                                    
                                                    //self.switchImageView.layer.cornerRadius = self.switchImageView.frame.size.width/2;
                                                    //self.switchImageView.layer.masksToBounds = YES;//ravi 05Jun
                                                    
                                                    self.flashImageView.layer.cornerRadius = self.flashImageView.frame.size.width/2;                                                self.flashImageView.layer.masksToBounds = YES;
                                                });
                                            }];
    
}


#pragma mark --------------------- Load and start camera methods ---------------------

-(void)configureCameraSession {
    
    //Avaneesh 26 Dec
    _backgroundRecordingID = UIBackgroundTaskInvalid;
    
    //1- Initialise camera capture session
    self.session = [[AVCaptureSession alloc]init];
    self.session.sessionPreset = AVCaptureSessionPresetHigh;//TODO
    self.previewView.session = self.session;
    
    
    //###################---------------Start configuring capture session------------------###################///
    
    [self.session beginConfiguration];
    
    NSError *error;
    
    
    // *****************Add Inputs to this session****************//
    
    //2- Add camera in this _captureSession
    
    AVCaptureDevice *backCamera = [CustomCameraVC deviceWithMediaType:AVMediaTypeVideo preferringPosition:AVCaptureDevicePositionFront];//AVCaptureDevicePositionBack
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:backCamera error:&error];
    self.videoDeviceInput = input;
    if ((error == nil) && [self.session canAddInput:input]) {
        [CustomCameraVC setFlashMode:AVCaptureFlashModeOff forDevice:backCamera];//AVCaptureFlashModeAuto forDevice:backCamera];//ravi // nisha 5/7/17
        [self.session addInput:input];
        [self updateVideoOrientation];
    }
    else { self.setupResult = AVCamSetupResultSessionConfigurationFailed;}
    
    
    //3- Add microphone in this _captureSession
    
    AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    AVCaptureDeviceInput *audioDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:&error];
    
    NSArray *availableInputs = [[AVAudioSession sharedInstance] availableInputs];
    BOOL micPresent = false;
    for (AVAudioSessionPortDescription *port in availableInputs)
    {
        if ([port.portType isEqualToString:AVAudioSessionPortBuiltInMic] ||
            [port.portType isEqualToString:AVAudioSessionPortHeadsetMic])
        {
           /* if([AppDelegate getAppDelegate].isOngoingCall == YES) { //ravi 31May
                micPresent = false;
            }
            else {*/
                micPresent = true;
            //}
        }
    }
    
    if (micPresent)
    {
        // Do something cool
        if ( [self.session canAddInput:audioDeviceInput] ) { [self.session addInput:audioDeviceInput];}
        else { NSLog( @"Could not add audio device input to the session" );}
    }
    else
    {
        // No mic present - show alert
        NSLog( @"Could not add audio device input to the session" );
    }
    
    // *****************Add Outputs to this session****************//
    
    //4- Add AVCaptureMovieFile Output in this _captureSession
    
    AVCaptureMovieFileOutput *movieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
    
    if ( [self.session canAddOutput:movieFileOutput] ) {
        [self.session addOutput:movieFileOutput];
        AVCaptureConnection *connection = [movieFileOutput connectionWithMediaType:AVMediaTypeVideo];
        if ( connection.isVideoStabilizationSupported ) {
            connection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeAuto;
        }
        self.movieFileOutput = movieFileOutput;
    }
    else {
        NSLog( @"Could not add movie file output to the session" );
        self.setupResult = AVCamSetupResultSessionConfigurationFailed;
    }
    
    //5- Add AVCaptureStillImage Output in this _captureSession
    
    AVCaptureStillImageOutput *stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    if ( [self.session canAddOutput:stillImageOutput] ) {
        stillImageOutput.outputSettings = @{AVVideoCodecKey : AVVideoCodecJPEG};
        [self.session addOutput:stillImageOutput];
        self.stillImageOutput = stillImageOutput;
    }
    else {
        NSLog( @"Could not add still Image Output to the session" );
        self.setupResult = AVCamSetupResultSessionConfigurationFailed;
    }
    
    self.session.automaticallyConfiguresApplicationAudioSession = YES;
    
    [self.session commitConfiguration];
    // Avanish Singh
    //        AVCaptureConnection* audioConnection = [_movieFileOutput connectionWithMediaType:AVMediaTypeAudio];
    //        if(audioConnection) {
    //            audioConnection.enabled=NO;
    //        }
    
    //[AppDelegate getAppDelegate].sessionRefrence = self.session; //ravi 31May
    //###################---------------End configuring capture session------------------###################///
    
    
    //6- Add _captureSession on AVCaptureVideoPreviewLayer
    //    _previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    //    _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    //    _previewLayer.connection.videoOrientation = AVCaptureVideoOrientationPortrait;
    
    
    //7- Add previewLayer on cameraView.layer
    [self.previewView.layer addSublayer:_previewLayer];
    
}

-(void)updateVideoOrientation {
    dispatch_async( dispatch_get_main_queue(), ^{
        // Why are we dispatching this to the main queue?
        // Because AVCaptureVideoPreviewLayer is the backing layer for AAPLPreviewView and UIView
        // can only be manipulated on the main thread.
        // Note: As an exception to the above rule, it is not necessary to serialize video orientation changes
        // on the AVCaptureVideoPreviewLayer’s connection with other session manipulation.
        
        // Use the status bar orientation as the initial video orientation. Subsequent orientation changes are handled by
        // -[viewWillTransitionToSize:withTransitionCoordinator:].
        UIInterfaceOrientation statusBarOrientation = [UIApplication sharedApplication].statusBarOrientation;
        AVCaptureVideoOrientation initialVideoOrientation = AVCaptureVideoOrientationPortrait;
        if ( statusBarOrientation != UIInterfaceOrientationUnknown ) {
            initialVideoOrientation = (AVCaptureVideoOrientation)statusBarOrientation;
        }
        
        AVCaptureVideoPreviewLayer *previewLayer = (AVCaptureVideoPreviewLayer *)self.previewView.layer;
        previewLayer.connection.videoOrientation = initialVideoOrientation;
        
    } );
}

#pragma mark --------------- Button action Methods --------------------

- (IBAction)libraryButtonAction:(id)sender {
    
    isImagePickerOpened =YES;
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        switch (status) {
            case PHAuthorizationStatusAuthorized:{
                
                img_picker = [[UIImagePickerController alloc] init];
                img_picker.delegate = self;
                img_picker.mediaTypes = @[(NSString *)kUTTypeMovie, (NSString *)kUTTypeImage];//ravi 31May
                img_picker.allowsEditing = NO;
                img_picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                //picker.navigationBar.tintColor = [UIColor whiteColor];//ravi 07Apr
                //picker.navigationBar.barTintColor =[UIColor blackColor];
                
                
                //ravi 07Apr
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self presentViewController:img_picker animated:YES completion:nil];
                });
                NSLog(@"PHAuthorizationStatusAuthorized");
                break;
            }
                
            case PHAuthorizationStatusDenied:
            {
                dispatch_async( dispatch_get_main_queue(), ^{
                    NSString *message = NSLocalizedString( @"User doesn't have permission to use the library, please change privacy settings", @"Alert message when the user has denied access to the library" );
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Alert!" message:message preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString( @"OK", @"Alert OK button" ) style:UIAlertActionStyleCancel handler:nil];
                    [alertController addAction:cancelAction];
                    // Provide quick access to Settings.
                    UIAlertAction *settingsAction = [UIAlertAction actionWithTitle:NSLocalizedString( @"Settings", @"Alert button to open Settings" ) style:UIAlertActionStyleDefault handler:^( UIAlertAction *action ) {
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                    }];
                    [alertController addAction:settingsAction];
                    [self presentViewController:alertController animated:YES completion:nil];
                } );
                NSLog(@"PHAuthorizationStatusDenied");
                
                break;
            }
                
            case PHAuthorizationStatusNotDetermined:
                NSLog(@"PHAuthorizationStatusNotDetermined");
                break;
            case PHAuthorizationStatusRestricted:
                NSLog(@"PHAuthorizationStatusRestricted");
                break;
        }
    }];
}

- (IBAction)on_click_switch_flash:(id)sender {
    
    //[self setVideoZoomFactor:0.8];
    //return;
    
    self.btn_flash_onoff.selected = !self.btn_flash_onoff.selected;
    
    AVCaptureDevice * device = self.videoDeviceInput.device;
    
    if ( [device hasTorch] && [device hasFlash] ) {
        [device lockForConfiguration:nil];
        
        if ( self.btn_flash_onoff.selected ) {
            
            device.torchMode = AVCaptureTorchModeOn;
            device.flashMode = AVCaptureFlashModeOn;
            self.flashImageView.image = [UIImage imageNamed:@"flash_on"];
        }else{
            self.flashImageView.image = [UIImage imageNamed:@"flash_off"];
            device.torchMode = AVCaptureTorchModeOff;
            device.flashMode = AVCaptureFlashModeOff;
        }
        
        [device unlockForConfiguration];
    }
}

- (IBAction)on_click_close:(id)sender {
    
    //ravi 31May
   /* [UIView animateWithDuration:.25 animations:^{
        detailSwipeVC.scroll_Menu.contentOffset = CGPointMake(0,0);
        
    }completion:^(BOOL finished) {
        if (finished)
            [self notifyToOffCamera];
    }];*/
   
    [self.navigationController popViewControllerAnimated:YES];
    
    
}

#pragma mark --------------- UIImagePickerController Delegate method ---------------

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    //[self init_handler];
    [picker dismissViewControllerAnimated:NO completion:nil];
    
    //    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
    //        [self setUpImagePicker];
    //    });
    //    isCameraON =NO;//ravi
    //    [self notifyToStartCamera];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    [picker dismissViewControllerAnimated:NO completion:nil];
    
    //    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
    //        [self setUpImagePicker];
    //    });
    
    //obtaining saving path
//    NSString *temporaryFileName = [NSProcessInfo processInfo].globallyUniqueString;
//    NSString *temporaryFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[temporaryFileName stringByAppendingPathExtension:@"jpg"]];
//    NSURL *temporaryFileURL = [NSURL fileURLWithPath:temporaryFilePath];
    
    //extracting image from the picker and saving it
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    
    //ravi 01Jun TODO:
    if ([mediaType isEqualToString:@"public.image"]) {
        UIImage *editedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        if(editedImage.imageOrientation==3){
           // editedImage=[CommonClass fixrotation:editedImage];
        }

        
        
        //ravi 01Jun
//        FilterVC *vc=[[FilterVC alloc]init];
//        vc.originalimage=editedImage;
//        vc.wasFrontCameraOn=NO; //ravi
//        vc.Path=@"";
//        [self.navigationController pushViewController:vc animated:NO];  // by nisha 6/7/17 set animtaion No
        
    }
    else
    {
        //ravi 01Jun TODO:
        //video
//        NSURL *moviePath = [info objectForKey:UIImagePickerControllerMediaURL];
//        if(moviePath){
//            VideoTrimmerVC *vc=[[VideoTrimmerVC alloc]init];
//            vc.movieUrl=moviePath;
//            [self.navigationController pushViewController:vc animated:NO]; // by nisha 6/7/17 set animtaion No
//        }
//        else{
//            moviePath=[info objectForKey:UIImagePickerControllerReferenceURL];
//            VideoTrimmerVC *vc=[[VideoTrimmerVC alloc]init];
//            vc.movieUrl=moviePath;
//            [self.navigationController pushViewController:vc animated:NO]; // by nisha 6/7/17 set animtaion No
//        }
//        [ACVideo emptyDocumentDirectoryTrashAtOnce];
    }
}

#pragma mark --------------- Zoom method ---------------

- (void)pinchToZoom:(UIPinchGestureRecognizer *)gestureRecognizer {
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        zoomAtStart = self.videoDeviceInput.device.videoZoomFactor;
    }
    
    CGFloat newZoom = gestureRecognizer.scale * zoomAtStart;
    
    if (newZoom > kDefaultMaxZoomFactor) {
        newZoom = kDefaultMaxZoomFactor;
    } else if (newZoom < kDefaultMinZoomFactor) {
        newZoom = kDefaultMinZoomFactor;
    }
    
    [self setVideoZoomFactor:newZoom];
    
}

- (void)setVideoZoomFactor:(CGFloat)videoZoomFactor {
    
    if (![self.videoDeviceInput.device respondsToSelector:@selector(videoZoomFactor)]) {
        return;
    }
    
    AVCaptureDevice *device = self.videoDeviceInput.device;
    
    if ([device respondsToSelector:@selector(videoZoomFactor)]) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            if (videoZoomFactor <= device.activeFormat.videoMaxZoomFactor) {
                device.videoZoomFactor = videoZoomFactor;
            } else {
                NSLog(@"Unable to set videoZoom: (max %f, asked %f)", device.activeFormat.videoMaxZoomFactor, videoZoomFactor);
            }
            
            [device unlockForConfiguration];
        } else {
            NSLog(@"Unable to set videoZoom: %@", error.localizedDescription);
        }
    }
}

#pragma mark --------------- Shutterview Delegate method---------------

- (void) captureImage {
    [self snapStillImage:self.view_shutter];
}

- (void) captureVideo{
}

- (void) startRecordingVideo {
    
    self.session.sessionPreset = AVCaptureSessionPresetHigh; //ravi
    
    
    //Avaneesh 26 Dec
    urlArray = [[NSMutableArray alloc]init];
    _view_shutter.transform = CGAffineTransformMakeScale(1,1);
    
    [UIView beginAnimations:@"button" context:nil];
    [UIView setAnimationDuration:0.75];
    _view_shutter.transform = CGAffineTransformMakeScale(1.5,1.5);
    
    [UIView commitAnimations];
    
    bottomView.hidden = YES;
    self.btn_cancel.hidden = YES;

    self.btn_flash_onoff.hidden = YES;
    self.btn_upback.hidden = YES;
    self.btn_library.hidden = YES;
    self.galleryImageView.hidden = YES;
    self.flashImageView.hidden = YES;
    self.bottombackImageView.hidden = YES;
    
    //Avaneesh 26 dec
    isRecordingStopped = NO;
    
    [self toggleMovieRecording:self.view_shutter];
}

- (void) stopRecordingVideo{
    //Avaneesh 12 Dec
    _view_shutter.transform = CGAffineTransformMakeScale(1.5,1.5);
    
    [UIView beginAnimations:@"button" context:nil];
    [UIView setAnimationDuration:0.25];
    _view_shutter.transform = CGAffineTransformMakeScale(1,1);
    
    [UIView commitAnimations];
    
    bottomView.hidden = NO;
    self.btn_cancel.hidden = NO;
    self.btn_flash_onoff.hidden = NO;
    self.btn_upback.hidden = NO;
    self.btn_library.hidden = NO;
    self.galleryImageView.hidden = NO;
    self.flashImageView.hidden = NO;
    self.bottombackImageView.hidden = NO;
    
    //Avaneesh 26 dec
    isRecordingStopped = YES;
    [self toggleMovieRecording:self.view_shutter];
    
}

#pragma mark Orientation

- (BOOL)shouldAutorotate {
    // Disable autorotation of the interface when recording is in progress.
    return ! self.movieFileOutput.isRecording;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    // Note that the app delegate controls the device orientation notifications required to use the device orientation.
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    if ( UIDeviceOrientationIsPortrait( deviceOrientation ) || UIDeviceOrientationIsLandscape( deviceOrientation ) ) {
        AVCaptureVideoPreviewLayer *previewLayer = (AVCaptureVideoPreviewLayer *)self.previewView.layer;
        previewLayer.connection.videoOrientation = (AVCaptureVideoOrientation)deviceOrientation;
    }
}

#pragma mark --------------------- KVO and Notifications -------------------

- (void)addObservers {
    [self.session addObserver:self forKeyPath:@"running" options:NSKeyValueObservingOptionNew context:SessionRunningContext];
    [self.stillImageOutput addObserver:self forKeyPath:@"capturingStillImage" options:NSKeyValueObservingOptionNew context:CapturingStillImageContext];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subjectAreaDidChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:self.videoDeviceInput.device];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionRuntimeError:) name:AVCaptureSessionRuntimeErrorNotification object:self.session];
    // A session can only run when the app is full screen. It will be interrupted in a multi-app layout, introduced in iOS 9,
    // see also the documentation of AVCaptureSessionInterruptionReason. Add observers to handle these session interruptions
    // and show a preview is paused message. See the documentation of AVCaptureSessionWasInterruptedNotification for other
    // interruption reasons.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionWasInterrupted:) name:AVCaptureSessionWasInterruptedNotification object:self.session];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionInterruptionEnded:) name:AVCaptureSessionInterruptionEndedNotification object:self.session];
}

- (void)removeObservers {
    @try{
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        
        [self.session removeObserver:self forKeyPath:@"running" context:SessionRunningContext];
        [self.stillImageOutput removeObserver:self forKeyPath:@"capturingStillImage" context:CapturingStillImageContext];
        
    }@catch(id anException){
        //do nothing, obviously it wasn't attached because an exception was thrown
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ( context == CapturingStillImageContext ) {
        BOOL isCapturingStillImage = [change[NSKeyValueChangeNewKey] boolValue];
        
        if ( isCapturingStillImage ) {
            dispatch_async( dispatch_get_main_queue(), ^{
                self.previewView.layer.opacity = 0.0;
                [UIView animateWithDuration:0.25 animations:^{
                    self.previewView.layer.opacity = 1.0;
                }];
            } );
        }
    }
    else if ( context == SessionRunningContext ) {
        //BOOL isSessionRunning = [change[NSKeyValueChangeNewKey] boolValue];
        
        dispatch_async( dispatch_get_main_queue(), ^{
            // Only enable the ability to change camera if the device has more than one camera.
            //self.cameraButton.enabled = isSessionRunning && ( [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo].count > 1 );
            //self.recordButton.enabled = isSessionRunning;
            //self.stillButton.enabled = isSessionRunning;
        } );
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)subjectAreaDidChange:(NSNotification *)notification {
    CGPoint devicePoint = CGPointMake( 0.5, 0.5 );
    [self focusWithMode:AVCaptureFocusModeContinuousAutoFocus exposeWithMode:AVCaptureExposureModeContinuousAutoExposure atDevicePoint:devicePoint monitorSubjectAreaChange:NO];
}

#pragma mark ------------------ AVCapture Session Interruption Methods -------------------

- (void)sessionRuntimeError:(NSNotification *)notification {
    NSError *error = notification.userInfo[AVCaptureSessionErrorKey];
    NSLog( @"Capture session runtime error: %@", error );
    
    // Automatically try to restart the session running if media services were reset and the last start running succeeded.
    // Otherwise, enable the user to try to resume the session running.
    if ( error.code == AVErrorMediaServicesWereReset ) {
        dispatch_async( self.sessionQueue, ^{
            if ( self.isSessionRunning ) {
                [self.session startRunning];
                self.sessionRunning = self.session.isRunning;
            }
            else {
                dispatch_async( dispatch_get_main_queue(), ^{
                    //self.resumeButton.hidden = NO;
                } );
            }
        } );
    }
    else {
        //self.resumeButton.hidden = NO;
    }
}

- (void)sessionWasInterrupted:(NSNotification *)notification {
    // In some scenarios we want to enable the user to resume the session running.
    // For example, if music playback is initiated via control center while using AVCam,
    // then the user can let AVCam resume the session running, which will stop music playback.
    // Note that stopping music playback in control center will not automatically resume the session running.
    // Also note that it is not always possible to resume, see -[resumeInterruptedSession:].
    BOOL showResumeButton = NO;
    
    // In iOS 9 and later, the userInfo dictionary contains information on why the session was interrupted.
    if ( &AVCaptureSessionInterruptionReasonKey ) {
        AVCaptureSessionInterruptionReason reason = [notification.userInfo[AVCaptureSessionInterruptionReasonKey] integerValue];
        NSLog( @"Capture session was interrupted with reason %ld", (long)reason );
        
        if ( reason == AVCaptureSessionInterruptionReasonAudioDeviceInUseByAnotherClient ||
            reason == AVCaptureSessionInterruptionReasonVideoDeviceInUseByAnotherClient ) {
            showResumeButton = YES;
        }
        else if ( reason == AVCaptureSessionInterruptionReasonVideoDeviceNotAvailableWithMultipleForegroundApps ) {
            // Simply fade-in a label to inform the user that the camera is unavailable.
            //self.cameraUnavailableLabel.hidden = NO;
            //self.cameraUnavailableLabel.alpha = 0.0;
            [UIView animateWithDuration:0.25 animations:^{
                //self.cameraUnavailableLabel.alpha = 1.0;
            }];
        }
    }
    else {
        NSLog( @"Capture session was interrupted" );
        showResumeButton = ( [UIApplication sharedApplication].applicationState == UIApplicationStateInactive );
    }
    
    if ( showResumeButton ) {
        // Simply fade-in a button to enable the user to try to resume the session running.
        //self.resumeButton.hidden = NO;
        //self.resumeButton.alpha = 0.0;
        [UIView animateWithDuration:0.25 animations:^{
            //self.resumeButton.alpha = 1.0;
        }];
    }
}

- (void)sessionInterruptionEnded:(NSNotification *)notification {
    NSLog( @"Capture session interruption ended" );
}

- (void)resumeInterruptedSession:(id)sender {
    dispatch_async( self.sessionQueue, ^{
        // The session might fail to start running, e.g., if a phone or FaceTime call is still using audio or video.
        // A failure to start the session running will be communicated via a session runtime error notification.
        // To avoid repeatedly failing to start the session running, we only try to restart the session running in the
        // session runtime error handler if we aren't trying to resume the session running.
        [self.session startRunning];
        self.sessionRunning = self.session.isRunning;
        if ( ! self.session.isRunning ) {
            dispatch_async( dispatch_get_main_queue(), ^{
                NSString *message = NSLocalizedString( @"Unable to resume", @"Alert message when unable to resume the session running" );
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"AVCam" message:message preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString( @"OK", @"Alert OK button" ) style:UIAlertActionStyleCancel handler:nil];
                [alertController addAction:cancelAction];
                [self presentViewController:alertController animated:YES completion:nil];
            } );
        }
        else {
            dispatch_async( dispatch_get_main_queue(), ^{
                //self.resumeButton.hidden = YES;
            } );
        }
    } );
}

#pragma mark --------------------- Private Methods ------------------------

- (void)toggleMovieRecording:(id)sender {
    // Disable the Camera button until recording finishes, and disable the Record button until recording starts or finishes. See the AVCaptureFileOutputRecordingDelegate methods.
    
    dispatch_async( self.sessionQueue, ^{
        if ( ! self.movieFileOutput.isRecording ) {
            if ( [UIDevice currentDevice].isMultitaskingSupported ) {
                // Setup background task. This is needed because the -[captureOutput:didFinishRecordingToOutputFileAtURL:fromConnections:error:]
                // callback is not received until AVCam returns to the foreground unless you request background execution time.
                // This also ensures that there will be time to write the file to the photo library when AVCam is backgrounded.
                // To conclude this background execution, -endBackgroundTask is called in
                // -[captureOutput:didFinishRecordingToOutputFileAtURL:fromConnections:error:] after the recorded file has been saved.
                self.backgroundRecordingID = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
            }
            
            // Update the orientation on the movie file output video connection before starting recording.
            AVCaptureConnection *connection = [self.movieFileOutput connectionWithMediaType:AVMediaTypeVideo];
            AVCaptureVideoPreviewLayer *previewLayer = (AVCaptureVideoPreviewLayer *)self.previewView.layer;
            connection.videoOrientation = previewLayer.connection.videoOrientation;
            
            // Turn OFF flash for video recording.
            //[TuurntClipPickerViewController setFlashMode:AVCaptureFlashModeOff forDevice:self.videoDeviceInput.device];
            
            // Start recording to a temporary file.
            //NSString *outputFileName = [NSProcessInfo processInfo].globallyUniqueString;
            NSString *outputFileName = @"the-samefile-video-recoding";
            NSString *outputFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[outputFileName stringByAppendingPathExtension:@"mov"]];
            
            NSError * error;
            [[NSFileManager defaultManager] removeItemAtPath:outputFilePath error:&error];
            
            [self.movieFileOutput startRecordingToOutputFileURL:[NSURL fileURLWithPath:[self getVideoSaveFilePathString]] recordingDelegate:self];
        }
        else {
            [self.movieFileOutput stopRecording];
        }
    } );
}

- (void)changeCamera:(UITapGestureRecognizer *)gestureRecognizer {
    dispatch_async( self.sessionQueue, ^{
        AVCaptureDevice *currentVideoDevice = self.videoDeviceInput.device;
        AVCaptureDevicePosition preferredPosition = AVCaptureDevicePositionUnspecified;
        AVCaptureDevicePosition currentPosition = currentVideoDevice.position;
        
        switch ( currentPosition )
        {
            case AVCaptureDevicePositionUnspecified:{
                preferredPosition = AVCaptureDevicePositionBack;
                isFrontCamera=NO;
                dispatch_async( dispatch_get_main_queue(), ^{
                self.flashImageView.hidden=NO;
                } );
            }
                break;
            case AVCaptureDevicePositionFront:{
                preferredPosition = AVCaptureDevicePositionBack;
                isFrontCamera=NO;
                dispatch_async( dispatch_get_main_queue(), ^{
                    self.flashImageView.hidden=NO;
                } );
            }
                break;
            case AVCaptureDevicePositionBack://ravi
                dispatch_async( dispatch_get_main_queue(), ^{
                    [self.flashImageView setImage:[UIImage imageNamed:@"flash_off.png"]];
                    self.btn_flash_onoff.selected = NO;//ravi 21Dec
                    self.flashImageView.hidden=YES;
                } );
                
                preferredPosition = AVCaptureDevicePositionFront;
                isFrontCamera=YES;
                break;
        }
        
        AVCaptureDevice *videoDevice = [CustomCameraVC deviceWithMediaType:AVMediaTypeVideo preferringPosition:preferredPosition];
        AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:nil];
        
        [self.session beginConfiguration];
        
        // Remove the existing device input first, since using the front and back camera simultaneously is not supported.
        [self.session removeInput:self.videoDeviceInput];
        
        if ( [self.session canAddInput:videoDeviceInput] ) {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureDeviceSubjectAreaDidChangeNotification object:currentVideoDevice];
            
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subjectAreaDidChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:videoDevice];
            
            
            [self.session addInput:videoDeviceInput];
            self.videoDeviceInput = videoDeviceInput;
        }
        else {
            [self.session addInput:self.videoDeviceInput];
        }
        //ravi
        //        AVCaptureConnection *connection = [self.movieFileOutput connectionWithMediaType:AVMediaTypeVideo];
        //        if ( connection.isVideoStabilizationSupported ) {
        //            connection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeAuto;
        //        }
        //
        //        if (preferredPosition == AVCaptureDevicePositionFront) {
        //            self.session.sessionPreset = AVCaptureSessionPresetPhoto; //TODO
        //        }
        //        else {
        //            self.session.sessionPreset = AVCaptureSessionPreset1920x1080; //TODO
        //        }
        
        
        [self.session commitConfiguration];
        
    } );
}

// call after taking image
- (void)snapStillImage:(id)sender {
    dispatch_async( self.sessionQueue, ^{
        AVCaptureConnection *connection = [self.stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
        AVCaptureVideoPreviewLayer *previewLayer = (AVCaptureVideoPreviewLayer *)self.previewView.layer;
        
        // Update the orientation on the still image output video connection before capturing.
        connection.videoOrientation = previewLayer.connection.videoOrientation;
        
        // Capture a still image.
        [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:connection completionHandler:^( CMSampleBufferRef imageDataSampleBuffer, NSError *error ) {
            if ( imageDataSampleBuffer ) {
                // The sample buffer is not retained. Create image data before saving the still image to the photo library asynchronously.
                
                NSString *temporaryFileName = @"the-samefile-photo-recoding";
                NSString *temporaryFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[temporaryFileName stringByAppendingPathExtension:@"jpg"]];
                NSURL *temporaryFileURL = [NSURL fileURLWithPath:temporaryFilePath];
                
                dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                    NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                    
                    //ravi 01Jun TODO:
                    UIImage *image = [UIImage imageWithData:imageData];
                    
                    if(image.imageOrientation==3){
                        //image=[CommonClass fixrotation:image];
                    }
                    
                    NSError *error = nil;
                    imageData = UIImagePNGRepresentation(image);
                    [imageData writeToURL:temporaryFileURL options:NSDataWritingAtomic error:&error];
                    NSDictionary *imageDataDict = [[NSDictionary alloc]initWithObjectsAndKeys:image,
                                                   @"image",nil];
                    NSNotification *myNotification = [NSNotification notificationWithName:@"ImageVideoUploadNotification" object:nil userInfo:imageDataDict];
                    //Post it to the default notification center
                    [[NSNotificationCenter defaultCenter] postNotification:myNotification];
                   
                    [self.navigationController popViewControllerAnimated:YES];
                    
                    
                });
                
                if ( error ) {
                   
                    return;
                }
                else {

                }
            }
            else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                message:[NSString stringWithFormat:@"Could not capture still image: %@", error ]
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                alert.delegate = self;
                alert.tag = 5;
                [alert show];
                return;
            }
        }];
    } );
}

#pragma mark --------------------- Device Configuration ---------------------

- (void)focusWithMode:(AVCaptureFocusMode)focusMode exposeWithMode:(AVCaptureExposureMode)exposureMode atDevicePoint:(CGPoint)point monitorSubjectAreaChange:(BOOL)monitorSubjectAreaChange {
    
    dispatch_async( self.sessionQueue, ^{
        AVCaptureDevice *device = self.videoDeviceInput.device;
        NSError *error = nil;
        if ( [device lockForConfiguration:&error] ) {
            // Setting (focus/exposure)PointOfInterest alone does not initiate a (focus/exposure) operation.
            // Call -set(Focus/Exposure)Mode: to apply the new point of interest.
            if ( device.isFocusPointOfInterestSupported && [device isFocusModeSupported:focusMode] ) {
                device.focusPointOfInterest = point;
                device.focusMode = focusMode;
            }
            
            if ( device.isExposurePointOfInterestSupported && [device isExposureModeSupported:exposureMode] ) {
                device.exposurePointOfInterest = point;
                device.exposureMode = exposureMode;
            }
            
            device.subjectAreaChangeMonitoringEnabled = monitorSubjectAreaChange;
            [device unlockForConfiguration];
        }
        else {
            NSLog( @"Could not lock device for configuration: %@", error );
        }
    } );
}

+ (void)setFlashMode:(AVCaptureFlashMode)flashMode forDevice:(AVCaptureDevice *)device {
    if ( device.hasFlash && [device isFlashModeSupported:flashMode] ) {
        NSError *error = nil;
        if ( [device lockForConfiguration:&error] ) {
            device.flashMode = flashMode;
            [device unlockForConfiguration];
        }
        else {
            NSLog( @"Could not lock device for configuration: %@", error );
        }
    }
}

+ (AVCaptureDevice *)deviceWithMediaType:(NSString *)mediaType preferringPosition:(AVCaptureDevicePosition)position {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:mediaType];
    AVCaptureDevice *captureDevice = devices.firstObject;
    
    for ( AVCaptureDevice *device in devices ) {
        if ( device.position == position ) {
            captureDevice = device;
            break;
        }
    }
    return captureDevice;
}

//ravi 21Dec
-(void)switchOffFlash { //when we are moving out from this view then we should off flash
    self.btn_flash_onoff.selected = NO;
    AVCaptureDevice * device = self.videoDeviceInput.device;
    if ( [device hasTorch] && [device hasFlash] ) {
        [device lockForConfiguration:nil];
        
        self.flashImageView.image = [UIImage imageNamed:@"flash_off"];
        device.torchMode = AVCaptureTorchModeOff;
        device.flashMode = AVCaptureFlashModeOff;
        [device unlockForConfiguration];
    }
}


#pragma mark --------------------- AVCaptureFileOutputRecording Delegate methods ---------------------

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections {
    // Enable the Record button to let the user stop the recording.
    NSLog( @"didStartRecordingToOutputFileAtURL: %@", fileURL );
    
}

// call after video recording
- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error {
    
    if ( error ) {
        NSLog( @"Movie file finishing error: %@", error );
    }
    
    [urlArray addObject:outputFileURL];
    
    if (isRecordingStopped == NO) {
        [self toggleMovieRecording:self.view_shutter];
        return;
    }
    
    //Avaneesh 26 Dec
    [self mergeAndExportVideosAtFileURLs:urlArray];
}

-(void)doneButtonClick:(NSNotification*)aNotification {
    NSNumber *reason = [aNotification.userInfo objectForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey];
    
    if ([reason intValue] == MPMovieFinishReasonPlaybackEnded) {
        
    }
}


#pragma mark -------------------- create and merge video on flip camera ----------------------
//Avaneesh 26 Dec
- (void)createVideoFolderIfNotExist {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    
    NSString *folderPath = [path stringByAppendingPathComponent:VIDEO_FOLDER];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = NO;
    BOOL isDirExist = [fileManager fileExistsAtPath:folderPath isDirectory:&isDir];
    
    if(!(isDirExist && isDir))
    {
        BOOL bCreateDir = [fileManager createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:nil];
        if(!bCreateDir){
            NSLog(@"Creating a saved video folder failed");
        }
    }
}

//最后合成为 mp4
- (NSString *)getVideoMergeFilePathString {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    
    path = [path stringByAppendingPathComponent:VIDEO_FOLDER];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *nowTimeStr = [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]];

    NSString *fileName = [[path stringByAppendingPathComponent:nowTimeStr] stringByAppendingString:@"merge.mp4"];
    fileName =[fileName stringByReplacingOccurrencesOfString:@" " withString:@""];

    return fileName;
}

//录制保存的时候要保存为 mov
- (NSString *)getVideoSaveFilePathString {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    
    path = [path stringByAppendingPathComponent:VIDEO_FOLDER];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *nowTimeStr = [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]];
    
    NSString *fileName = [[path stringByAppendingPathComponent:nowTimeStr] stringByAppendingString:@".mov"];
    
    return fileName;
}

- (void)deleteAllVideos {
    for (NSURL *videoFileURL in urlArray) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString *filePath = [[videoFileURL absoluteString] stringByReplacingOccurrencesOfString:@"file://" withString:@""];
            NSFileManager *fileManager = [NSFileManager defaultManager];
            if ([fileManager fileExistsAtPath:filePath]) {
                NSError *error = nil;
                [fileManager removeItemAtPath:filePath error:&error];
                
              
                
                
                if (error) {
                    NSLog(@"delete All Video There was an error deleting the video file:%@", error);
                }
            }
        });
    }
    [urlArray removeAllObjects];
}

- (void)mergeAndExportVideosAtFileURLs:(NSMutableArray *)fileURLArray {
    //[[AppDelegate getAppDelegate]showIndicator];
    NSError *error = nil;
    
    CGSize renderSize = CGSizeMake(0, 0);
    
    NSMutableArray *layerInstructionArray = [[NSMutableArray alloc] init];
    
    AVMutableComposition *mixComposition = [[AVMutableComposition alloc] init];
    
    CMTime totalDuration = kCMTimeZero;
    
    NSMutableArray *assetTrackArray = [[NSMutableArray alloc] init];
    NSMutableArray *assetArray = [[NSMutableArray alloc] init];
    for (NSURL *fileURL in fileURLArray) {
        
        AVAsset *asset = [AVAsset assetWithURL:fileURL];
        [assetArray addObject:asset];
        
        NSArray* tmpAry =[asset tracksWithMediaType:AVMediaTypeVideo];
        if (tmpAry.count>0) {
            AVAssetTrack *assetTrack = [tmpAry objectAtIndex:0];
            [assetTrackArray addObject:assetTrack];
            renderSize.width = MAX(renderSize.width, assetTrack.naturalSize.height);
            renderSize.height = MAX(renderSize.height, assetTrack.naturalSize.width);
        }
    }
    
    CGFloat renderW = MIN(renderSize.width, renderSize.height);
    
    for (int i = 0; i < [assetArray count] && i < [assetTrackArray count]; i++) {
        
        AVAsset *asset = [assetArray objectAtIndex:i];
        AVAssetTrack *assetTrack = [assetTrackArray objectAtIndex:i];
        
        NSArray*dataSourceArray= [asset tracksWithMediaType:AVMediaTypeAudio];
        
        // on call audio
        if (dataSourceArray.count > 0) {
            AVMutableCompositionTrack *audioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
            
            [audioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration)
                                ofTrack:([dataSourceArray count]>0)?[dataSourceArray objectAtIndex:0]:nil
                                 atTime:totalDuration
                                  error:nil];
        }
        
        AVMutableCompositionTrack *videoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        
        [videoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration)
                            ofTrack:assetTrack
                             atTime:totalDuration
                              error:&error];
        
        AVMutableVideoCompositionLayerInstruction *layerInstruciton = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
        
        totalDuration = CMTimeAdd(totalDuration, asset.duration);
        
        CGFloat rate;
        rate = renderW / MIN(assetTrack.naturalSize.width, assetTrack.naturalSize.height);
        
        CGAffineTransform layerTransform = CGAffineTransformMake(assetTrack.preferredTransform.a, assetTrack.preferredTransform.b, assetTrack.preferredTransform.c, assetTrack.preferredTransform.d, assetTrack.preferredTransform.tx * rate, assetTrack.preferredTransform.ty * rate);
        layerTransform = CGAffineTransformConcat(layerTransform, CGAffineTransformMake(1, 0, 0, 1, 0, -(assetTrack.naturalSize.width - assetTrack.naturalSize.height) / 2.0+preLayerHWRate*(preLayerHeight-preLayerWidth)/2));
        layerTransform = CGAffineTransformScale(layerTransform, rate, rate);
        
        [layerInstruciton setTransform:layerTransform atTime:kCMTimeZero];
        [layerInstruciton setOpacity:0.0 atTime:totalDuration];
        
        [layerInstructionArray addObject:layerInstruciton];
    }
    
    NSString *path = [self getVideoMergeFilePathString];
    NSURL *mergeFileURL = [NSURL fileURLWithPath:path];
    
    AVMutableVideoCompositionInstruction *mainInstruciton = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    mainInstruciton.timeRange = CMTimeRangeMake(kCMTimeZero, totalDuration);
    mainInstruciton.layerInstructions = layerInstructionArray;
    AVMutableVideoComposition *mainCompositionInst = [AVMutableVideoComposition videoComposition];
    mainCompositionInst.instructions = @[mainInstruciton];
    mainCompositionInst.frameDuration = CMTimeMake(1, 100);
    mainCompositionInst.renderSize = CGSizeMake(renderW, renderW*preLayerHWRate);
    
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetMediumQuality];
    exporter.videoComposition = mainCompositionInst;
    exporter.outputURL = mergeFileURL;
    exporter.outputFileType = AVFileTypeMPEG4;
    exporter.shouldOptimizeForNetworkUse = YES;
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            
            
            [timer invalidate];
          //  toggleTorch(on: false)
            
     
        //    [changeFlashBtn setBackgroundImage:[UIImage imageNamed:@"flash_off"] forState:UIControlStateNormal];
            countLbl.hidden = YES;
            
            countLbl.text = @"00:00";
//            if (CameraModeManageSelected) {
//            //    print("Rear Mode")
//                changeFlashBtn.hidden = true;
//            } else {
//          //      print("Front Mode")
//                changeFlashBtn.hidden = false;
//
//            }
//
            UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            ChooseVideoPreviewVC * controller = [storyboard instantiateViewControllerWithIdentifier:@"ChooseVideoPreviewVC"];
         //   NSURL *url = [[NSURL alloc] initWithString:mergeFileURL];
            controller.videoURl = mergeFileURL ;
            controller.count = 59 - count;
            count = 59;
            controller.coachDetails = self.coachDetails;
            [self.navigationController pushViewController:controller animated:YES];
            
         //   [self finishVideoRecordingWithUrl:mergeFileURL];
            
        });
    }];
}

-(void)finishVideoRecordingWithUrl:(NSURL *)outputUrl{
    
    //ravi 01Jun TODO
    //[[AppDelegate getAppDelegate]hideIndicator];
    [self deleteAllVideos];
    
    [self switchOffFlash]; //ravi 21Dec
    // success handle
    
    //ravi 01Jun
/*    if ([[AppDelegate getAppDelegate]isfromChat]) {
        for (UIViewController *controller in self.navigationController.viewControllers) {
            
            //Do not forget to import AnOldViewController.h
            if ([controller isKindOfClass:[RCMessagesView class]]) {
                
                RCMessagesView * vc = (RCMessagesView *)controller;
                self.chatDelegate = vc;
                if([self.chatDelegate respondsToSelector:@selector(getVideoDetails:videoPath:duration:isFromTrimmer:)]) {
                    [self.chatDelegate getVideoDetails:@"Video" videoPath:[NSString stringWithFormat:@"%@",outputUrl ] duration:@"1" isFromTrimmer:NO];
                }
                [self.navigationController popToViewController:vc animated:NO];
                break;
            }
        }

    }
    else{
        PostVC *tag=[[PostVC alloc]init];
        tag.Class_name=@"Video";
        tag.Path=[NSString stringWithFormat:@"%@",outputUrl];
        [self .navigationController pushViewController:tag animated:YES];
    }
    */
    
    //[self.navigationController popToRootViewControllerAnimated:YES];
}


#pragma mark ------------------- Slide to open Camera methods -------------------------

-(void)notifyToStartCamera {
    // NSLog(@"start camera");
    
    //detailSwipeVC.navigationController.interactivePopGestureRecognizer.enabled = NO;
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES
                                            withAnimation:NO];
    
    //here we need to check camera permission then do further setup //ravi 29May
    if(![self checkPermissions])
        return;
    
    if (self.setupResult == AVCamSetupResultSessionConfigurationFailed) {
        
        dispatch_async( self.sessionQueue, ^{
            [self configureCameraSession];
        } );
    }
    [Checking isCameraAccess:^(BOOL cameraAccess) {
        
        if (cameraAccess == YES && self.setupResult == AVCamSetupResultSuccess) {
            if (!self.session.isRunning) {
                
                if(isCameraON==NO){
                    isCameraON =YES;
                    // Because -[AVCaptureSession startRunning] is a blocking call which can take a long time. We dispatch session setup to the sessionQueue
                    // so that the main queue isn't blocked, which keeps the UI responsive.
                    dispatch_async( self.sessionQueue, ^{
                        [self addObservers];
                        [self.session startRunning];
                        
                        //[self setupAudioSession];//ravi 27Feb
                        
                    } );
                    
                    _previewLayer.frame = self.previewView.bounds;
                }
            }
        }
        else {
            NSString *message;
            UIAlertAction *settingsAction;
            
            if (self.setupResult == AVCamSetupResultCameraNotAuthorized) {
                message = NSLocalizedString( @"AVCam doesn't have permission to use the camera, please change privacy settings", @"Alert message when the user has denied access to the camera" );
                settingsAction = [UIAlertAction actionWithTitle:NSLocalizedString( @"Settings", @"Alert button to open Settings" ) style:UIAlertActionStyleDefault handler:^( UIAlertAction *action ) {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                }];
                dispatch_async( dispatch_get_main_queue(), ^{
                    
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"AVCam" message:message preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString( @"OK", @"Alert OK button" ) style:UIAlertActionStyleCancel handler:nil];
                    [alertController addAction:cancelAction];
                    [alertController addAction:settingsAction];
                    [self presentViewController:alertController animated:YES completion:nil];
                } );
            }
            else {
                message = NSLocalizedString( @"Unable to capture media", @"Alert message when something goes wrong during capture session configuration" );
                settingsAction = [UIAlertAction actionWithTitle:NSLocalizedString( @"OK", @"Alert OK button" ) style:UIAlertActionStyleCancel handler:nil];
                dispatch_async( dispatch_get_main_queue(), ^{
                    
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"AVCam" message:message preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString( @"OK", @"Alert OK button" ) style:UIAlertActionStyleCancel handler:nil];
                    [alertController addAction:cancelAction];
                    
                    [self presentViewController:alertController animated:YES completion:nil];
                } );
                
            }
        }
    }];
    
    //[self demonstrateInputSelection];

}

-(void)notifyToOffCamera {
    //Remove swipe gesture when coming from detail view
    
    
    isCameraON =NO;
    [[UIApplication sharedApplication] setStatusBarHidden:NO
                                            withAnimation:NO];
    if ((self.session != nil) && (self.session.isRunning)) {
        dispatch_async( self.sessionQueue, ^{
            if ( self.setupResult == AVCamSetupResultSuccess ) {
                [self.session stopRunning];
                [self removeObservers];
                self.btn_flash_onoff.selected = NO;//ravi 21Dec
                self.flashImageView.image = [UIImage imageNamed:@"flash_off"];//ravi 21Dec
                
//                [[NSNotificationCenter defaultCenter] addObserver:self
//                                                         selector:@selector(doneButtonClick:)
//                                                             name:MPMoviePlayerPlaybackDidFinishNotification
//                                                           object:nil];
            }
        } );
    }
}


-(void)moveToCameraVCWithData:(NSDictionary *)data{
    
    //ravi 12Apr
    
    if (data != nil) {
        self.data_tuurnt_selected = [NSMutableDictionary dictionaryWithDictionary:data];
    }
    else {
        self.data_tuurnt_selected = nil;
    }
    
    [self notifyToStartCamera];
}

//Avanish Singh
-(void)notifyForTheCallConnected {
    
   /* //- Remove microphone when call is connected
    NSLog(@"self.session %@",self.session);
    NSLog(@"[AppDelegate getAppDelegate].sessionRefrence %@",[AppDelegate getAppDelegate].sessionRefrence);
    
    [[AppDelegate getAppDelegate].sessionRefrence beginConfiguration];
    
    AVCaptureConnection* audioConnection = [_movieFileOutput connectionWithMediaType:AVMediaTypeAudio];
    if(audioConnection) {
        audioConnection.enabled=NO;
    }
    
    NSArray *devices = [AppDelegate getAppDelegate].sessionRefrence.inputs;
    for (AVCaptureDeviceInput *input in devices) {
        if ([input.device hasMediaType:AVMediaTypeAudio]) {
            
            //  [[AppDelegate getAppDelegate].sessionRefrence removeInput:input];
            break;
        }
    }
    [[AppDelegate getAppDelegate].sessionRefrence commitConfiguration];
    self.session = [AppDelegate getAppDelegate].sessionRefrence;*/
    [self.session startRunning];
}

-(void)notifyForTheCallDisconnected {
    
    //- Add microphone when call is disconnected
    NSError *error = nil;
    AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    AVCaptureDeviceInput *audioDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:&error];
    
   /* [[AppDelegate getAppDelegate].sessionRefrence beginConfiguration];
    
    if ( [[AppDelegate getAppDelegate].sessionRefrence canAddInput:audioDeviceInput] ) {
        [[AppDelegate getAppDelegate].sessionRefrence addInput:audioDeviceInput];
    }
    else { NSLog( @"Could not add audio device input to the session" );}
    
    [[AppDelegate getAppDelegate].sessionRefrence commitConfiguration];
    self.session = [AppDelegate getAppDelegate].sessionRefrence;*/
    [self.session startRunning];
}


-(void)demonstrateInputSelection
{
    NSError* theError = nil;
    BOOL result = YES;
    
    AVAudioSession* myAudioSession = [AVAudioSession sharedInstance];
    
    // result = [myAudioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&theError];
    //Feb 23 For Mixing Audio to don't stop music on app start
    result =[myAudioSession setCategory:AVAudioSessionCategoryAmbient withOptions:AVAudioSessionCategoryOptionMixWithOthers|AVAudioSessionCategoryOptionInterruptSpokenAudioAndMixWithOthers error:&theError];//ravi 18Apr
    if (!result)
    {
        NSLog(@"setCategory failed");
    }
    
    result = [myAudioSession setActive:NO error:&theError];
    if (!result)
    {
        NSLog(@"setActive failed");
    }
    
    // Get the set of available inputs. If there are no audio accessories attached, there will be
    // only one available input -- the built in microphone.
    NSArray* inputs = [myAudioSession availableInputs];
    
    // Locate the Port corresponding to the built-in microphone.
    AVAudioSessionPortDescription* builtInMicPort = nil;
    for (AVAudioSessionPortDescription* port in inputs)
    {
        if ([port.portType isEqualToString:AVAudioSessionPortBuiltInMic])
        {
            builtInMicPort = port;
            break;
        }
    }
    
    // Print out a description of the data sources for the built-in microphone
    NSLog(@"There are %u data sources for port :\"%@\"", (unsigned)[builtInMicPort.dataSources count], builtInMicPort);
    NSLog(@"%@", builtInMicPort.dataSources);
    
    // loop over the built-in mic's data sources and attempt to locate the front microphone
    AVAudioSessionDataSourceDescription* frontDataSource = nil;
    for (AVAudioSessionDataSourceDescription* source in builtInMicPort.dataSources)
    {
        if ([source.orientation isEqual:AVAudioSessionOrientationFront])
        {
            frontDataSource = source;
            break;
        }
    } // end data source iteration
    
    if (frontDataSource)
    {
        NSLog(@"Currently selected source is \"%@\" for port \"%@\"", builtInMicPort.selectedDataSource.dataSourceName, builtInMicPort.portName);
        NSLog(@"Attempting to select source \"%@\" on port \"%@\"", frontDataSource, builtInMicPort.portName);
        
        // Set a preference for the front data source.
        theError = nil;
        result = [builtInMicPort setPreferredDataSource:frontDataSource error:&theError];
        if (!result)
        {
            // an error occurred. Handle it!
            NSLog(@"setPreferredDataSource failed");
        }
    }
    
    // Make sure the built-in mic is selected for input. This will be a no-op if the built-in mic is
    // already the current input Port.
    theError = nil;
    result = [myAudioSession setPreferredInput:builtInMicPort error:&theError];
    if (!result)
    {
        // an error occurred. Handle it!
        NSLog(@"setPreferredInput failed");
    }
    
}

-(void)setupAudioSession {
    NSError* theError = nil;
    BOOL result = YES;
    
    AVAudioSession* myAudioSession = [AVAudioSession sharedInstance];
    
    // result = [myAudioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&theError];
    //Feb 23 For Mixing Audio to don't stop music on app start
    result =[myAudioSession setCategory:AVAudioSessionCategoryAmbient withOptions:AVAudioSessionCategoryOptionMixWithOthers|AVAudioSessionCategoryOptionInterruptSpokenAudioAndMixWithOthers error:&theError]; //ravi 18Apr
    if (!result)
    {
        NSLog(@"setCategory failed");
    }
    result = [myAudioSession setActive:NO error:&theError];
}


-(BOOL)checkPermissions{
    BOOL granted =YES;
    
 /*   PermissionHandler *obj =[[PermissionHandler alloc]init];
    if(![obj isCameraAccessGranted])
    {
        view_access.hidden=NO;
        btn_camera.selected=NO;
    }
    else{
        btn_camera.selected=YES;
        granted =YES;
    }
    
    if(![obj isMicrophoneAccessGranted])
    {
        view_access.hidden=NO;
        btn_microphone.selected=NO;
    }
    else
        btn_microphone.selected=YES;
    
    if(btn_camera.selected == YES && btn_microphone.selected == YES)
        view_access.hidden=YES;
    */
    return granted;
}

-(IBAction)btn_allowMicrophoneAccess:(id)sender{
    [self openSettings];
}
-(IBAction)btn_allowCameraAccess:(id)sender{
    [self openSettings];
}
- (void)openSettings
{
    BOOL canOpenSettings = (UIApplicationOpenSettingsURLString != NULL);
    if (canOpenSettings) {
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        [[UIApplication sharedApplication] openURL:url];
    }
}

@end

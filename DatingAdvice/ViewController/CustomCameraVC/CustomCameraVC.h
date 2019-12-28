//
//  CustomCameraVC.h
//  Pawpular
//
//  Created by Shine Wave Solutions on 31/05/17.
//  Copyright © 2017 IBCMobile. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "ShuterView.h"
#import <AVFoundation/AVFoundation.h>//ravi 20Apr


@interface CustomCameraVC : UIViewController<ShutterViewDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>
{
    __weak IBOutlet UIView *bottomView;
}
@property (strong, nonatomic) IBOutlet UIView *switchCameraView;

@property (strong,nonatomic) NSMutableDictionary * data_tuurnt_selected;

//sumit 24 Aug 2016
@property(nonatomic,retain)NSString *pageFrom;

@property(nonatomic,retain)NSString *tuurntType;
@property (weak, nonatomic) IBOutlet UIImageView *bottombackImageView;
@property (weak, nonatomic) IBOutlet UIImageView *galleryImageView;
@property (weak, nonatomic) IBOutlet UIImageView *switchImageView;
@property (weak, nonatomic) IBOutlet UIImageView *flashImageView;

@property (weak, nonatomic) IBOutlet UIImageView *img_PostType;
@property (nonatomic, strong) NSDictionary * coachDetails;
@property (nonatomic, strong) NSString *fromCoachSignUp;

// Session management.
@property (nonatomic) dispatch_queue_t sessionQueue;
@property (nonatomic) AVCaptureSession *session;
-(void)moveToCameraVCWithData:(NSDictionary *)data;
-(void)notifyToStartCamera;

@property BOOL isBackBtn;

@end



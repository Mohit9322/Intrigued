//
//  Checking.m
//  SnapChatMenu
//
//  Created by Umesh Sharma on 19/01/17.
//  Copyright © 2017 Umesh Shrama. All rights reserved.
//

#import "Checking.h"
@import Photos;
@import AVFoundation;

@implementation Checking

+(void)isLibraryAccess:(GalleryPermissions)permissionAccess
{
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    
    switch (status)
    {
        case PHAuthorizationStatusAuthorized:
            permissionAccess(YES);
            break;
        case PHAuthorizationStatusNotDetermined:
        {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus authorizationStatus)
             {
                 if (authorizationStatus == PHAuthorizationStatusAuthorized)
                 {
                     permissionAccess(YES);
                 }
                 else
                 {
                     permissionAccess(NO);
                 }
             }];
            break;
        }
        default:
            permissionAccess(NO);
            break;
    }
}

+(void)isCameraAccess:(GalleryPermissions)permissionAccess {
    
    // Check video authorization status. Video access is required and audio access is optional.
    // If audio access is denied, audio is not recorded during movie recording.
    
    // Setup the capture session.
    // In general it is not safe to mutate an AVCaptureSession or any of its inputs, outputs, or connections from multiple threads at the same time.
    // Why not do all of this on the main queue?
    // Because -[AVCaptureSession startRunning] is a blocking call which can take a long time. We dispatch session setup to the sessionQueue
    // so that the main queue isn't blocked, which keeps the UI responsive.
    
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    switch (status)
    {
        case AVAuthorizationStatusAuthorized:
        {
            // The user has previously granted access to the camera.
            permissionAccess(YES);
            break;
        }
        case AVAuthorizationStatusNotDetermined:
        {
            // The user has not yet been presented with the option to grant video access.
            // We suspend the session queue to delay session setup until the access request has completed to avoid
            // asking the user for audio access if video access is denied.
            // Note that audio access will be implicitly requested when we create an AVCaptureDeviceInput for audio during session setup.
//            dispatch_suspend( self.sessionQueue );
//            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^( BOOL granted ) {
//                if ( ! granted ) {
//                    self.setupResult = AVCamSetupResultCameraNotAuthorized;
//                }
//                dispatch_resume( self.sessionQueue );
//            }];
            permissionAccess(NO);
            break;
        }
        default:
        {
           permissionAccess(NO);
            break;
        }
    }

}

@end

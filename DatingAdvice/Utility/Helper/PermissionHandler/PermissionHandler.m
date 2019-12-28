//
//  PermissionHandler.m
//  Tuurnt
//
//  Created by Shine Wave Solutions on 22/05/17.
//  Copyright © 2017 fabricemishiki. All rights reserved.
//

#import "PermissionHandler.h"
#import "AppDelegate.h"

#define SYSTEM_VERSION_GRATERTHAN_OR_EQUALTO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)


@implementation PermissionHandler



//ravi 22May
- (BOOL)isCameraAccessGranted
{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if(authStatus == AVAuthorizationStatusAuthorized)
    {
        return YES;
    }
    else if(authStatus == AVAuthorizationStatusNotDetermined)
    {
        NSLog(@"%@", @"Camera access not determined. Ask for permission.");
        
//        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted)
//         {
//             if(granted)
//             {
//                 NSLog(@"Granted access to %@", AVMediaTypeVideo);
//             }
//             else
//             {
//                 NSLog(@"Not granted access to %@", AVMediaTypeVideo);
//             }
//         }];
        
        return NO;
    }
    else if (authStatus == AVAuthorizationStatusRestricted)
    {
        // My own Helper class is used here to pop a dialog in one simple line.
        return NO;
    }
    else
    {
        return NO;
    }
    return YES;
}


//ravi 22May
-(BOOL)isMicrophoneAccessGranted{
    
   __block BOOL accessGranted =NO;
    
    AVAudioSessionRecordPermission permissionStatus = [[AVAudioSession sharedInstance] recordPermission];
    
    switch (permissionStatus) {
        case AVAudioSessionRecordPermissionUndetermined:{
//            [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
//                // CALL YOUR METHOD HERE - as this assumes being called only once from user interacting with permission alert!
//                if (granted) {
//                    // Microphone enabled code
//                    accessGranted=YES;
//                }
//                else {
//                    // Microphone disabled code
//                    accessGranted=NO;
//                }
//            }];
            break;
        }
        case AVAudioSessionRecordPermissionDenied:
            // direct to settings...
            accessGranted=NO;
            break;
        case AVAudioSessionRecordPermissionGranted:
            // mic access ok...
            accessGranted=YES;
            break;
        default:
            accessGranted=NO;
            // this should not happen.. maybe throw an exception.
            break;
    }
    
    return accessGranted;
    
    
   /* if([AppDelegate getAppDelegate].isOngoingCall ==YES){
        AVAudioSession *session1 = [AVAudioSession sharedInstance];
       // [session1 setCategory:AVAudioSessionCategoryAmbient  withOptions:AVAudioSessionCategoryOptionMixWithOthers | AVAudioSessionCategoryOptionInterruptSpokenAudioAndMixWithOthers|AVAudioSessionCategoryOptionAllowBluetooth error:nil];
       // [session1 setActive:YES error:nil];
        
        [session1 requestRecordPermission:^(BOOL granted) {
            if (granted)
            {
                // Microphone enabled code
            }
            else
            {
                // Microphone disabled code
            }
        }];
    }
    else{
        AVAudioSession *session1 = [AVAudioSession sharedInstance];
        
        if(SYSTEM_VERSION_GRATERTHAN_OR_EQUALTO(@"10.0")){
            //[session1 setCategory:AVAudioSessionCategoryPlayAndRecord  withOptions:AVAudioSessionCategoryOptionMixWithOthers|AVAudioSessionCategoryOptionDefaultToSpeaker|AVAudioSessionCategoryOptionAllowBluetoothA2DP error:nil];
        }
        else
        {
           // [session1 setCategory:AVAudioSessionCategoryPlayAndRecord  withOptions:AVAudioSessionCategoryOptionMixWithOthers|AVAudioSessionCategoryOptionDefaultToSpeaker|AVAudioSessionCategoryOptionAllowBluetooth error:nil];
        }
        
        //[session1 setActive:YES error:nil];
        
        [session1 requestRecordPermission:^(BOOL granted) {
            if (granted)
            {
                // Microphone enabled code
            }
            else
            {
                // Microphone disabled code
            }
        }];
    }*/
    
}


@end

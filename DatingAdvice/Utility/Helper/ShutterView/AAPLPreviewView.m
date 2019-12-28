/*
Copyright (C) 2015 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
Application preview view.
*/

@import AVFoundation;

#import "AAPLPreviewView.h"

@implementation AAPLPreviewView

+ (Class)layerClass
{
	return [AVCaptureVideoPreviewLayer class];
}

- (AVCaptureSession *)session
{
	AVCaptureVideoPreviewLayer *previewLayer = (AVCaptureVideoPreviewLayer *)self.layer;
//    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord
//                                         withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker | AVAudioSessionCategoryOptionMixWithOthers
//                                               error:nil];
	return previewLayer.session;
}

- (void)setSession:(AVCaptureSession *)session
{
    dispatch_async(dispatch_get_main_queue(), ^{
        AVCaptureVideoPreviewLayer *previewLayer = (AVCaptureVideoPreviewLayer *)self.layer;
        session.automaticallyConfiguresApplicationAudioSession = NO; // added to record video while music is playing in background.
        previewLayer.session = session;
    });
	
}

@end

//
//  ShuterView.h
//  tuurnt
//
//  Created by micheladrion on 9/18/15.
//  Copyright (c) 2015 fabricemishiki. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ShutterViewDelegate <NSObject>

- (void) captureImage;
- (void) captureVideo;
- (void) startRecordingVideo;
- (void) stopRecordingVideo;

@end

@interface ShuterView : UIView

@property (nonatomic, assign) float shuttingLength;
@property (nonatomic, assign) id<ShutterViewDelegate> delegate;

@end

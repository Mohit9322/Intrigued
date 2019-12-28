//
//  PermissionHandler.h
//  Tuurnt
//
//  Created by Shine Wave Solutions on 22/05/17.
//  Copyright © 2017 fabricemishiki. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PermissionHandler : NSObject

//ravi 22May
- (BOOL)isCameraAccessGranted;
-(BOOL)isMicrophoneAccessGranted;

@end

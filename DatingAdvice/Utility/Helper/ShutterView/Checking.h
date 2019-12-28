//
//  Checking.h
//  SnapChatMenu
//
//  Created by Umesh Sharma on 19/01/17.
//  Copyright © 2017 Umesh Shrama. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^GalleryPermissions) (BOOL);

@interface Checking : NSObject

+(void)isLibraryAccess:(GalleryPermissions)block;
+(void)isCameraAccess:(GalleryPermissions)permissionAccess;
@end

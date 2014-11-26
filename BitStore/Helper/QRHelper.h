//
//  QRHelper.h
//  BitStore
//
//  Created by Dylan Marriott on 16.06.14.
//  Copyright (c) 2014 Dylan Marriott. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface QRHelper : NSObject

+ (UIImage *)qrcode:(NSString *)dataString withDimension:(int)imageWidth;

@end

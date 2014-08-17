//
//  MessageHelper.m
//  BitStore
//
//  Created by Dylan Marriott on 29/06/14.
//  Copyright (c) 2014 Dylan Marriott. All rights reserved.
//

#import "MessageHelper.h"
#import "AppDelegate.h"

@implementation MessageHelper

+ (void)showMessage:(NSString *)message {
    AppDelegate* appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;

    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:appDelegate.window animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = message;
    hud.labelFont = [UIFont systemFontOfSize:14];
    hud.margin = 10.f;
    hud.yOffset = appDelegate.window.frame.size.height / 3 - 20;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:2];
}

@end

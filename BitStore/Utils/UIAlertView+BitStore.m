//
//  UIAlertView+BitStore.m
//  BitStore
//
//  Created by Dylan Marriott on 03.07.14.
//  Copyright (c) 2014 Dylan Marriott. All rights reserved.
//

#import "UIAlertView+BitStore.h"

@implementation UIAlertView (BitStore)

- (void)dismiss {
    [self dismissWithClickedButtonIndex:0 animated:YES];
}

@end

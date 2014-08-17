//
//  Color.m
//  BitStore
//
//  Created by Dylan Marriott on 13/07/14.
//  Copyright (c) 2014 Dylan Marriott. All rights reserved.
//

#import "Color.h"

@implementation Color

+ (UIColor *)mainTintColor {
    if ([[Environment environment] isEqualToString:@"TEST"]) {
        return [UIColor colorWithRed:0.63 green:0.00 blue:0.05 alpha:1.00];
    } else {
        return [UIColor colorWithRed:0.34 green:0.63 blue:0.87 alpha:1.00];
    }
}

@end

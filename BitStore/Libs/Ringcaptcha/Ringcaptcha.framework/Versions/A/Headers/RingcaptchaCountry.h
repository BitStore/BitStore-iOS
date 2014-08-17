//
//  RingcaptchaCountry.h
//  Ringcaptcha
//
//  Created by Martin on 3/4/14.
//  Copyright (c) 2014 Thrivecom LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>

@interface RingcaptchaCountry : NSObject {
    NSString *dialingCode;
    NSString *isoCode;
    NSString *name;
    UIImage *flag;
}

@property (strong, nonatomic) NSString* dialingCode;
@property (strong, nonatomic) NSString* isoCode;
@property (strong, nonatomic) NSString* name;
@property (strong, nonatomic) UIImage* flag;

@end

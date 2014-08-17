//
//  Ringcaptcha.h
//  Ringcaptcha
//
//  Created by Martin Cocaro on 2/11/13.
//  Copyright (c) 2013 Thrivecom LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>

#import "RingcaptchaVerification.h"
#import "RingcaptchaCountry.h"

@protocol RingcaptchaDelegate <NSObject>

@required

- (void) didFinishPhoneNumberVerification: (RingcaptchaVerification*) verification;

@optional

- (void) didFinishPhoneNumberVerificationWithCancel: (RingcaptchaVerification*) verification;

@end

#pragma mark - Callback blocks definitions
typedef void (^RingcaptchaSuccessBlock)(RingcaptchaVerification *verification);
typedef void (^RingcaptchaCancelBlock)(RingcaptchaVerification *verification);


@interface Ringcaptcha : NSObject {
}

//
//  verifyPhoneNumber: UI Controller to take control from and give back to
//  withAppKey: ${app_key} delivered by Ringcaptcha upon registration
//  andSecretKey: ${secret_key} delivered by Ringcaptcha upon registration
//
+ (RingcaptchaVerification*) verifyPhoneNumberWithAppKey:(NSString *)appKey
                                            andSecretKey:(NSString *)secretKey
                                        inViewController:(UIViewController *)viewController
                                                delegate: (id<RingcaptchaDelegate>) delegate
                                                 success:(RingcaptchaSuccessBlock)success
                                                  cancel:(RingcaptchaCancelBlock)cancel;

//  Returns all supported countries sorted by locale with isoCode, name and flag image
+ (NSMutableArray*) getSupportedCountries;

@end
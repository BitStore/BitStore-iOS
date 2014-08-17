//
//  RingcaptchaVerification.h
//  Ringcaptcha
//
//  Created by Martin Cocaro on 2/14/13.
//  Copyright (c) 2013 Thrivecom LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RingcaptchaVerification : NSObject

//Id identifying the verification process
@property (nonatomic) NSString* verificationId;

//Boolean value indicating whether the phone number has been verified successfully or not
@property (nonatomic) Boolean verificationSuccessful;

//String value representing verified phone number, correctly typed
@property (nonatomic, strong) NSString* phoneNumber;

//Error description in the event the verification is not successful
@property (nonatomic, strong) NSString* errorDescription;

@end

//
//  RingcaptchaAPI.h
//  Ringcaptcha
//
//  Created by Martin Cocaro on 4/4/13.
//  Copyright (c) 2013 Thrivecom LLC. All rights reserved.
//

/*
 Copyright (C) 2009-2011 Stig Brautaset. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 
 * Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 
 * Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation
 and/or other materials provided with the distribution.
 
 * Neither the name of the author nor the names of its contributors may be used
 to endorse or promote products derived from this software without specific
 prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import <Foundation/Foundation.h>

#import "RingcaptchaAPIDelegate.h"

typedef enum { SMS, VOICE } RingcaptchaService;
typedef enum { RCDisplayNavigation, RCDisplayPresentation } RingcaptchaDisplayMode;

/*
 * This interface represents Ringcaptcha API SDK implementation
 */
@interface RingcaptchaAPI : NSObject

/*
 * This method initializes the object with the specified appKey and apiKey
 *
 * They can be found in Ringcaptcha site directly.
 */
- (id) initWithAppKey: (NSString*) appKey andAPIKey: (NSString*) apiKey;

/*
 * This method sends a one-time expiring passcode to the phone number provided
 * via the communication method stipulated by the app key (e.g.: SMS, VOICE).
 *
 * The phone number must be formatted with the international formatting scheme (e.g.: +5491112345678, +123456789, etc)
 * The delegate will be called whenever the request is finished with or without error
 *
 * Note that the server will only accept requests from verified clients
 */
- (void) sendCaptchaCodeToNumber: (NSString*) phoneNumber withService: (RingcaptchaService) service delegate:(id<RingcaptchaAPIDelegate>) sender;

/*
 * This method checks the passcode submitted is valid for the token used to send it
 * with the app key selected on the previous method.
 *
 * The secret key is used to ensure the entity who submitted the initial request is
 * the same that attempts to verify
 *
 * The delegate will be called whenever the request is finished with or without error
 */
- (void) checkCode: (NSString *) code delegate: (id<RingcaptchaAPIDelegate>) sender;

/*
 * This method verifies the passcode submitted is valid for the token used to send it
 * with the app key selected on the previous method.
 *
 * The secret key is used to ensure the entity who submitted the initial request is 
 * the same that attempts to verify
 *
 * The delegate will be called whenever the request is finished with or without error
 */
- (void) verifyCaptchaWithCode: (NSString *) code delegate: (id<RingcaptchaAPIDelegate>) sender;

/*
 * This method returns TRUE if there is a valid token for the app key, meaning the user has requested a PIN
 * and is still valid. Will return FALSE if there is not a valid token for the app key.
 */
- (BOOL) isTokenActive;

@end

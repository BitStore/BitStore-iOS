//
//  RingcaptchaAPIDelegate.h
//  RingcaptchaAPI
//
//  Created by Martin Cocaro on 4/9/13.
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

#import "RingcaptchaResponse.h"

/*
 * This protocol represents the methods invoked by the API SDK implementation
 */
@protocol RingcaptchaAPIDelegate <NSObject>

@optional

/*
 * This method is called when the communication with the server API was
 * established correctly and a response received from the server for sending the one-time
 * code to the phone number requested via the communication method estipulated in the app key.
 *
 * RingcaptchaResponse object will be populated with the data received from the server
 * such as: token, serviceType (e.g.: SMS, VOICE), status (e.g.: SUCCESS, ERROR),
 * errorMessage (e.g.: ERROR_INVALID_PIN_CODE, etc), phone (e.g.: +123456789), 
 * transactionId (unique id for this verification transaction) and timeout (used when attempts 
 * have been blocked for X time)
 */
- (void) didFinishCodeRequest: (RingcaptchaResponse*) rsp;

/*
 * This method is called when there is a communication error with the server API for sending 
 * the one-time code to the phone number requested via the communication method estipulated in the 
 * app key.
 *
 * NSError object will be populated with the NSLocalizedDescriptionKey and NSUnderlyingErrorKey
 * with their corresponding exceptions user info and description.
 */
- (void) didFinishCodeRequestWithError: (NSError*) err;

/*
 * This method is called when the communication with the server API was
 * established correctly and a response received from the server for checking the one-time
 * code to the phone number requested via the communication method estipulated in the app key.
 *
 * RingcaptchaResponse object will be populated with the status data received from the server
 * such as: status (e.g.: SUCCESS, ERROR), errorMessage (e.g.: ERROR_INVALID_PIN_CODE, etc) 
 * and timeout (used when attempts have been blocked for X time)
 */
- (void) didFinishCheckRequest: (RingcaptchaResponse*) rsp;

/*
 * This method is called when there is a communication error with the server API for checking
 * the one-time code to the phone number requested via the communication method estipulated in the
 * app key and secret key/api key.
 *
 * NSError object will be populated with the NSLocalizedDescriptionKey and NSUnderlyingErrorKey
 * with their corresponding exceptions user info and description.
 */
- (void) didFinishCheckRequestWithError: (NSError*) err;

/*
 * This method is called when the communication with the server API was
 * established correctly and a response received from the server for verifying the one-time
 * code to the phone number requested via the communication method estipulated in the app key.
 *
 * RingcaptchaResponse object will be populated with the data received from the server
 * such as: token, serviceType (e.g.: SMS, VOICE), status (e.g.: NEW, SUCCESS, ERROR),
 * errorMessage (e.g.: ERROR_INVALID_PIN_CODE, etc), phone (e.g.: +123456789),
 * transactionId (unique id for this verification transaction) and timeout (used when attempts
 * have been blocked for X time)
 */
- (void) didFinishVerifyRequest: (RingcaptchaResponse*) rsp;

/*
 * This method is called when there is a communication error with the server API for verifying
 * the one-time code to the phone number requested via the communication method estipulated in the
 * app key and secret key.
 *
 * NSError object will be populated with the NSLocalizedDescriptionKey and NSUnderlyingErrorKey
 * with their corresponding exceptions user info and description.
 */
- (void) didFinishVerifyRequestWithError: (NSError*) err;


@end
//
//  RingcaptchaResponse.h
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

@interface RingcaptchaResponse : NSObject

/*
 * A string representing the expirable token used to send a one-time
 * passcode to a phone number via any communication method
 *
 * This token expires after 15 minutes of no use.
 */
@property (strong, nonatomic) NSString* token;

/*
 * A string representing the type of communication used to send the
 * one-time passcode.
 *
 * Options are: SMS, VOICE.
 */
@property (strong, nonatomic) NSString* serviceType;

/*
 * A string representing the status of the request whether it finished
 * successfully or there was an error
 *
 * Options are: SUCCESS, ERROR
 */
@property (strong, nonatomic) NSString* status;

/*
 * A string populated only during ERROR status representing error messages
 * returned by the server
 *
 * Options are:
 *
 *  - ERROR_INVALID_NUMBER_LENGTH: returned when phone number has insufficient or excessive numbers
 *  - ERROR_INVALID_NUMBER: returned when the phone number is invalid for the country or
 *                          communication method for the app key
 *  - ERROR_COUNTRY_NOT_SUPPORTED: returned when the country for that phone number is not supported
 *  - ERROR_INVALID_SITE_KEY: returned when the app key is incorrect
 *  - ERROR_INVALID_DOMAIN: returned when the request is made from another application than
 *                          specified in ringcapthca.com
 *  - ERROR_INVALID_PIN_CODE: returned when the submitted one-time passcode does not match
 *                            the number sent to the phone number
 *  - ERROR_INVALID_SECRET_KEY: returned when the secret key does not match our records for the 
 *                              app key used
 *  - ERROR_INVALID_SESSION: returned when the session token does not exist
 *  - ERROR_SESSION_EXPIRED: returned when the session has expired. In this case, we recommend 
 *                           giving the option to try again to the user
 *  - ERROR_MAX_ATTEMPTS_REACHED: returned when the session token has exceeded the maximum amount of attempts
 */
@property (strong, nonatomic) NSString* errorMessage;

/*
 * A string representing the phone number in international format that was sent the one-time
 * passcode via the communication established in the app key
 */
@property (strong, nonatomic) NSString* phone;

/*
 * A unique string identifying this verification transaction. Store this number in your database
 * for future reconcilliation should there be an error.
 */
@property (strong, nonatomic) NSString* transactionId;

/*
 * A number representing the amount of seconds before another request can be made
 */
@property (nonatomic) NSDate* timeout;

@end

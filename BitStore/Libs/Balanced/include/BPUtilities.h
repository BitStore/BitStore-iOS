//
//  BPUtilities.h
//  Balanced
//
//  Created by Ben Mills on 3/14/13.
//

#import <Foundation/Foundation.h>

@interface BPUtilities : NSObject

+ (NSDictionary *)capabilities;
+ (NSString *)getIPAddress;
+ (NSString *)getMACAddress;
+ (int)getTimezoneOffset;
+ (NSString *)userAgentString;

@end

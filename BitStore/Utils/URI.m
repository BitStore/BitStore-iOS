//
//  URI.m
//  BitStore
//
//  Created by Dylan Marriott on 08.08.14.
//  Copyright (c) 2014 Dylan Marriott. All rights reserved.
//

#import "URI.h"

@implementation URI

- (id)initWithString:(NSString *)string {
    if (self = [super init]) {
        NSString* query = [string substringFromIndex:[@"bitcoin:" length]];
        NSRange queryStart = [query rangeOfString:@"?"];
        if (queryStart.length > 0) {
            _address = [query substringToIndex:queryStart.location];
            
            NSRange amountStart = [query rangeOfString:@"amount="];
            if (amountStart.length > 0) {
                NSString* amountAndMore = [query substringFromIndex:amountStart.location + 7];
                NSRange additionalQueryStart = [amountAndMore rangeOfString:@"&"];
                if (additionalQueryStart.length > 0) {
                    // more parms in query, cut of
                    amountAndMore = [amountAndMore substringToIndex:additionalQueryStart.location];
                }
                _amount = amountAndMore;
            }
        } else {
            _address = query;
        }
    }
    return self;
}

@end

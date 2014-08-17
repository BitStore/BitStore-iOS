//
//  NSString+Satoshi.m
//  BitStore
//
//  Created by Dylan Marriott on 29/06/14.
//  Copyright (c) 2014 Dylan Marriott. All rights reserved.
//

#import "NSString+Satoshi.h"
#import "Unit.h"
#import "ExchangeHelper.h"

@implementation NSString (Satoshi)

- (BTCSatoshi)satoshi {
    Unit* unit = [[ExchangeHelper instance] currentUnit];
    double factor = unit.factor;
    return [self satoshiWithFactor:factor];
}

- (BTCSatoshi)satoshiWithFactor:(double)factor {
    NSString* string = [self stringByReplacingOccurrencesOfString:@"," withString:@"."];
    long long satoshi = 0;
    NSRange delimiter = [string rangeOfString:@"."];
    if (delimiter.length == 0) {
        // no . found
        satoshi = string.longLongValue * factor;
    } else {
        NSString* full = [string substringToIndex:delimiter.location];
        NSString* fraction = [string substringFromIndex:delimiter.location + 1];
        satoshi = full.longLongValue * factor;
        
        Unit* unit = [[ExchangeHelper instance] currentUnit];
        if (fraction.length > unit.maxFraction) {
            fraction = [fraction substringToIndex:unit.maxFraction]; // 0.00000001 is the minimum
        }
        for (int i = 0; i < fraction.length; i++) {
            unichar c = [fraction characterAtIndex:i];
            NSString* s = [NSString stringWithCharacters:&c length:1];
            double e = factor / pow(10,i+1);
            satoshi += (int)(s.intValue * e);
        }
    }
    
    return satoshi;
}

- (double)btc {
    return [self satoshi] / 100000000.0f;
}

- (double)cur {
    Unit* unit = [[ExchangeHelper instance] currentUnit];
    double factor = unit.factor;
    return [self satoshi] / factor;
}

@end

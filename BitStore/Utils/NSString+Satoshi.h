//
//  NSString+Satoshi.h
//  BitStore
//
//  Created by Dylan Marriott on 29/06/14.
//  Copyright (c) 2014 Dylan Marriott. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Satoshi)

- (BTCSatoshi)satoshi;
- (BTCSatoshi)satoshiWithFactor:(double)factor;
- (double)btc;
- (double)cur;

@end

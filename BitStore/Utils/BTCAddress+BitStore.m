//
//  BTCAddress+BitStore.m
//  BitStore
//
//  Created by Dylan Marriott on 23.09.14.
//  Copyright (c) 2014 Dylan Marriott. All rights reserved.
//

#import "BTCAddress+BitStore.h"

@implementation BTCAddress (BitStore)

- (BOOL)isPrivateAddress {
    return [self isKindOfClass:[BTCPrivateKeyAddress class]];
}

- (BOOL)isPublicAddress {
    return [self isKindOfClass:[BTCPublicKeyAddress class]];
}

@end

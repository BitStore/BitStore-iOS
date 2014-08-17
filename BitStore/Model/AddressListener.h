//
//  AddressListener.h
//  BitStore
//
//  Created by Dylan Marriott on 01.02.14.
//  Copyright (c) 2014 Dylan Marriott. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Address;

@protocol AddressListener <NSObject>

- (void)addressChanged:(Address *)address;

@end

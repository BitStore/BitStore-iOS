//
//  AddressHelper.h
//  BitStore
//
//  Created by Dylan Marriott on 08.02.14.
//  Copyright (c) 2014 Dylan Marriott. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Address;
@protocol AddressHelperListener;

@interface AddressHelper : NSObject

+ (AddressHelper *)instance;
- (NSArray *)addresses;
- (Address *)defaultAddress;
- (void)setDefaultAddress:(int)index;

- (void)addAddress:(Address *)address;
- (void)removeAddress:(Address *)address;

- (void)addAddressHelperListener:(id<AddressHelperListener>)listener;

@end

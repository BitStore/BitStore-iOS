//
//  Address.h
//  BitStore
//
//  Created by Dylan Marriott on 01.02.14.
//  Copyright (c) 2014 Dylan Marriott. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AddressListener;

@interface Address : NSObject <NSCoding>

@property (nonatomic, strong) NSString* address;
@property (nonatomic, strong) NSString* label;
@property (nonatomic, assign) long long total;
@property (nonatomic, strong) NSArray* transactions;

- (void)addAddressListener:(id<AddressListener>)listener;
- (void)refresh;
- (void)refresh:(BOOL)showError;
- (void)startUpdate:(int)refreshRate;
- (void)stopUpdate;

@end

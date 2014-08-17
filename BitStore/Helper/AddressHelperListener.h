//
//  AddressHelperListener.h
//  BitStore
//
//  Created by Dylan Marriott on 25.07.14.
//  Copyright (c) 2014 Dylan Marriott. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AddressHelperListener <NSObject>

- (void)defaultAddressChanged:(Address *)address;

@end

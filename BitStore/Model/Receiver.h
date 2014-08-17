//
//  Receiver.h
//  BitStore
//
//  Created by Dylan Marriott on 02/02/14.
//  Copyright (c) 2014 Dylan Marriott. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Receiver : NSObject <NSCoding>

@property (nonatomic, strong) NSString* address;
@property (nonatomic, assign) long long amount;

@end

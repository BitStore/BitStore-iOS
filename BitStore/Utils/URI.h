//
//  URI.h
//  BitStore
//
//  Created by Dylan Marriott on 08.08.14.
//  Copyright (c) 2014 Dylan Marriott. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface URI : NSObject

- (id)initWithString:(NSString *)string;

@property (nonatomic, readonly) NSString* address;
@property (nonatomic, readonly) NSString* amount;

@end

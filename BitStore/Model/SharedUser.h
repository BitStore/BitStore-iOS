//
//  SharedUser.h
//  BitStore
//
//  Created by Dylan Marriott on 23/09/14.
//  Copyright (c) 2014 Dylan Marriott. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SharedUser : NSObject

@property (nonatomic) NSString* todayCurrency;
@property (nonatomic) NSNumber* cachedPrice;
@property (nonatomic) NSString* address;

@end

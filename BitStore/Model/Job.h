//
//  Job.h
//  BitStore
//
//  Created by Dylan Marriott on 20.07.14.
//  Copyright (c) 2014 Dylan Marriott. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Job : NSObject <NSCoding>

- (id)initWithUrl:(NSString *)url;

@property (nonatomic) NSString* url;

@end

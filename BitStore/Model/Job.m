//
//  Job.m
//  BitStore
//
//  Created by Dylan Marriott on 20.07.14.
//  Copyright (c) 2014 Dylan Marriott. All rights reserved.
//

#import "Job.h"

@implementation Job

- (id)initWithUrl:(NSString *)url {
    if (self = [super init]) {
        self.url = url;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.url = [aDecoder decodeObjectForKey:@"url"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.url forKey:@"url"];
}

@end

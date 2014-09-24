//
//  SharedUser.m
//  BitStore
//
//  Created by Dylan Marriott on 23/09/14.
//  Copyright (c) 2014 Dylan Marriott. All rights reserved.
//

#import "SharedUser.h"
#import "UserDefaults.h"

@implementation SharedUser

- (id)init {
    if (self = [super init]) {
        self.todayCurrency = @"USD";
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.todayCurrency = [aDecoder decodeObjectForKey:@"todayCurrency"];
        self.cachedPrice = [aDecoder decodeObjectForKey:@"cachedPrice"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.todayCurrency forKey:@"todayCurrency"];
    [encoder encodeObject:self.cachedPrice forKey:@"cachedPrice"];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"currency: %@", self.todayCurrency];
}

@end

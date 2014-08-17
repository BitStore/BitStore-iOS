//
//  WeakRef.m
//  BitStore
//
//  Created by Dylan Marriott on 25.07.14.
//  Copyright (c) 2014 Dylan Marriott. All rights reserved.
//

#import "WeakRef.h"

@implementation WeakRef

- (id)initWithObject:(id)object {
    self.ref = object;
    return self;
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    invocation.target = self.ref;
    [invocation invoke];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    return [self.ref methodSignatureForSelector:sel];
}

- (NSString *)description {
    return [[self.ref class] description];
}

@end
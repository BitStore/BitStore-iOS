//
//  DMWeakRef.m
//  Pods
//
//  Created by Dylan Marriott on 04/11/14.
//
//

#import "DMWeakRef.h"

@implementation DMWeakRef

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

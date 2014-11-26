//
//  DMDummyJob.m
//  Pods
//
//  Created by Dylan Marriott on 03/11/14.
//
//

#import "DMDummyJob.h"

@implementation DMDummyJob {
    CompletionBlock _completion;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
    
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {

}

- (void)executeWithCompletion:(CompletionBlock)completion {
    _completion = completion;
    NSLog(@"Performing dummy job...");
    [self performSelector:@selector(finish) withObject:nil afterDelay:1.0];
}

- (void)finish {
    NSLog(@"Finished dummy job. (failed)");
    _completion(NO);
}

@end

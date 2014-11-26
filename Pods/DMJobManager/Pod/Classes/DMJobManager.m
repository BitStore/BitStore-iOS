//
//  DMJobManager.m
//  Pods
//
//  Created by Dylan Marriott on 03/11/14.
//
//

#import "DMJobManager.h"
#import "DMJob.h"
#import <objc/runtime.h>

static DMJobManager* instance;

@implementation DMJobManager {
    NSUserDefaults* _defaults;
    NSMutableArray* _queue;
    BOOL _running;
}

+ (void)startManager {
    NSAssert(!instance, @"DMJobManager already started.");
    NSAssert([NSThread isMainThread], @"Not main thread.");
    instance = [[DMJobManager alloc] init];
}

+ (void)postJob:(id<DMJob>)job {
    NSAssert(instance, @"DMJobManager not started.");
    [instance performSelectorOnMainThread:@selector(postJob:) withObject:job waitUntilDone:NO];
}

+ (NSUInteger)pendingJobs {
    return [instance pendingJobs];
}

- (id)init {
    if (self = [super init]) {
        _defaults = [NSUserDefaults standardUserDefaults];
        _queue = [[NSMutableArray alloc] init];
        for (id<DMJob> job in (NSArray *)[self codableObjectForKey:@"DMJobManager_jobs"]) {
            [_queue addObject:job];
        }
        if (_queue.count > 0 && !_running) {
            [self processQueue];
        }
    }
    return self;
}

- (void)postJob:(id<DMJob>)job {
    if (![_queue containsObject:job]) {
        [_queue addObject:job];
        [self storeState];
        if (!_running) {
            [self processQueue];
        }
    }
}

- (void)processQueue {
    _running = YES;
    id<DMJob> job = [_queue objectAtIndex:0];
    [job executeWithCompletion:^(BOOL success) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [_queue removeObjectAtIndex:0];
            [self storeState];
            
            if (_queue.count > 0) {
                // new objects in queue
                [self processQueue];
            } else {
                _running = NO;
            }
            
            if (!success) {
                NSUInteger retryDelay = 10;
                if ([job respondsToSelector:@selector(retryDelay)]) {
                    retryDelay = [job retryDelay];
                }
                if ([job respondsToSelector:@selector(willRetry)]) {
                    [job willRetry];
                }
                [self performSelector:@selector(postJob:) withObject:job afterDelay:retryDelay];
            }
        });
    }];
}

- (NSUInteger)pendingJobs {
    return _queue.count;
}

- (void)storeState {
    [self setCodableObject:_queue forKey:@"DMJobManager_jobs"];
}

- (void)setCodableObject:(id<NSCoding>)object forKey:(NSString *)key {
    NSData* encoded = [NSKeyedArchiver archivedDataWithRootObject:object];
    [_defaults setObject:encoded forKey:key];
    [_defaults synchronize];
}

- (id<NSCoding>)codableObjectForKey:(NSString *)key {
    NSData* encoded = [_defaults objectForKey:key];
    id<NSCoding> ret = [NSKeyedUnarchiver unarchiveObjectWithData:encoded];
    return ret;
}

@end
//
//  JobHelper.m
//  BitStore
//
//  Created by Dylan Marriott on 20.07.14.
//  Copyright (c) 2014 Dylan Marriott. All rights reserved.
//

#import "JobHelper.h"
#import "Job.h"
#import "RequestHelper.h"
#import "UserDefaults.h"

static JobHelper* sharedHelper;

@implementation JobHelper {
    NSMutableArray* _queue;
    BOOL _running;
}

+ (void)initialize {
    [super initialize];
    sharedHelper = [[JobHelper alloc] init];
}

+ (JobHelper *)instance {
    return sharedHelper;
}

- (id)init {
    if (self = [super init]) {
	    _queue = [[NSMutableArray alloc] init];
		for (Job* job in [UserDefaults instance].jobs) {
			[_queue addObject:job];
		}
		if (_queue.count > 0 && !_running) {
			[self processQueue];
		}
	}
    return self;
}

- (void)postJob:(Job *)job {
    [_queue addObject:job];
    [self storeState];
    if (!_running) {
        [self processQueue];
    }
}

- (void)processQueue {
    _running = YES;
    Job* job = [_queue objectAtIndex:0];
    RequestHelper* rh = [[RequestHelper alloc] init];
	[rh startRequestWithUrl:job.url completion:^(BOOL success, NSData* data) {
		if (success) {
			[_queue removeObjectAtIndex:0];
			[self storeState];
			if (_queue.count > 0) {
				// new objects in queue
				[self processQueue];
			} else {
				_running = NO;
			}
		} else {
			// try again in 5 seconds
			[self performSelector:@selector(processQueue) withObject:nil afterDelay:5.0];
		}
	}];
}

- (void)storeState {
    [UserDefaults instance].jobs = _queue;
}

@end

//
//  DMJobManager.h
//  Pods
//
//  Created by Dylan Marriott on 03/11/14.
//
//

#import <Foundation/Foundation.h>
#import "DMJob.h"
#import "DMDummyJob.h"
#import "DMHTTPRequestJob.h"

/**
 *  DMJobManager receives new jobss and processes the job queue
 */
@interface DMJobManager : NSObject

/**
 *  This call has to be done before the manager can be used. Will start processing persisted jobs.
 */
+ (void)startManager;

/**
 *  Add a new job to the queue.
 *
 *  @param job a job
 */
+ (void)postJob:(id<DMJob>)job;

/**
 *  Returns the number of jobs in the queue.
 *
 *  @return number of jobs in the queue
 */
+ (NSUInteger)pendingJobs;

@end

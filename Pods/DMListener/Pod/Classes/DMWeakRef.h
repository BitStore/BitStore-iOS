//
//  DMWeakRef.h
//  Pods
//
//  Created by Dylan Marriott on 04/11/14.
//
//

#import <Foundation/Foundation.h>

@interface DMWeakRef : NSProxy

@property (nonatomic, weak) id ref;
- (id)initWithObject:(id)object;

@end

//
//  ScanNavigationController.h
//  BitStore
//
//  Created by Dylan Marriott on 20.07.14.
//  Copyright (c) 2014 Dylan Marriott. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ScanDelegate;

@interface ScanNavigationController : UINavigationController

- (id)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithScanDelegate:(id<ScanDelegate>)delegate;
- (void)reset;

@end

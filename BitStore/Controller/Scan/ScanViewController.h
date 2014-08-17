//
//  ScanViewController.h
//  BitStore
//
//  Created by Dylan Marriott on 16.06.14.
//  Copyright (c) 2014 Dylan Marriott. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ScanDelegate;

@interface ScanViewController : UIViewController

@property (nonatomic, weak) id<ScanDelegate> delegate;

- (void)reset;

@end

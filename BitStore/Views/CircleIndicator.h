//
//  CircleIndicator.h
//  BitStore
//
//  Created by Dylan Marriott on 25/09/14.
//  Copyright (c) 2014 Dylan Marriott. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CircleIndicator : UIView

- (id)initWithCircles:(int)numberOfCircles;
- (void)setFilledCircles:(int)filledCircles;

- (id)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithFrame:(CGRect)frame UNAVAILABLE_ATTRIBUTE;

@end

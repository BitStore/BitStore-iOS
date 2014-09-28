//
//  CircleIndicator.m
//  BitStore
//
//  Created by Dylan Marriott on 25/09/14.
//  Copyright (c) 2014 Dylan Marriott. All rights reserved.
//

#import "CircleIndicator.h"

static CGFloat circleRadius = 4;

@implementation CircleIndicator {
    NSMutableArray* _circleViews;
    int _filledCircles;
}

- (id)initWithCircles:(int)numberOfCircles {
    if (self = [super init]) {
        _circleViews = [NSMutableArray array];
        for (int i = 0; i < numberOfCircles; i++) {
            UIView* circle = [[UIView alloc] init];
            circle.layer.cornerRadius = circleRadius;
            circle.layer.borderColor = [UIColor colorWithWhite:0.6 alpha:1.0].CGColor;
            circle.layer.borderWidth = 0.5f;
            circle.backgroundColor = [UIColor clearColor];
            [_circleViews addObject:circle];
            [self addSubview:circle];
        }
    }
    return self;
}

- (void)setFilledCircles:(int)filledCircles {
    NSAssert(filledCircles <= _circleViews.count, @"Can't fill more circles than provided.");
    NSAssert(filledCircles >= 0, @"Can't fill < 0 circles.");
    _filledCircles = filledCircles;
    [self updateViews];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [self updateViews]; // table view cell fix
}

- (void)updateViews {
    for (int i = 0; i < _filledCircles; i++) {
        UIView* circle = [_circleViews objectAtIndex:_circleViews.count - i - 1];
        circle.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1.0];
    }
    for (int i = _filledCircles; i < _circleViews.count; i++) {
        UIView* circle = [_circleViews objectAtIndex:_circleViews.count - i - 1];
        circle.backgroundColor = [UIColor clearColor];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat space = (self.bounds.size.width - (circleRadius * 2 * _circleViews.count)) / (_circleViews.count - 1);
    for (int i = 0; i < _circleViews.count; i++) {
        UIView* circle = [_circleViews objectAtIndex:i];
        circle.frame = CGRectMake(i * (space + circleRadius * 2), self.bounds.size.height / 2 - circleRadius, circleRadius * 2, circleRadius * 2);
    }
}



@end

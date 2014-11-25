//
//  BEMLine.h
//  SimpleLineGraph
//
//  Created by Bobo on 12/27/13. Updated by Sam Spencer on 1/11/14.
//  Copyright (c) 2013 Boris Emorine. All rights reserved.
//  Copyright (c) 2014 Sam Spencer.
//


#if __has_feature(objc_modules)
    // We recommend enabling Objective-C Modules in your project Build Settings for numerous benefits over regular #imports
    @import Foundation;
    @import UIKit;
    @import CoreGraphics;
#else
    #import <Foundation/Foundation.h>
    #import <UIKit/UIKit.h>
    #import <CoreGraphics/CoreGraphics.h>
#endif

/// The type of animation used to display the graph
typedef NS_ENUM(NSInteger, BEMLineAnimation) {
    /// The draw animation draws the lines from left to right and bottom to top.
    BEMLineAnimationDraw,
    /// The fade animation fades in the lines from 0% opaque to 100% opaque (based on the \p lineAlpha property).
    BEMLineAnimationFade,
    /// No animation is used to display the graph
    BEMLineAnimationNone
};



/// Class to draw the line of the graph
@interface BEMLine : UIView



//----- POINTS -----//

/// The previous point. Necessary for Bezier curve
@property (assign, nonatomic) CGPoint P0;

/// The starting point of the line
@property (assign, nonatomic) CGPoint P1;

/// The ending point of the line
@property (assign, nonatomic) CGPoint P2;

/// The next point. Necessary for Bezier curve
@property (assign, nonatomic) CGPoint P3;

/// All of the Y-axis values for the points
@property (nonatomic) NSArray *arrayOfPoints;

/// All of the X-Axis coordinates used to draw vertical lines through
@property (nonatomic) NSArray *arrayOfVerticalRefrenceLinePoints;

/// All of the Y-Axis coordinates used to draw horizontal lines through
@property (nonatomic) NSArray *arrayOfHorizontalRefrenceLinePoints;

/// All of the point values
@property (nonatomic) NSArray *arrayOfValues;

/** Draw thin, translucent, reference lines using the provided X-Axis and Y-Axis coordinates.
 @see Use \p arrayOfVerticalRefrenceLinePoints to specify vertical reference lines' positions. Use \p arrayOfHorizontalRefrenceLinePoints to specify horizontal reference lines' positions. */
@property (nonatomic) BOOL enableRefrenceLines;

/** Draw a thin, translucent, frame on the edge of the graph to separate it from the labels on the X-Axis and the Y-Axis. */
@property (nonatomic) BOOL enableRefrenceFrame;



//----- COLORS -----//

/// The line color. A single, solid color which is applied to the entire line. If the \p gradient property is non-nil this property will be ignored.
@property (strong, nonatomic) UIColor *color;

/// The color of the area above the line, inside of its superview
@property (strong, nonatomic) UIColor *topColor;

/// The color of the area below the line, inside of its superview
@property (strong, nonatomic) UIColor *bottomColor;

@property (strong, nonatomic) UIColor *xAxisBackgroundColor;

@property (nonatomic) CGFloat xAxisBackgroundAlpha;

/** A color gradient to be applied to the line. If this property is set, it will mask (override) the \p color property.
 @todo This property is non-functional at this point in time. It only serves as a marker for further implementation. */
@property (assign, nonatomic) CGGradientRef gradient;



//----- ALPHA -----//

/// The line alpha
@property (nonatomic) float lineAlpha;

/// The alpha value of the area above the line, inside of its superview
@property (nonatomic) float topAlpha;

/// The alpha value of the area below the line, inside of its superview
@property (nonatomic) float bottomAlpha;



//----- SIZE -----//

/// The width of the line
@property (nonatomic) float lineWidth;



//----- BEZIER CURVE -----//

/// The line is drawn with smooth curves rather than straight lines when set to YES.
@property (nonatomic) BOOL bezierCurveIsEnabled;



//----- ANIMATION -----//

/// The entrance animation period in seconds.
@property (nonatomic) CGFloat animationTime;

/// The type of entrance animation.
@property (nonatomic) BEMLineAnimation animationType;



//----- FRAME -----//

/// The offset dependant on the size of the labels to create the frame
@property (nonatomic) CGFloat frameOffset;



@end

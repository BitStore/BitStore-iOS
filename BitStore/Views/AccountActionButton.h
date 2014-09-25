//
//  AccountActionButton.h
//  BitStore
//
//  Created by Dylan Marriott on 06.07.14.
//  Copyright (c) 2014 Dylan Marriott. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AccountActionButton : UIButton

@property (nonatomic) CGFloat padding;

- (id)initWithTitle:(NSString *)title image:(UIImage *)image selectedImage:(UIImage *)selectedImage;
- (void)setTintColor:(UIColor *)tintColor;
- (void)setSelectedTintColor:(UIColor *)selectedTintColor;

- (id)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (id)initWithFrame:(CGRect)frame UNAVAILABLE_ATTRIBUTE;

@end

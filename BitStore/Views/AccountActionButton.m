//
//  AccountActionButton.m
//  BitStore
//
//  Created by Dylan Marriott on 06.07.14.
//  Copyright (c) 2014 Dylan Marriott. All rights reserved.
//

#import "AccountActionButton.h"

@implementation AccountActionButton

- (id)initWithTitle:(NSString *)title image:(UIImage *)image selectedImage:(UIImage *)selectedImage {
    if (self = [super init]) {
        [self setImage:[image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
		UIImage* selected = [selectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
		[self setImage:selected forState:UIControlStateHighlighted];
		[self setImage:selected forState:UIControlStateSelected];
		[self setTitle:title forState:UIControlStateNormal];
        [self setTintColor:[UIColor colorWithWhite:0.6 alpha:1.0]];
        [self setSelectedTintColor:[UIColor colorWithWhite:0.5 alpha:1.0]];
		self.titleLabel.font = [UIFont systemFontOfSize:12];
    }
    return self;
}

- (void)setTintColor:(UIColor *)tintColor {
    [super setTintColor:tintColor];
    [self setTitleColor:tintColor forState:UIControlStateNormal];
}

- (void)setSelectedTintColor:(UIColor *)selectedTintColor {
    [self setTitleColor:selectedTintColor forState:UIControlStateHighlighted];
    [self setTitleColor:selectedTintColor forState:UIControlStateSelected];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // Move the image to the top and center it horizontally
    CGRect imageFrame = self.imageView.frame;
    imageFrame.origin.y = 0;
    imageFrame.origin.x = (self.frame.size.width / 2) - (imageFrame.size.width / 2);
    self.imageView.frame = CGRectIntegral(imageFrame);
    
    // Adjust the label size to fit the text, and move it below the image
    CGRect titleLabelFrame = self.titleLabel.frame;
    CGSize labelSize = [self.titleLabel.text boundingRectWithSize:CGSizeMake(self.frame.size.width, CGFLOAT_MAX)
                                         options:NSStringDrawingUsesLineFragmentOrigin
                                      attributes:@{NSFontAttributeName:self.titleLabel.font}
                                         context:nil].size;
    
    titleLabelFrame.size.width = labelSize.width;
    titleLabelFrame.size.height = labelSize.height;
    titleLabelFrame.origin.x = (self.frame.size.width / 2) - (labelSize.width / 2);
    titleLabelFrame.origin.y = self.imageView.frame.origin.y + self.imageView.frame.size.height + self.padding;
    self.titleLabel.frame = CGRectIntegral(titleLabelFrame);
}

- (void)setEnabled:(BOOL)enabled {
    [super setEnabled:enabled];
    if (enabled) {
        [self setTitleColor:[UIColor colorWithWhite:0.6 alpha:1.0] forState:UIControlStateNormal];
    } else {
        [self setTitleColor:[UIColor colorWithWhite:0.8 alpha:1.0] forState:UIControlStateNormal];
    }
}

@end

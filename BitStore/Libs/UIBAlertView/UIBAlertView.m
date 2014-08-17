//
//  UIBAlertView.m
//  UIBAlertView
//
//  Created by Stav Ashuri on 1/31/13.
//  Copyright (c) 2013 Stav Ashuri. All rights reserved.
//

#import "UIBAlertView.h"

@interface UIBAlertView() <UIAlertViewDelegate>

@property (strong, nonatomic) UIBAlertView *strongAlertReference;

@property (copy, nonatomic) UIBAlertDismissedHandler activeDismissHandler;

@property (strong, nonatomic) UIAlertView *activeAlert;

@end

@implementation UIBAlertView

#pragma mark - Public (Initialization)

- (id)initWithTitle:(NSString *)aTitle message:(NSString *)aMessage cancelButtonTitle:(NSString *)aCancelTitle otherButtonTitles:(NSString *)otherTitles,... {
    self = [super init];
    if (self) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:aTitle message:aMessage delegate:self cancelButtonTitle:aCancelTitle otherButtonTitles:otherTitles, nil];
        if (otherTitles != nil) {
            va_list args;
            va_start(args, otherTitles);
            NSString * title = nil;
            while((title = va_arg(args,NSString*))) {
                [alert addButtonWithTitle:title];
            }
            va_end(args);
        }
        self.activeAlert = alert;
    }
    return self;
}

#pragma mark - Public (Functionality)

- (void)showWithDismissHandler:(UIBAlertDismissedHandler)handler {
    self.activeDismissHandler = handler;
    self.strongAlertReference = self;
    [self.activeAlert show];
}

#pragma mark UIAlertView passthroughs

- (UIAlertViewStyle)alertViewStyle
{
    return self.activeAlert.alertViewStyle;
}

- (void)setAlertViewStyle:(UIAlertViewStyle)alertViewStyle
{
	self.activeAlert.alertViewStyle = alertViewStyle;
}

- (UITextField *)textFieldAtIndex:(NSInteger)textFieldIndex
{
	return [self.activeAlert textFieldAtIndex:textFieldIndex];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (self.activeDismissHandler) {
        self.activeDismissHandler(buttonIndex, [alertView buttonTitleAtIndex:buttonIndex], buttonIndex == alertView.cancelButtonIndex);
    }
    self.strongAlertReference = nil;
}

- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView
{
    if (self.shouldEnableFirstOtherButtonHandler)
        return self.shouldEnableFirstOtherButtonHandler();

    return YES;
}

@end

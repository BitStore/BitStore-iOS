//
//  TodayViewController.m
//  BitStoreToday
//
//  Created by Dylan Marriott on 22/09/14.
//  Copyright (c) 2014 Dylan Marriott. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>
#import "SharedUser.h"
#import "AccountActionButton.h"

@interface TodayViewController () <NCWidgetProviding>

@end

@implementation TodayViewController {
    SharedUser* _user;
    UILabel* _priceLabel;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _user = [[SharedUser alloc] init];
    self.preferredContentSize = CGSizeMake(200, 64);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    UILabel* description = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 30)];
    description.text = NSLocalizedString(@"current_price", nil);
    description.font = [UIFont systemFontOfSize:13];
    description.textColor = [UIColor colorWithWhite:0.5 alpha:1.0];
    [self.view addSubview:description];
    
    _priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 27, 200, 30)];
    _priceLabel.textColor = [UIColor whiteColor];
    _priceLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:24];
    [self updatePriceLabel];
    [self.view addSubview:_priceLabel];
    
    
    UIColor* buttonTintColor = [UIColor whiteColor];
    UIColor* buttonSelectedColor = [UIColor colorWithWhite:0.8 alpha:1.0];
    
    NSString* sendTitle = NSLocalizedString(@"send", nil);
    AccountActionButton* sendButton = [[AccountActionButton alloc] initWithTitle:sendTitle image:[UIImage imageNamed:@"send"] selectedImage:[UIImage imageNamed:@"send_selected"]];
    sendButton.padding = 5;
    [sendButton setTintColor:buttonTintColor];
    [sendButton setSelectedTintColor:buttonSelectedColor];
    CGSize sendSize = [sendTitle sizeWithAttributes:@{NSFontAttributeName:sendButton.titleLabel.font}];
    [sendButton addTarget:self action:@selector(actionSend:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:sendButton];
    
    
    NSString* receiveTitle = NSLocalizedString(@"receive", nil);
    AccountActionButton* receiveButton = [[AccountActionButton alloc] initWithTitle:receiveTitle image:[UIImage imageNamed:@"receive"] selectedImage:[UIImage imageNamed:@"receive_selected"]];
    receiveButton.padding = 10;
    [receiveButton setTintColor:buttonTintColor];
    [receiveButton setSelectedTintColor:buttonSelectedColor];
    CGSize receiveSize = [receiveTitle sizeWithAttributes:@{NSFontAttributeName:receiveButton.titleLabel.font}];
    [receiveButton addTarget:self action:@selector(actionReceive:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:receiveButton];
    
    
    CGFloat width = sendSize.width + receiveSize.width;
    CGFloat padding = (180 - width) / 3;
    sendButton.frame = CGRectMake(self.view.bounds.size.width - sendSize.width - padding, 7, sendSize.width, 50);
    receiveButton.frame = CGRectMake(self.view.bounds.size.width - receiveSize.width - sendSize.width - padding * 2, 12, receiveSize.width, 50);
}

- (void)actionSend:(id)sender {
    NSURL* url = [[NSURL alloc] initWithScheme:@"bitstore" host:nil path:@"/send"];
    [self.extensionContext openURL:url completionHandler:nil];
}

- (void)actionReceive:(id)sender {
    NSURL* url = [[NSURL alloc] initWithScheme:@"bitstore" host:nil path:@"/receive"];
    [self.extensionContext openURL:url completionHandler:nil];
}

- (void)updatePriceLabel {
    if (_user.cachedPrice) {
        _priceLabel.text = [NSString stringWithFormat:@"%.0f %@", [_user.cachedPrice floatValue], _user.todayCurrency];
    } else {
        _priceLabel.text = NSLocalizedString(@"loading", nil);
    }
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    NSString* url = [NSString stringWithFormat:@"https://api.bitcoinaverage.com/ticker/global/%@", _user.todayCurrency];
    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response,
                                               NSData *data,
                                               NSError *error) {
                               
                               if (!error && data) {
                                   NSError* jsonError;
                                   NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                                   if (!jsonError) {
                                       _user.cachedPrice = [json objectForKey:@"last"];
                                       [self updatePriceLabel];
                                       completionHandler(NCUpdateResultNewData);
                                   } else {
                                       completionHandler(NCUpdateResultFailed);
                                   }
                               }
                               completionHandler(NCUpdateResultFailed);
                           }];
}

- (UIEdgeInsets)widgetMarginInsetsForProposedMarginInsets:(UIEdgeInsets)defaultMarginInsets {
    UIEdgeInsets newInsets = UIEdgeInsetsMake(18, defaultMarginInsets.left - 0, 18, defaultMarginInsets.right);
    return newInsets;
}

@end

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
    UILabel* _priceLabel;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.preferredContentSize = CGSizeMake(200, 65);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    UILabel* description = [[UILabel alloc] initWithFrame:CGRectMake(0, 18, 200, 30)];
    description.text = @"Current price:";
    description.font = [UIFont systemFontOfSize:13];
    description.textColor = [UIColor colorWithWhite:0.5 alpha:1.0];
    [self.view addSubview:description];
    
    _priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 45, 200, 30)];
    _priceLabel.textColor = [UIColor whiteColor];
    _priceLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:24];
    [self updatePriceLabel];
    [self.view addSubview:_priceLabel];
    
    
    NSString* sendTitle = NSLocalizedString(@"send", nil);
    AccountActionButton* sendButton = [[AccountActionButton alloc] initWithTitle:sendTitle image:[UIImage imageNamed:@"send"] selectedImage:[UIImage imageNamed:@"send_selected"]];
    sendButton.padding = 5;
    CGSize sendSize = [sendTitle sizeWithAttributes:@{NSFontAttributeName:sendButton.titleLabel.font}];
    sendButton.frame = CGRectMake(self.view.bounds.size.width - sendSize.width - 30, 25, sendSize.width, 50);
    [self.view addSubview:sendButton];
    
    
    NSString* receiveTitle = NSLocalizedString(@"receive", nil);
    AccountActionButton* receiveButton = [[AccountActionButton alloc] initWithTitle:receiveTitle image:[UIImage imageNamed:@"receive"] selectedImage:[UIImage imageNamed:@"receive_selected"]];
    receiveButton.padding = 5;
    CGSize receiveSize = [receiveTitle sizeWithAttributes:@{NSFontAttributeName:receiveButton.titleLabel.font}];
    receiveButton.frame = CGRectMake(self.view.bounds.size.width - receiveSize.width - sendSize.width - 60, 34, receiveSize.width, 50);
    [self.view addSubview:receiveButton];
}

- (void)updatePriceLabel {
    SharedUser* user = [self user];
    if (user.cachedPrice) {
        _priceLabel.text = [NSString stringWithFormat:@"%.0f %@", [user.cachedPrice floatValue], user.todayCurrency];
    } else {
        _priceLabel.text = @"Loading...";
    }
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    NSString* url = [NSString stringWithFormat:@"https://api.bitcoinaverage.com/ticker/global/%@", [self user].todayCurrency];
    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response,
                                               NSData *data,
                                               NSError *error) {
                               
                               if (!error && data) {
                                   NSError* jsonError;
                                   NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                                   if (!jsonError) {
                                       SharedUser* user = [self user];
                                       user.cachedPrice = [json objectForKey:@"last"];
                                       [self saveUser:user];
                                       [self updatePriceLabel];
                                       completionHandler(NCUpdateResultNewData);
                                   } else {
                                       completionHandler(NCUpdateResultFailed);
                                   }
                               }
                               completionHandler(NCUpdateResultFailed);
                           }];
}

- (NSUserDefaults *)userDefaults {
    return [[NSUserDefaults alloc]initWithSuiteName:@"com.dylanmarriott.BitStore"];
}

- (SharedUser *)user {
    NSData* data = [[self userDefaults] objectForKey:@"sharedUser"];
    return [NSKeyedUnarchiver unarchiveObjectWithData:data];
}

- (void)saveUser:(SharedUser *)user {
    NSData* encoded = [NSKeyedArchiver archivedDataWithRootObject:user];
    [[self userDefaults] setObject:encoded forKey:@"sharedUser"];
    [[self userDefaults] synchronize];
}

@end

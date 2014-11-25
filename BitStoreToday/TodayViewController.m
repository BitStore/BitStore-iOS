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
#import "BEMSimpleLineGraphView.h"

@interface TodayViewController () <NCWidgetProviding, BEMSimpleLineGraphDataSource, BEMSimpleLineGraphDelegate>

@end

@implementation TodayViewController {
    SharedUser* _user;
    UILabel* _priceLabel;
    BEMSimpleLineGraphView* _chart;
    NSArray* _data;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _user = [[SharedUser alloc] init];
    self.preferredContentSize = CGSizeMake(0, 64);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    for (UIView* v in self.view.subviews) {
        [v removeFromSuperview];
    }
    
    UILabel* description = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 200, 20)];
    description.text = NSLocalizedString(@"current_price", nil);
    description.font = [UIFont systemFontOfSize:13];
    description.textColor = [UIColor colorWithWhite:0.5 alpha:1.0];
    [self.view addSubview:description];
    
    _priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, 200, 20)];
    _priceLabel.textColor = [UIColor whiteColor];
    _priceLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:24];
    [self.view addSubview:_priceLabel];
    
    
    UIColor* buttonTintColor = [UIColor whiteColor];
    UIColor* buttonSelectedColor = [UIColor colorWithWhite:0.8 alpha:1.0];
    
    NSString* receiveTitle = NSLocalizedString(@"receive", nil);
    AccountActionButton* receiveButton = [[AccountActionButton alloc] initWithTitle:receiveTitle image:[UIImage imageNamed:@"receive"] selectedImage:[UIImage imageNamed:@"receive_selected"]];
    receiveButton.padding = 10;
    [receiveButton setTintColor:buttonTintColor];
    [receiveButton setSelectedTintColor:buttonSelectedColor];
    CGSize receiveSize = [receiveTitle sizeWithAttributes:@{NSFontAttributeName:receiveButton.titleLabel.font}];
    receiveButton.frame = CGRectMake(self.view.bounds.size.width - receiveSize.width, 8, receiveSize.width, 50);
    [receiveButton addTarget:self action:@selector(actionReceive:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:receiveButton];
    
    
    _chart = [[BEMSimpleLineGraphView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - receiveSize.width - 134, 0, 120, 50)];
    _chart.dataSource = self;
    _chart.delegate = self;
    _chart.animationGraphStyle = BEMLineAnimationNone;
    _chart.colorTop = [UIColor clearColor];
    _chart.colorBottom = [UIColor colorWithWhite:1.0 alpha:0.15];
    [self.view addSubview:_chart];
    
    [self updatePriceLabel];
    [self updateChart];
}

- (void)actionReceive:(UIButton *)receiveButton {
    receiveButton.selected = !receiveButton.selected;
    receiveButton.highlighted = !receiveButton.selected;
    if (receiveButton.selected) {
        self.preferredContentSize = CGSizeMake(0, 400);
    } else {
        self.preferredContentSize = CGSizeMake(0, 64);
    }
}

- (void)updatePriceLabel {
    if (_user.cachedPrice) {
        _priceLabel.text = [NSString stringWithFormat:@"%.0f %@", [_user.cachedPrice floatValue], _user.todayCurrency];
    } else {
        _priceLabel.text = NSLocalizedString(@"loading", nil);
    }
}

- (void)updateChart {
    _data = @[@3.5, @3.6, @3.2, @2.3, @2.5, @2.8, @2.5, @2.9, @3.4, @3.8];
    [_chart reloadGraph];
}

#pragma mark - Widget
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
                                       [self updateChart];
                                       completionHandler(NCUpdateResultNewData);
                                   } else {
                                       completionHandler(NCUpdateResultFailed);
                                   }
                               }
                               completionHandler(NCUpdateResultFailed);
                           }];
    
    
}

- (UIEdgeInsets)widgetMarginInsetsForProposedMarginInsets:(UIEdgeInsets)defaultMarginInsets {
    UIEdgeInsets newInsets = UIEdgeInsetsMake(12, 18, 18, 18);
    return newInsets;
}

#pragma mark - BEMSimpleLineGraphDataSource
- (NSInteger)numberOfPointsInLineGraph:(BEMSimpleLineGraphView *)graph {
    return _data.count;
}

- (CGFloat)lineGraph:(BEMSimpleLineGraphView *)graph valueForPointAtIndex:(NSInteger)index {
    return [[_data objectAtIndex:index] floatValue];
}

#pragma mark - BEMSimpleLineGraphDelegate


@end

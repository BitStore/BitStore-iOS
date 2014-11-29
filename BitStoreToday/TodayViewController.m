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
#import "QRHelper.h"

@interface TodayViewController () <NCWidgetProviding, BEMSimpleLineGraphDataSource, BEMSimpleLineGraphDelegate>

@end

@implementation TodayViewController {
    SharedUser* _user;
    UILabel* _priceLabel;
    UIImageView* _qrImageView;
    BEMSimpleLineGraphView* _miniChart;
    BEMSimpleLineGraphView* _bigChart;
    UIView* _bigChartContainer;
    BOOL _chartOpen;
    AccountActionButton* _receiveButton;
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
    _receiveButton = [[AccountActionButton alloc] initWithTitle:receiveTitle image:[UIImage imageNamed:@"receive"] selectedImage:[UIImage imageNamed:@"receive_selected"]];
    _receiveButton.padding = 10;
    [_receiveButton setTintColor:buttonTintColor];
    [_receiveButton setSelectedTintColor:buttonSelectedColor];
    CGSize receiveSize = [receiveTitle sizeWithAttributes:@{NSFontAttributeName:_receiveButton.titleLabel.font}];
    _receiveButton.frame = CGRectMake(self.view.bounds.size.width - receiveSize.width, 8, receiveSize.width, 50);
    [_receiveButton addTarget:self action:@selector(actionReceive:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_receiveButton];
    
    
    UIImage* qrImage = [QRHelper qrcode:_user.address withDimension:self.view.bounds.size.width];
    _qrImageView = [[UIImageView alloc] initWithImage:qrImage];
    _qrImageView.frame = CGRectMake(0, 64, qrImage.size.width, qrImage.size.height);
    _qrImageView.backgroundColor = [UIColor yellowColor];
    _qrImageView.alpha = 0.0;
    [self.view addSubview:_qrImageView];
    
    
    _miniChart = [[BEMSimpleLineGraphView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - receiveSize.width - 134, 0, 120, 50)];
    _miniChart.dataSource = self;
    _miniChart.delegate = self;
    _miniChart.animationGraphStyle = BEMLineAnimationNone;
    _miniChart.colorTop = [UIColor clearColor];
    _miniChart.colorBottom = [UIColor colorWithWhite:1.0 alpha:0.15];
    [_miniChart addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionGraph:)]];
    [self.view addSubview:_miniChart];
    
    _bigChartContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, 140)];
    _bigChartContainer.alpha = 0.0;
    _bigChart = [[BEMSimpleLineGraphView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 140)];
    _bigChart.dataSource = self;
    _bigChart.delegate = self;
    _bigChart.animationGraphStyle = BEMLineAnimationNone;
    _bigChart.colorTop = [UIColor clearColor];
    _bigChart.enableReferenceYAxisLines = YES;
    _bigChart.enableYAxisLabel = YES;
    _bigChart.colorYaxisLabel = [UIColor whiteColor];
    _bigChart.alphaBackgroundYaxis = 0.5;
    [_bigChartContainer addSubview:_bigChart];
    UILabel* chartLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 115, self.view.bounds.size.width - 20, 20)];
    chartLabel.text = @"24h BTC / USD";
    chartLabel.textAlignment = NSTextAlignmentCenter;
    chartLabel.font = [UIFont systemFontOfSize:12];
    chartLabel.textColor = [UIColor whiteColor];
    chartLabel.alpha = 0.6;
    [_bigChartContainer addSubview:chartLabel];
    [self.view addSubview:_bigChartContainer];
    
    [self updatePriceLabel];
    [self updateChart];
}

- (void)actionReceive:(UIButton *)receiveButton {
    if (_chartOpen) {
        [self toggleGraph];
    }
    [self toggleReceive];
    if (_receiveButton.selected) {
        self.preferredContentSize = CGSizeMake(0, self.view.frame.size.width + 64);
    } else {
        self.preferredContentSize = CGSizeMake(0, 64);
    }
}

- (void)toggleReceive {
    BOOL selected = !_receiveButton.selected;
    _receiveButton.selected = selected;
    _receiveButton.highlighted = selected;
    
    [UIView animateWithDuration:0.3 animations:^() {
        if (selected) {
            _qrImageView.alpha = 1.0;
        } else {
            _qrImageView.alpha = 0.0;
        }
    }];
}

- (void)actionGraph:(id)sender {
    if (_receiveButton.selected) {
        [self toggleReceive];
    }
    [self toggleGraph];
    if (_chartOpen) {
        self.preferredContentSize = CGSizeMake(0, 150 + 64);
    } else {
        self.preferredContentSize = CGSizeMake(0, 64);
    }
}

- (void)toggleGraph {
    _chartOpen = !_chartOpen;
    
    if (_chartOpen) {
        _miniChart.colorBottom = [UIColor colorWithWhite:1.0 alpha:0.45];
    } else {
        _miniChart.colorBottom = [UIColor colorWithWhite:1.0 alpha:0.15];
    }
    
    [UIView animateWithDuration:0.3 animations:^() {
        if (_chartOpen) {
            _bigChartContainer.alpha = 1.0;
        } else {
            _bigChartContainer.alpha = 0.0;
        }
    }];
}

- (void)fetchCurrent {
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
                                   } else {
                                   }
                               }
                           }];
}

- (void)fetchHistory {
    NSString* url = @"https://api.bitcoinaverage.com/history/USD/per_minute_24h_sliding_window.csv";
    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response,
                                               NSData *data,
                                               NSError *error) {
                               
                               if (!error && data) {
                                   NSString* result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                   NSArray* rows = [result componentsSeparatedByString:@"\r\n"];
                                   int i = 0;
                                   NSMutableArray* history = [NSMutableArray array];
                                   NSNumberFormatter* f = [[NSNumberFormatter alloc] init];
                                   [f setNumberStyle:NSNumberFormatterDecimalStyle];
                                   for (NSString* row in rows) {
                                       if (i > 0 && i % 20 == 0) {
                                           NSArray* cols = [row componentsSeparatedByString:@","];
                                           if (cols.count == 2) {
                                               NSNumber* value = [f numberFromString:cols[1]];
                                               if (value) {
                                                   [history addObject:value];
                                               }
                
                                           }
                                       }
                                       i++;
                                   }
                                   _user.cachedHistory = history;
                                   [self updateChart];
                               }
                           }];
}

- (void)updatePriceLabel {
    if (_user.cachedPrice) {
        _priceLabel.text = [NSString stringWithFormat:@"%.0f %@", [_user.cachedPrice floatValue], _user.todayCurrency];
    } else {
        _priceLabel.text = NSLocalizedString(@"loading", nil);
    }
}

- (void)updateChart {
    [_miniChart reloadGraph];
    [_bigChart reloadGraph];
}

#pragma mark - Widget
- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    [self fetchCurrent];
    [self fetchHistory];
    completionHandler(NCUpdateResultNewData);
}

- (UIEdgeInsets)widgetMarginInsetsForProposedMarginInsets:(UIEdgeInsets)defaultMarginInsets {
    UIEdgeInsets newInsets = UIEdgeInsetsMake(12, 18, 18, 18);
    return newInsets;
}

#pragma mark - BEMSimpleLineGraphDataSource
- (NSInteger)numberOfPointsInLineGraph:(BEMSimpleLineGraphView *)graph {
    return _user.cachedHistory.count;
}

- (CGFloat)lineGraph:(BEMSimpleLineGraphView *)graph valueForPointAtIndex:(NSInteger)index {
    return [[_user.cachedHistory objectAtIndex:index] floatValue];
}

#pragma mark - BEMSimpleLineGraphDelegate
- (CGFloat)staticPaddingForLineGraph:(BEMSimpleLineGraphView *)graph {
    return 10;
}

@end

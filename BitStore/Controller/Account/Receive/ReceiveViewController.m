//
//  ReceiveViewController.m
//  BitStore
//
//  Created by Dylan Marriott on 10.07.14.
//  Copyright (c) 2014 Dylan Marriott. All rights reserved.
//

#import "ReceiveViewController.h"
#import "Address.h"
#import "QRHelper.h"
#import "Transaction.h"
#import "UIBAlertView.h"
#import "Receiver.h"
#import "UserDefaults.h"
#import "AddressHelper.h"
#import "Exchange.h"
#import "ExchangeHelper.h"
#import "ExchangeListener.h"
#import "Unit.h"
#import "ReceiveAmountViewController.h"
#import "ReceiveAmountDelegate.h"
#import <SocketRocket/SRWebSocket.h>

static int QR_WIDTH = 240;

@interface ReceiveViewController () <ExchangeListener, ReceiveAmountDelegate, SRWebSocketDelegate>
@end

@implementation ReceiveViewController {
    Address* _address;
    Exchange* _exchange;
    BTCSatoshi _satoshi;
    
    UIButton* _addButton;
    UILabel* _amountLabel;  
    UIImageView* _qrCode;
    
    SRWebSocket* _ws;
}

- (id)init {
    if (self = [super init]) {
	    self.title = l10n(@"receive");
        _address = [AddressHelper instance].defaultAddress;
        _ws = [[SRWebSocket alloc] initWithURL:[NSURL URLWithString:@"wss://ws.blockchain.info/inv"]];
        _ws.delegate = self;
        [_ws open];
        [[ExchangeHelper instance] addExchangeListener:self];
	}
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    UIBarButtonItem* closeItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(close:)];
    self.navigationItem.leftBarButtonItem = closeItem;
    
    
    UIImage* qrCodeImage = [QRHelper qrcode:_address.address withDimension:QR_WIDTH];
	_qrCode = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2 - QR_WIDTH / 2, 20, QR_WIDTH, QR_WIDTH)];
	_qrCode.image = qrCodeImage;
    [self.view addSubview:_qrCode];
    
    UITextView* addressLabel = [[UITextView alloc] initWithFrame:CGRectMake(10, QR_WIDTH + 22, self.view.frame.size.width - 20, 25)];
    addressLabel.backgroundColor = [UIColor clearColor];
    addressLabel.text = _address.address;
    addressLabel.textColor = [UIColor colorWithWhite:0.2 alpha:1.0];
    addressLabel.font = [UIFont systemFontOfSize:12];
    addressLabel.editable = NO;
    addressLabel.scrollEnabled = NO;
	addressLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:addressLabel];

    
    _addButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2 - 50, QR_WIDTH + 60, 100, 32)];
    [_addButton setTitle:@"Add Amount" forState:UIControlStateNormal];
    [_addButton setTitleColor:[Color mainTintColor] forState:UIControlStateNormal];
    _addButton.titleLabel.font = [UIFont systemFontOfSize:14];
    _addButton.layer.cornerRadius = 4;
    _addButton.layer.borderWidth = 1;
    _addButton.layer.borderColor = [Color mainTintColor].CGColor;
    [_addButton addTarget:self action:@selector(actionAdd:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_addButton];
    
    _amountLabel = [[UILabel alloc] init];
    _amountLabel.font = [UIFont systemFontOfSize:18];
    _amountLabel.textColor = [Color mainTintColor];
    _amountLabel.textAlignment = NSTextAlignmentCenter;
    _amountLabel.numberOfLines = 0;
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionAdd:)];
    [_amountLabel addGestureRecognizer:tap];
    _amountLabel.userInteractionEnabled = YES;
    [self.view addSubview:_amountLabel];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    _ws.delegate = nil;
    [_ws close];
    _ws = nil;
}

- (void)actionAdd:(id)sender {
    ReceiveAmountViewController* vc = [[ReceiveAmountViewController alloc] initWithDelegate:self amount:_satoshi];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)close:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - ExchangeListener
- (void)exchangeChanged:(Exchange *)exchange {
    _exchange = exchange;
}

#pragma mark - ReceiveAmountDelegate
- (void)amountSelected:(BTCSatoshi)satoshi {
    _satoshi = satoshi;
    _addButton.hidden = _satoshi > 0;
    _amountLabel.hidden = _satoshi == 0;
    
    NSString* qrCodeText = _address.address;
    if (_satoshi > 0) {
        _amountLabel.text = [NSString stringWithFormat:@"%@\n(%.2f %@)", [_exchange.unit valueForSatoshi:_satoshi], _exchange.current * (_satoshi / 100000000.0f), _exchange.currency];
        CGSize size = [_amountLabel.text sizeWithAttributes:@{NSFontAttributeName:_amountLabel.font}];
        _amountLabel.frame = CGRectIntegral(CGRectMake(self.view.frame.size.width / 2 - size.width / 2, _addButton.frame.origin.y, size.width, size.height));
        
        qrCodeText = [NSString stringWithFormat:@"bitcoin:%@?amount=%.8f", _address.address, _satoshi / 100000000.0f];
    }
    
    UIImage* qrCodeImage = [QRHelper qrcode:qrCodeText withDimension:QR_WIDTH];
    _qrCode.image = qrCodeImage;
}

#pragma mark - SRWebSocketDelegate
- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
    NSString* cmd = [NSString stringWithFormat:@"{\"op\":\"addr_sub\", \"addr\":\"%@\"}", _address.address];
    [webSocket send:cmd];
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
    NSLog(@"websocked fail: %@", error);
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    NSLog(@"websocked did close");
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(NSString *)message {
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:[message dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
    NSArray* outputs = [[json objectForKey:@"x"]  objectForKey:@"out"];
    BTCSatoshi total = 0;
    for (NSDictionary* output in outputs) {
        if ([[output objectForKey:@"addr"] isEqualToString:_address.address]) {
            total += [[output objectForKey:@"value"] longValue];
        }
    }
    if (_satoshi == 0 || _satoshi == total) {
        NSString* amount = [_exchange.unit valueForSatoshi:total];
        UIBAlertView* successAlert = [[UIBAlertView alloc] initWithTitle:l10n(@"success") message:[NSString stringWithFormat:l10n(@"push_message"), amount] cancelButtonTitle:l10n(@"okay") otherButtonTitles:nil];
        [successAlert showWithDismissHandler:^(NSInteger selectedIndex, NSString *selectedTitle, BOOL didCancel) {
            [self close:self];
        }];
    }
}

@end

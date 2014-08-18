//
//  KeyExportViewController.m
//  BitStore
//
//  Created by Dylan Marriott on 28/06/14.
//  Copyright (c) 2014 Dylan Marriott. All rights reserved.
//

#import "KeyExportViewController.h"
#import "QRHelper.h"
#import "LTHPasscodeViewController.h"
#import "FXBlurView.h"
#import "UserDefaults.h"
#import "UIBAlertView.h"
#import "Lockbox.h"
#import "PushHelper.h"
#import "AddressHelper.h"

@interface KeyExportViewController () <LTHPasscodeViewControllerDelegate>
@end

@implementation KeyExportViewController {
    NSString* _privateKey;
    int _index;
    BOOL _showTrash;
    BOOL _correct;
    FXBlurView* _blur1, *_blur2;
}

- (id)initWithPrivateKey:(NSString *)privateKey index:(int)index showTrash:(BOOL)showTrash {
    if (self = [super init]) {
		_privateKey = privateKey;
		_index = index;
		_showTrash = showTrash;
		self.title = l10n(@"export");
		self.edgesForExtendedLayout = UIRectEdgeNone;
	}
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    _correct = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    
    [LTHPasscodeViewController sharedUser].delegate = self;
    [LTHPasscodeViewController sharedUser].maxNumberOfAllowedFailedAttempts = 3;
    if ([LTHPasscodeViewController doesPasscodeExist]) {
        [[LTHPasscodeViewController sharedUser] showLockScreen:self animated:NO];
    } else {
        [self showView:NO];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[PiwikTracker sharedInstance] sendViews:@"PrivKeyExport", nil];
}

- (void)maxNumberOfFailedAttemptsReached {
    [[LTHPasscodeViewController sharedUser] dismissViewControllerAnimated:YES completion:^() {
        [[LTHPasscodeViewController sharedUser] reset];
    }];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)passcodeWasEnteredSuccessfully {
    _correct = YES;
    [self showView:YES];
}

- (void)passcodeViewControllerWillClose {
    if (!_correct) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)showView:(BOOL)fromLockScreen {
    
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [self.view addGestureRecognizer:tap];
    
    BOOL showFav = YES;
    if (_index == [UserDefaults instance].defaultAddressIndex) {
        showFav = NO;
    }
    
    
    UIBarButtonItem* trashItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(trash:)];
    UIBarButtonItem* favItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"fav"] style:UIBarButtonItemStyleBordered target:self action:@selector(fav:)];
    
    NSMutableArray* items = [[NSMutableArray alloc] init];
    if (_showTrash) {
        [items addObject:trashItem];
    }
    if (showFav) {
        [items addObject:favItem];
    }
    self.navigationItem.rightBarButtonItems = items;
    
    CGFloat qrWidth = 200;
    UIImage* qrCodeImage = [QRHelper qrcode:_privateKey withDimension:qrWidth];
	UIImageView* qrCode = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2 - qrWidth / 2, 20, qrWidth, qrWidth)];
	qrCode.image = qrCodeImage;
    [self.view addSubview:qrCode];
    
    _blur1 = [[FXBlurView alloc] initWithFrame:CGRectMake(qrCode.frame.origin.x - 20, qrCode.frame.origin.y - 20, qrCode.frame.size.width + 40, qrCode.frame.size.height + 40)];
    _blur1.iterations = 3;
    _blur1.blurRadius = 15;
    _blur1.dynamic = NO;
    _blur1.tintColor = nil;
    [self.view addSubview:_blur1];
    
    
    
    UITextView* keyLabel = [[UITextView alloc] initWithFrame:CGRectMake(40, qrWidth + 30, self.view.frame.size.width - 80, 50)];
    keyLabel.text = _privateKey;
    keyLabel.textColor = [UIColor colorWithWhite:0.2 alpha:1.0];
    keyLabel.font = [UIFont systemFontOfSize:14];
    keyLabel.editable = NO;
    keyLabel.scrollEnabled = NO;
	keyLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:keyLabel];
    
    
    _blur2 = [[FXBlurView alloc] initWithFrame:keyLabel.frame];
    _blur2.iterations = 3;
    _blur2.blurRadius = 4;
    _blur2.dynamic = NO;
    _blur2.tintColor = nil;
    [self.view addSubview:_blur2];
}

- (void)fav:(id)sender {
    NSString* pk = [[Lockbox arrayForKey:@"bitstore_3"] objectAtIndex:[UserDefaults instance].defaultAddressIndex];
    BTCKey* k = [[BTCKey alloc] initWithPrivateKeyAddress:[BTCPrivateKeyAddress addressWithBase58String:pk]];
    [self configurePush:k.uncompressedPublicKeyAddress.base58String];
    [[AddressHelper instance] setDefaultAddress:_index];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)trash:(id)sender {
    UIBAlertView* av = [[UIBAlertView alloc] initWithTitle:@"Are you sure???" message:@"" cancelButtonTitle:l10n(@"cancel") otherButtonTitles:l10n(@"yes"), nil];
    [av showWithDismissHandler:^(NSInteger selectedIndex, NSString *selectedTitle, BOOL didCancel) {
        if (!didCancel) {
            if (_index == [UserDefaults instance].defaultAddressIndex) {
                NSString* pk = [[Lockbox arrayForKey:@"bitstore_3"] objectAtIndex:_index];
                BTCKey* k = [[BTCKey alloc] initWithPrivateKeyAddress:[BTCPrivateKeyAddress addressWithBase58String:pk]];
                [self configurePush:k.uncompressedPublicKeyAddress.base58String];
                [[AddressHelper instance] setDefaultAddress:0];
            }
            
            NSMutableArray* a = [[NSMutableArray alloc] initWithArray:[Lockbox arrayForKey:@"bitstore_3"]];
            [a removeObjectAtIndex:_index];
            [Lockbox setArray:a forKey:@"bitstore_3"];
            [[AddressHelper instance] removeAddress:[[AddressHelper instance].addresses objectAtIndex:_index]];
            
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
}

- (void)configurePush:(NSString *)oldAddress {
    if ([UserDefaults instance].pushActive) {
        [PushHelper unregister:oldAddress];
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    }
}

- (void)tap:(UITapGestureRecognizer *)recognizer {
    [UIView animateWithDuration:0.2 animations:^() {
        _blur1.alpha = 0.0;
        _blur2.alpha = 0.0;
    } completion:^(BOOL finished) {
        [_blur1 removeFromSuperview];
        [_blur2 removeFromSuperview];
    }];
}

@end

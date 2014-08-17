//
//  UnitTest.m
//  BitStore
//
//  Created by Dylan Marriott on 08.08.14.
//  Copyright (c) 2014 Dylan Marriott. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <CoreBitcoin/CoreBitcoin.h>
#import "Unit.h"

@interface UnitTest : XCTestCase

@end

@implementation UnitTest

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testUnit {
	Unit* _btc = [[Unit alloc] initWithType:btc];
	Unit* _mbtc = [[Unit alloc] initWithType:mbtc];
	Unit* _ubtc = [[Unit alloc] initWithType:ubtc];
	
	XCTAssert([[_btc valueForSatoshi:10] isEqualToString:@"0.0000 BTC"], @"");
	XCTAssert([[_btc valueForSatoshi:5000] isEqualToString:@"0.0001 BTC"], @"");
	XCTAssert([[_btc valueForSatoshi:5000 round:NO] isEqualToString:@"0.0000 BTC"], @"");
	XCTAssert([[_btc valueForSatoshi:4000 round:YES] isEqualToString:@"0.0000 BTC"], @"");
	XCTAssert([[_btc valueForSatoshi:5000 round:YES showUnit:NO] isEqualToString:@"0.0001"], @"");
	XCTAssert([[_btc valueForSatoshi:5000 round:NO showUnit:NO] isEqualToString:@"0.0000"], @"");
	
	XCTAssert([[_mbtc valueForSatoshi:10] isEqualToString:@"0.00 mBTC"], @"");
	XCTAssert([[_mbtc valueForSatoshi:500] isEqualToString:@"0.01 mBTC"], @"");
	XCTAssert([[_mbtc valueForSatoshi:500 round:NO] isEqualToString:@"0.00 mBTC"], @"");
	XCTAssert([[_mbtc valueForSatoshi:400 round:YES] isEqualToString:@"0.00 mBTC"], @"");
	XCTAssert([[_mbtc valueForSatoshi:500 round:YES showUnit:NO] isEqualToString:@"0.01"], @"");
	XCTAssert([[_mbtc valueForSatoshi:500 round:NO showUnit:NO] isEqualToString:@"0.00"], @"");
	
	XCTAssert([[_ubtc valueForSatoshi:10] isEqualToString:@"0 μBTC"], @"");
	XCTAssert([[_ubtc valueForSatoshi:50] isEqualToString:@"1 μBTC"], @"");
	XCTAssert([[_ubtc valueForSatoshi:50 round:NO] isEqualToString:@"0 μBTC"], @"");
	XCTAssert([[_ubtc valueForSatoshi:40 round:YES] isEqualToString:@"0 μBTC"], @"");
	XCTAssert([[_ubtc valueForSatoshi:50 round:YES showUnit:NO] isEqualToString:@"1"], @"");
	XCTAssert([[_ubtc valueForSatoshi:50 round:NO showUnit:NO] isEqualToString:@"0"], @"");
	
	
	XCTAssert([[_btc valueForSatoshi:358905325 round:YES showUnit:NO] isEqualToString:@"3.5891"], @"");
	XCTAssert([[_mbtc valueForSatoshi:358905325 round:YES showUnit:NO] isEqualToString:@"3589.05"], @"");
	XCTAssert([[_ubtc valueForSatoshi:358905325 round:YES showUnit:NO] isEqualToString:@"3589053"], @"");
	
	XCTAssert([[_btc valueForSatoshi:358905325 round:NO showUnit:NO] isEqualToString:@"3.5890"], @"");
	XCTAssert([[_mbtc valueForSatoshi:358905325 round:NO showUnit:NO] isEqualToString:@"3589.05"], @"");
	XCTAssert([[_ubtc valueForSatoshi:358905325 round:NO showUnit:NO] isEqualToString:@"3589053"], @"");
}

@end

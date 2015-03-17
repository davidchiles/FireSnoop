//
//  FSPData.h
//  FireSnoop
//
//  Created by David Chiles on 3/16/15.
//  Copyright (c) 2015 David Chiles. All rights reserved.
//

#import "MTLModel.h"

@interface FSPData : MTLModel

@property (nonatomic, strong, readonly) NSString *yapKey;
@property (nonatomic, strong, readonly) NSDate *date;

@property (nonatomic, strong) NSString *identifier;

@property (nonatomic, strong) NSData *data;

- (NSString *)utf8String;

- (NSString *)yapCollection;

+ (NSString *)yapCollection;

@end

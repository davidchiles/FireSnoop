//
//  FSPData.m
//  FireSnoop
//
//  Created by David Chiles on 3/16/15.
//  Copyright (c) 2015 David Chiles. All rights reserved.
//

#import "FSPData.h"

@implementation FSPData

- (instancetype)init
{
    if (self = [super init]) {
        _yapKey = [NSUUID UUID].UUIDString;
        _date = [NSDate date];
    }
    return self;
}

- (NSString *)yapCollection
{
    return [[self class] yapCollection];
}

+ (NSString *)yapCollection
{
    return NSStringFromClass(self);
}
@end

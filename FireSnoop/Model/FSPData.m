//
//  FSPData.m
//  FireSnoop
//
//  Created by David Chiles on 3/16/15.
//  Copyright (c) 2015 David Chiles. All rights reserved.
//

#import "FSPData.h"
#import "NSData+FireSnoop.h"

@implementation FSPData

- (instancetype)init
{
    if (self = [super init]) {
        _yapKey = [NSUUID UUID].UUIDString;
        _date = [NSDate date];
    }
    return self;
}

- (NSString *)utf8String
{
    NSUInteger start = 1;
    uint8_t firstByte = 0;
    if (self.data.length) {
        firstByte = [self.data fsp_byteAtIndex:0];
    }
    
    if (self.data.length > 1 && firstByte > 128) {
        start = 2;
    }
    return [[NSString alloc] initWithData:[self.data fsp_dataRemovingLeadingBytes:start] encoding:NSUTF8StringEncoding];
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

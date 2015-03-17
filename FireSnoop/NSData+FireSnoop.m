//
//  NSData+FireSnoop.m
//  FireSnoop
//
//  Created by David Chiles on 3/17/15.
//  Copyright (c) 2015 David Chiles. All rights reserved.
//

#import "NSData+FireSnoop.h"

@implementation NSData (FireSnoop)

- (uint8_t)fsp_byteAtIndex:(NSUInteger)index
{
    if (index < self.length) {
        uint8_t *dataAsBytes = (uint8_t *)[self bytes];
        return dataAsBytes[index];
    }
    return 0;
}

- (NSData *)fsp_dataRemovingLeadingBytes:(NSUInteger)count
{
    NSRange range = NSMakeRange(count, [self length] - count);
    return [self subdataWithRange:range];
}

@end

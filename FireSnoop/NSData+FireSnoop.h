//
//  NSData+FireSnoop.h
//  FireSnoop
//
//  Created by David Chiles on 3/17/15.
//  Copyright (c) 2015 David Chiles. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (FireSnoop)

- (uint8_t)fsp_byteAtIndex:(NSUInteger)index;

- (NSData *)fsp_dataRemovingLeadingBytes:(NSUInteger)count;

@end

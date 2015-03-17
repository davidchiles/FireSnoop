//
//  FSPBluetoothCentrel.h
//  FireSnoop
//
//  Created by David Chiles on 3/16/15.
//  Copyright (c) 2015 David Chiles. All rights reserved.
//

#import <Foundation/Foundation.h>

@class YapDatabaseConnection;

@interface FSPBluetoothCentrel : NSObject

- (instancetype)initWithConnection:(YapDatabaseConnection *)connection;

@end

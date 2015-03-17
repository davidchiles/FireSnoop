//
//  FSPDatabaseManager.h
//  FireSnoop
//
//  Created by David Chiles on 3/16/15.
//  Copyright (c) 2015 David Chiles. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YapDatabase.h"

extern NSString *const kFSPDataView;
extern NSString *const KFSPDataGroup;

@interface FSPDatabaseManager : NSObject

@property (nonatomic, strong, readonly) YapDatabase *databse;
@property (nonatomic, strong, readonly) YapDatabaseConnection *readWriteConnection;

- (instancetype)initWithPath:(NSString *)path;

@end

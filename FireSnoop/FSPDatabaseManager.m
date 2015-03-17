//
//  FSPDatabaseManager.m
//  FireSnoop
//
//  Created by David Chiles on 3/16/15.
//  Copyright (c) 2015 David Chiles. All rights reserved.
//

#import "FSPDatabaseManager.h"
#import "YapDatabaseView.h"
#import "YapDatabaseViewTypes.h"
#import "FSPData.h"

NSString *const kFSPDataView = @"kFSPDataView";
NSString *const KFSPDataGroup = @"KFSPDataGroup";

@implementation FSPDatabaseManager


- (instancetype)initWithPath:(NSString *)path
{
    if (self = [self init]) {
        
        _databse = [[YapDatabase alloc] initWithPath:path];
        _readWriteConnection = [self.databse newConnection];
        [self setupViews];
    }
    return self;
}

- (void)setupViews
{
    [self setupDataView];
}

- (void)setupDataView
{
    YapDatabaseViewGrouping *grouping = [YapDatabaseViewGrouping withKeyBlock:^NSString *(NSString *collection, NSString *key) {
        return KFSPDataGroup;
    }];
                                         
    YapDatabaseViewSorting *sorting = [YapDatabaseViewSorting withObjectBlock:^NSComparisonResult(NSString *group, NSString *collection1, NSString *key1, id object1, NSString *collection2, NSString *key2, id object2) {
        
        FSPData *dataEntry1 = (FSPData *)object1;
        FSPData *dataEntry2 = (FSPData *)object2;
        
        return [dataEntry1.date compare:dataEntry2.date];
    }];
    
    YapDatabaseViewOptions *options = [[YapDatabaseViewOptions alloc] init];
    NSSet *set = [NSSet setWithArray:@[[FSPData yapCollection]]];
    options.allowedCollections = [[YapWhitelistBlacklist alloc] initWithWhitelist:set];
    
    
    YapDatabaseView *view = [[YapDatabaseView alloc] initWithGrouping:grouping sorting:sorting versionTag:@"1" options:options];
    [self.databse registerExtension:view withName:kFSPDataView];
}
        

@end

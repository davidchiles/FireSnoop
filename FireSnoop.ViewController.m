//
//  ViewController.m
//  FireSnoop
//
//  Created by David Chiles on 3/16/15.
//  Copyright (c) 2015 David Chiles. All rights reserved.
//

#import "ViewController.h"
#import "FSPDatabaseManager.h"
#import "PureLayout.h"
#import "YapDatabaseViewMappings.h"
#import "YapDatabaseViewChange.h"
#import "YapDatabaseViewConnection.h"
#import "YapDatabaseViewTransaction.h"
#import "FSPData.h"

@interface ViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) BOOL addedConstraints;
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@property (nonatomic, strong) YapDatabaseConnection *databaseConnection;
@property (nonatomic, strong) YapDatabaseViewMappings *mappings;

@end

@implementation ViewController

- (instancetype)initWithReadOnlyConnection:(YapDatabaseConnection *)connection
{
    if (self = [self init]) {
        self.databaseConnection = connection;
        self.dateFormatter = [[NSDateFormatter alloc] init];
        [self.dateFormatter setDateStyle:NSDateFormatterShortStyle];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"FireSnoop";
    
    self.addedConstraints = NO;
    
    [self.databaseConnection beginLongLivedReadTransaction];
    
    self.mappings = [[YapDatabaseViewMappings alloc] initWithGroups:@[KFSPDataGroup]
                                                               view:kFSPDataView];
    
    [self.databaseConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
        [self.mappings updateWithTransaction:transaction];
    }];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.view addSubview:self.tableView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(yapDatabaseModified:)
                                                 name:YapDatabaseModifiedNotification
                                               object:nil];
    
}

- (FSPData *)dataEntryForIndexPath:(NSIndexPath *)indexPath
{
    __block FSPData *dataEntry = nil;
    [self.databaseConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
        
        dataEntry = [[transaction extension:kFSPDataView] objectAtIndexPath:indexPath withMappings:self.mappings];
    }];
    return dataEntry;
}

#pragma - mark UITableViewDataSource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.mappings numberOfItemsInSection:section];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.mappings numberOfSections];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    
    FSPData *dataEntry = [self dataEntryForIndexPath:indexPath];
    cell.textLabel.text = dataEntry.identifier;
    NSString *dateString = [self.dateFormatter stringFromDate:dataEntry.date];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %lu bytes",dateString,(unsigned long)dataEntry.data.length];
    
    return cell;
}

#pragma - mark UITableViewDelegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FSPData *dataEntry = [self dataEntryForIndexPath:indexPath];
    
    NSLog(@"String: %@",[[NSString alloc] initWithData:dataEntry.data encoding:NSASCIIStringEncoding]);
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma - mark YapDatabase Methods

- (void)yapDatabaseModified:(NSNotification *)notification
{
    NSArray *notifications = [self.databaseConnection beginLongLivedReadTransaction];
    
    NSArray *sectionChanges = nil;
    NSArray *rowChanges = nil;
    
    [[self.databaseConnection ext:kFSPDataView] getSectionChanges:&sectionChanges
                                                       rowChanges:&rowChanges
                                                 forNotifications:notifications
                                                     withMappings:self.mappings];
    
    
    // No need to update mappings.
    // The above method did it automatically.
    
    if ([sectionChanges count] == 0 && [rowChanges count] == 0)
    {
        // Nothing has changed that affects our tableView
        return;
    }
    
    [self.tableView beginUpdates];
    
    for (YapDatabaseViewSectionChange *sectionChange in sectionChanges)
    {
        switch (sectionChange.type)
        {
            case YapDatabaseViewChangeDelete :
            {
                [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionChange.index]
                              withRowAnimation:UITableViewRowAnimationAutomatic];
                break;
            }
            case YapDatabaseViewChangeInsert :
            {
                [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionChange.index]
                              withRowAnimation:UITableViewRowAnimationAutomatic];
                break;
            }
            case YapDatabaseViewChangeUpdate:
            case YapDatabaseViewChangeMove:
                break;
        }
    }
    
    for (YapDatabaseViewRowChange *rowChange in rowChanges)
    {
        switch (rowChange.type)
        {
            case YapDatabaseViewChangeDelete :
            {
                [self.tableView deleteRowsAtIndexPaths:@[ rowChange.indexPath ]
                                      withRowAnimation:UITableViewRowAnimationAutomatic];
                break;
            }
            case YapDatabaseViewChangeInsert :
            {
                [self.tableView insertRowsAtIndexPaths:@[ rowChange.newIndexPath ]
                                      withRowAnimation:UITableViewRowAnimationAutomatic];
                break;
            }
            case YapDatabaseViewChangeMove :
            {
                [self.tableView deleteRowsAtIndexPaths:@[ rowChange.indexPath ]
                                      withRowAnimation:UITableViewRowAnimationAutomatic];
                [self.tableView insertRowsAtIndexPaths:@[ rowChange.newIndexPath ]
                                      withRowAnimation:UITableViewRowAnimationAutomatic];
                break;
            }
            case YapDatabaseViewChangeUpdate :
            {
                [self.tableView reloadRowsAtIndexPaths:@[ rowChange.indexPath ]
                                      withRowAnimation:UITableViewRowAnimationNone];
                break;
            }
        }
    }
    
    [self.tableView endUpdates];
}
@end

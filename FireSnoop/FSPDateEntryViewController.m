//
//  FSPDateEntryViewController.m
//  FireSnoop
//
//  Created by David Chiles on 3/17/15.
//  Copyright (c) 2015 David Chiles. All rights reserved.
//

#import "FSPDateEntryViewController.h"
#import "FSPData.h"
#import "NSData+FireSnoop.h"

@interface FSPDateEntryViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) FSPData *dataEntry;

@end

@implementation FSPDateEntryViewController

- (instancetype)initWithDataEntry:(FSPData *)dataEntry
{
    if (self = [self init]) {
        self.dataEntry = dataEntry;
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    
    [self.view addSubview:tableView];
    
}

#pragma - mark UITableViewDataSource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    switch (indexPath.row) {
        case 0:
        {
            cell.textLabel.text = @"Identifier";
            cell.detailTextLabel.text = self.dataEntry.identifier;
            break;
        }
        case 1:
        {
            cell.textLabel.text = @"Date";
            cell.detailTextLabel.text = [NSDateFormatter localizedStringFromDate:self.dataEntry.date
                                                                       dateStyle:NSDateFormatterShortStyle
                                                                       timeStyle:NSDateFormatterLongStyle];
            break;
        }
        case 2:
        {
            cell.textLabel.text = @"Byte Length";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu",self.dataEntry.data.length];
            break;
        }
        case 3: {
            cell.textLabel.text = @"UTF-8";
            cell.detailTextLabel.text = [self.dataEntry utf8String];
            break;
        }
        case 4:{
            cell.textLabel.text = @"First Byte";
            cell.detailTextLabel.text = nil;
             
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%d",[self.dataEntry.data fsp_byteAtIndex:0]];
            break;
        }
        default:
            break;
    }
    
    return cell;
}

@end

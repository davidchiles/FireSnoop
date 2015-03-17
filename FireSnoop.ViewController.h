//
//  ViewController.h
//  FireSnoop
//
//  Created by David Chiles on 3/16/15.
//  Copyright (c) 2015 David Chiles. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YapDatabaseConnection;

@interface ViewController : UIViewController

- (instancetype)initWithReadOnlyConnection:(YapDatabaseConnection *)connection;

@end


//
//  AppDelegate.h
//  FireSnoop
//
//  Created by David Chiles on 3/16/15.
//  Copyright (c) 2015 David Chiles. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FSPDatabaseManager, FSPBluetoothCentrel;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, strong, readonly) FSPDatabaseManager *databaseManager;
@property (nonatomic, strong, readonly) FSPBluetoothCentrel *bluetoothCentral;


@end


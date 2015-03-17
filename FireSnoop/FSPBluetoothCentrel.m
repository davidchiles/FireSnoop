//
//  FSPBluetoothCentrel.m
//  FireSnoop
//
//  Created by David Chiles on 3/16/15.
//  Copyright (c) 2015 David Chiles. All rights reserved.
//

#import "FSPBluetoothCentrel.h"
#import "YapDatabaseConnection.h"
#import "YapDatabaseTransaction.h"
#import "FSPData.h"
#import <CoreBluetooth/CoreBluetooth.h>

NSString *const kFSPUUID = @"4621192D-315F-478A-943F-B2CA635213DF";

@interface FSPBluetoothCentrel () <CBCentralManagerDelegate, CBPeripheralDelegate>

@property (nonatomic, strong) YapDatabaseConnection *connection;

@property (nonatomic, strong) CBCentralManager *centralManager;

@property (nonatomic, strong) CBUUID *uuid;

@property (nonatomic, strong) NSOperationQueue *centralManagerQueue;

@property (nonatomic, strong) NSMutableSet *peripheralSet;

@end

@implementation FSPBluetoothCentrel


- (instancetype)initWithConnection:(YapDatabaseConnection *)connection
{
    if (self = [self init]) {
        self.connection = connection;
        self.centralManagerQueue = [[NSOperationQueue alloc] init];
        self.peripheralSet = [NSMutableSet set];
        [self setupCentral];
    }
    return self;
}

- (void)setupCentral
{
    self.uuid = [CBUUID UUIDWithString:kFSPUUID];
    self.centralManager  = [[CBCentralManager alloc] initWithDelegate:self queue:self.centralManagerQueue.underlyingQueue];
}

#pragma - mark CBCentralManagerDelegate Methods

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if (self.centralManager.state == CBCentralManagerStatePoweredOn) {
        BOOL allowDuplicates = NO;
        NSArray *services = @[self.uuid];
        [self.centralManager scanForPeripheralsWithServices:services
                                                    options:@{CBCentralManagerScanOptionAllowDuplicatesKey: @(allowDuplicates)}];
        NSLog(@"Starting Central Scan...");
    } else {
        NSLog(@"New Central State: %ld",central.state);
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSLog(@"Found Peripheral: %@",peripheral.identifier);
    peripheral.delegate = self;
    [self.peripheralSet addObject:peripheral];
    [central connectPeripheral:peripheral options:nil];
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"Did Connect to Peripheral: %@",peripheral.identifier);
    [peripheral discoverServices:@[self.uuid]];
}


#pragma - mark CBPeripheralDelegate Methods

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    NSLog(@"didDiscoverServices: %@", peripheral.services);
    if (peripheral.services.count == 0) {
        return;
    }
    NSUInteger serviceIndex = [peripheral.services indexOfObjectPassingTest:^BOOL(CBService *service, NSUInteger idx, BOOL *stop) {
        if ([service.UUID isEqual:self.uuid]) {
            *stop = YES;
            return YES;
        }
        return NO;
    }];
    if (serviceIndex == NSNotFound) {
        NSLog(@"Data service not found");
        return;
    }
    CBService *service = [peripheral.services objectAtIndex:serviceIndex];
    [peripheral discoverCharacteristics:@[self.uuid] forService:service];
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if (error) {
        NSLog(@"didDiscoverCharacteristicsForService error %@" ,error);
        return;
    } else {
        NSLog(@"didDiscoverCharacteristicsForService: %@", service.characteristics);
    }
    NSArray *characteristics = service.characteristics;
    NSUInteger characteristicIndex = [characteristics indexOfObjectPassingTest:^BOOL(CBCharacteristic *characteristic, NSUInteger idx, BOOL *stop) {
        if ([characteristic.UUID isEqual:self.uuid]) {
            *stop = YES;
            return YES;
        }
        return NO;
    }];
    if (characteristicIndex == NSNotFound) {
        NSLog(@"Characteristic not found");
        return;
    }
    CBCharacteristic *characteristic = [characteristics objectAtIndex:characteristicIndex];
    if (!characteristic) {
        NSLog(@"Characteristic not found");
        return;
    }
    [peripheral setNotifyValue:YES forCharacteristic:characteristic];
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"didUpdateValueForCharacteristic error %@", error);
        return;
    }
    
    __block FSPData *yapEntry = [[FSPData alloc] init];
    yapEntry.identifier = peripheral.identifier.UUIDString;
    yapEntry.data = characteristic.value;
    
    [self.connection asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        
        [transaction setObject:yapEntry forKey:yapEntry.yapKey inCollection:[yapEntry yapCollection]];
        
    } completionBlock:^{
        NSLog(@"didUpdateValueForCharacteristic %@", characteristic.value);
    }];
}



@end

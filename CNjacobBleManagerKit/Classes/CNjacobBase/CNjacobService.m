//
//  CNjacobService.m
//  CNjacobBleManagerKit
//
//  Created by CNjacob on 2019/3/26.
//

#import "CNjacobService.h"
#import <CoreBluetooth/CoreBluetooth.h>

#import "CNjacobPeripheral+Private.h"

@interface CNjacobService () {
    CBUUID *_UUID;
}

@property (nonatomic, strong) CBService *appleService;

@property (nonatomic, strong) NSMutableDictionary<NSString *, CNjacobCharacteristic *> *discoveredCharacterists;

@property (nonatomic, strong) NSMutableDictionary<NSString *, CNjacobService *> *discoveredIncludedServices;

@property (nonatomic, assign) CNjacobPeripheral *peripheral;

@property (nonatomic, copy) CNjacobServiceDiscoverCharacteristicCallback discoverCallback;

@end





@implementation CNjacobService

- (CNjacobPeripheral *)peripheral {
    
    return _peripheral;
}

- (CBUUID *)UUID {
    
    if (!_UUID) {
        _UUID = _appleService.UUID;
    }
    
    return _UUID;
}

- (BOOL)isPrimary {
    
    return self.appleService.isPrimary;
}

- (NSString*)name {
    
    return @"Unknown";
}

- (NSArray<CNjacobCharacteristic *> *)characteristics {
    
    return self.discoveredCharacterists.allValues;
}

- (NSArray<CNjacobService *> *)includedServices {
    
    return self.discoveredIncludedServices.allValues;
}

- (void)discoverCharacteristics:(CNjacobServiceDiscoverCharacteristicCallback)discoverCallback {
    
    [self discoverCharacteristics:nil callback:discoverCallback];
}

- (void)discoverCharacteristics:(NSArray<CBUUID *> *)characteristicUUIDs callback:(CNjacobServiceDiscoverCharacteristicCallback)discoverCallback {
    
    self.discoverCallback = discoverCallback;
    [self.peripheral.applePeripheral discoverCharacteristics:characteristicUUIDs forService:self.appleService];
}

- (CNjacobCharacteristic *)characteristicWithUUID:(NSString *)UUID {
    
    return [self.discoveredCharacterists objectForKey:UUID];
}

@end

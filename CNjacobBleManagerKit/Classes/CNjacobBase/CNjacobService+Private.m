//
//  CNjacobService+Private.m
//  CNjacobBleManagerKit
//
//  Created by CNjacob on 2019/3/26.
//

#import "CNjacobService+Private.h"

#import "CNjacobBluetoothManager+Private.h"
#import "CNjacobCentralManager.h"

#import "CNjacobPeripheral+Private.h"

#import "CNjacobAttribute.h"
#import "CNjacobCharacteristic+Private.h"

@implementation CNjacobService (Private)

@dynamic appleService;
@dynamic discoveredCharacterists;
@dynamic discoveredIncludedServices;
@dynamic discoverCallback;
@dynamic peripheral;

- (instancetype)initWithService:(CBService *)service peripheral:(CNjacobPeripheral *)peripheral {
    
    self = [super init];
    
    if (self) {
        self.appleService = service;
        self.peripheral = peripheral;
        self.discoveredCharacterists = [NSMutableDictionary<NSString *, CNjacobCharacteristic *> dictionary];
    }
    
    return self;
}

- (void)removeAllCharacteristics {
    
    for (CNjacobCharacteristic *characteristic in self.discoveredCharacterists.allValues) {
        [characteristic removeAllDescriptors];
    }
    
    [self.discoveredCharacterists removeAllObjects];
}

- (void)didDiscoverCharacteristics:(NSError *)error {
    
    CNJACOB_ASYNC_CALLBACK(self.discoverCallback,
                           self.discoverCallback(self, error),
                           CNjacobService,
                           self.centralManager);
}

- (CNjacobCentralManager *)centralManager {
    
    return self.peripheral.centralManager;
}

@end

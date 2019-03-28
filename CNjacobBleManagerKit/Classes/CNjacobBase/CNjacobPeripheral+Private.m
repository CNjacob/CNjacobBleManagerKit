//
//  CNjacobPeripheral+Private.m
//  CNjacobBleManagerKit
//
//  Created by CNjacob on 2019/3/26.
//

#import "CNjacobPeripheral+Private.h"

#import "CNjacobBluetoothManager+Private.h"
#import "CNjacobCentralManager.h"
#import "CNjacobCentralManagerOptions.h"

@implementation CNjacobPeripheral (Private)

@dynamic connectCallback;
@dynamic delayCallback;
@dynamic disconnectCallback;
@dynamic receiveDisconnectCallback;
@dynamic receiveAdvertisingCallback;
@dynamic discoverCallback;
@dynamic applePeripheral;
@dynamic connectionSequenceNumber;
@dynamic advertisementData;
@dynamic discoveredServices;
@dynamic RSSI;
@dynamic connectRetryTimes;
@dynamic connectOptions;
@dynamic centralManager;

- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral centralManager:(nonnull CNjacobCentralManager *)centralManager {
    
    return [self initWithPeripheral:peripheral advertisementData:nil RSSI:nil centralManager:centralManager];
}

- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI centralManager:(nonnull CNjacobCentralManager *)centralManager {
    
    self = [super init];
    if (self) {
        self.centralManager = centralManager;
        self.discoveredServices = [NSMutableDictionary<NSString *, CNjacobService *> dictionary];
        self.applePeripheral = peripheral;
        self.applePeripheral.delegate = self;
        self.advertisementData = advertisementData;
        self.RSSI = RSSI;
        self.connectRetryTimes = self.centralManager.options.connectRetryTimes;
    }
    return self;
}

- (void)didConnectPeripheral:(NSError *)error {
    // Reset connection sequence number
    self.connectionSequenceNumber = 0;
    
    if (error
        && self.centralManager.options.autoReconnectAfterDisconnect
        && self.connectRetryTimes > 0) {
        
        // Decrease retry times and try to reconnect
        self.connectRetryTimes --;
        [self connect:self.connectOptions callback:self.connectCallback];
        
    } else {
        // Connect callback
        CNJACOB_ASYNC_CALLBACK(self.connectCallback,
                               self.connectCallback(self, error),
                               CNjacobPeripheral,
                               self.centralManager);
        // Cancel delay callback
        [self.centralManager cancelDelayCallback:self.delayCallback];
        
        // Free delay callback
        self.delayCallback = nil;
    }
}

- (void)didDisconnectPeripheral:(NSError *)error {
    
    self.connectRetryTimes = self.centralManager.options.connectRetryTimes;
    
    // Disconnect callback
    if (self.disconnectCallback) {
        CNJACOB_ASYNC_CALLBACK(self.disconnectCallback,
                               self.disconnectCallback(self, error),
                               CNjacobPeripheral,
                               self.centralManager);
        
    } else if (self.receiveDisconnectCallback) {
        // Receive disconnect callback
        CNJACOB_ASYNC_CALLBACK(self.receiveDisconnectCallback,
                               self.receiveDisconnectCallback(self, error),
                               CNjacobPeripheral,
                               self.centralManager)
    }
}

- (void)didReceiveAdvertising:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI {
    
    self.advertisementData = advertisementData;
    self.RSSI = RSSI;
    // Here has a bug, because didDiscoverPeripheral using async callback,
    //      so this may happens before you call receiveAdvertising
    CNJACOB_ASYNC_CALLBACK(self.receiveAdvertisingCallback,
                           self.receiveAdvertisingCallback(self, nil),
                           CNjacobPeripheral,
                           self.centralManager);
}

@end

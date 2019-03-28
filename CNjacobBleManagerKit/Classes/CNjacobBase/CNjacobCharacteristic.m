//
//  CNjacobCharacteristic.m
//  CNjacobBleManagerKit
//
//  Created by CNjacob on 2019/3/26.
//

#import "CNjacobCharacteristic.h"
#import <CoreBluetooth/CoreBluetooth.h>

#import "CNjacobBluetoothManager+Private.h"
#import "CNjacobCentralManager.h"
#import "CNjacobCentralManagerOptions.h"

#import "CNjacobPeripheral+Private.h"

#import "CNjacobAttribute.h"
#import "CNjacobService+Private.h"
#import "CNjacobCharacteristic+Private.h"

@interface CNjacobCharacteristic () {
    CBUUID *_UUID;
}

@property (nonatomic, strong) CBCharacteristic *appleCharacteristic;

@property (nonatomic, strong) NSMutableDictionary<NSString *, CNjacobDescriptor *> *discoveredDescriptors;

@property (nonatomic, copy) dispatch_block_t readDelayCallback;

@property (nonatomic, copy) dispatch_block_t writeDelayCallback;

@property (nonatomic, copy) CNjacobCharacteristicCallback readCallback;

@property (nonatomic, copy) CNjacobCharacteristicCallback notificationStateCallback;

@property (nonatomic, copy) CNjacobCharacteristicCallback discoverDescriptorCallback;

@property (nonatomic, assign) BOOL readReceived;

@property (nonatomic, assign) BOOL writeReceived;

@property (nonatomic, assign) CNjacobService *service;

@property (nonatomic, strong) NSMutableArray<CNjacobCharacteristicWriteQueueData *> *writingQueue;

@end





@implementation CNjacobCharacteristic

- (BOOL)isNotifying {
    
    return self.appleCharacteristic.isNotifying;
}

- (CBUUID *)UUID {
    
    if (!_UUID) {
        _UUID = _appleCharacteristic.UUID;
    }
    
    return _UUID;
}

- (NSString *)name {
    
    return @"Unkown";
}

- (NSData *)value {
    
    return self.appleCharacteristic.value;
}

- (NSArray<CNjacobDescriptor *> *)descriptors {
    
    return self.discoveredDescriptors.allValues;
}

- (BOOL)propertyEnabled:(CNjacobCharacteristicProperties)property {
    
    return (self.appleCharacteristic.properties & (CBCharacteristicProperties)property);
}

- (void)readData:(CNjacobCharacteristicCallback)readCallback {
    
    if (!readCallback) {
        return ;
    }
    
    self.readCallback = readCallback;
    
    // Check read property
    if ([self propertyEnabled:CNjacobCharacteristicPropertyRead]) {
        self.readReceived = NO;
        [self.service.peripheral.applePeripheral readValueForCharacteristic:self.appleCharacteristic];
        [self readTimeout];
        
    } else {
        [self readNotSupportErrorCallback];
    }
}

- (void)receiveUpdates:(CNjacobCharacteristicCallback)notifyCallback {
    
    if (!notifyCallback) {
        return ;
    }
    
    if (![self propertyEnabled:CNjacobCharacteristicPropertyNotify]) {
        return ;
    }
    
    self.readCallback = notifyCallback;
}

- (void)dropUpdates {
    
    self.readCallback = nil;
}

- (void)startNotifications:(CNjacobCharacteristicCallback)notificationStateCallback {
    
    self.notificationStateCallback = notificationStateCallback;
    
    if ([self propertyEnabled:CNjacobCharacteristicPropertyNotify]) {
        [self.service.peripheral.applePeripheral setNotifyValue:YES forCharacteristic:self.appleCharacteristic];
        
    } else {
        [self notificationNotSupportErrorCallback];
    }
}

- (void)stopNotifications:(CNjacobCharacteristicCallback)notificationStateCallback {
    
    self.notificationStateCallback = notificationStateCallback;
    
    if ([self propertyEnabled:CNjacobCharacteristicPropertyNotify]) {
        [self.service.peripheral.applePeripheral setNotifyValue:NO forCharacteristic:self.appleCharacteristic];
        
    } else {
        [self notificationNotSupportErrorCallback];
    }
}

- (void)writeData:(NSData *)data {
    
    if ([self propertyEnabled:CNjacobCharacteristicPropertyWriteWithoutResponse]) {
        
        if ([self.service.peripheral.applePeripheral canSendWriteWithoutResponse]) {
            [self.service.peripheral.applePeripheral writeValue:data forCharacteristic:self.appleCharacteristic type:CBCharacteristicWriteWithoutResponse];
            
        } else {
            //TODO: peripheralIsReadyToSendWriteWithoutResponse
        }
        
    } else if ([self propertyEnabled:CNjacobCharacteristicPropertyWrite]) {
        [self writeData:data callback:nil];
        
    } else {
        // Write not support
    }
}

- (void)writeData:(NSData *)data callback:(CNjacobCharacteristicWriteDataCallback)writeCallback {
    
    // Create a queue data
    NSInteger retryTimes = self.centralManager.options.writeRetryTimes;
    
    CNjacobCharacteristicWriteQueueData *queueData = [[CNjacobCharacteristicWriteQueueData alloc] initWithData:data retryTimes:retryTimes callback:writeCallback];
    
    // Add data to queue
    @synchronized (self.writingQueue) {
        [self.writingQueue addObject:queueData];
    }
    
    // Start write in queue
    [self writeQueueData];
}

- (void)discoverDiscriptors:(CNjacobCharacteristicCallback)discoverDescriptorCallback {
    
    self.discoverDescriptorCallback = discoverDescriptorCallback;
    
    [self.service.peripheral.applePeripheral discoverDescriptorsForCharacteristic:self.appleCharacteristic];
}

- (void)readTimeout {
    
    NSTimeInterval timeoutInterval = self.centralManager.options.readTimeoutInterval;
    
    if (timeoutInterval <= 0) {
        return ;
    }
    
    __weak typeof(self) weakSelf = self;
    self.readDelayCallback = dispatch_block_create(0, ^{
        [weakSelf handleReadTimeout];
    });
    [self.centralManager delayCallback:timeoutInterval withBlock:self.readDelayCallback];
}

- (void)handleReadTimeout {
    
    if (self.readReceived) {
        return ;
    }
    
    // Read timeout, cancel peripheral connection
//        [self.centralManager.cbCentralManager
//            cancelPeripheralConnection:self.service.peripheral.cbPeripheral];
    
    NSError *error = [self.centralManager error:@{NSLocalizedDescriptionKey: @"Read data timeout."}];
    [self didUpdateValue:error];
}

- (void)readNotSupportErrorCallback {
    
    NSError *error = [self.centralManager error:@{NSLocalizedDescriptionKey: @"Read not supported."}];
    CNJACOB_ASYNC_CALLBACK(self.readCallback,
                           self.readCallback(self, error),
                           CNjacobCharacteristic,
                           self.centralManager);
}

- (void)notificationNotSupportErrorCallback {
    
    NSError *error = [self.centralManager error:@{NSLocalizedDescriptionKey: @"Notifications not supported."}];
    CNJACOB_ASYNC_CALLBACK(self.notificationStateCallback,
                           self.notificationStateCallback(self, error),
                           CNjacobCharacteristic,
                           self.centralManager);
}

@end

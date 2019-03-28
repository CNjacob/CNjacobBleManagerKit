//
//  CNjacobPeripheral.m
//  CNjacobBleManagerKit
//
//  Created by CNjacob on 2019/3/26.
//

#import "CNjacobPeripheral.h"
#import <CoreBluetooth/CoreBluetooth.h>

#import "CNjacobBluetoothManager+Private.h"
#import "CNjacobCentralManager.h"
#import "CNjacobCentralManager+Private.h"
#import "CNjacobCentralManagerOptions.h"

#import "CNjacobPeripheral+Private.h"

#import "CNjacobService+Private.h"
#import "CNjacobCharacteristic+Private.h"
#import "CNjacobDescriptor+Private.h"

@interface CNjacobPeripheral ()

@property (nonatomic, strong) CBPeripheral *applePeripheral;

@property (nonatomic, copy) dispatch_block_t delayCallback;

@property (nonatomic, copy) CNjacobPeripheralCallback connectCallback;

@property (nonatomic, copy) CNjacobPeripheralCallback disconnectCallback;

@property (nonatomic, copy) CNjacobPeripheralCallback receiveDisconnectCallback;

@property (nonatomic, copy) CNjacobPeripheralCallback receiveAdvertisingCallback;

@property (nonatomic, copy) CNjacobPeripheralCallback discoverServiceCallback;

@property (nonatomic, copy) CNjacobPeripheralCallback discoverCharacteristicCallback;

@property (nonatomic, copy) CNjacobPeripheralCallback readRSSICallback;

/**
 *  @property connectRetryTimes if connect failed or timeout how many times it will retry
 */
@property (nonatomic, assign) NSInteger connectRetryTimes;

@property (nonatomic, assign) NSInteger connectionSequenceNumber;

@property (nonatomic, strong) NSMutableDictionary<NSString *, CNjacobService *> *discoveredServices;

@property (atomic, strong) NSDictionary<NSString *, id> *advertisementData;

@property (nonatomic, strong) NSNumber *RSSI;

@property (nonatomic, strong) NSDictionary<NSString *,id> *connectOptions;

@property (nonatomic, assign) CNjacobCentralManager *centralManager;

@property (nonatomic, assign) BOOL isWaitingDiscoveringCharacteristics;

@property (nonatomic, strong) NSArray<CBUUID *> *characteristicUUIDs;

@end





@implementation CNjacobPeripheral

- (NSArray<CNjacobService *> *)services {
    
    return self.discoveredServices.allValues;
}

- (NSUUID *)identifier {
    
    return self.applePeripheral.identifier;
}

- (NSString *)name {
    
    NSString *name = [self.advertisementData objectForKey:CBAdvertisementDataLocalNameKey];
    if (name) {
        return name;
    }
    
    return self.applePeripheral.name;
}

- (CNjacobPeripheralState)state {
    
    return (CNjacobPeripheralState)self.applePeripheral.state;
}

- (void)connect:(CNjacobPeripheralCallback)connectCallback {
    
    [self connect:self.centralManager.options.connectOptions callback:connectCallback];
}

- (void)connect:(NSDictionary<NSString *,id> *)connectOptions callback:(CNjacobPeripheralCallback)connectCallback {
    
    if (self.state == CNjacobPeripheralStateConnected
        || self.state == CNjacobPeripheralStateConnecting) {
        return ;
    }
    
    self.connectOptions = connectOptions;
    self.connectCallback = connectCallback;
    
    // Connect use central manager
    [self.centralManager.appleCentralManager connectPeripheral:self.applePeripheral options:connectOptions];
    
    // Increce connection sequence number
    self.connectionSequenceNumber ++;
    
    // Timeout connection
    [self timeoutConnection:self.connectionSequenceNumber];
}

- (void)timeoutConnection:(NSInteger)connectionSequenceNumber {
    
    NSTimeInterval connectTimeoutInterval = self.centralManager.options.connectTimeoutInterval;
    if (connectTimeoutInterval <= 0) {
        return ;
    }
    
    __weak typeof(self) weakSelf = self;
    self.delayCallback = dispatch_block_create(0, ^{
        [weakSelf handleTimeoutConnection:connectionSequenceNumber];
    });
    [self.centralManager delayCallback:connectTimeoutInterval withBlock:self.delayCallback];
}

- (void)handleTimeoutConnection:(NSInteger)connectionSequenceNumber {
    
    if (self.state == CNjacobPeripheralStateConnected
        || connectionSequenceNumber != self.connectionSequenceNumber) {
        return ;
    }
    
    // Assign a timeout error to peipheral
    self.error = [self.centralManager error:@{NSLocalizedDescriptionKey: @"Connection timeout."}];
    // Cancel peripheral connection
    [self.centralManager.appleCentralManager cancelPeripheralConnection:self.applePeripheral];
}

- (void)disconnect {
    
    [self disconnect:nil];
}

- (void)disconnect:(CNjacobPeripheralCallback)disconnectCallback {
    
    if (self.state != CNjacobPeripheralStateConnected) {
        return ;
    }
    
    self.disconnectCallback = disconnectCallback;
    // Disconnect use central manager
    [self.centralManager.appleCentralManager cancelPeripheralConnection:self.applePeripheral];
}

- (void)receiveDisconnect:(CNjacobPeripheralCallback)receiveDisconnectCallback {
    
    self.receiveDisconnectCallback = receiveDisconnectCallback;
}

- (void)dropDisconnect {
    
    [self.centralManager asyncCallback:^{
        self.receiveDisconnectCallback = nil;
    }];
}

- (void)receiveAdvertising:(CNjacobPeripheralCallback)receiveAdvertisingCallback {
    
    self.receiveAdvertisingCallback = receiveAdvertisingCallback;
}

- (void)dropAdvertising {
    
    [self.centralManager asyncCallback:^{
        self.receiveAdvertisingCallback = nil;
    }];
}

- (void)readRSSI:(CNjacobPeripheralCallback)readRSSICallback {
    
    self.readRSSICallback = readRSSICallback;
    [self readRSSI];
}

- (void)readRSSI {
    
    if (self.state != CNjacobPeripheralStateConnected) {
        return ;
    }
    
    [self.applePeripheral readRSSI];
}

- (void)dropRSSIUpdates {
    
    [self.centralManager asyncCallback:^{
        self.readRSSICallback = nil;
    }];
}

- (void)discoverServices:(CNjacobPeripheralCallback)discoverCallback {
    
    [self discoverServices:nil callback:discoverCallback];
}

- (void)discoverServices:(NSArray<CBUUID *> *)serviceUUIDs callback:(CNjacobPeripheralCallback)discoverCallback {
    
    self.discoverServiceCallback = discoverCallback;
    self.isWaitingDiscoveringCharacteristics = NO;
    [self.applePeripheral discoverServices:serviceUUIDs];
}

- (void)discoverServicesAndCharacteristics:(CNjacobPeripheralCallback)discoverCallback {
    
    [self discoverServices:nil andCharacteristics:nil callback:discoverCallback];
}

- (void)discoverServices:(NSArray<CBUUID *> *)serviceUUIDs andCharacteristics:(NSArray<CBUUID *> *)characteristicUUIDs callback:(CNjacobPeripheralCallback)discoverCallback {
    
    self.discoverCharacteristicCallback = discoverCallback;
    self.characteristicUUIDs = characteristicUUIDs;
    self.isWaitingDiscoveringCharacteristics = YES;
    [self.applePeripheral discoverServices:serviceUUIDs];
}





#pragma mark - CBPeripheralDelegate
/**
 *  @method peripheralDidUpdateName:
 *  This method is invoked when the name of <i>peripheral</i> changes.
 */
- (void)peripheralDidUpdateName:(CBPeripheral *)peripheral NS_AVAILABLE(10_9, 6_0) {
    // Do nothing currently
}

/**
 *  @method peripheral:didModifyServices:
 *  This method is invoked when the services of <i>peripheral</i> have been changed.
 */
- (void)peripheral:(CBPeripheral *)peripheral didModifyServices:(NSArray<CBService *> *)invalidatedServices NS_AVAILABLE(10_9, 7_0) {
    // Do nothing currently
}

//- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral
//                          error:(nullable NSError *)error NS_DEPRECATED(10_7, 10_13, 5_0, 8_0) {
//    // Deprecated
//}

/**
 *  @method peripheral:didReadRSSI:error:
 *  This method returns the result of a readRSSI: call.
 */
- (void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(nullable NSError *)error NS_AVAILABLE(10_13, 8_0) {
    
    CNJACOB_ASYNC_CALLBACK(self.readRSSICallback,
                           self.readRSSICallback(self, error),
                           CNjacobPeripheral,
                           self.centralManager);
}

/**
 *  @method peripheral:didDiscoverServices:
 *  This method returns the result of a discoverServices: call.
 *      If the service(s) were read successfully
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(nullable NSError *)error {
    // Clear services
    for (CNjacobService *service in self.discoveredServices.allValues) {
        [service removeAllCharacteristics];
    }
    [self.discoveredServices removeAllObjects];
    
    // Add services
    for (CBService *service in peripheral.services) {
        CNjacobService *cnjacobService = [[CNjacobService alloc] initWithService:service peripheral:self];
        [self.discoveredServices setObject:cnjacobService forKey:service.UUID.UUIDString];
        
        // Discover characteristic
        if (!self.isWaitingDiscoveringCharacteristics) {
            return ;
        }
        
        [cnjacobService discoverCharacteristics:self.characteristicUUIDs callback:nil];
    }
    
    CNJACOB_ASYNC_CALLBACK(self.discoverServiceCallback,
                           self.discoverServiceCallback(self, error),
                           CNjacobPeripheral,
                           self.centralManager);
}

/**
 *  @method peripheral:didDiscoverIncludedServicesForService:error:
 *  This method returns the result of a discoverIncludedServices:forService: call.
 *      If the included service(s) were read successfully,
 *  they can be retrieved via <i>service</i>'s <code>includedServices</code> property.
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverIncludedServicesForService:(CBService *)service error:(nullable NSError *)error {
    
    CNjacobService *cnjacobService = [self.discoveredServices objectForKey:service.UUID.UUIDString];
    if (!cnjacobService) {
        return ;
    }
    
    for (CBService *includedService in service.includedServices) {
        
        CNjacobService *includedCNjacobService = [self.discoveredServices objectForKey:includedService.UUID.UUIDString];
        
        if (!includedCNjacobService) {
            includedCNjacobService = [[CNjacobService alloc] initWithService:includedService peripheral:self];
        }
        
        [cnjacobService.discoveredIncludedServices setObject:includedCNjacobService forKey:includedService.UUID.UUIDString];
    }
}

/**
 *  @method peripheral:didDiscoverCharacteristicsForService:error:
 *  This method returns the result of a discoverCharacteristics:forService: call.
 *      If the characteristic(s) were read successfully,
 *  they can be retrieved via <i>service</i>'s <code>characteristics</code> property.
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(nullable NSError *)error {
    
    CNJACOB_ASYNC_CALLBACK(self.discoverCharacteristicCallback,
                           self.discoverCharacteristicCallback(self, error),
                           CNjacobPeripheral,
                           self.centralManager);
    
    CNjacobService *cnjacobService = [self.discoveredServices objectForKey:service.UUID.UUIDString];
    if (!cnjacobService) {
        return ;
    }
    
    [cnjacobService removeAllCharacteristics];
    for (CBCharacteristic *characteristic in service.characteristics) {
        CNjacobCharacteristic *cnjacobCharacteristic = [[CNjacobCharacteristic alloc] initWithCharacteristic:characteristic service:cnjacobService];
        [cnjacobService.discoveredCharacterists setObject:cnjacobCharacteristic forKey:characteristic.UUID.UUIDString];
    }
    
    // Service discover callback
    [cnjacobService didDiscoverCharacteristics:error];
}

/**
 *  @method peripheral:didUpdateValueForCharacteristic:error:
 *  This method is invoked after a readValueForCharacteristic: call,
 *      or upon receipt of a notification/indication.
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error {
    
    [self didUpdateValueForCharacteristic:characteristic error:error];
}

/**
 *  @method peripheral:didWriteValueForCharacteristic:error:
 *  This method returns the result of a writeValue:forCharacteristic:type: call,
 *      when the CBCharacteristicWriteWithResponse type is used.
 */
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error {
    
    [self didWriteValueForCharacteristic:characteristic error:error];
}

- (void)didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
    [self didUpdateOrWriteValueForCharacteristic:characteristic error:error isUpdate:YES];
}

- (void)didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
    [self didUpdateOrWriteValueForCharacteristic:characteristic error:error isUpdate:NO];
}

- (void)didUpdateOrWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error isUpdate:(BOOL)isUpdate {
    
    CNjacobService *cnjacobService = [self.discoveredServices objectForKey:characteristic.service.UUID.UUIDString];
    if (!cnjacobService) {
        return ;
    }
    
    CNjacobCharacteristic *cnjacobCharacteristic = [cnjacobService.discoveredCharacterists objectForKey:characteristic.UUID.UUIDString];
    if (!cnjacobCharacteristic) {
        return ;
    }
    
    if (isUpdate) {
        [cnjacobCharacteristic didUpdateValue:error];
        
    } else {
        [cnjacobCharacteristic didWriteValue:error];
    }
}

/**
 * @method peripheral:didUpdateNotificationStateForCharacteristic:error:
 * This method returns the result of a setNotifyValue:forCharacteristic: call.
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error {
    
    CNjacobService *cnjacobService = [self.discoveredServices objectForKey:characteristic.service.UUID.UUIDString];
    if (!cnjacobService) {
        return ;
    }
    
    CNjacobCharacteristic *cnjacobCharacteristic = [cnjacobService.discoveredCharacterists objectForKey:characteristic.UUID.UUIDString];
    if (!cnjacobCharacteristic) {
        return ;
    }
    
    [cnjacobCharacteristic didUpdateNotificationState:error];
}

/**
 *  @method peripheral:didDiscoverDescriptorsForCharacteristic:error:
 *  This method returns the result of a discoverDescriptorsForCharacteristic: call.
 *      If the descriptors were read successfully,
 *  they can be retrieved via <i>characteristic</i>'s <code>descriptors</code> property.
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error {
    
    CNjacobService *cnjacobService = [self.discoveredServices objectForKey:characteristic.service.UUID.UUIDString];
    if (!cnjacobService) {
        return ;
    }
    
    CNjacobCharacteristic *cnjacobCharacteristic = [cnjacobService.discoveredCharacterists objectForKey:characteristic.UUID.UUIDString];
    if (!cnjacobCharacteristic) {
        return ;
    }
    
    for (CBDescriptor *descriptor in characteristic.descriptors) {
        CNjacobDescriptor *cnjacobDescriptor = [[CNjacobDescriptor alloc] initWithDescriptor:descriptor characteristic:cnjacobCharacteristic];
        [cnjacobCharacteristic.discoveredDescriptors setObject:cnjacobDescriptor
                                                   forKey:descriptor.UUID.UUIDString];
    }
    [cnjacobCharacteristic didDiscoverDescriptors:error];
}

/**
 *  @method peripheral:didUpdateValueForDescriptor:error:
 *  This method returns the result of a readValueForDescriptor: call.
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(nullable NSError *)error {
    
    [self didUpdateValueForDescriptor:descriptor error:error];
}

- (void)didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error {
    
    [self didUpdateOrWriteValueForDescriptor:descriptor error:error readOrWrite:YES];
}

- (void)didUpdateOrWriteValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error readOrWrite:(BOOL)readOrWrite {
    
    CNjacobService *cnjacobService = [self.discoveredServices objectForKey:descriptor.characteristic.service.UUID.UUIDString];
    
    CNjacobCharacteristic *cnjacobCharacteristic = [cnjacobService.discoveredCharacterists objectForKey:descriptor.characteristic.UUID.UUIDString];
    if (!cnjacobCharacteristic) {
        return ;
    }
    
    CNjacobDescriptor *cnjacobDescriptor = [cnjacobCharacteristic.discoveredDescriptors objectForKey:descriptor.UUID.UUIDString];
    if (!cnjacobDescriptor) {
        return;
    }
    
    if (readOrWrite) {
        [cnjacobDescriptor didUpdateValue:error];
        
    } else {
        [cnjacobDescriptor didWriteValue:error];
    }
}

/**
 *  @method peripheral:didWriteValueForDescriptor:error:
 *  This method returns the result of a writeValue:forDescriptor: call.
 */
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForDescriptor:(CBDescriptor *)descriptor error:(nullable NSError *)error {
    
    [self didWriteValueForDescriptor:descriptor error:error];
}

- (void)didWriteValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error {
    
    [self didUpdateOrWriteValueForDescriptor:descriptor error:error readOrWrite:NO];
}

/**
 *  @method peripheralIsReadyToSendWriteWithoutResponse:
 *  This method is invoked after a failed call to writeValue:forCharacteristic:type:,
 *      when <i>peripheral</i> is again
 *  ready to send characteristic value updates.
 */
- (void)peripheralIsReadyToSendWriteWithoutResponse:(CBPeripheral *)peripheral {
    
}

/**
 *  @method peripheral:didOpenL2CAPChannel:error:
 *  This method returns the result of a openL2CAPChannel: call.
 */
- (void)peripheral:(CBPeripheral *)peripheral didOpenL2CAPChannel:(nullable CBL2CAPChannel *)channel error:(nullable NSError *)error NS_AVAILABLE_IOS(11.0) {
    // Do nothing currently
}

@end

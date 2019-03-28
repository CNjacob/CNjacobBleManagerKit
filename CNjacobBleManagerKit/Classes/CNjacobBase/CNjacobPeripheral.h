//
//  CNjacobPeripheral.h
//  CNjacobBleManagerKit
//
//  Created by CNjacob on 2019/3/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  @enum CNjacobPeripheralState
 *
 *  @discussion Represents the current state of a CNjacobPeripheral.
 *
 *  @constant CNjacobPeripheralStateDisconnected       State disconnected, update imminent.
 *  @constant CNjacobPeripheralStateConnecting         State connecting.
 *  @constant CNjacobPeripheralStateConnected          State connected.
 *  @constant CNjacobPeripheralStateDisconnecting      State disconnecting.
 */
typedef NS_ENUM(NSInteger, CNjacobPeripheralState) {
    CNjacobPeripheralStateDisconnected = 0,
    CNjacobPeripheralStateConnecting,
    CNjacobPeripheralStateConnected,
    CNjacobPeripheralStateDisconnecting NS_AVAILABLE(10_13, 9_0),
};

@class CBUUID, CNjacobService, CNjacobPeripheral;

/**
 *  Peripheral connect callback
 *
 *  @discussion A common peripheral callback
 */
typedef void (^CNjacobPeripheralCallback) (CNjacobPeripheral *peripheral, NSError * _Nullable error);





/**
 *  @class CNjacobPeripheral
 */
@interface CNjacobPeripheral : NSObject

/**
 *  @property services
 */
@property (nonatomic, strong, readonly) NSArray<CNjacobService *> *services;

/**
 *  @property identifier NSUUID
 */
@property (nonatomic, strong, readonly) NSUUID *identifier;

/**
 *  @property name
 */
@property (nonatomic, strong, readonly) NSString *name;

/**
 *  @property state
 */
@property (nonatomic, assign, readonly) CNjacobPeripheralState state;

/**
 *  @property advertisementData
 */
@property (atomic, strong, readonly) NSDictionary<NSString *, id> *advertisementData;

/**
 *  @property error Connect error etc.
 */
@property (nonatomic, strong, nullable) NSError *error;





/**
 *  @method connect: Connect callback
 *
 *  @param connectCallback Connect callback handler
 */
- (void)connect:(nullable CNjacobPeripheralCallback)connectCallback;

/**
 *  @method connect: connect peripheral with callback and options
 *
 *  @param connectOptions connect options
 *  @param connectCallback Connect callback handler
 *  @seealso CBConnectPeripheralOptionNotifyOnConnectionKey
 *  @seealso CBConnectPeripheralOptionNotifyOnDisconnectionKey
 *  @seealso CBConnectPeripheralOptionNotifyOnNotificationKey
 */
- (void)connect:(nullable NSDictionary<NSString *, id> *)connectOptions callback:(nullable CNjacobPeripheralCallback)connectCallback;

/**
 *  @method disconnect
 */
- (void)disconnect;

/**
 *  @method disconnect: with disconnect callback
 */
- (void)disconnect:(nullable CNjacobPeripheralCallback)disconnectCallback;

/**
 *  @method receiveDisconnect
 */
- (void)receiveDisconnect:(nullable CNjacobPeripheralCallback)receiveDisconnectCallback;

/**
 *  @method dropDisconnect
 */
- (void)dropDisconnect;

/**
 *  @method receiveAdvertising
 */
- (void)receiveAdvertising:(CNjacobPeripheralCallback)receiveAdvertisingCallback;

/**
 *  @method dropAdvertising
 */
- (void)dropAdvertising;

/**
 *  @method readRSSI
 */
- (void)readRSSI:(nullable CNjacobPeripheralCallback)readRSSICallback;

/**
 *  @method dropRSSIUpdates
 */
- (void)dropRSSIUpdates;

/**
 *  @method discoverServices: with callback
 *
 *  @param discoverCallback discover callback
 */
- (void)discoverServices:(nullable CNjacobPeripheralCallback)discoverCallback;

/**
 *  @method discoverServices: with services UUIDs
 *
 *  @param serviceUUIDs service uuids to be discovered
 *  @param discoverCallback discover callback
 */
- (void)discoverServices:(nullable NSArray<CBUUID *> *)serviceUUIDs callback:(nullable CNjacobPeripheralCallback)discoverCallback;

/**
 *  @method discoverServicesAndCharacteristics
 *
 *  @param discoverCallback discover callback
 */
- (void)discoverServicesAndCharacteristics:(nullable CNjacobPeripheralCallback)discoverCallback;

/**
 *  @method discoverServices:andCharacteristics
 *
 *  @param serviceUUIDs     serviceUUIDs to be discovered
 *  @param characteristicUUIDs  characteristics to be discovered
 *  @param discoverCallback discover callback
 */
- (void)discoverServices:(nullable NSArray<CBUUID *> *)serviceUUIDs andCharacteristics:(nullable NSArray<CBUUID *> *)characteristicUUIDs callback:(nullable CNjacobPeripheralCallback)discoverCallback;

@end

NS_ASSUME_NONNULL_END

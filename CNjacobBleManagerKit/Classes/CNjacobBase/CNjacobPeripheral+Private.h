//
//  CNjacobPeripheral+Private.h
//  CNjacobBleManagerKit
//
//  Created by CNjacob on 2019/3/26.
//

#import "CNjacobPeripheral.h"
#import <CoreBluetooth/CoreBluetooth.h>

NS_ASSUME_NONNULL_BEGIN

@class CNjacobCentralManager, CNjacobService;

/**
 *  @Category CNjacobPeripheral+Private
 */
@interface CNjacobPeripheral (Private) <CBPeripheralDelegate>

@property (nonatomic, strong) CBPeripheral *applePeripheral;

@property (nonatomic, copy) CNjacobPeripheralCallback connectCallback;

@property (nonatomic, copy, nullable) dispatch_block_t delayCallback;

@property (nonatomic, copy) CNjacobPeripheralCallback disconnectCallback;

@property (nonatomic, copy) CNjacobPeripheralCallback receiveDisconnectCallback;

@property (nonatomic, copy) CNjacobPeripheralCallback receiveAdvertisingCallback;

@property (nonatomic, copy) CNjacobPeripheralCallback discoverCallback;

@property (nonatomic, assign) NSInteger connectionSequenceNumber;

@property (nonatomic, strong) NSMutableDictionary<NSString *, CNjacobService *> *discoveredServices;

@property (nonatomic, strong) NSDictionary<NSString *, id> *advertisementData;

@property (atomic, strong) NSNumber *RSSI;

/**
 *  @property connectRetryTimes if connect failed or timeout how many times it will retry
 */
@property (atomic, assign) NSInteger connectRetryTimes;

@property (nonatomic, strong) NSDictionary<NSString *,id> *connectOptions;

@property (nonatomic, assign) CNjacobCentralManager *centralManager;





/**
 *  @method initWithPeripheral Initialize a CNjacobPeripheral with a CBPeripheral object
 *
 *  @param peripheral Core Bluetooth Peripheral
 *  @param centralManager Access to central manager
 */
- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral
                    centralManager:(CNjacobCentralManager *)centralManager;

/**
 *  @method initWithPeripheral Initialize a CNjacobPeripheral with a CBPeripheral object, etc
 *
 *  @param peripheral Core Bluetooth Peripheral
 *  @param advertisementData Advertisement data
 *  @param RSSI RSSI number
 *  @param centralManager Access to central manager
 */
- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral
                 advertisementData:(nullable NSDictionary<NSString *,id> *)advertisementData
                              RSSI:(nullable NSNumber *)RSSI
                    centralManager:(CNjacobCentralManager *)centralManager;

/**
 *  @method didConnectPeripheral
 */
- (void)didConnectPeripheral:(nullable NSError *)error;

/**
 *  @method didDisconnectPeripheral
 */
- (void)didDisconnectPeripheral:(nullable NSError *)error;

/**
 *  @method didReceiveAdvertising
 */
- (void)didReceiveAdvertising:(nullable NSDictionary<NSString *,id> *)advertisementData
                         RSSI:(NSNumber *)RSSI;

@end

NS_ASSUME_NONNULL_END

//
//  CNjacobCentralManager.h
//  CNjacobBleManagerKit
//
//  Created by CNjacob on 2019/3/20.
//

#import "CNjacobBluetoothManager.h"

NS_ASSUME_NONNULL_BEGIN

@class CBCentralManager, CBUUID, CNjacobCentralManager, CNjacobCentralManagerOptions, CNjacobPeripheral;

//  CNjacobCentralManager common callback
typedef void (^CNjacobCentralManagerCallback) (CNjacobCentralManager *centralManager);

//  CNjacobCentralManager error callback
typedef void (^CNjacobCentralManagerErrorCallback) (CNjacobCentralManager *centralManager,
                                               NSError * _Nullable error);

//  CNjacobCentralManager discover peripheral callback
typedef void (^CNjacobCentralManagerDiscoverPeripheralCallback) (CNjacobCentralManager *centralManager,
                                                            CNjacobPeripheral *peripheral);





@interface CNjacobCentralManager : CNjacobBluetoothManager

/**
 *  @property options An optional dictionary specifying options for the manager.
 *
 *  @discussion CNjacobCentral manager options, see 'CNjacobCentralManagerOptions' for details
 */
@property (nonatomic, strong, readonly) CNjacobCentralManagerOptions *options;

/**
 *  @property connectedPeripherals A collect of connected peripherals
 */
@property (nonatomic, strong, readonly) NSArray *connectedPeripherals;

/**
 *  @property discoveredPeripherals A collect of discovered peripherals
 */
@property (nonatomic, strong, readonly) NSArray *discoveredPeripherals;





/**
 *  Creates and returns a 'CNjacobCenteralManager' object
 */
+ (CNjacobCentralManager *)manager;

/**
 *  @method stateDidUpdate:
 *
 *  @param stateDidUpdateCallback Callback after CNjacobCentralManager state did update
 */
- (void)stateDidUpdate:(CNjacobCentralManagerCallback)stateDidUpdateCallback;

/**
 *  @method startScanning: with callback
 *
 *  @param discoverPeripheralCallback discover callback
 */
- (void)startScanning:(nullable CNjacobCentralManagerDiscoverPeripheralCallback)discoverPeripheralCallback;

/**
 *  @method startScanning: with callback
 *
 *  @param discoverPeripheralCallback discover callback
 *  @param timeoutCallback scan timeout callback
 *          @see CNjacobCentralManagerOptions's scanTimeoutInterval
 */
- (void)startScanning:(nullable CNjacobCentralManagerDiscoverPeripheralCallback)discoverPeripheralCallback timeoutCallback:(nullable CNjacobCentralManagerErrorCallback)timeoutCallback;

/**
 *  @method startScanningForPeripheralsWithServices:discoverCallback
 *
 *  @param serviceUUIDs services to be discovered
 *  @param discoverPeripheralCallback discover peripheral callback
 *  @param timeoutCallback scan timeout callback
 *          @see CNjacobCentralManagerOptions's scanTimeoutInterval
 */
- (void)startScanningForPeripheralsWithServices:(nullable NSArray<CBUUID *> *)serviceUUIDs discoverCallback:(nullable CNjacobCentralManagerDiscoverPeripheralCallback)discoverPeripheralCallback timeoutCallback:(nullable CNjacobCentralManagerErrorCallback)timeoutCallback;

/**
 *  @method stopScanning
 */
- (void)stopScanning;

/**
 *  @method disconnectAllPeripherals
 */
- (void)disconnectAllPeripherals;

/**
 *  @method retrieveConnectedPeripheralsWithServices:
 */
- (NSArray<CNjacobPeripheral *> *)retrieveConnectedPeripheralsWithServices:(NSArray<CBUUID *> *)serviceUUIDs;

@end

NS_ASSUME_NONNULL_END

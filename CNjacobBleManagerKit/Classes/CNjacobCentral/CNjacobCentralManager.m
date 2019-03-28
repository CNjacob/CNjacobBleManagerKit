//
//  CNjacobCentralManager.m
//  CNjacobBleManagerKit
//
//  Created by CNjacob on 2019/3/20.
//

#import "CNjacobCentralManager.h"
#import <CoreBluetooth/CoreBluetooth.h>

#import "CNjacobBluetoothManager+Private.h"
#import "CNjacobCentralManager+Private.h"
#import "CNjacobCentralManagerOptions.h"

#import "CNjacobPeripheral.h"
#import "CNjacobPeripheral+Private.h"

@interface CNjacobCentralManager () <CBCentralManagerDelegate>

@property (nonatomic, strong) dispatch_queue_t mainQueue;

@property (nonatomic, strong) dispatch_queue_t callbackQueue;

@property (nonatomic, strong) CBCentralManager *appleCentralManager;

@property (nonatomic, strong) NSMutableDictionary<NSString *, CNjacobPeripheral *> *configuredConnectedPeripherals;

@property (nonatomic, strong) NSMutableDictionary<NSString *, CNjacobPeripheral *> *configuredDiscoveredPeripherals;

@property (nonatomic, copy) CNjacobCentralManagerCallback stateDidUpdateCallback;

@property (nonatomic, copy) CNjacobCentralManagerDiscoverPeripheralCallback discoverPeripheralCallback;

@property (nonatomic, copy) CNjacobCentralManagerErrorCallback timeoutCallback;

@property (nonatomic, copy) dispatch_block_t delayCallback;

/**
 *  @property isScanning, why use custom isScanning because
 *  CBCentralManager isScanning only works on ios9.0 or later
 */
@property (nonatomic, assign) BOOL isScanning;

@property (nonatomic, assign) BOOL isWaitingScanning;

@property (nonatomic, strong) NSArray<CBUUID *> *serviceUUIDs;

@end





@implementation CNjacobCentralManager

+ (CNjacobCentralManager *)manager {
    
    return [CNjacobCentralManager new];
}

- (instancetype)init {
    
    self = [super init];
    
    if (self) {
        _options = [[CNjacobCentralManagerOptions alloc] init];
        
        _configuredConnectedPeripherals = [NSMutableDictionary<NSString *, CNjacobPeripheral *> dictionary];
        _configuredDiscoveredPeripherals = [NSMutableDictionary<NSString *, CNjacobPeripheral *> dictionary];
        
        _mainQueue = [self createQueue:DISPATCH_QUEUE_SERIAL];
        _callbackQueue = [self createQueue:DISPATCH_QUEUE_SERIAL];
    }
    
    return self;
}

- (CBCentralManager *)appleCentralManager {
    
    if (!_appleCentralManager) {
        _appleCentralManager = [[CBCentralManager alloc] initWithDelegate:self queue:self.options.dispatchQueue options:self.options.managerOptions];
    }
    
    return _appleCentralManager;
}

- (CNjacobBluetoothManagerState)state {
    
    return (CNjacobBluetoothManagerState)self.appleCentralManager.state;
}

- (NSArray<CNjacobPeripheral *> *)connectedPeripherals {
    
    return self.configuredConnectedPeripherals.allValues;
}

- (NSArray<CNjacobPeripheral *> *)discoveredPeripherals {
    
    return self.configuredDiscoveredPeripherals.allValues;
}

- (void)stateDidUpdate:(CNjacobCentralManagerCallback)stateDidUpdateCallback {
    
    self.stateDidUpdateCallback = stateDidUpdateCallback;
    if (self.state != CNjacobBluetoothManagerStateUnknown) {
        [self centralManagerStateDidUpdateCallback];
    }
}

- (void)startScanning:(CNjacobCentralManagerDiscoverPeripheralCallback)discoverPeripheralCallback {
    
    [self startScanning:discoverPeripheralCallback timeoutCallback:nil];
}

- (void)startScanning:(CNjacobCentralManagerDiscoverPeripheralCallback)discoverPeripheralCallback timeoutCallback:(CNjacobCentralManagerErrorCallback)timeoutCallback {
    
    [self startScanningForPeripheralsWithServices:nil discoverCallback:discoverPeripheralCallback timeoutCallback:timeoutCallback];
}

- (void)startScanningForPeripheralsWithServices:(NSArray<CBUUID *> *)serviceUUIDs discoverCallback:(CNjacobCentralManagerDiscoverPeripheralCallback)discoverPeripheralCallback timeoutCallback:(CNjacobCentralManagerErrorCallback)timeoutCallback {
    
    self.serviceUUIDs = serviceUUIDs;
    
    if (self.isScanning) {
        return ;
    }
    
    self.isScanning = YES;
    // Clear all discovered peripherals
    [self.configuredDiscoveredPeripherals removeAllObjects];
    [self.configuredConnectedPeripherals removeAllObjects];
    
    self.discoverPeripheralCallback = discoverPeripheralCallback;
    self.timeoutCallback = timeoutCallback;
    
    if (self.state == CNjacobBluetoothManagerStatePoweredOn) {
        [self startScan:serviceUUIDs];
    } else {
        // Will start scan after power on
        self.isWaitingScanning = YES;
    }
}

- (void)startScan:(nullable NSArray<CBUUID *> *)serviceUUIDs {
    
    NSArray<CBUUID *> *UUIDs = serviceUUIDs ?: self.options.serviceUUIDs;
    [self.appleCentralManager scanForPeripheralsWithServices:UUIDs options:self.options.scanOptions];
    
    // Timeout check
    if (self.options.scanTimeoutInterval <= 0) {
        return ;
    }
    __weak typeof(self) weakSelf = self;
    self.delayCallback = dispatch_block_create(0, ^{
        [weakSelf handleScanTimeout];
    });
    [self delayCallback:self.options.scanTimeoutInterval withBlock:self.delayCallback];
}

- (void)handleScanTimeout {
    
    if (!self.isScanning) {
        return ;
    }
    
    // Stop scanning
    [self stopScanning];
    
    // Scanning timeout callback
    NSError *error = [self error:@{NSLocalizedDescriptionKey: @"Scanning timeout."}];
    
    CNJACOB_ASYNC_CALLBACK(self.timeoutCallback,
                           self.timeoutCallback(self, error),
                           CNjacobCentralManager,
                           self);
}

- (void)stopScanning {
    
    if (!self.isScanning) {
        return ;
    }
    self.isScanning = NO;
    [self.appleCentralManager stopScan];
}

- (void)disconnectAllPeripherals {
    
    for (CNjacobPeripheral *peripheral in self.configuredConnectedPeripherals) {
        [peripheral disconnect];
    }
}

- (NSArray<CNjacobPeripheral *> *)retrieveConnectedPeripheralsWithServices:(NSArray<CBUUID *> *)serviceUUIDs {
    
    NSArray<CBPeripheral *> *cbPeripherals = [self.appleCentralManager retrieveConnectedPeripheralsWithServices:serviceUUIDs];
    
    if (!cbPeripherals || cbPeripherals.count <= 0) {
        return nil;
    }
    
    NSMutableArray<CNjacobPeripheral *> *cnjacobPeripherals = [NSMutableArray<CNjacobPeripheral *> array];
    
    for (CBPeripheral *cbPeripheral in cbPeripherals) {
        
        CNjacobPeripheral *cnjacobPeripheral = [[CNjacobPeripheral alloc] initWithPeripheral:cbPeripheral centralManager:self];
        [cnjacobPeripherals addObject:cnjacobPeripheral];
        
        // Add to configured peripheral
        [self addPeripheral:cnjacobPeripheral to:self.configuredDiscoveredPeripherals];
    }
    
    return cnjacobPeripherals;
}





#pragma mark - CentralManagerDelegate
/**
 *  @method centralManagerDidUpdateState:
 *
 *  The central manager whose state has changed.
 *  You should call 'scanForPeripheralsWithServices'
 *          when central.state is CBCentralManagerStatePoweredOn
 */
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    
    CNjacobBluetoothManagerState state = (CNjacobBluetoothManagerState)central.state;
    // State did update callback
    [self centralManagerStateDidUpdateCallback];
    
    // Check is waiting scanning status
    if (state == CNjacobBluetoothManagerStatePoweredOn && self.isWaitingScanning) {
        self.isWaitingScanning = NO;
        [self startScan:self.serviceUUIDs];
        
    } else if (state != CNjacobBluetoothManagerStatePoweredOn) {
        // Not powered on state, stop scanning to reset is scanning state
        [self stopScanning];
    }
}

/**
 *  @method centralManager:willRestoreState:
 *            This method is invoked when the app is relaunched into the background
 *
 *  @seealso  CBCentralManagerRestoredStatePeripheralsKey;
 *  @seealso  CBCentralManagerRestoredStateScanServicesKey;
 *  @seealso  CBCentralManagerRestoredStateScanOptionsKey;
 */
- (void)centralManager:(CBCentralManager *)central
      willRestoreState:(NSDictionary<NSString *, id> *)dict {
    
    // App is relaunched into background
//    NSArray<CBPeripheral *> *peripherals =
//    [dict objectForKey:CBCentralManagerRestoredStatePeripheralsKey];
//    NSArray<CBService *> *services =
//    [dict objectForKey:CBCentralManagerRestoredStateScanServicesKey];
}

/**
 *  @method centralManager:didDiscoverPeripheral:advertisementData:RSSI:
 *
 *  Did discover peripheral callback
 *  This method is invoked after you call CBCentralManager's scanForPeripheralsWithServices
 */
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI {
    
    CNjacobPeripheral *jacobPeripheral = [self.configuredDiscoveredPeripherals objectForKey:peripheral.identifier.UUIDString];
    
    if (!jacobPeripheral) {
        jacobPeripheral = [[CNjacobPeripheral alloc] initWithPeripheral:peripheral
                                                 advertisementData:advertisementData
                                                              RSSI:RSSI
                                                    centralManager:self];
        // Add peripheral to discovered peripherals
        [self addPeripheral:jacobPeripheral to:self.configuredDiscoveredPeripherals];
        
    } else {
        [jacobPeripheral didReceiveAdvertising:advertisementData RSSI:RSSI];
    }
    
    // Peripheral callback
    [self discoverPeripheralCallback:jacobPeripheral];
}

/**
 *  @method centralManager:didConnectPeripheral:
 *
 *  Central did connect to peripheral callback
 *  This method is invoked afater you call CBCentralManager's connectPeripheral
 */
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    
    CNjacobPeripheral *cnjacobPeripheral = [self.configuredDiscoveredPeripherals objectForKey:peripheral.identifier.UUIDString];
    
    if (!cnjacobPeripheral) {
        return ;
    }
    
    // Add peripheral to connected peripherals if not exists in connected peripherals
    [self addPeripheral:cnjacobPeripheral to:self.configuredConnectedPeripherals];
    
    // Reset connect error because error property is not nil
    //      if has failed to connect before this
    cnjacobPeripheral.error = nil;
    
    // Peripheral connect callback
    [cnjacobPeripheral didConnectPeripheral:cnjacobPeripheral.error];
    
    // Cancel dealy callback
    [self cancelDelayCallback:self.delayCallback];
    
    // Free delay callback
    self.delayCallback = nil;
}

/**
 *  @method centralManager:didDisconnectPeripheral:error:
 *
 *  Central did disconnect from peripheral
 *  This method is invoked after you call CBCentralManager's cancelPeripheralConnection
 *      or by other reasons
 *  If this method is not invoked by CBCentralManager's cancelPeripheralConnection
 *      the cause will be detailed in the error parameters
 */
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    
    // Look up peripheral in discovered peripherals instead of connected peripherals
    CNjacobPeripheral *cnjacobPeripheral = [self.configuredDiscoveredPeripherals objectForKey:peripheral.identifier.UUIDString];
    
    if (!cnjacobPeripheral) {
        return ;
    }
    
    // Peripheral callback
    if (cnjacobPeripheral.error) {
        // Peripheral connect calback
        [cnjacobPeripheral didConnectPeripheral:cnjacobPeripheral.error];
        
    } else {
        // Peripheral connect calback
        [cnjacobPeripheral didDisconnectPeripheral:error];
    }
    
    // Remove peripheral from connected peripheral
    [self removePeripheral:cnjacobPeripheral to:self.configuredConnectedPeripherals];
}

/**
 *  @method centralManager:didFailToConnectPeripheral:error
 *
 *  Central did fail to connect peripheral
 *  This method is invoked after you call CBCentralManager's connectPeripheral,
 *      but failed to complete
 *  More details see the error parameter
 */
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    
    // Look up peripheral in discovered peripherals instead of connected peripherals
    CNjacobPeripheral *cnjacobPeripheral = [self.configuredDiscoveredPeripherals objectForKey:peripheral.identifier.UUIDString];
    
    if (!cnjacobPeripheral) {
        return ;
    }
    
    // Assign connect error to peripheral
    cnjacobPeripheral.error = error;
    
    // Peripheral connect calback
    [cnjacobPeripheral didConnectPeripheral:error];
}





#pragma mark - public
- (void)addPeripheral:(CNjacobPeripheral *)peripheral to:(NSMutableDictionary<NSString *, CNjacobPeripheral *> *)mutableDisctionary {
    
    if (!peripheral || !mutableDisctionary) {
        return ;
    }
    
    [mutableDisctionary setObject:peripheral forKey:peripheral.identifier.UUIDString];
}

- (void)removePeripheral:(CNjacobPeripheral *)peripheral to:(NSMutableDictionary<NSString *, CNjacobPeripheral *> *)mutableDictionary {
    
    if (!peripheral || !mutableDictionary) {
        return ;
    }
    
    [mutableDictionary removeObjectForKey:peripheral.identifier.UUIDString];
}

- (void)centralManagerStateDidUpdateCallback {
    
    CNJACOB_ASYNC_CALLBACK(self.stateDidUpdateCallback,
                           self.stateDidUpdateCallback(self),
                           CNjacobCentralManager,
                           self);
}

- (void)discoverPeripheralCallback:(CNjacobPeripheral *)peripheral {
    
    CNJACOB_ASYNC_CALLBACK(self.discoverPeripheralCallback,
                           self.discoverPeripheralCallback(self, peripheral),
                           CNjacobCentralManager,
                           self);
}

@end

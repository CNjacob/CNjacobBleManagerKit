//
//  CNjacobCentralManagerOptions.h
//  CNjacobBleManagerKit
//
//  Created by CNjacob on 2019/3/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class CBUUID;

/**
 *  @class CNjacobCentralManagerOptions
 */
@interface CNjacobCentralManagerOptions : NSObject

/**
 *  @property dispatchQueue, The dispatch queue on which the events will be dispatched.
 *  @discussion The events of the central role will be dispatched on the provided queue.
 *                  If <i>nil</i>, the main queue will be used.
 */
@property (nonatomic, strong) dispatch_queue_t dispatchQueue;

/**
 *  @property managerOptions, An optional dictionary specifying options for the manager.
 *
 *  @seealso CBCentralManagerOptionShowPowerAlertKey
 *  @seealso CBCentralManagerOptionRestoreIdentifierKey
 */
@property (nonatomic, strong) NSDictionary *managerOptions;

/**
 *  @property scanOptions An optional dictionary specifying options for the scan.
 *
 *  @see     centralManager:didDiscoverPeripheral:advertisementData:RSSI:
 *  @seealso CBCentralManagerScanOptionAllowDuplicatesKey
 *  @seealso CBCentralManagerScanOptionSolicitedServiceUUIDsKey
 */
@property (nonatomic, strong) NSDictionary *scanOptions;

/**
 *  @property serviceUUIDs A list of <code>CBUUID</code> objects representing the service(s) to scan for.
 *
 *  @see scanForPeripheralsWithServices:options:
 *  @see centralManager:didDiscoverPeripheral:advertisementData:RSSI:
 */
@property (nonatomic, strong) NSArray<CBUUID *> *serviceUUIDs;

/**
 *  @property connectOptions An optional dictionary specifying connection behavior options.
 *
 *  @see     centralManager:didConnectPeripheral:
 *  @see     centralManager:didFailToConnectPeripheral:error:
 *
 *  @seealso CBConnectPeripheralOptionNotifyOnConnectionKey
 *  @seealso CBConnectPeripheralOptionNotifyOnDisconnectionKey
 *  @seealso CBConnectPeripheralOptionNotifyOnNotificationKey
 */
@property (nonatomic, strong) NSDictionary *connectOptions;

/**
 *  @property scanTimeoutInterval
 *
 *  @discussion defalut value is foreveral
 */
@property (nonatomic, assign) NSTimeInterval scanTimeoutInterval;

/**
 *  @property connectTimeoutInterval
 *      A interval to specify how long it will wait when try to scan or connect to a peripheral
 *
 *  @discussion default value is 5s
 */
@property (nonatomic, assign) NSTimeInterval connectTimeoutInterval;

/**
 *  @property readTimeoutInterval
 *      A interval to specify how long it will wait until read callback
 *
 *  @discussion default value is 5s
 */
@property (nonatomic, assign) NSTimeInterval readTimeoutInterval;

/**
 *  @property writeTimeoutInterval
 *      A interval to specify how long it will wait until write callback
 *
 *  @discussion default value is 5s
 */
@property (nonatomic, assign) NSTimeInterval writeTimeoutInterval;

/**
 *  @property autoRewriteAfterFailure
 *      A flag to specify if auto re-write to characteristic after failure
 *
 *  @discussion default value is NO
 */
@property (nonatomic, assign) BOOL autoRewriteAfterFailure;

/**
 *  @property writeRetryTimes
 *      A interval to specify how many times it will retry to re-write when write failed
 *
 *  @discussion default value is 3
 */
@property (nonatomic, assign) NSTimeInterval writeRetryTimes;

/**
 *  @property autoReconnectAfterDisconnect
 *      A flag to specify if auto reconnect to peripheral after disconnect
 *
 *  @discussion default value is NO
 */
@property (nonatomic, assign) BOOL autoReconnectAfterDisconnect;

/**
 *  @property retryTimes
 *      An integer value to specify how many times it will retry to connect
 *      if the connect is timeout
 *
 *  @discussion default value is 3
 */
@property (nonatomic, assign) NSInteger connectRetryTimes;

@end

NS_ASSUME_NONNULL_END

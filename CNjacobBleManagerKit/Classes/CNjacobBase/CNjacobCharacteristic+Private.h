//
//  CNjacobCharacteristic+Private.h
//  CNjacobBleManagerKit
//
//  Created by CNjacob on 2019/3/26.
//

#import "CNjacobCharacteristic.h"

NS_ASSUME_NONNULL_BEGIN

@class CBCharacteristic;

/**
 *  @class
 */
@interface CNjacobCharacteristicWriteQueueData : NSObject

/**
 *  @property data
 */
@property (nonatomic, strong, readonly) NSData *data;

/**
 *  @property retryTimes
 */
@property (nonatomic, assign, readonly) NSInteger retryTimes;

/**
 *  @property writeCallback
 */
@property (nonatomic, copy, readonly) CNjacobCharacteristicWriteDataCallback writeCallback;





/**
 *  @method initWithData:retryTimes:callback
 */
- (instancetype)initWithData:(NSData *)data retryTimes:(NSInteger)retryTimes callback:(CNjacobCharacteristicWriteDataCallback)writeCallback;

@end





/**
 *  @Category CNjacobCharacteristic+Private
 */
@interface CNjacobCharacteristic (Private)

/**
 *  @property cbCharacteristic A CBCharacteristic object
 */
@property (nonatomic, strong) CBCharacteristic *appleCharacteristic;

/**
 *  @property discoveredDescriptors
 */
@property (nonatomic, strong)
NSMutableDictionary<NSString *, CNjacobDescriptor *> *discoveredDescriptors;

/**
 *  @property readCallback
 */
@property (nonatomic, copy) CNjacobCharacteristicCallback readCallback;

/**
 *  @property readDelayCallback
 */
@property (nonatomic, copy, nullable) dispatch_block_t readDelayCallback;

/**
 *  @property writeDelayCallback
 */
@property (nonatomic, copy, nullable) dispatch_block_t writeDelayCallback;

/**
 *  @property notificationCallback
 */
@property (nonatomic, copy) CNjacobCharacteristicCallback notificationStateCallback;

/**
 *  @property descriptorCallback
 */
@property (nonatomic, copy) CNjacobCharacteristicCallback discoverDescriptorCallback;

/**
 *  @property writingQueue, A list to keep writing data if callback specified
 */
@property (nonatomic, strong) NSMutableArray<CNjacobCharacteristicWriteQueueData *> *writingQueue;

/**
 *  @property readReceived
 */
@property (nonatomic, assign) BOOL readReceived;

/**
 *  @property writeReceived
 */
@property (nonatomic, assign) BOOL writeReceived;

/**
 *  @property service
 *
 *  @discussion
 *      A back-pointer to the service this characteristic belongs to.
 */
@property (nonatomic, assign, readwrite) CNjacobService *service;





/**
 *  @method initWithCharacteristic:service
 *
 *  @param characteristic A CBCharacteristic object
 *  @param service A CNjacobService object
 */
- (instancetype)initWithCharacteristic:(CBCharacteristic *)characteristic service:(CNjacobService *)service;

/**
 *  @method removeAllDescriptors
 */
- (void)removeAllDescriptors;

/**
 *  @method didUpdateValue:
 */
- (void)didUpdateValue:(nullable NSError *)error;

/**
 *  @method didWriteValue:
 */
- (void)didWriteValue:(nullable NSError *)error;

/**
 *  @method didUpdateNotificationState:
 */
- (void)didUpdateNotificationState:(nullable NSError *)error;

/**
 *  @method didDiscoverDescriptors
 */
- (void)didDiscoverDescriptors:(nullable NSError *)error;

/**
 *  @method writeQueueData
 */
- (void)writeQueueData;

@end

NS_ASSUME_NONNULL_END

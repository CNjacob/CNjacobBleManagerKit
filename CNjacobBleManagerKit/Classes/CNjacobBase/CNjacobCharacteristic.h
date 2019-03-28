//
//  CNjacobCharacteristic.h
//  CNjacobBleManagerKit
//
//  Created by CNjacob on 2019/3/26.
//

#import "CNjacobAttribute.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  @enum CNjacobCharacteristicProperties
 *
 *  @discussion Characteristic properties determine how the characteristic value can be used,
 *              or how the descriptor(s) can be accessed. Can be combined.
 *              Unless otherwise specified,
 *              properties are valid for local characteristics published via
 *              @link CNjacobPeripheralManager @/link.
 *
 *    @constant CNjacobCharacteristicPropertyBroadcast
 *              Permits broadcasts of the characteristic value
 *              using a characteristic configuration descriptor.
 *              Not allowed for local characteristics.
 *    @constant CNjacobCharacteristicPropertyRead
 *              Permits reads of the characteristic value.
 *    @constant CNjacobCharacteristicPropertyWriteWithoutResponse
 *              Permits writes of the characteristic value, without a response.
 *    @constant CNjacobCharacteristicPropertyWrite
 *              Permits writes of the characteristic value.
 *    @constant CNjacobCharacteristicPropertyNotify
 *              Permits notifications of the characteristic value, without a response.
 *    @constant CNjacobCharacteristicPropertyIndicate
 *              Permits indications of the characteristic value.
 *    @constant CNjacobCharacteristicPropertyAuthenticatedSignedWrites
 *              Permits signed writes of the characteristic value
 *    @constant CNjacobCharacteristicPropertyExtendedProperties
 *              If set, additional characteristic properties are defined
 *              in the characteristic extended properties descriptor.
 *              Not allowed for local characteristics.
 *    @constant CNjacobCharacteristicPropertyNotifyEncryptionRequired
 *              If set, only trusted devices can enable notifications of the characteristic value.
 *    @constant CNjacobCharacteristicPropertyIndicateEncryptionRequired
 *              If set, only trusted devices can enable indications of the characteristic value.
 */
typedef NS_OPTIONS(NSUInteger, CNjacobCharacteristicProperties) {
    CNjacobCharacteristicPropertyBroadcast                                                  = 0x01,
    CNjacobCharacteristicPropertyRead                                                       = 0x02,
    CNjacobCharacteristicPropertyWriteWithoutResponse                                       = 0x04,
    CNjacobCharacteristicPropertyWrite                                                      = 0x08,
    CNjacobCharacteristicPropertyNotify                                                     = 0x10,
    CNjacobCharacteristicPropertyIndicate                                                   = 0x20,
    CNjacobCharacteristicPropertyAuthenticatedSignedWrites                                  = 0x40,
    CNjacobCharacteristicPropertyExtendedProperties                                         = 0x80,
    CNjacobCharacteristicPropertyNotifyEncryptionRequired NS_ENUM_AVAILABLE(10_9, 6_0)      = 0x100,
    CNjacobCharacteristicPropertyIndicateEncryptionRequired NS_ENUM_AVAILABLE(10_9, 6_0)    = 0x200
};

@class CNjacobService, CNjacobCharacteristic, CNjacobDescriptor;

/**
 *  Write data callback
 */
typedef void (^CNjacobCharacteristicWriteDataCallback) (CNjacobCharacteristic *characteristic, NSData * _Nullable data, NSError * _Nullable error);

/**
 *  Characteristic common callback
 */
typedef void (^CNjacobCharacteristicCallback) (CNjacobCharacteristic *characteristic, NSError * _Nullable error);





/**
 *  @class CNjacobCharacteristic
 */
@interface CNjacobCharacteristic : CNjacobAttribute

/**
 *  @property service
 *
 *  @discussion
 *      A back-pointer to the service this characteristic belongs to.
 */
@property (nonatomic, assign, readonly) CNjacobService *service;

/**
 *  @property isNotifying
 */
@property (nonatomic, assign, readonly) BOOL isNotifying;

/**
 *  @property name
 */
@property (nonatomic, strong, readonly) NSString *name;

/**
 *  @property value
 */
@property (nonatomic, strong, readonly) NSData *value;

/**
 *  @property descriptors
 */
@property (nonatomic, strong, readonly) NSArray<CNjacobDescriptor *> *descriptors;





/**
 *  @method propertyEnabled: check if the characteristic has specified property enabled
 */
- (BOOL)propertyEnabled:(CNjacobCharacteristicProperties)property;

/**
 *  @method readData: with callback
 */
- (void)readData:(nullable CNjacobCharacteristicCallback)readCallback;

/**
 *  @method receiveUpdates
 */
- (void)receiveUpdates:(nullable CNjacobCharacteristicCallback)notifyCallback;

/**
 *  @method dropUpdates
 */
- (void)dropUpdates;

/**
 *  @method startNotifications: with callback
 */
- (void)startNotifications:(nullable CNjacobCharacteristicCallback)notificationStateCallback;

/**
 *  @method stopNotifications: with callback
 */
- (void)stopNotifications:(nullable CNjacobCharacteristicCallback)notificationStateCallback;

/**
 *  @method writeData without a callback
 */
- (void)writeData:(NSData *)data;

/**
 *  @method writeData: with a callback
 */
- (void)writeData:(NSData *)data callback:(nullable CNjacobCharacteristicWriteDataCallback)writeCallback;

/**
 *  @method discoverDescriptors: with callback
 */
- (void)discoverDiscriptors:(CNjacobCharacteristicCallback)discoverDescriptorCallback;

@end

NS_ASSUME_NONNULL_END

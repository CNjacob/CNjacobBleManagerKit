//
//  CNjacobService.h
//  CNjacobBleManagerKit
//
//  Created by CNjacob on 2019/3/26.
//

#import "CNjacobAttribute.h"

NS_ASSUME_NONNULL_BEGIN

@class CBUUID, CNjacobPeripheral, CNjacobCharacteristic, CNjacobService;

/**
 *  Discover characteristics callback
 */
typedef void (^CNjacobServiceDiscoverCharacteristicCallback) (CNjacobService *service, NSError * _Nullable error);





/**
 *  @class CNjacobService
 */
@interface CNjacobService : CNjacobAttribute

/**
 *  @property peripheral
 *
 *  @discussion
 *      A back-pointer to the peripheral this service belongs to.
 */
@property (nonatomic, assign, readonly) CNjacobPeripheral *peripheral;

/**
 *  @property characterists A collect of CNjacobCharacteristic
 */
@property (nonatomic, strong, readonly) NSArray<CNjacobCharacteristic *> *characteristics;

/**
 *  @property includedServices
 *      A list of included CBServices that have so far been discovered in this service.
 */
@property (nonatomic, strong, readonly) NSArray<CNjacobService *> *includedServices;

/**
 *  @property isPrimary
 */
@property (nonatomic, assign, readonly) BOOL isPrimary;

/**
 *  @property name
 */
@property (nonatomic, strong, readonly) NSString *name;





/**
 *  @method discoverCharacterists with callback
 *
 *  @param discoverCallback Discover callback
 */
- (void)discoverCharacteristics:(CNjacobServiceDiscoverCharacteristicCallback)discoverCallback;

/**
 *  @method discoverCharacterists with callback
 *
 *  @param characteristicUUIDs Characteristics to be discovered
 *  @param discoverCallback Discover callback
 */
- (void)discoverCharacteristics:(nullable NSArray<CBUUID *> *)characteristicUUIDs callback:(nullable CNjacobServiceDiscoverCharacteristicCallback)discoverCallback;

/**
 *  @method characteristicWithUUID:
 *
 *  @param UUID characteristicUUID to be searched
 *  @return CNjacobCharacteristic
 */
- (CNjacobCharacteristic *)characteristicWithUUID:(NSString *)UUID;

@end

NS_ASSUME_NONNULL_END

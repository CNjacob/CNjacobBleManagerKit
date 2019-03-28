//
//  CNjacobService+Private.h
//  CNjacobBleManagerKit
//
//  Created by CNjacob on 2019/3/26.
//

#import "CNjacobService.h"

NS_ASSUME_NONNULL_BEGIN

@class CBService, CNjacobCentralManager;

/**
 *  @Category CNjacobService+Private
 */
@interface CNjacobService (Private)

/**
 *  @property service A CBService object
 */
@property (nonatomic, strong) CBService *appleService;

/**
 *  @property characteristics
 */
@property (nonatomic, strong) NSMutableDictionary<NSString *, CNjacobCharacteristic *> *discoveredCharacterists;

/**
 *  @property discoveredIncludedServices
 */
@property (nonatomic, strong) NSMutableDictionary<NSString *, CNjacobService *> *discoveredIncludedServices;

/**
 *  @property peripheral
 *
 *  @discussion
 *      A back-pointer to the peripheral this service belongs to.
 */
@property (nonatomic, assign, readwrite) CNjacobPeripheral *peripheral;

/**
 *  @property Did discover characteristics callback
 */
@property (nonatomic, copy) CNjacobServiceDiscoverCharacteristicCallback discoverCallback;





/**
 *  @method initWithService:
 *
 *  @param service CBService object
 *  @param peripheral CNjacobPeripheral object
 */
- (instancetype)initWithService:(CBService *)service peripheral:(CNjacobPeripheral *)peripheral;

/**
 *  @method removeAllCharacteristics
 */
- (void)removeAllCharacteristics;

/**
 *  @method didDiscoverCharacteristics
 */
- (void)didDiscoverCharacteristics:(nullable NSError *)error;

@end

NS_ASSUME_NONNULL_END

//
//  CNjacobDescriptor+Private.h
//  CNjacobBleManagerKit
//
//  Created by CNjacob on 2019/3/26.
//

#import "CNjacobDescriptor.h"

NS_ASSUME_NONNULL_BEGIN

@class CBDescriptor, CNjacobCharacteristic, CNjacobCentralManager;

/**
 *  @Category CNjacobDescriptor+Private
 */
@interface CNjacobDescriptor (Private)

/**
 *  @property characteristic
 *
 *  @discussion
 *      A back-pointer to the characteristic this descriptor belongs to.
 */
@property (nonatomic, assign, readwrite) CNjacobCharacteristic *characteristic;

/**
 *  @property cbDescriptor
 */
@property (nonatomic, strong) CBDescriptor *appleDescriptor;

/**
 *  @property readCallback
 */
@property (nonatomic, copy) CNjacobDescriptorDataCallback readCallback;

/**
 *  @property writeCallback
 */
@property (nonatomic, copy) CNjacobDescriptorDataCallback writeCallback;





/**
 *  @method initWithDescriptor:characteristic
 *
 *  @param descriptor A CBDescriptor object
 *  @param characteristic A CNjacobCharacteristic object
 */
- (instancetype)initWithDescriptor:(CBDescriptor *)descriptor characteristic:(CNjacobCharacteristic *)characteristic;

/**
 *  @method didUpdateValue:
 */
- (void)didUpdateValue:(nullable NSError *)error;

/**
 *  @method didWriteValue:
 */
- (void)didWriteValue:(nullable NSError *)error;

@end

NS_ASSUME_NONNULL_END

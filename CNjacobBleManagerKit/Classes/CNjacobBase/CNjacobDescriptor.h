//
//  CNjacobDescriptor.h
//  CNjacobBleManagerKit
//
//  Created by CNjacob on 2019/3/26.
//

#import "CNjacobAttribute.h"

NS_ASSUME_NONNULL_BEGIN

@class CNjacobCharacteristic, CNjacobDescriptor;

typedef void (^CNjacobDescriptorDataCallback) (CNjacobDescriptor *descriptor, NSError * _Nullable error);





/**
 *  @class CNjacobDescriptor
 */
@interface CNjacobDescriptor : CNjacobAttribute

/**
 *  @property characteristic
 *
 *  @discussion
 *      A back-pointer to the characteristic this descriptor belongs to.
 */
@property (nonatomic, assign, readonly) CNjacobCharacteristic *characteristic;

/**
 *  @property stringValue
 */
@property (nonatomic, strong, readonly) NSString *stringValue;

/**
 *  @property numberValue
 */
@property (nonatomic, strong, readonly) NSNumber *numberValue;

/**
 *  @property dataValue
 */
@property (nonatomic, strong, readonly) NSData *dataValue;

/**
 *  @property typeStringValue
 */
@property (nonatomic, strong, readonly) NSString *typeStringValue;





/**
 *  @method readData: with callback
 */
- (void)readData:(CNjacobDescriptorDataCallback)readCallback;

/**
 *  @method writeData: with callback
 */
- (void)writeData:(NSData *)data callback:(CNjacobDescriptorDataCallback)writeCallback;

@end

NS_ASSUME_NONNULL_END

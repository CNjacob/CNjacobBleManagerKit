//
//  CNjacobAttribute.h
//  CNjacobBleManagerKit
//
//  Created by CNjacob on 2019/3/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class CBUUID, CNjacobCentralManager;

/**
 *  @class CNjacobAttribute
 */
@interface CNjacobAttribute : NSObject

/**
 *  @property UUID
 */
@property (nonatomic, strong, readonly) CBUUID *UUID;

/**
 *  @property centralManager
 */
@property (nonatomic, assign, readonly) CNjacobCentralManager *centralManager;

@end

NS_ASSUME_NONNULL_END

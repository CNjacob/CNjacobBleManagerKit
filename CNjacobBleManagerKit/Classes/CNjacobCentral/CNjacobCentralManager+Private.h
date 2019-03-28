//
//  CNjacobCentralManager+Private.h
//  CNjacobBleManagerKit
//
//  Created by jacob on 2019/3/28.
//

#import <CNjacobBleManagerKit/CNjacobBleManagerKit.h>

NS_ASSUME_NONNULL_BEGIN

@class CBCentralManager;

/**
 *  @Category CNjacobCentralManager+Private
 */
@interface CNjacobCentralManager (Private)

/**
 *  @property cbCentralManager A CBCentralManager of CoreBluetooth
 */
@property (nonatomic, strong) CBCentralManager *appleCentralManager;

@end

NS_ASSUME_NONNULL_END

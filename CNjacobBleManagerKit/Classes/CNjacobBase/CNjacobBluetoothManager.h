//
//  CNjacobBluetoothManager.h
//  CNjacobBleManagerKit
//
//  Created by CNjacob on 2019/3/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  @enum CNjacobBluetoothManagerState
 *
 *  @discussion Represents the current state of a CNjacobCentralManager.
 *
 *  @constant CNjacobBluetoothManagerStateUnknown
 *              State unknown, update imminent.
 *  @constant CNjacobBluetoothManagerStateResetting
 *              The connection with the system service was momentarily lost, update imminent.
 *  @constant CNjacobBluetoothManagerStateUnsupported
 *              The platform doesn't support the Bluetooth Low Energy Central/Client role.
 *  @constant CNjacobBluetoothManagerStateUnauthorized
 *              The application is not authorized to use the Bluetooth Low Energy role.
 *  @constant CNjacobBluetoothManagerStatePoweredOff
 *              Bluetooth is currently powered off.
 *  @constant CNjacobBluetoothManagerStatePoweredOn
 *              Bluetooth is currently powered on and available to use.
 */
typedef NS_ENUM(NSInteger, CNjacobBluetoothManagerState) {
    CNjacobBluetoothManagerStateUnknown = 0,
    CNjacobBluetoothManagerStateResetting,
    CNjacobBluetoothManagerStateUnsupported,
    CNjacobBluetoothManagerStateUnauthorized,
    CNjacobBluetoothManagerStatePoweredOff,
    CNjacobBluetoothManagerStatePoweredOn,
};

@interface CNjacobBluetoothManager : NSObject

/**
 *  @property state
 *
 *  @seealso CNjacobBluetoothManagerState
 */
@property (nonatomic, assign, readonly) CNjacobBluetoothManagerState state;

@end

NS_ASSUME_NONNULL_END

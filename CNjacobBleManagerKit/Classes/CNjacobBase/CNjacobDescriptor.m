//
//  CNjacobDescriptor.m
//  CNjacobBleManagerKit
//
//  Created by CNjacob on 2019/3/26.
//

#import "CNjacobDescriptor.h"
#import <CoreBluetooth/CoreBluetooth.h>

#import "CNjacobPeripheral+Private.h"

#import "CNjacobService+Private.h"
#import "CNjacobCharacteristic+Private.h"
#import "CNjacobDescriptor+Private.h"

@interface CNjacobDescriptor () {
    CBUUID *_UUID;
}

@property (nonatomic, copy) CNjacobDescriptorDataCallback readCallback;

@property (nonatomic, copy) CNjacobDescriptorDataCallback writeCallback;

@property (nonatomic, strong) CBDescriptor *appleDescriptor;

@property (nonatomic, assign) CNjacobCharacteristic *characteristic;

@end





@implementation CNjacobDescriptor

- (CNjacobCharacteristic *)characteristic {
    
    return _characteristic;
}

- (CBUUID *)UUID {
    
    if (!_UUID) {
        _UUID = _appleDescriptor.UUID;
    }
    
    return _UUID;
}

- (void)readData:(CNjacobDescriptorDataCallback)readCallback {
    
    self.readCallback = readCallback;
    [self.characteristic.service.peripheral.applePeripheral readValueForDescriptor:self.appleDescriptor];
}

- (void)writeData:(NSData *)data callback:(CNjacobDescriptorDataCallback)writeCallback {
    
    self.writeCallback = writeCallback;
    [self.characteristic.service.peripheral.applePeripheral writeValue:data forDescriptor:self.appleDescriptor];
}

@end

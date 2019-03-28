//
//  CNjacobDescriptor+Private.m
//  CNjacobBleManagerKit
//
//  Created by CNjacob on 2019/3/26.
//

#import "CNjacobDescriptor+Private.h"

#import "CNjacobBluetoothManager+Private.h"
#import "CNjacobCentralManager.h"

#import "CNjacobAttribute.h"
#import "CNjacobCharacteristic+Private.h"

@implementation CNjacobDescriptor (Private)

@dynamic characteristic;
@dynamic appleDescriptor;
@dynamic readCallback;
@dynamic writeCallback;

- (instancetype)initWithDescriptor:(CBDescriptor *)descriptor characteristic:(CNjacobCharacteristic *)characteristic {
    
    self = [super init];
    
    if (self) {
        self.characteristic = characteristic;
        self.appleDescriptor = descriptor;
    }
    
    return self;
}

- (void)didUpdateValue:(NSError *)error {
    
    CNJACOB_ASYNC_CALLBACK(self.readCallback,
                           self.readCallback(self, error),
                           CNjacobDescriptor,
                           self.centralManager);
}

- (void)didWriteValue:(NSError *)error {
    
    CNJACOB_ASYNC_CALLBACK(self.writeCallback,
                           self.writeCallback(self, error),
                           CNjacobDescriptor,
                           self.centralManager);
}

- (CNjacobCentralManager *)centralManager {
    
    return self.characteristic.centralManager;
}

@end

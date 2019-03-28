//
//  CNjacobCentralManagerOptions.m
//  CNjacobBleManagerKit
//
//  Created by CNjacob on 2019/3/20.
//

#import "CNjacobCentralManagerOptions.h"

@implementation CNjacobCentralManagerOptions

- (instancetype)init {
    
    self = [super init];
    
    if (self) {
        _scanTimeoutInterval = 0;
        _connectTimeoutInterval = 5;
        _readTimeoutInterval = 5;
        _writeTimeoutInterval = 5;
        _writeRetryTimes = 3;
        _connectRetryTimes = 3;
        _autoReconnectAfterDisconnect = NO;
        _autoRewriteAfterFailure = NO;
    }
    
    return self;
}

@end

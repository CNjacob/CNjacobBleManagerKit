//
//  CNjacobBluetoothManager+Private.m
//  CNjacobBleManagerKit
//
//  Created by CNjacob on 2019/3/26.
//

#import "CNjacobBluetoothManager+Private.h"

static NSInteger CNJACOB_BLEMANAGER_KIT_COMMON_ERROR_CODE = 408;

static char * const kCNjacobBleManagerKitQueueLabel = "com.cnjacob.bluetooth.queue";

@implementation CNjacobBluetoothManager (Private)

@dynamic mainQueue;
@dynamic callbackQueue;

- (NSError *)error:(NSDictionary<NSErrorUserInfoKey, id> *)userInfo {
    
    return [NSError errorWithDomain:@"CNjacobBleManagerKit"
                               code:CNJACOB_BLEMANAGER_KIT_COMMON_ERROR_CODE
                           userInfo:userInfo];
}

- (dispatch_queue_t)createQueue:(dispatch_queue_attr_t)attribute {
    
    dispatch_queue_t queue = nil;
    if (@available(iOS 8.0, *)) {
        dispatch_queue_attr_t attr =
        dispatch_queue_attr_make_with_qos_class(attribute, QOS_CLASS_USER_INITIATED, 0);
        queue = dispatch_queue_create(kCNjacobBleManagerKitQueueLabel, attr);
        
    } else {
        queue = dispatch_queue_create(kCNjacobBleManagerKitQueueLabel, attribute);
        dispatch_set_target_queue(queue, DISPATCH_QUEUE_PRIORITY_DEFAULT);
    }
    return queue;
}

- (void)syncCallback:(dispatch_block_t)block {
    
    if (!block) {
        return ;
    }
    dispatch_sync(self.callbackQueue, block);
}

- (void)asyncCallback:(dispatch_block_t)block {
    
    if (!block) {
        return ;
    }
    dispatch_async(self.callbackQueue, block);
}

- (void)delayCallback:(NSTimeInterval)delay withBlock:(dispatch_block_t)block {
    
    if (!block) {
        return ;
    }
    dispatch_time_t delayTime =
    dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC));
    dispatch_after(delayTime, self.callbackQueue, block);
}

- (void)cancelDelayCallback:(dispatch_block_t)block {
    
    if (!block) {
        return ;
    }
    dispatch_block_cancel(block);
}

@end

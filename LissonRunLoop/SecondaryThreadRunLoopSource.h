//
//  SecondaryThreadRunLoopSource.h
//  LissonRunLoop
//
//  Created by zhangdong on 16/5/18.
//  Copyright © 2016年 zhangdong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SecondaryThreadRunLoopSource : NSObject
{
    CFRunLoopSourceRef _runloopSource;
}

@property (nonatomic, strong) NSMutableArray *commandBuffer;
- (void)signalSourceAndWakeUpRunloop:(CFRunLoopRef)runloop ;

- (void)addToCurrentRunLoop;

- (void)stopCurrentRunLoop;
@end

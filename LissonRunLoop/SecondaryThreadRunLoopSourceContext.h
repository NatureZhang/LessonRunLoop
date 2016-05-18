//
//  SecondaryThreadRunLoopSourceContext.h
//  LissonRunLoop
//
//  Created by zhangdong on 16/5/18.
//  Copyright © 2016年 zhangdong. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SecondaryThreadRunLoopSource;

@interface SecondaryThreadRunLoopSourceContext : NSObject

@property (nonatomic) CFRunLoopRef runloop;
@property (nonatomic) SecondaryThreadRunLoopSource *runloopSource;

- (instancetype)initWithRunLoopRef:(CFRunLoopRef)runLoop runLoopSource:(SecondaryThreadRunLoopSource *)runloopSource;
@end

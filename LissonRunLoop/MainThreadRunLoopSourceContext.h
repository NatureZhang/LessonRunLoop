//
//  MainThreadRunLoopSourceContext.h
//  LissonRunLoop
//
//  Created by zhangdong on 16/5/18.
//  Copyright © 2016年 zhangdong. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MainThreadRunLoopSource;
@interface MainThreadRunLoopSourceContext : NSObject

@property (nonatomic) CFRunLoopRef runloop;
@property (nonatomic) MainThreadRunLoopSource *runloopSource;

- (instancetype)initWithRunLoopRef:(CFRunLoopRef)runLoop runLoopSource:(MainThreadRunLoopSource *)runloopSource
;
@end

//
//  RunLoopDelegate.h
//  LissonRunLoop
//
//  Created by zhangdong on 16/5/19.
//  Copyright © 2016年 zhangdong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MainThreadRunLoopSource.h"
#import "MainThreadRunLoopSourceContext.h"
#import "SecondaryThreadRunLoopSource.h"
#import "SecondaryThreadRunLoopSourceContext.h"
#import "MainCollectionVC.h"

@interface RunLoopDelegate : NSObject

@property (strong, nonatomic) MainCollectionVC *mainCollectionVC;

+ (RunLoopDelegate *)shareDelegate;

- (void)registerMainThreadRunLoopSource:(MainThreadRunLoopSourceContext *)mainThreadRunLoopSourceContext;

- (void)performMainThreadRunLoopSourceTask;

- (void)performMainThreadRunLoopSourceCancelTask;

- (void)registerSecondaryThreadRunLoopSource:(SecondaryThreadRunLoopSourceContext *)secondThreadRunLoopSourceContext;

- (void)performSecondaryThreadRunLoopSourceTask;

- (void)removeSecondaryThreadRunloopSourceContext;
@end

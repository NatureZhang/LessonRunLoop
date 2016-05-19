//
//  RunLoopDelegate.m
//  LissonRunLoop
//
//  Created by zhangdong on 16/5/19.
//  Copyright © 2016年 zhangdong. All rights reserved.
//

#import "RunLoopDelegate.h"
@interface RunLoopDelegate ()

@property (nonatomic, strong) MainThreadRunLoopSourceContext *mainContext;
@property (nonatomic, strong) SecondaryThreadRunLoopSourceContext *secondContext;

@end

@implementation RunLoopDelegate

+ (RunLoopDelegate *)shareDelegate {
    
    static RunLoopDelegate *shareDelgt = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareDelgt = [[RunLoopDelegate alloc] init];
    });
    
    return shareDelgt;
}

#pragma mark - MainThreadRunLoopSource
- (void)registerMainThreadRunLoopSource:(MainThreadRunLoopSourceContext *)mainThreadRunLoopSourceContext {
    
    self.mainContext = mainThreadRunLoopSourceContext;
    
}

- (void)performMainThreadRunLoopSourceTask {
    
    if (self.mainContext.runloopSource.commandBuffer.count > 0) {
        [self.mainContext.runloopSource.commandBuffer removeAllObjects];
    }
    
    [self.mainCollectionVC.collectionView reloadData];
    
    NSTimer *timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(sendCommandToSecondaryThread) userInfo:nil repeats:NO];
    
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
}

- (void)performMainThreadRunLoopSourceCancelTask {
    
    [self.secondContext.runloopSource stopCurrentRunLoop];
}

#pragma mark - SecondThreadRunLoopSource

- (void)registerSecondaryThreadRunLoopSource:(SecondaryThreadRunLoopSourceContext *)secondThreadRunLoopSourceContext {
    
    self.secondContext = secondThreadRunLoopSourceContext;
    
    [self sendCommandToSecondaryThread];
}

- (void)sendCommandToSecondaryThread {
    
    [self.secondContext.runloopSource.commandBuffer addObject:self.mainContext];
    
    [self.secondContext.runloopSource signalSourceAndWakeUpRunloop:self.secondContext.runloop];
    
}

- (void)performSecondaryThreadRunLoopSourceTask {
    if (self.secondContext.runloopSource.commandBuffer.count > 0) {
        
        [self.mainCollectionVC randomAlpha];
        
        MainThreadRunLoopSourceContext *mainTmpContext = self.secondContext.runloopSource.commandBuffer[0];
        [self.secondContext.runloopSource.commandBuffer removeAllObjects];
        
        [mainTmpContext.runloopSource.commandBuffer addObject:self.secondContext];
        
        [mainTmpContext.runloopSource signalSourceAndWakeUpRunloop:mainTmpContext.runloop];
        
    }
}

- (void)removeMainThreadRunloopSourceContext {
    self.mainContext = nil;
}

- (void)removeSecondaryThreadRunloopSourceContext {
    self.secondContext = nil;
}

@end

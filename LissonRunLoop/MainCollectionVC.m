//
//  MainCollectionVC.m
//  LissonRunLoop
//
//  Created by zhangdong on 16/5/18.
//  Copyright © 2016年 zhangdong. All rights reserved.
//

#import "MainCollectionVC.h"
#import "AppDelegate.h"
#import "MainThreadRunLoopSource.h"
#import "SecondaryThreadRunLoopSource.h"


static NSString *const collectionCellId = @"collectionCellId";
static NSInteger collectionCellNum = 32;
@interface MainCollectionVC ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) NSMutableArray *alphaArray;
@end

@implementation MainCollectionVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self layoutCollectionView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)layoutCollectionView {
    
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:collectionCellId];
    
    AppDelegate *appDelgt = [UIApplication sharedApplication].delegate;
    appDelgt.mainCollectionVC = self;
}

#pragma mark - 辅助函数
- (void)randomAlpha {
    self.alphaArray = [NSMutableArray arrayWithCapacity:0];
    
    for (int i = 0; i < collectionCellNum; i ++) {
        int value = arc4random() % 100;
        CGFloat valueF = value * 0.01;
        NSNumber *valueNum = [NSNumber numberWithFloat:valueF];
        [self.alphaArray addObject:valueNum];
    }
}
- (IBAction)startRandom:(id)sender {
    
    MainThreadRunLoopSource *mainRunLoopSource = [[MainThreadRunLoopSource alloc] init];
    [mainRunLoopSource addToCurrentRunLoop];
    
    NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(startThreadWithRunloop) object:nil];
    [thread start];
}

- (void)startThreadWithRunloop {
    @autoreleasepool {
        
        BOOL done = NO;
        SecondaryThreadRunLoopSource *secondSource = [[SecondaryThreadRunLoopSource alloc] init];
        [secondSource addToCurrentRunLoop];
        
        while (!done) {
            CFRunLoopRunResult result =  CFRunLoopRunInMode(kCFRunLoopDefaultMode, 5, true);
            
            if (result == kCFRunLoopRunStopped || result == kCFRunLoopRunFinished) {
                done = true;
            }
        
            NSLog(@"secondThread Runing");
        }
    }
}


- (IBAction)cancelRandom:(id)sender {
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return collectionCellNum;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:collectionCellId forIndexPath:indexPath];

    cell.backgroundColor = [UIColor colorWithRed:76.0/255.0 green:174.0/255.0 blue:39.0/255.0 alpha:1];
   
    CGFloat alpha = 1;
    
    if (self.alphaArray.count > 0) {
        NSNumber *alphaNum = self.alphaArray[indexPath.row];
        alpha = alphaNum.floatValue;
    
    }
    
    cell.alpha = alpha;
    return cell;
}

#pragma mark - UICollectionViewDelegate

#pragma mark - UICollectionViewFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(50, 50);
}
@end

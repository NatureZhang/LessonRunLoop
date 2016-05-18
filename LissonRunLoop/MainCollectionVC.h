//
//  MainCollectionVC.h
//  LissonRunLoop
//
//  Created by zhangdong on 16/5/18.
//  Copyright © 2016年 zhangdong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainCollectionVC : UIViewController
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

- (void)randomAlpha;
@end

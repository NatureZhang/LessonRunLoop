//
//  ViewController.m
//  LissonRunLoop
//
//  Created by zhangdong on 16/5/17.
//  Copyright © 2016年 zhangdong. All rights reserved.
//

#import "ViewController.h"
#import "MainCollectionVC.h"

#import "RunLoopThread.h"

// http://www.devtalking.com/articles/read-threading-programming-guide-2/

/*
 什么是runloop
 顾名思义就是跑圈，兜圈的意思，一个应用程序能够一直运行而不退出就是基于这种机制
 作用：1 保持程序持续运行，相当于一个死循环
      2 处理应用程序中的各种事件，比如触摸事件，定时器事件
      3 作用机制是有事就做事，没事就待命休息，节省资源
 runloop是一个事件事件循环机制，用来分配、分派线程接受到的事件任务，同时可以让线程成为一个常驻线程，即有任务时处理任务，没任务时休眠，且不消耗资源。
 

 runloop与线程
 每一个线程都有一个与之对应的runloop对象
 runloop生命周期与子线程息息相关，当子线程被销毁时，与之对应的runloop也会被销毁
 子线程的runloop要手动开启，懒加载的形式创建
 
 */

/*
 
 runloop 观察者
 runloop的观察者可以理解为runloop自身运行状态的监听器，它可以监听runloop的下面运行状态
 a runloop准备开始执行
 b 当runloop准备要执行一个timer source 事件时
 c 当runloop准备执行要给input source 事件时
 d 当runloop准备休眠时
 e 当runloop被进入的事件消息唤醒并且还没有开始让处理器执行事件消息时
 f 退出runloop时
 
 自动释放池什么时候创建和释放？
 第一次创建是在runloop进入的时候创建，对应的状态=kCRunLoopEntry
 最后一次释放，是在runloop退出的时候，对应的状态=kCFRunLoopExit
 它的创建和释放，每次睡觉的时候都会释放前自动释放池，然后再建一个新的
 
 */

/*
 相关类 Core Foundation下
 
 CFRunLoopRef(runloop 抽象类)
 CFRunLoopModeRef(runloop 的运行模式)
 CFRunLoopSourceRef(runloop 要处理的事件源)
 CFRunLoopTimerRef(timer 事件)
 CFRunLoopObserverRef(runloop的观察者)
 
 */

/*
 RunLoop的运行模式
 理解为一个集合，这个集合里包括所有要监视的事件源和要通知的runloop中注册的观察者。必须指定mode
 设置mode后，runloop会自动过滤其他Mode相关的事件源，而只观察当前Mode相关的源。如果Mode下没有添加事件源，runloop会立即退出
 5中RunLoopMode
 1) NSDefaultRunLoopMode: 该模式包含的事件源囊括了除网络连接操作的大多数操作以及时间事件。
 2) NSConnectionReplyMode: 使用这个Mode去监听NSConnection对象的状态，我们很少需要自己使用这个Mode。
 3) NSModalPanelRunLoopMode: 使用这个Mode在Model Panel情况下去区分事件(OS X开发中会遇到)。
 4) UITrackingRunLoopMode: 使用这个Mode去跟踪来自用户交互的事件（比如UITableView上下滑动）。
 5) GSEventReceiveRunLoopMode: 用来接受系统事件，内部的Run Loop Mode。
 6) NSRunLoopCommonModes: 这是一个伪模式，其为一组run loop mode的集合。如果将Input source加入此模式，意味着关联Input source到Common Modes中包含的所有模式下。在iOS系统中NSRunLoopCommonMode包含NSDefaultRunLoopMode、NSTaskDeathCheckMode、UITrackingRunLoopMode.可使用CFRunLoopAddCommonMode方法向Common Modes中添加自定义mode。
 */

/*
 
 runloop事件源（有两类事件源）：
 
 事件源也就是输入源，可能包括用户输入设备（如点击button），网络链接，定期或时间延迟事件（NSTimer），还有异步回调
 runloop中至少要有一种事件源，不论是input source还是timer，如果runloop没有事件源的话，那么启动runloop后会立即退出
 
 
 1  一个是input Source 接收来自其他线程或应用程序的异步事件消息，并将消息分派给对应的事件处理方法
 input source分为两大类事件源：
 1 基于端口的事件源，在CFRunLoopSourceRef 的结构中为source1, 主要通过监听应用程序的mach端口接收消息并分派，改类型的事件源可以主动唤醒runloop。
 实现这种源主要通过NSPort类实现
 2 自定义事件源，在CFRunLoopSourceRef的结构中为source0，一般是接收其他线程的事件消息并分派给当前线程的runloop。
==========================
 2  另一个是Timer Source 接收定期循环执行或定时执行的同步事件消息，同样会将消息分派给对应的事件处理方法。当某线程不需要其他线程通知而需要自己通知自己执行任务时就可以用这种事件源。
 
 */

/*
 
 runloop 的事件队列
 每次运行runloop，线程的runloop会自动处理之前未处理的消息，并通知相关的观察者，具体顺序如下：
 
 1  通知对应观察者Run Loop准备开始运行。
 2  通知对应观察者准备执行定时任务。
 3  通知对应观察者准备执行自定义事件源的任务。
 4  开始执行自定义事件源任务。
 5  如果有基于端口事件源的任务准备待执行，那么立即执行该任务。然后跳到步骤9继续运转。
 6  通知对应观察者线程进入休眠。
 7  如果有下面的事件发生，则唤醒线程：
        1 接收到基于端口事件源的任务。
        2 定时任务到了该执行的时间点。
        3 Run Loop的超时时间到期。
        4 Run Loop被手动唤醒。
 8  通知对应观察者线程被唤醒。
 9  执行等待执行的任务。
        1 如果有定时任务已启动，执行定时任务并重启Run Loop。然后跳到步骤2继续运转。
        2 如果有非定时器事件源的任务待执行，那么分派执行该任务。
        3 如果Run Loop被手动唤醒，重启Run Loop。然后跳转到步骤2继续运转。
 10 通知对应观察者已退出Run Loop。
 
 */


/*
 
 需要使用runloop的情况
 1 通过基于端口或自定义的数据源与其他线程进行通信
 2 在线程中执行定时源的任务
 3 使用cocoa框架提供的performSelector系列方法
 4 在线程中执行较为频繁的，具有周期性的任务
 
 */

/*
 AFNetWorking   开辟子线程的同时开启一个runloop，然后手动维护这个runloop，来持续监听事件的接收
 */

/*
 
 疑问点：有说基于端口（port）的输入源并不能主动触发事件http://xionv.com/page/2/
 又说：基于端口的输入源主动触发runloop http://www.devtalking.com/articles/read-threading-programming-guide-2/
 
 通过AFN的源码，可知后者对
 */


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (IBAction)startRunLoop:(id)sender {
    
    RunLoopThread *testThread = [[RunLoopThread alloc] init];
    [testThread launch];
}


- (IBAction)gotoSecondThread:(id)sender {
    
    MainCollectionVC *mainCollectionVC = [[MainCollectionVC alloc] init];
    [self.navigationController pushViewController:mainCollectionVC animated:YES];
}


@end

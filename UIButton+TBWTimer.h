//
//  UIButton+TBWTimer.h
//  TBWSystemAlert
//
//  Created by tangbowen on 2017/3/6.
//  Copyright © 2017年 tbw. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NSAttributedString *(^DidChangeBlock)(UIButton *btn, NSInteger second);

typedef NSAttributedString *(^DidFinshedBlock)(UIButton *btn, NSInteger second);

@interface UIButton (TBWTimer)

@property (nonatomic, copy) DidChangeBlock tbw_didChangeBlock;

@property (nonatomic, copy) DidFinshedBlock tbw_didFinshedBlock;

@property (nonatomic, assign, readonly) BOOL tbw_timerIsRuning; // 定时器是否正在工作

#pragma mark --

/**获取计数中btn，并可以自定义btn显示title*/
- (void)tbw_didChangeBlock:(DidChangeBlock)changeBlock;

/**获取计数完成btn，并可以自定义btn显示title*/
- (void)tbw_didFinshBlock:(DidFinshedBlock)finshBlock;

/**
 * 开始计数。 如果需要保证计数器能够继续执行上一次没有被完成的计时操作。 请传入cacheKey。 不需要为空即可。
 * @param totalSeccond  总计数时间 （s）
 * @param cacheKey  用来做缓存的 key 值
 */
- (void)tbw_starTimerWithTotalSecond:(NSInteger)totalSeccond
        isSaveTimerStateWithCacheKey:(NSString *)cacheKey;

/**停止定时器*/
- (void)tbw_timerStop;

/**
 * 当上一次在做缓存处理的情况下，按钮计时没有完成是否自动按照上次状态继续下去，传入cacheKey继续上次操作
 * @param totalSeconds 需要计时的总时间 （s)
 * @param changeBlock  在计时时的 显示状态
 * @pram finshBlock   结束时的显示状态
 * return cacheKey:(NSString *)cacheKey
 */
- (void)tbw_keepTheTimerStateWhenTheLastTimeIsNotComplete:(NSInteger)totalSeconds
                                                 cacheKey:(NSString *)cacheKey
                                              changeBlock:(DidChangeBlock)changeBlock
                                               finshBlock:(DidFinshedBlock)finshBlock;

/**
 * 当上一次在做缓存处理的情况下，按钮计时没有完成是否自动按照上次状态继续下去，传入cacheKey继续上次操作
 * @param totalSeconds  需要计时的总时间 （s）
 * @param cacheKey  用来做缓存的key值 （s）
 */
- (void)tbw_keepTheTimerStateWhenTheLastTimeisNotComplete:(NSInteger)totalSeconds
                                                 cacheKey:(NSString *)cacheKey;



@end

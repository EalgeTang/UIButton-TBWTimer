//
//  UIButton+TBWTimer.m
//  TBWSystemAlert
//
//  Created by tangbowen on 2017/3/6.
//  Copyright © 2017年 tbw. All rights reserved.
//

#import "UIButton+TBWTimer.h"
#import <objc/runtime.h>

@interface UIButton (TimerPrivateProperty)

@property (nonatomic) NSInteger second;
@property (nonatomic) NSInteger totalSecond;
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, copy)   NSString *cacheKey;
@end

@implementation UIButton (TBWTimer)

- (void)tbw_keepTheTimerStateWhenTheLastTimeIsNotComplete:(NSInteger)totalSeconds
                                                 cacheKey:(NSString *)cacheKey
                                              changeBlock:(DidChangeBlock)changeBlock
                                               finshBlock:(DidFinshedBlock)finshBlock
{
    if (!cacheKey)
    {
        return;
    }
    self.tbw_didFinshedBlock = finshBlock;
    self.tbw_didChangeBlock = changeBlock;
    [self tbw_keepTheTimerStateWhenTheLastTimeisNotComplete:totalSeconds cacheKey:cacheKey];
    
}
- (void)tbw_keepTheTimerStateWhenTheLastTimeisNotComplete:(NSInteger)totalSeconds
                                                 cacheKey:(NSString *)cacheKey;
{
    if (!cacheKey)
    {// key值为空，不用做多余操作
        return;
    }
    NSDate *last = [[NSUserDefaults standardUserDefaults] objectForKey:cacheKey];
    if (last)
    {
        [self tbw_starTimerWithTotalSecond:totalSeconds isSaveTimerStateWithCacheKey:cacheKey];
    }
}

/**获取计数中btn，并可以自定义btn显示title*/
- (void)tbw_didChangeBlock:(DidChangeBlock)changeBlock
{
    self.tbw_didChangeBlock = changeBlock;
}

/**获取计数完成btn，并可以自定义btn显示title*/
- (void)tbw_didFinshBlock:(DidFinshedBlock)finshBlock
{
    self.tbw_didFinshedBlock = finshBlock;
}


/**开始计数，并设置总计数时间（s）*/
- (void)tbw_starTimerWithTotalSecond:(NSInteger)totalSeccond
        isSaveTimerStateWithCacheKey:(NSString *)cacheKey
{
    self.totalSecond = totalSeccond;
    self.second = totalSeccond;
    self.cacheKey = cacheKey;
    
    if (self.cacheKey)
    {
        NSDate *lastDate = [[NSUserDefaults standardUserDefaults] objectForKey:cacheKey];
        if (lastDate)
        {
            CGFloat deltaTime = [[NSDate date] timeIntervalSinceDate:lastDate];
            NSInteger sec = self.totalSecond - (NSInteger)(deltaTime + 0.5);
            if (sec < 0)
            {
                //如果新的一轮已经超过了缓存时间， 应当从新记录
                self.startDate = [NSDate date];
                [[NSUserDefaults standardUserDefaults] setObject:self.startDate forKey:cacheKey];
                
            }
            else
            {
                self.startDate = lastDate;
            }
        }
        else
        {
            self.startDate = [NSDate date];
            [[NSUserDefaults standardUserDefaults] setObject:self.startDate forKey:cacheKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
    else
    {
        self.startDate = [NSDate date];
        
    }
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                              target:self
                                            selector:@selector(onTimerRun:)
                                            userInfo:nil
                                             repeats:YES];
    
    //设置 runloop 模式保证 timer不会因为runloop切换被打断
    [[NSRunLoop currentRunLoop] addTimer:self.timer
                                 forMode:NSRunLoopCommonModes];
    
}

- (void)tbw_timerStop
{
    self.enabled = YES;
    
    if (self.timer)
    {
        if ([self.timer respondsToSelector:@selector(isValid)])
        {
            if ([self.timer isValid])
            {
                [self.timer invalidate];
                self.timer = nil;
                self.second = self.totalSecond;
                
                if (self.cacheKey)
                {
                    // 移除缓存
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:self.cacheKey];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
                
                if (self.tbw_didFinshedBlock)
                {
                    [self setAttributedTitle:self.tbw_didFinshedBlock(self, self.totalSecond) forState:UIControlStateNormal];
                    [self setAttributedTitle:self.tbw_didFinshedBlock(self, self.totalSecond) forState:UIControlStateDisabled];
                }
                else
                {
                    NSString *str = @"重新获取";
                    NSAttributedString *attributed = [[NSAttributedString alloc] initWithString:str];
                    
                    if (self.currentAttributedTitle)
                    {
                        [self setAttributedTitle:attributed forState:UIControlStateNormal];
                        [self setAttributedTitle:attributed forState:UIControlStateDisabled];
                    }
                    else
                    {
                        [self setTitle:str forState:UIControlStateNormal];
                        [self setTitle:str forState:UIControlStateDisabled];
                    }

                }
            }
        }
    }
}

- (void)onTimerRun:(NSTimer *)timer
{
    CGFloat deltaTime = [[NSDate date] timeIntervalSinceDate:self.startDate];
    self.second = self.totalSecond - (NSInteger)(deltaTime + 0.5);
    
    if (self.second < 0)
    {
        [self tbw_timerStop];
    }
    else
    {
        if (self.tbw_didChangeBlock)
        {
            [self setAttributedTitle:self.tbw_didChangeBlock(self, self.second) forState:UIControlStateNormal];
            [self setAttributedTitle:self.tbw_didChangeBlock(self, self.second) forState:UIControlStateDisabled];
        }
        else
        {
            NSString *title = [NSString stringWithFormat:@"%zd秒", self.second];
            [self setTitle:title forState:UIControlStateNormal];
            [self setTitle:title forState:UIControlStateDisabled];
        }
    }
}

#pragma mark -  set/ get

- (BOOL)tbw_timerIsRuning
{
    if (self.timer)
    {
        return YES;
    }
    return NO;
}

- (void)setCacheKey:(NSString *)cacheKey
{
    objc_setAssociatedObject(self,
                             "cacheKey",
                             cacheKey,
                             OBJC_ASSOCIATION_COPY_NONATOMIC);
    
}

- (NSString *)cacheKey
{
    return objc_getAssociatedObject(self, "cacheKey");
}

- (void)setSecond:(NSInteger)second
{
    NSString *secondStr = [NSString stringWithFormat:@"%zd",second];
    objc_setAssociatedObject(self,
                             "second",
                             secondStr,
                             OBJC_ASSOCIATION_COPY_NONATOMIC);
    
}

- (NSInteger)second
{
    NSInteger sec = [objc_getAssociatedObject(self, "second") integerValue];
    return sec;
}

- (void)setTotalSecond:(NSInteger)totalSecond
{
    NSString *totalSec = [NSString stringWithFormat:@"%zd", totalSecond];
    objc_setAssociatedObject(self,
                             "totalSecond",
                             totalSec,
                             OBJC_ASSOCIATION_COPY_NONATOMIC);
    
}

- (NSInteger)totalSecond
{
    return [objc_getAssociatedObject(self, "totalSecond") integerValue];
}

- (void)setStartDate:(NSDate *)startDate
{
    objc_setAssociatedObject(self,
                             "startDate",
                             startDate,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
}

- (NSDate *)startDate
{
    return objc_getAssociatedObject(self, "startDate");
}

- (void)setTimer:(NSTimer *)timer
{
    objc_setAssociatedObject(self,
                             "timer",
                             timer,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
}

- (NSTimer *)timer
{
    return objc_getAssociatedObject(self, "timer");
}

- (void)setTbw_didChangeBlock:(DidChangeBlock)tbw_didChangeBlock
{
    objc_setAssociatedObject(self,
                             "tbw_didChangeBlock",
                             tbw_didChangeBlock,
                             OBJC_ASSOCIATION_COPY_NONATOMIC);
    
}

- (DidChangeBlock)tbw_didChangeBlock
{
    return objc_getAssociatedObject(self, "tbw_didChangeBlock");
}

- (void)setTbw_didFinshedBlock:(DidFinshedBlock)tbw_didFinshedBlock
{
    objc_setAssociatedObject(self,
                             "tbw_didFinshedBlock",
                             tbw_didFinshedBlock,
                             OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (DidFinshedBlock)tbw_didFinshedBlock
{
    return objc_getAssociatedObject(self, "tbw_didFinshedBlock");
}
@end

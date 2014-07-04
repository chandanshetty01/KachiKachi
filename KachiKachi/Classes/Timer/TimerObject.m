//
//  TimerView.m
//  KachiKachi
//
//  Created by Chandan on 08/08/2013.
//  Copyright (c) 2014 Chanddan. All rights reserved.
//

#import "TimerObject.h"

@interface TimerObject()
@property(nonatomic,strong) NSTimer *timer;
@end

@implementation TimerObject

-(id)initWithDuration:(NSTimeInterval)duration fireInterval:(NSTimeInterval)fireInterval
{
    self = [super init];
    if (self) {
        // Initialization code
        self.fireInterval = fireInterval;
        self.duration = duration;
        self.remainingTime = duration;
    }
    return self;
}

-(void)startTimer
{
    if(self.timer == nil){
        self.timer = [NSTimer scheduledTimerWithTimeInterval:self.fireInterval target:self selector:@selector(timerFired:) userInfo:nil repeats:YES];
    }
}

-(void)timerFired:(NSTimer*)timer
{
    self.remainingTime = self.remainingTime-self.fireInterval;
    if(self.remainingTime <= 0)
    {
        [self.timer invalidate];
        self.timer = nil;
        
        if(self.delegate && [self.delegate respondsToSelector:@selector(timerDidCompleted:)]){
            [self.delegate timerDidCompleted:self];
        }
    }
    else{
        if(self.delegate && [self.delegate respondsToSelector:@selector(timerDidTick:andTimer:)]){
            [self.delegate timerDidTick:self.remainingTime andTimer:self];
        }
    }
}

-(void)pauseTimer
{
    if(self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

@end

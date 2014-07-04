//
//  TimerView.h
//  KachiKachi
//
//  Created by Chandan on 08/08/2013.
//  Copyright (c) 2014 Chanddan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TimerObject : NSObject
{
    
}
@property(nonatomic,assign)NSTimeInterval duration;
@property(nonatomic,assign)NSTimeInterval fireInterval;
@property(nonatomic,assign)NSTimeInterval remainingTime;
@property(nonatomic,weak)id delegate;

-(id)initWithDuration:(NSTimeInterval)duration fireInterval:(NSTimeInterval)fireInterval;
-(void)startTimer;
-(void)pauseTimer;

@end

@protocol TimerObjectDelegates <NSObject>

-(void)timerDidCompleted:(TimerObject*)timer;
-(void)timerDidTick:(NSTimeInterval)remainingInteval andTimer:(TimerObject*)timer;

@end

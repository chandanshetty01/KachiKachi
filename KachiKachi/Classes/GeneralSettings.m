//
//  GeneralSettings.m
//  KachiKachi
//
//  Created by Chandan on 08/08/2013.
//  Copyright (c) 2014 Chanddan. All rights reserved.
//

#import "GeneralSettings.h"

#define kKKpointsEarned  @"pointsEarned"
#define kKKMagicStickUsage @"kKKMagicStickUsage"
#define kKKSHARECOUNT @"kKKSHARECOUNT"
#define kCan_remove_ads @"can_remove_ads"

@implementation GeneralSettings

+ (id) sharedManager
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

-(void)setMagicStickUsageCount:(NSInteger)magicCount
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%ld",(long)magicCount] forKey:kKKMagicStickUsage];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(NSInteger)getmagicStickUsageCount
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:kKKMagicStickUsage] intValue];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)setSharePoint:(NSInteger)count
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:count] forKey:kKKSHARECOUNT];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)setCanRemoveAds:(BOOL)canRemoveAds
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:canRemoveAds] forKey:kCan_remove_ads];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(BOOL)getCanRemoveAds
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:kCan_remove_ads] boolValue];
}

-(NSInteger)getSharePointsCount
{
    NSNumber *object = [[NSUserDefaults standardUserDefaults] objectForKey:kKKSHARECOUNT];
    if(object == nil){
        NSInteger defaultVal = 10;
        [self setSharePoint:defaultVal];
        return defaultVal;
    }
    else
        return [[[NSUserDefaults standardUserDefaults] objectForKey:kKKSHARECOUNT] integerValue];
}

-(BOOL)isMusicEnabled
{
    NSNumber *isOn = [[NSUserDefaults standardUserDefaults] objectForKey:@"isSoundEnabled"];
    if(isOn)
        return [isOn boolValue];
    else
        return YES;
}

-(void)setMusicEnabled:(BOOL)value
{
    NSNumber *isOn = [NSNumber numberWithBool:value];
    [[NSUserDefaults standardUserDefaults] setObject:isOn forKey:@"isSoundEnabled"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(BOOL)isSoundEnabled
{
    NSNumber *isOn = [[NSUserDefaults standardUserDefaults] objectForKey:@"isMusicEnabled"];
    if(isOn)
        return [isOn boolValue];
    else
        return YES;
}

-(void)setSoundEnabled:(BOOL)value
{
    NSNumber *isOn = [NSNumber numberWithBool:value];
    [[NSUserDefaults standardUserDefaults] setObject:isOn forKey:@"isMusicEnabled"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(BOOL)isStageLocked:(NSInteger)stageNo
{
    BOOL status = YES;
    if(stageNo == 1){
        status =  NO;
    }
    NSNumber *stage = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"stage_%ld",(long)stageNo]];
    if(stage){
        status = [stage boolValue];
    }
    return status;
}

-(void)unlockStage:(NSInteger)stageNo
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:[NSString stringWithFormat:@"stage_%ld",(long)stageNo]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end

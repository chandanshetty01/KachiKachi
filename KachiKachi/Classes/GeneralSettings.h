//
//  GeneralSettings.h
//  KachiKachi
//
//  Created by Chandan on 08/08/2013.
//  Copyright (c) 2014 Chanddan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GeneralSettings : NSObject
{
    
}
+(id)sharedManager;

-(void)setMagicStickUsageCount:(NSInteger)magicCount;
-(NSInteger)getmagicStickUsageCount;
-(NSInteger)getSharePointsCount;
-(void)setSharePoint:(NSInteger)count;
-(void)setCanRemoveAds:(BOOL)canRemoveAds;
-(BOOL)getCanRemoveAds;
-(BOOL)isMusicEnabled;
-(void)setMusicEnabled:(BOOL)value;
-(BOOL)isSoundEnabled;
-(void)setSoundEnabled:(BOOL)value;

-(BOOL)isStageLocked:(NSInteger)stageNo;
-(void)unlockStage:(NSInteger)stageNo;

@end

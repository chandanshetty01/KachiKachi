//
//  KKGameStateManager.h
//  KachiKachi
//
//  Created by Chandan on 08/08/2013.
//  Copyright (c) 2014 Chanddan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KKGameStateManager : NSObject
{
    
}

+(id)sharedManager;

-(NSInteger)currentLevelNumber;
-(NSInteger)currentStageNumber;
-(BOOL)isStageLocked:(NSInteger)stage;
-(void)unlockStage:(NSInteger)stage;
-(void)setCurrentLevel:(NSInteger)currentLevel andStage:(NSInteger)stage;
-(void)setRemainingLife:(NSInteger)life;
-(void)markUnlocked:(NSInteger)level stage:(NSInteger)stage;
-(void)markCompleted:(NSInteger)level stage:(NSInteger)stage;
-(void)setData:(NSMutableDictionary*)data level:(NSInteger)level stage:(NSInteger)stage;
-(BOOL)isLevelUnlocked:(NSInteger)level stage:(NSInteger)stage;
-(BOOL)isLevelCompleted:(NSInteger)level stage:(NSInteger)stage;
-(NSMutableDictionary*)gameData:(NSInteger)level stage:(NSInteger)stage;
-(NSMutableDictionary*)levelsDictionary:(NSInteger)stage;

-(BOOL)isSoundEnabled;
-(void)setSoundEnabled:(BOOL)value;

-(void)save;
-(void)load;

@end

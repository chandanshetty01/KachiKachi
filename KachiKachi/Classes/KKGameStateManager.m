//
//  KKGameStateManager.m
//  KachiKachi
//
//  Created by Chandan on 08/08/2013.
//  Copyright (c) 2014 Chanddan. All rights reserved.
//

#import "KKGameStateManager.h"
#import "KKGameConfigManager.h"
#import "Utility.h"
#import "StageModel.h"
#import "GeneralSettings.h"

@interface KKGameStateManager()
@property(nonatomic,strong)StageModel *stageModel;
@property(nonatomic,strong)KKLevelModel *levelModel;
@end

@implementation KKGameStateManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.currentLevel = 1;
        self.currentStage = 1;
    }
    return self;
}

+ (KKGameStateManager*) sharedManager
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

-(void)saveData:(KKLevelModel*)levelModel andStage:(StageModel*)stageModel
{
    //Save Level
    NSMutableDictionary *data = [levelModel itemsData];
    if(data){
        [Utility saveData:data fileName:[self levelFileName:levelModel.levelID andStage:stageModel.stageID]];
    }
    
    //Save Stage
    NSMutableDictionary *stageData = [stageModel savedDictionary];
    if(stageData){
        [Utility saveData:stageData fileName:[self stageFileName:stageModel.stageID]];
    }
}

-(void)saveData
{
    //Save Level
    NSMutableDictionary *data = [self.stageModel itemsDictionaryForLevel:self.currentLevel];
    if(data){
        [Utility saveData:data fileName:[self levelFileName:self.currentLevel andStage:self.currentStage]];
    }

    //Save Stage
    NSMutableDictionary *stageData = [self.stageModel savedDictionary];
    if(stageData){
        [Utility saveData:stageData fileName:[self stageFileName:self.currentStage]];
    }
}

-(void)resetDuration
{
    if(self.currentStage == 1){
        self.levelModel.duration = EASY_MODE_DURATION;
    }
    else if(self.currentStage == 2){
        self.levelModel.duration = MEDIUM_MODE_DURATION;
    }
    else{
        self.levelModel.duration = ADVANCED_MODE_DURATION;
    }
}

-(void)resetScores
{
    self.levelModel.score = 0;
    [self resetDuration];
}

-(void)resetLevelData
{
    NSDictionary *data = [[KKGameConfigManager sharedManager] levelWithID:self.currentLevel andStage:self.currentStage];
    if(data){
        [self.levelModel updateWithDictionary:data];
        self.levelModel.stageID = self.currentStage;
        [self resetScores];
    }
}

-(void)completeLevel
{
    NSDictionary *data = [[KKGameConfigManager sharedManager] levelWithID:self.currentLevel andStage:self.currentStage];
    if(data){
        [self.levelModel updateWithDictionary:data];
        self.levelModel.stageID = self.currentStage;
    }
    if(self.levelModel.score > self.levelModel.bestScore){
        self.levelModel.bestScore = self.levelModel.score;
    }
    self.levelModel.isLevelCompleted = YES;
    [self resetScores];
}

-(KKLevelModel*)getLevelData:(NSInteger)levelID andStage:(NSInteger)stageID
{
    KKLevelModel *levelModel = nil;
    
    NSDictionary *data = [Utility loadData:[self levelFileName:levelID andStage:stageID]];
    if(!data){
        data = [[KKGameConfigManager sharedManager] levelWithID:levelID andStage:stageID];
    }
    
    if(data){
        if(self.stageModel.levels.count > 0 && levelID <= self.stageModel.levels.count && levelID > 0){
            levelModel = [self.stageModel.levels objectAtIndex:levelID-1];
            levelModel.stageID = stageID;
            [levelModel updateWithDictionary:data];
        }
    }
    return levelModel;
}

-(void)loadLevelData
{
    KKLevelModel *model = [self getLevelData:self.currentLevel andStage:self.currentStage];
    self.levelModel = model;
}

-(StageModel*)getStageModel:(NSInteger)stageID
{
    StageModel *model = nil;
    
    NSDictionary *data = [Utility loadData:[self stageFileName:stageID]];
    if(!data){
        data = [[KKGameConfigManager sharedManager] stageWithID:stageID];
    }
    
    model = [[StageModel alloc] initWithDictionary:data];
    model.stageID = stageID;
    return model;
}

-(void)loadStage
{
    self.stageModel = [self getStageModel:self.currentStage];
}

-(void)unlockStage
{
    self.stageModel.isLocked = NO;
    [self saveData];
    [[GeneralSettings sharedManager] unlockStage:self.currentStage];
}

-(NSInteger)numberOfLevels
{
    return [self.stageModel.levels count];
}

-(void)unlockNextLevel
{
    NSInteger nextLevel = self.currentLevel;
    NSInteger nextStage = self.currentStage;
    
    NSInteger noOfLevels = [self.stageModel.levels count];
    if(self.currentLevel>0 && self.currentLevel < noOfLevels){
        nextLevel = self.currentLevel+1;
    }
    else if(self.currentLevel == noOfLevels){
        //load Next stage
        nextLevel = 1;
        if(self.currentStage > 0 && self.currentStage <= 3){
            nextStage = self.currentStage + 1;
        }
    }
    
    KKLevelModel *levelModel = [self getLevelData:nextLevel andStage:nextStage];
    levelModel.isLevelUnlocked = YES;
    StageModel *stageModel = [self getStageModel:nextStage];
    stageModel.isLocked = NO;
    [[GeneralSettings sharedManager] unlockStage:nextStage];
    
    [self saveData:levelModel andStage:stageModel];
}

-(KKLevelModel*)loadNextLevel
{
    NSInteger noOfLevels = [self.stageModel.levels count];
    if(self.currentLevel>0 && self.currentLevel < noOfLevels){
        self.currentLevel += 1;
        [self loadLevelData];
    }
    else if(self.currentLevel == noOfLevels){
        //load Next stage
        self.currentLevel = 1;
        if(self.currentStage > 0 && self.currentStage <= 3){
            self.currentStage += 1;
            [self loadStage];
            [self loadLevelData];
            [self unlockStage];
        }
    }
    return self.levelModel;
}

-(NSMutableArray*)levels
{
    return self.stageModel.levels;
}

-(NSString*)levelFileName:(NSInteger)levelID andStage:(NSInteger)stageID
{
    if(IS_IPAD){
        return [NSString stringWithFormat:@"stage_%ld_level_%ld_iPad",(long)stageID,(long)levelID];
    }
    else{
        return [NSString stringWithFormat:@"stage_%ld_level_%ld",(long)stageID,(long)levelID];
    }
}

-(NSString*)stageFileName:(NSInteger)stageID
{
    if(IS_IPAD){
        return [NSString stringWithFormat:@"stage_%ld_iPad",(long)stageID];
    }
    else{
        return [NSString stringWithFormat:@"stage_%ld",(long)stageID];
    }
}

-(NSDictionary*)levelData:(NSInteger)level stage:(NSInteger)stage
{
    return [Utility loadData:[self levelFileName:level andStage:stage]];
}


@end

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

-(void)saveData
{
    //Save Level
    NSMutableDictionary *data = [self.stageModel itemsDictionaryForLevel:self.currentLevel];
    if(data){
        [Utility saveData:data fileName:[self levelFileName]];
    }

    //Save Stage
    NSMutableDictionary *stageData = [self.stageModel savedDictionary];
    if(stageData){
        [Utility saveData:stageData fileName:[self stageFileName]];   
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
        [self resetScores];
    }
}

-(void)completeLevel
{
    NSDictionary *data = [[KKGameConfigManager sharedManager] levelWithID:self.currentLevel andStage:self.currentStage];
    if(data){
        [self.levelModel updateWithDictionary:data];
    }
    if(self.levelModel.score > self.levelModel.bestScore){
        self.levelModel.bestScore = self.levelModel.score;
    }
    self.levelModel.isLevelCompleted = YES;
    [self resetScores];
}

-(void)loadLevelData
{
    NSDictionary *data = [Utility loadData:[self levelFileName]];
    if(!data){
        data = [[KKGameConfigManager sharedManager] levelWithID:self.currentLevel andStage:self.currentStage];
    }
    
    if(data){
        if(self.stageModel.levels.count > 0 && self.currentLevel <= self.stageModel.levels.count && self.currentLevel > 0){
            self.levelModel = [self.stageModel.levels objectAtIndex:self.currentLevel-1];
            [self.levelModel updateWithDictionary:data];
        }
    }
}

-(void)loadStage
{
    NSDictionary *data = [Utility loadData:[self stageFileName]];
    if(!data){
        data = [[KKGameConfigManager sharedManager] stageWithID:self.currentStage];
    }
                                            
    self.stageModel = [[StageModel alloc] initWithDictionary:data];
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

-(NSString*)levelFileName
{
    if(IS_IPAD){
        return [NSString stringWithFormat:@"level_%ld_%ld_iPad",(long)self.currentStage,(long)self.currentLevel];
    }
    else{
        return [NSString stringWithFormat:@"level_%ld_%ld",(long)self.currentStage,(long)self.currentLevel];
    }
}

-(NSString*)stageFileName
{
    if(IS_IPAD){
        return [NSString stringWithFormat:@"stage_%ld_iPad",(long)self.currentStage];
    }
    else{
        return [NSString stringWithFormat:@"stage_%ld",(long)self.currentStage];
    }
}

-(NSDictionary*)levelData:(NSInteger)level stage:(NSInteger)stage
{
    return [Utility loadData:[self levelFileName]];
}


@end

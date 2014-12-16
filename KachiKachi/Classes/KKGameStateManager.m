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
#import "KKLevelModal.h"

@interface KKGameStateManager()
@property(nonatomic,strong)StageModel *stageModel;
@property(nonatomic,strong)KKLevelModal *levelModel;
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

-(void)loadLevelData
{
    NSDictionary *data = [Utility loadData:[self levelFileName]];
    if(!data){
        data = [[KKGameConfigManager sharedManager] levelWithID:self.currentLevel andStage:self.currentStage];
    }
    
    if(data){
        if(self.stageModel.levels.count > 0 && self.currentLevel < self.stageModel.levels.count && self.currentLevel > 0){
            self.levelModel = [self.stageModel.levels objectAtIndex:self.currentLevel-1];
            [self.levelModel updateWithDictionary:data];
        }
    }
}

-(void)loadData
{
    NSDictionary *data = [Utility loadData:[self stageFileName]];
    if(!data){
        data = [[KKGameConfigManager sharedManager] stageWithID:self.currentStage];
    }
                                            
    self.stageModel = [[StageModel alloc] initWithDictionary:data];
}

-(NSMutableArray*)levels
{
    return self.stageModel.levels;
}

-(NSString*)levelFileName
{
    return [NSString stringWithFormat:@"level_%ld_%ld",self.currentStage,self.currentLevel];
}

-(NSString*)stageFileName
{
    return [NSString stringWithFormat:@"stage_%ld",self.currentStage];
}

-(NSDictionary*)levelData:(NSInteger)level stage:(NSInteger)stage
{
    return [Utility loadData:[self levelFileName]];
}


@end

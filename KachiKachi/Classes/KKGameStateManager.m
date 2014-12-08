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

@interface KKGameStateManager()
@property(nonatomic,strong)StageModel *stageModel;
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
    NSDictionary *data = [self.stageModel savedDictionary];
    [Utility saveData:data fileName:[self fileName]];
}

-(void)loadData
{
    NSDictionary *data = [Utility loadData:[NSString stringWithFormat:@"stage_%ld",self.currentStage]];
    if(!data){
        data = [[KKGameConfigManager sharedManager] stageWithID:self.currentStage];
    }
                                            
    self.stageModel = [[StageModel alloc] initWithDictionary:data];
}

-(NSMutableArray*)levels
{
    return self.stageModel.levels;
}

-(NSString*)fileName
{
    return [NSString stringWithFormat:@"level_%ld_%ld",self.currentStage,self.currentLevel];
}

-(NSDictionary*)levelData:(NSInteger)level stage:(NSInteger)stage
{
    return [Utility loadData:[self fileName]];
}


@end

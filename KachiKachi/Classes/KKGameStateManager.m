//
//  KKGameStateManager.m
//  KachiKachi
//
//  Created by Chandan on 08/08/2013.
//  Copyright (c) 2014 Chanddan. All rights reserved.
//

#import "KKGameStateManager.h"
#import "KKGameConfigManager.h"

@interface KKGameStateManager()

@property(nonatomic,retain) NSMutableDictionary *savedGameData;

@end

@implementation KKGameStateManager

#define kKKRootDictionary @"KKSavedData"
#define kKKCurrentLevel @"KKCurrentLevel"
#define kKKCurrentStage @"KKCurrentStage"
#define kKKCurrentLife @"KKCurrentLife"
#define kKKLevels  @"levels"
#define kKKLevelIsCompleted  @"isLevelCompleted"
#define kKKLevelIsUnlocked  @"isLevelUnlocked"

+ (id) sharedManager
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.savedGameData = [[NSUserDefaults standardUserDefaults] objectForKey:kKKRootDictionary];
        if(self.savedGameData == nil)
        {
            self.savedGameData = [[NSMutableDictionary alloc] initWithDictionary:[[KKGameConfigManager sharedManager] initialGameConfiguration]];
        }
    }
    return self;
}

-(void)setCurrentLevel:(NSInteger)currentLevel andStage:(NSInteger)stage
{
    [self.savedGameData setObject:[NSString stringWithFormat:@"%ld",(long)currentLevel] forKey:kKKCurrentLevel];
    [self.savedGameData setObject:[NSString stringWithFormat:@"%ld",(long)stage] forKey:kKKCurrentStage];
}

-(NSInteger)currentLevelNumber
{
    return [[self.savedGameData objectForKey:kKKCurrentLevel] intValue];
}

-(NSInteger)currentStageNumber
{
    return [[self.savedGameData objectForKey:kKKCurrentStage] intValue];
}

-(void)setRemainingLife:(NSInteger)life
{
    [self.savedGameData setObject:[NSString stringWithFormat:@"%ld",(long)life] forKey:kKKCurrentLife];
}

-(NSMutableDictionary*)stageDictionary:(NSInteger)stage
{
    NSString *key = [NSString stringWithFormat:@"stage%ld",(long)stage];
    NSMutableDictionary *stageDict = [self.savedGameData objectForKey:key];
    if(stageDict == nil){
        stageDict = [NSMutableDictionary dictionary];
        BOOL isLocked = [[KKGameConfigManager sharedManager] isStageLocked:stage];
        [stageDict setObject:[NSNumber numberWithBool:isLocked] forKey:@"locked"];
        [self.savedGameData setObject:stageDict forKey:key];
    }
    return stageDict;
}

-(NSMutableDictionary*)levelsDictionary:(NSInteger)stage
{
    NSMutableDictionary *levels = nil;
    NSMutableDictionary *stageDict = [self stageDictionary:stage];
    if(stageDict){
        levels = [stageDict objectForKey:kKKLevels];
        if(levels == nil){
            levels = [NSMutableDictionary dictionary];
            [stageDict setObject:levels forKey:kKKLevels];
        }
    }
    return levels;
}

-(NSMutableDictionary*)levelDictionary:(NSInteger)level stage:(NSInteger)stage
{
    NSMutableDictionary *levelDict = nil;
    NSString *key = [NSString stringWithFormat:@"level%ld",(long)level];
    NSMutableDictionary *levelsDict = [self levelsDictionary:stage];
    if(levelsDict){
        levelDict = [levelsDict objectForKey:key];
    }
    else{
        levelDict = [NSMutableDictionary dictionary];
        [levelsDict setObject:levelDict forKey:key];
    }
    return levelDict;
}

-(void)markUnlocked:(NSInteger)level stage:(NSInteger)stage
{
    NSMutableDictionary *levelDict = [self levelDictionary:level stage:stage];
    if(levelDict){
        [levelDict setObject:[NSNumber numberWithBool:YES] forKey:kKKLevelIsUnlocked];
    }
}

-(void)unlockStage:(NSInteger)stage
{
    NSMutableDictionary *stageDict = [self stageDictionary:stage];
    if(stageDict){
        [stageDict setObject:[NSNumber numberWithBool:NO] forKey:@"locked"];
    }
}

-(BOOL)isStageLocked:(NSInteger)stage
{
    NSMutableDictionary *stageDict = [self stageDictionary:stage];
    if(stageDict){
        return [[stageDict objectForKey:@"locked"] boolValue];
    }
    return false;
}

-(void)markCompleted:(NSInteger)level stage:(NSInteger)stage
{
    NSMutableDictionary *levelDict = [self levelDictionary:level stage:stage];
    if(levelDict){
        [levelDict setObject:[NSNumber numberWithBool:YES] forKey:kKKLevelIsCompleted];
    }
}

-(BOOL)isLevelUnlocked:(NSInteger)level stage:(NSInteger)stage
{
    BOOL isUnlocked = NO;
    NSMutableDictionary *levelDict = [self levelDictionary:level stage:stage];
    if(levelDict){
        NSNumber *unlocked = (NSNumber*)[levelDict objectForKey:kKKLevelIsUnlocked];
        isUnlocked = [unlocked boolValue];
    }
    return isUnlocked;
}

-(BOOL)isLevelCompleted:(NSInteger)level stage:(NSInteger)stage
{
    BOOL completed = NO;
    NSMutableDictionary *levelDict = [self levelDictionary:level stage:stage];
    if(levelDict){
        NSNumber *unlocked = (NSNumber*)[levelDict objectForKey:kKKLevelIsCompleted];
        completed = [unlocked boolValue];
    }
    return completed;
}

-(void)setData:(NSMutableDictionary*)data level:(NSInteger)level stage:(NSInteger)stage
{
    NSMutableDictionary *levelsDict = [self levelsDictionary:stage];
    if (levelsDict) {
        [levelsDict setObject:data forKey:[NSString stringWithFormat:@"level%ld",(long)level]];
    }
}

-(NSMutableDictionary*)gameData:(NSInteger)level stage:(NSInteger)stage
{
    NSMutableDictionary *levelDict = nil;
    NSMutableDictionary *levelsDict = [self levelsDictionary:stage];
    if(levelsDict){
        levelDict = [levelsDict objectForKey:[NSString stringWithFormat:@"level%ld",(long)level]];
    }
    return levelDict;
}

-(void)save
{
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[NSUserDefaults standardUserDefaults] setObject:_savedGameData forKey:kKKRootDictionary];
        [[NSUserDefaults standardUserDefaults] synchronize];
    });
        
#ifdef DEVELOPMENT_MODE
    //test code
    [_savedGameData writeToFile:@"/Users/chandanshettysp/Desktop/kachikachi.plist" atomically:YES];
#endif
}

-(void)load
{
    _savedGameData = [[NSUserDefaults standardUserDefaults] objectForKey:kKKRootDictionary];
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

@end

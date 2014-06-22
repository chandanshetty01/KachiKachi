//
//  KKGameStateManager.m
//  KachiKachi
//
//  Created by Chandan on 08/08/2013.
//  Copyright (c) 2014 Chanddan. All rights reserved.
//

#import "KKGameStateManager.h"

@interface KKGameStateManager()

@property(nonatomic,retain) NSMutableDictionary *gameData;

@end

@implementation KKGameStateManager

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
        
        _gameData = [[NSUserDefaults standardUserDefaults] objectForKey:@"gameData"];
        if(_gameData == nil)
        {
            _gameData = [[NSMutableDictionary alloc] init];
        }
    }
    return self;
}

-(NSMutableDictionary*)getItem:(NSInteger)itemID
{
    NSMutableDictionary *item = [_gameData objectForKey:[NSString stringWithFormat:@"item%d",itemID]];
    if(item == nil)
    {
        item = [[NSMutableDictionary alloc] init];
        [_gameData setObject:item forKey:[NSString stringWithFormat:@"item%d",itemID]];
    }
    return item;
}

-(NSMutableDictionary*)getLevelsForItem:(NSInteger)itemID
{
    NSMutableDictionary *levels = nil;
    NSMutableDictionary *item = [self getItem:itemID];
    levels = [item objectForKey:@"levels"];
    if(levels == nil)
    {
        levels = [[NSMutableDictionary alloc] init];
        [item setObject:levels forKey:@"levels"];
    }
    
    return levels;
}

-(NSMutableDictionary*)getLevel:(NSInteger)levelID forItem:(NSInteger)itemID
{
    NSMutableDictionary *level = nil;
    NSMutableDictionary *levels = [self getLevelsForItem:itemID];
    level = [levels objectForKey:[NSString stringWithFormat:@"level%d",levelID]];
    if(level == nil)
    {
        level = [[NSMutableDictionary alloc] init];
        [levels setObject:level forKey:[NSString stringWithFormat:@"level%d",levelID]];
    }
    return level;
}

-(void)setLife:(NSInteger)inLife level:(NSInteger)inLevelID forItem:(NSInteger)itemID
{
    NSMutableDictionary *level = [self getLevel:inLevelID forItem:itemID];
    [level setObject:[NSNumber numberWithInteger:inLife] forKey:@"life"];
}

-(NSInteger)getLifeForLevel:(NSInteger)inLevelID forItem:(NSInteger)itemID
{
    NSMutableDictionary *level = [self getLevel:inLevelID forItem:itemID];
    NSNumber *life = [level objectForKey:@"life"];
    if(life == nil)
        return -1;
    return [life integerValue];
}


@end

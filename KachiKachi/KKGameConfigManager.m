//
//  WUNGameConfigManager.m
//  WakeUpNow
//
//  Created by S P, Chandan Shetty (external - Project) on 2/7/14.
//  Copyright (c) 2014 S P, Chandan Shetty (external - Project). All rights reserved.
//

#import "KKGameConfigManager.h"


const NSString *kLevels = @"levels";
const NSString *kElements = @"elements";
const NSString *kNoOfLevels = @"noOfLevels";
const NSString *kItem = @"item";
const NSString *kLevel = @"level";
const NSString *kNoOfItems = @"noOfItems";

@interface KKGameConfigManager ()

@property(nonatomic,strong) NSDictionary *configuration;

@end

@implementation KKGameConfigManager

+ (id) sharedManager
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

-(id)init
{
    self =[super init];
    if(self)
    {
        NSString *strplistPath = [[NSBundle mainBundle] pathForResource:@"GameData" ofType:@"plist"];
        NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:strplistPath];
        
        NSString *strerrorDesc = nil;
        NSPropertyListFormat plistFormat;
        // convert static property liost into dictionary object
        _configuration = (NSDictionary *)[NSPropertyListSerialization propertyListFromData:plistXML mutabilityOption:NSPropertyListMutableContainersAndLeaves format:&plistFormat errorDescription:&strerrorDesc];
        if (!_configuration)
        {
            NSLog(@"Error reading plist: %@, format: %d", strerrorDesc, plistFormat);
        }
    }
    return self;
}

-(NSMutableDictionary*)stageWithID:(NSInteger)stageID
{
    NSMutableDictionary *stage = nil;
    stage = [_configuration objectForKey:[NSString stringWithFormat:@"Stage%d",stageID]];
    return stage;
}

-(NSMutableDictionary*)getAllLevels:(NSInteger)stageID
{
    NSMutableDictionary *levels = nil;
    
    NSMutableDictionary *stage = [self stageWithID:stageID];
    if(stage){
        levels = [stage objectForKey:@"levels"];
    }
    
    return levels;
}

-(NSMutableDictionary*)levelWithID:(NSInteger)levelID andStage:(NSInteger)stageID
{
    NSMutableDictionary *level = nil;
    NSMutableDictionary *levels = [self getAllLevels:stageID];
    if(levels){
        level = [levels objectForKey:[NSString stringWithFormat:@"level%d",levelID]];
    }
    return level;
}


@end

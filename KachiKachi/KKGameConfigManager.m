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
        
        _noOfItems = [[_configuration objectForKey:kNoOfItems] intValue];
    }
    return self;
}

-(NSMutableDictionary*)itemWithId:(NSInteger)inItemID
{
    NSMutableDictionary *item = nil;
    item = [_configuration objectForKey:[NSString stringWithFormat:@"item%d",inItemID]];
    if(item)
    {
        
    }
    
    return item;
}

-(NSMutableDictionary*)levelForID:(NSInteger)inLevelID forItem:(NSInteger)inItemID
{
    NSMutableDictionary *levels = nil;
    
    NSMutableDictionary *item = [self itemWithId:inItemID];
    if(item){
        levels = [item objectForKey:kLevels];
        if(levels){
            
        }
    }
    
    return levels;
}

-(NSMutableDictionary*)elementForLevel:(NSInteger)inLevelID forItem:(NSInteger)inItemID
{
    NSMutableDictionary *element = nil;
    
    NSMutableDictionary *levels = [self levelForID:inLevelID forItem:inItemID];
    if(levels){
        element = [levels objectForKey:[NSString stringWithFormat:@"level%d",inLevelID]];
    }
    
    return element;
}



@end

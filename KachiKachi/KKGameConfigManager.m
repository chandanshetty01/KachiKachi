//
//  WUNGameConfigManager.m
//  WakeUpNow
//
//  Created by S P, Chandan Shetty (external - Project) on 2/7/14.
//  Copyright (c) 2014 S P, Chandan Shetty (external - Project). All rights reserved.
//

#import "KKGameConfigManager.h"

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

-(NSDictionary*)getData:(NSString*)fileName
{
    NSString *strplistPath = nil;
    strplistPath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"plist"];
    NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:strplistPath];
    NSString *strerrorDesc = nil;
    NSPropertyListFormat plistFormat;
    // convert static property liost into dictionary object
    NSDictionary *data = (NSDictionary *)[NSPropertyListSerialization propertyListFromData:plistXML mutabilityOption:NSPropertyListMutableContainersAndLeaves format:&plistFormat errorDescription:&strerrorDesc];
    if (!data)
    {
        NSLog(@"Error reading plist: %@, format: %lu", strerrorDesc, (unsigned long)plistFormat);
    }
    return data;
}

-(NSDictionary*)levelWithID:(NSInteger)levelID andStage:(NSInteger)stageID
{
    NSDictionary *data = nil;
    if(IS_IPAD){
        data = [self getData:[NSString stringWithFormat:@"stage_%ld_level_%ld_iPad",(long)stageID,(long)levelID]];
    }
    else{
        data = [self getData:[NSString stringWithFormat:@"stage_%ld_level_%ld",(long)stageID,(long)levelID]];
    }
    return data;
}

-(NSDictionary*)stageWithID:(NSInteger)stageID
{
    NSDictionary *data = nil;
    if(IS_IPAD){
        data = [self getData:[NSString stringWithFormat:@"stage_%ld_iPad",(long)stageID]];
    }
    else{
        data = [self getData:[NSString stringWithFormat:@"stage_%ld",(long)stageID]];
    }
    return data;
}

-(NSString*)leaderBoardID:(NSInteger)levelID andStage:(NSInteger)stageID
{
    return [NSString stringWithFormat:@"Stage%ldLevel%ld",(long)stageID,(long)levelID];
}

@end

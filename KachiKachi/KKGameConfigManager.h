//
//  WUNGameConfigManager.h
//  WakeUpNow
//
//  Created by S P, Chandan Shetty (external - Project) on 2/7/14.
//  Copyright (c) 2014 S P, Chandan Shetty (external - Project). All rights reserved.
//

#import <Foundation/Foundation.h>

const NSString *kGrid_size;
const NSString *kCell_size;
const NSString *kLevels;
const NSString *kElements;
const NSString *kNoOfLevels;
const NSString *kNoOfItems;

@interface KKGameConfigManager : NSObject

@property(nonatomic,assign,readonly) NSInteger noOfItems;

+(id)sharedManager;
-(NSMutableDictionary*)stageWithID:(NSInteger)stageID;
-(NSMutableDictionary*)levelWithID:(NSInteger)inLevelID andStage:(NSInteger)stageID;

@end


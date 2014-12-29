//
//  WUNGameConfigManager.h
//  WakeUpNow
//
//  Created by S P, Chandan Shetty (external - Project) on 2/7/14.
//  Copyright (c) 2014 S P, Chandan Shetty (external - Project). All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KKGameConfigManager : NSObject

+(KKGameConfigManager*)sharedManager;

-(NSDictionary*)levelWithID:(NSInteger)levelID andStage:(NSInteger)stageID;
-(NSDictionary*)stageWithID:(NSInteger)stageID;
-(NSString*)leaderBoardID:(NSInteger)levelID andStage:(NSInteger)stageID;

@end


//
//  KKGameStateManager.h
//  KachiKachi
//
//  Created by Chandan on 08/08/2013.
//  Copyright (c) 2014 Chanddan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KKGameStateManager : NSObject
{
    
}
@property(nonatomic,assign)NSInteger currentLevel;
@property(nonatomic,assign)NSInteger currentStage;

+(KKGameStateManager*)sharedManager;
-(void)loadData;
-(void)saveData;
-(void)loadLevelData;

-(NSMutableArray*)levels;

@end

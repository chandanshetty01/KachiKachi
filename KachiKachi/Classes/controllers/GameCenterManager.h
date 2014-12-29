//
//  GameCenterManager.h
//  KachiKachi
//
//  Created by Chandan on 08/08/2013.
//  Copyright (c) 2014 Chanddan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GameCenterManager : NSObject
{
    
}
@property (nonatomic) BOOL gameCenterEnabled;

+(GameCenterManager*)sharedManager;

-(void)authenticateLocalPlayer:(UIViewController*)presentingController;
-(void)reportScore:(NSInteger)inScore identifier:(NSString*)leaderboardIdentifier;
-(void)showLeaderboard:(NSString*)leaderboardIdentifier inController:(UIViewController*)presentingController;

@end

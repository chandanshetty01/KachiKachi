//
//  GameCenterManager.m
//  KachiKachi
//
//  Created by Chandan on 08/08/2013.
//  Copyright (c) 2014 Chanddan. All rights reserved.
//

#import "GameCenterManager.h"

@interface GameCenterManager()<GKGameCenterControllerDelegate>

@end

@implementation GameCenterManager

+ (id) sharedManager
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

-(void)authenticateLocalPlayer:(UIViewController*)presentingController
{
    // Instantiate a GKLocalPlayer object to use for authenticating a player.
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    
    localPlayer.authenticateHandler = ^(UIViewController *viewController, NSError *error){
        if (viewController != nil) {
            // If it's needed display the login view controller.
            [presentingController presentViewController:viewController animated:YES completion:nil];
        }
        else{
            if ([GKLocalPlayer localPlayer].authenticated) {
                // If the player is already authenticated then indicate that the Game Center features can be used.
                _gameCenterEnabled = YES;
            }
            
            else{
                _gameCenterEnabled = NO;
            }
        }
    };
}

-(void)reportScore:(NSInteger)inScore identifier:(NSString*)leaderboardIdentifier
{
    if(!_gameCenterEnabled){
        return;
    }
    
    // Create a GKScore object to assign the score and report it as a NSArray object.
    GKScore *score = [[GKScore alloc] initWithLeaderboardIdentifier:leaderboardIdentifier];
    score.value = inScore;
    
    [GKScore reportScores:@[score] withCompletionHandler:^(NSError *error) {
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
        }
    }];
}


-(void)showLeaderboard:(NSString*)leaderboardIdentifier inController:(UIViewController*)presentingController
{
    if(!_gameCenterEnabled){
        return;
    }
    
    // Init the following view controller object.
    GKGameCenterViewController *gcViewController = [[GKGameCenterViewController alloc] init];
    
    // Set self as its delegate.
    gcViewController.gameCenterDelegate = self;
    
    gcViewController.viewState = GKGameCenterViewControllerStateLeaderboards;
    if(leaderboardIdentifier){
        gcViewController.leaderboardIdentifier = leaderboardIdentifier;        
    }

    // Finally present the view controller.
    [presentingController presentViewController:gcViewController animated:YES completion:nil];
}

-(void)getGameCenterScore:(NSString*)leaderboardIdentifier  completionBlk:(completionBlkWithScore)block
{
    if(!_gameCenterEnabled){
        block(nil);
    }
    
    GKLeaderboard *board = [[GKLeaderboard alloc] init];
    board.timeScope = GKLeaderboardTimeScopeAllTime;
    board.playerScope = GKLeaderboardPlayerScopeGlobal; // or GKLeaderboardPlayerScopeFriendsOnly
    board.range = NSMakeRange(1, 1);
    board.identifier = leaderboardIdentifier;
    [board loadScoresWithCompletionHandler: ^(NSArray *scores, NSError *error) {
        if (error != nil) {
            // handle the error.
            block(nil);
        }
        if (scores != nil) {
            GKScore* score = [board localPlayerScore];
            block(score);
        }
    }];
}

#pragma mark - GKGameCenterControllerDelegate method implementation

-(void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController
{
    [gameCenterViewController dismissViewControllerAnimated:YES completion:nil];
}

@end

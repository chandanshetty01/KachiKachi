//
//  KKGameOverViewController.h
//  KachiKachi
//
//  Created by Chandan on 08/08/2013.
//  Copyright (c) 2014 Chanddan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KKGameOverViewController : UIViewController
{
    
}

@property(nonatomic,weak) id delegate;
@property (weak, nonatomic) IBOutlet UILabel *scoreTitle;
@property (weak, nonatomic) IBOutlet UILabel *rankingTitle;
@property (weak, nonatomic) IBOutlet UILabel *bestScoreTitle;
@property (weak, nonatomic) IBOutlet UILabel *score;
@property (weak, nonatomic) IBOutlet UILabel *ranking;
@property (weak, nonatomic) IBOutlet UILabel *bestScore;
@property (weak, nonatomic) IBOutlet UILabel *gameCompletedTitle;
@property (weak, nonatomic) IBOutlet UIButton *facebookBtn;
@property (weak, nonatomic) IBOutlet UIButton *twitterBtn;
@property (weak, nonatomic) IBOutlet UIButton *gameCenterBtn;
@property (weak, nonatomic) IBOutlet UIButton *nextLevelBtn;
@property (weak, nonatomic) IBOutlet UIButton *ReplayBtn;
@property (weak, nonatomic) IBOutlet UIButton *mainMenuBtn;

@end

@protocol KKGameOverViewControllerDelegates <NSObject>

- (void)facebookAction;
- (void)twitterAction;
- (void)gameCenterAction;
- (void)nextLevelAction;
- (void)replayAction;
- (void)mainMenuAction;

@end

//
//  KKGameOverViewController.m
//  KachiKachi
//
//  Created by Chandan on 08/08/2013.
//  Copyright (c) 2014 Chanddan. All rights reserved.
//

#import "KKGameOverViewController.h"
#import "SoundManager.h"
#import "KKGameStateManager.h"

@interface KKGameOverViewController ()

@end

@implementation KKGameOverViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.scoreTitle.text = NSLocalizedString(@"SCORE_TITLE", );
    self.rankingTitle.text = NSLocalizedString(@"RANKING", );
    self.bestScoreTitle.text = NSLocalizedString(@"BEST_SCORE", );
    [self.facebookBtn setTitle:NSLocalizedString(@"FACEBOOK_SHARE", ) forState:UIControlStateNormal];
    [self.twitterBtn setTitle:NSLocalizedString(@"TWEET", ) forState:UIControlStateNormal];
    [self.gameCenterBtn setTitle:NSLocalizedString(@"GAME_CENTER", ) forState:UIControlStateNormal];
    [self.nextLevelBtn setTitle:NSLocalizedString(@"PLAY_NEXT_LEVEL", ) forState:UIControlStateNormal];
    [self.ReplayBtn setTitle:NSLocalizedString(@"REPLAY", ) forState:UIControlStateNormal];
    [self.mainMenuBtn setTitle:NSLocalizedString(@"MAIN_MENU", ) forState:UIControlStateNormal];
}

-(void)updateData:(KKLevelModel*)levelModel
{
    self.levelModel = levelModel;
    self.score.text = [NSString stringWithFormat:@"%d",(int)levelModel.score];
    if(self.levelModel.bestScore > 0){
        self.bestScore.text = [NSString stringWithFormat:@"%d",(int)levelModel.bestScore];
    }
    else{
        self.bestScore.text = @"-";
    }
    self.ranking.text = @"-";
    
    if(self.status == eLevelCompleted){
        self.nextLevelBtn.hidden = NO;

        self.gameCompletedTitle.text = [NSString stringWithFormat:NSLocalizedString(@"LEVEL_COMPLETE", ),self.levelModel.levelID];
        if(self.levelModel.levelID == [[KKGameStateManager sharedManager] numberOfLevels]){
            NSString *stageName = nil;
            if(self.levelModel.stageID == 1){
                stageName = NSLocalizedString(@"EASY",nil);
            }
            else if(self.levelModel.stageID == 2){
                stageName = NSLocalizedString(@"MEDIUM",nil);
            }
            else{
                stageName = NSLocalizedString(@"ADVANCE",nil);
            }
            self.gameCompletedTitle.text = [NSString stringWithFormat:NSLocalizedString(@"STAGE_COMPLETE", ),stageName];
        }
    }
    else{
        self.nextLevelBtn.hidden = YES;
        self.gameCompletedTitle.text = NSLocalizedString(@"LEVEL_FAILED",nil);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)facebookAction:(id)sender
{
    [[SoundManager sharedManager] playSound:@"tap" looping:NO];

    if(self.delegate && [self.delegate respondsToSelector:@selector(facebookAction)]){
        [self.delegate facebookAction];
    }
}

- (IBAction)twitterAction:(id)sender
{
    [[SoundManager sharedManager] playSound:@"tap" looping:NO];

    if(self.delegate && [self.delegate respondsToSelector:@selector(twitterAction)]){
        [self.delegate twitterAction];
    }
}

- (IBAction)gameCenterAction:(id)sender
{
    [[SoundManager sharedManager] playSound:@"tap" looping:NO];

    if(self.delegate && [self.delegate respondsToSelector:@selector(gameCenterAction)]){
        [self.delegate gameCenterAction];
    }
}

- (IBAction)nextLevelAction:(id)sender
{
    [[SoundManager sharedManager] playSound:@"tap" looping:NO];

    if(self.delegate && [self.delegate respondsToSelector:@selector(nextLevelAction)]){
        [self.delegate nextLevelAction];
    }
}

- (IBAction)replayAction:(id)sender
{
    [[SoundManager sharedManager] playSound:@"tap" looping:NO];

    if(self.delegate && [self.delegate respondsToSelector:@selector(replayAction)]){
        [self.delegate replayAction];
    }
}

- (IBAction)mainMenuAction:(id)sender
{
    [[SoundManager sharedManager] playSound:@"tap" looping:NO];

    if(self.delegate && [self.delegate respondsToSelector:@selector(mainMenuAction)]){
        [self.delegate mainMenuAction];
    }
}

@end

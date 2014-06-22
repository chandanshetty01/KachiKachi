//
//  ViewController.m
//  KachiKachi
//
//  Created by Chandan on 08/08/2013.
//  Copyright (c) 2014 Chanddan. All rights reserved.
//

#import "KKLevelSelectViewController.h"
#import "KKGameSceneController.h"
#import "SoundManager.h"
#import "KKLevelModal.h"

@interface KKLevelSelectViewController ()

@end

@implementation KKLevelSelectViewController

- (void)viewDidLoad
{    
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [SoundManager sharedManager].allowsBackgroundMusic = YES;
    [[SoundManager sharedManager] prepareToPlay];
    
    [self playMusic];
}

-(void)playMusic
{
    [[SoundManager sharedManager] playMusic:@"track1" looping:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backButtonAction:(id)sender {
    AppDelegate *appdelegate = APP_DELEGATE;
    [appdelegate.navigationController popViewControllerAnimated:YES];
}

-(KKLevelModal*)currentLevelData:(NSInteger)levelID
{
    KKLevelModal *levelModel = nil;
    KKGameConfigManager *config = [KKGameConfigManager sharedManager];
    NSDictionary *level = [config levelWithID:levelID andStage:self.currentStage];
    levelModel = [[KKLevelModal alloc] initWithDictionary:level];
    return levelModel;
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UIButton *btn = (UIButton*)sender;
    KKGameSceneController *nextVC = (KKGameSceneController *)[segue destinationViewController];
    nextVC.levelModel = [self currentLevelData:btn.tag];
}

- (void)dealloc
{
}

@end

//
//  KKStageSelectControllerViewController.m
//  KachiKachi
//
//  Created by Chandan on 08/08/2013.
//  Copyright (c) 2014 Chanddan. All rights reserved.
//

#import "KKStageSelectController.h"
#import "KKLevelSelectViewController.h"
#import "SoundManager.h"
#import "KKGameStateManager.h"

@interface KKStageSelectController ()

@end

@implementation KKStageSelectController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    BOOL isOn = [[KKGameStateManager sharedManager] isSoundEnabled];
    [self.soundSwitch setOn:isOn];
    
    [self playMusic];
}



-(void)playMusic
{
    [SoundManager sharedManager].allowsBackgroundMusic = YES;
    [[SoundManager sharedManager] prepareToPlay];
    [[SoundManager sharedManager] playMusic:@"track1" looping:YES];
}

-(void)stopMusic
{
    [[SoundManager sharedManager] stopMusic];
}

- (IBAction)handleSwitchBtn:(UISwitch*)sender
{
    [[KKGameStateManager sharedManager] setSoundEnabled:sender.isOn];
    
    if(sender.isOn)
        [self playMusic];
    else
        [self stopMusic];
}

- (IBAction)handleSupportBtn:(id)sender
{
    
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(UIButton*)sender
{
    NSInteger stage = sender.tag;
    
    BOOL isLocked = [[KKGameStateManager sharedManager] isStageLocked:stage];
#ifdef ENABLE_ALL_LEVELS
    isLocked = NO;
#endif
    if(!isLocked){
        [Flurry logEvent:[NSString stringWithFormat:@"StageSelect-%d(Selected)",stage]];
        
        self.currentStage = sender.tag;
        return YES;
    }
    else{
        [Flurry logEvent:[NSString stringWithFormat:@"StageSelect-%d(Locked)",stage]];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Stage Locked!"
                                                        message:@"Complete all levels in previous stage to unlock the stage"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        
        [alert show];
    }
    
    return NO;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UIButton *button = (UIButton*)sender;
    
    KKLevelSelectViewController *nextVC = (KKLevelSelectViewController *)[segue destinationViewController];
    if([nextVC respondsToSelector:@selector(setCurrentStage:)])
        nextVC.currentStage = button.tag;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

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
#import "UserVoice.h"
#import "KKMailComposerManager.h"

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
    
    BOOL isOn = [[KKGameStateManager sharedManager] isMusicEnabled];
    [self.soundSwitch setOn:isOn];
    
    [self playMusic];
}

-(void)playMusic
{
    [SoundManager sharedManager].allowsBackgroundMusic = YES;
    [[SoundManager sharedManager] prepareToPlay];
    [[SoundManager sharedManager] playMusic:@"FunkGameLoop"];
}

-(void)stopMusic
{
    [[SoundManager sharedManager] stopMusic];
}

- (IBAction)handleSwitchBtn:(UISwitch*)sender
{
    [[SoundManager sharedManager] playSound:@"tap" looping:NO];

    [[KKGameStateManager sharedManager] setMusicEnabled:sender.isOn];
    
    if(sender.isOn)
        [self playMusic];
    else
        [self stopMusic];
}

- (IBAction)handleSoundSwitchBtn:(UISwitch *)sender
{
    [[KKGameStateManager sharedManager] setSoundEnabled:sender.isOn];
    
    [[SoundManager sharedManager] playSound:@"tap" looping:NO];
}

- (IBAction)handleSupportBtn:(id)sender
{
    [[SoundManager sharedManager] playSound:@"tap" looping:NO];
    UVConfig *config = [UVConfig configWithSite:@"aismobileapps.uservoice.com"];
    [UserVoice initialize:config];
    [UserVoice presentUserVoiceInterfaceForParentViewController:self];
}

-(void)purchaseALert:(NSInteger)stageID
{
    NSString *money = nil;
    NSString *msg = [NSString stringWithFormat:NSLocalizedString(@"UNLOCK_STAGE", nil),money];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"UNLOCK_STAGE_TITLE", nil)
                                                    message:msg
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    alert.tag = stageID;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [[SoundManager sharedManager] playSound:@"tap" looping:NO];

    if(alertView.tag == 2)
    {
        [self purchase:2];
    }
    else if(alertView.tag == 3)
    {
        [self purchase:3];
    }
}

-(void)purchase:(NSInteger)stageID
{
    NSString *featureID = nil;
    if(stageID == 2)
        featureID = kTimedMode;
    else if(stageID == 3)
        featureID = kAdvancedMode;
        
    [[MKStoreManager sharedManager] buyFeature:featureID
                                    onComplete:^(NSString* purchasedFeature,
                                                 NSData* purchasedReceipt,
                                                 NSArray* availableDownloads)
     {
         self.currentStage = stageID;
         if(stageID == 2){
             [self performSegueWithIdentifier:@"stage2Seague" sender:self];
         }
         else if(stageID == 3){
             [self performSegueWithIdentifier:@"stage3Seague" sender:self];
         }
         
         [[SoundManager sharedManager] playSound:@"won" looping:NO];

         NSLog(@"Purchased: %@", purchasedFeature);
     }
                                   onCancelled:^
     {
         NSLog(@"User Cancelled Transaction");
     }];
    
    /*
    //test
    if(stageID == 2){
        self.currentStage = stageID;
        [self performSegueWithIdentifier:@"stage2Seague" sender:self];
    }
    else if(stageID == 3){
        self.currentStage = stageID;
        [self performSegueWithIdentifier:@"stage3Seague" sender:self];
    }
     */
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(UIButton*)sender
{
    [[SoundManager sharedManager] playSound:@"tap" looping:NO];

#ifdef ENABLE_ALL_LEVELS
    self.currentStage = sender.tag;
    return YES;
#endif
    
    NSInteger stage = sender.tag;
    BOOL isLocked = [[KKGameStateManager sharedManager] isStageLocked:stage];
    if(!isLocked)
    {
        [Flurry logEvent:[NSString stringWithFormat:@"StageSelect-%ld(Selected)",(long)stage]];
        self.currentStage = sender.tag;
        return YES;
    }
    else
    {
        [Flurry logEvent:[NSString stringWithFormat:@"StageSelect-%ld(Locked)",(long)stage]];
        
        NSString *featureID = nil;
        if(stage == 2)
            featureID = kTimedMode;
        else if(stage == 3)
            featureID = kAdvancedMode;
        
        if([MKStoreManager isFeaturePurchased:featureID])
        {
            self.currentStage = sender.tag;
            return YES;
        }
        else
        {
            [self purchaseALert:stage];
        }
    }
    
    return NO;
}

- (IBAction)handleShareButton:(id)sender {
    
    [[SoundManager sharedManager] playSound:@"tap" looping:NO];

    // Fill out the email body text
    NSString *emailBody = [NSString stringWithFormat:NSLocalizedString(@"TELL_A_FRIEND_MSG", nil),APP_URL];
    NSString *emailSub = NSLocalizedString(@"TELL_A_FRIEND_TITLE", nil);
    
    [[KKMailComposerManager sharedManager] displayMailComposerSheet:self
                                                       toRecipients:nil
                                                       ccRecipients:nil
                                                     attachmentData:nil
                                                 attachmentMimeType:nil
                                                 attachmentFileName:nil
                                                          emailBody:emailBody
                                                       emailSubject:emailSub];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    KKLevelSelectViewController *nextVC = (KKLevelSelectViewController *)[segue destinationViewController];
    if([nextVC respondsToSelector:@selector(setCurrentStage:)])
        nextVC.currentStage = self.currentStage;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

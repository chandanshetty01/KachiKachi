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
#import "Utility.h"

@interface KKStageSelectController ()

@property (weak, nonatomic) IBOutlet UILabel *easyTitle;
@property (weak, nonatomic) IBOutlet UILabel *mediumTitle;
@property (weak, nonatomic) IBOutlet UILabel *advancedTitle;
@property (weak, nonatomic) IBOutlet UIButton *rateusBtn;
@property (weak, nonatomic) IBOutlet UIButton *howToPlayButton;

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
    
    self.easyTitle.text = NSLocalizedString(@"EASY", nil);
    self.mediumTitle.text = NSLocalizedString(@"MEDIUM", nil);
    self.advancedTitle.text = NSLocalizedString(@"ADVANCE", nil);
    [self.rateusBtn setTitle:NSLocalizedString(@"RATE_US", nil) forState:UIControlStateNormal];
    [self.howToPlayButton setTitle:NSLocalizedString(@"HOW_TO_PLAY", nil) forState:UIControlStateNormal];
    
    BOOL isOn = [[KKGameStateManager sharedManager] isSoundEnabled];
    [self.soundSwitch setOn:isOn];
    isOn = [[KKGameStateManager sharedManager] isMusicEnabled];
    [self.musicSwitch setOn:isOn];
}

-(void)viewDidAppear:(BOOL)animated
{
    [self playMusic];
}

- (IBAction)handleHowToPlay:(id)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"HOW_TO_PLAY", nil)
                                                        message:NSLocalizedString(@"HOW_TO_PLAY_DESC", nil)
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"GOT_IT", nil)
                                              otherButtonTitles:nil, nil];
    [alertView show];
}

- (IBAction)rateUsBtnAction:(id)sender
{
    [Flurry logEvent:@"rate_us_btn_tap"];

    NSString *url = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%d",APPSTORE_ID];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
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
    NSString *money = @"0.99$";

    SKProduct *product = nil;
    if(stageID == 2)
        product = [[Utility sharedManager] productWithID:kTimedMode];
    else
        product = [[Utility sharedManager] productWithID:kAdvancedMode];
    
    if(product){
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
        [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        [numberFormatter setLocale:product.priceLocale];
        money = [numberFormatter stringFromNumber:product.price];
    }

    NSString *title = nil;
    NSString *desc = nil;
    if(stageID == 2){
        title = NSLocalizedString(@"UNLOCK_STAGE_MEDIUM", nil);
        desc = [NSString stringWithFormat:NSLocalizedString(@"UNLOCK_STAGE_MEDIUM_DESC", nil),money];
    }
    else{
        title = NSLocalizedString(@"UNLOCK_STAGE_ADVANCED", nil);
        desc = [NSString stringWithFormat:NSLocalizedString(@"UNLOCK_STAGE_ADVANCED_DESC", nil),money];
    }
    

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:desc
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"CANCEL", nil)
                                          otherButtonTitles:nil];
    [alert addButtonWithTitle:NSLocalizedString(@"BUY", nil)];
    [alert addButtonWithTitle:NSLocalizedString(@"RESTORE", nil)];
    
    alert.tag = stageID;
    [alert show];
}

-(void)showAlertForError:(NSError*)error
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERROR",nil)
                                                    message:[error localizedDescription]
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [[SoundManager sharedManager] playSound:@"tap" looping:NO];

    if(alertView.tag == 2)
    {
        if(buttonIndex == 0){
            [Flurry logEvent:[NSString stringWithFormat:@"InApp-Cancel-Stage%ld",(long)alertView.tag]];
            //Cancel
        }
        else if(buttonIndex == 2){
            [Flurry logEvent:[NSString stringWithFormat:@"InApp-Restore-Stage%ld",(long)alertView.tag]];

            //Restore
            [[MKStoreManager sharedManager] restorePreviousTransactionsOnComplete:^{
                [self provideContent:alertView.tag];
            } onError:^(NSError *error) {
                [self showAlertForError:error];
            }];
        }
        else{
            
            //Buy
            [self purchase:2];
        }
    }
    else if(alertView.tag == 3)
    {
        if(buttonIndex == 0){
            [Flurry logEvent:[NSString stringWithFormat:@"InApp-Restore-Stage%ld",(long)alertView.tag]];

            //cancel
        }
        else if(buttonIndex == 2){
            [Flurry logEvent:[NSString stringWithFormat:@"InApp-Restore-Restore%ld",(long)alertView.tag]];

            //restore
            [[MKStoreManager sharedManager] restorePreviousTransactionsOnComplete:^{
                [self provideContent:alertView.tag];
            } onError:^(NSError *error) {
                [self showAlertForError:error];
            }];
        }
        else{
            //Buy
            [self purchase:3];
        }
    }
}

-(void)provideContent:(NSInteger)stageID
{
    NSString *featureID = nil;
    if(stageID == 2)
        featureID = kTimedMode;
    else if(stageID == 3)
        featureID = kAdvancedMode;
    
    if([MKStoreManager isFeaturePurchased:featureID])
    {
        self.currentStage = stageID;
        if(stageID == 2){
            [self performSegueWithIdentifier:@"stage2Seague" sender:self];
        }
        else if(stageID == 3){
            [self performSegueWithIdentifier:@"stage3Seague" sender:self];
        }
        
        [[SoundManager sharedManager] playSound:@"won" looping:NO];
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
         [Flurry logEvent:[NSString stringWithFormat:@"Purchased-Stage(%ld)",(long)stageID]];
         [self provideContent:stageID];
     }
                                   onCancelled:^
     {
         [Flurry logEvent:[NSString stringWithFormat:@"Purchase-Cacelled(%ld)",(long)stageID]];
     }];
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
                                                       emailSubject:emailSub
                                                         completion:^(NSInteger index) {
                                                             if(index == 1){
                                                                 //sent
                                                                 [Flurry logEvent:@"tellafriend_mailsent"];
                                                                 NSInteger sharePoints = [[KKGameStateManager sharedManager] getSharePointsCount];
                                                                 if(sharePoints > 0){
                                                                     NSInteger gamepoints = [[KKGameStateManager sharedManager] gamePoints];
                                                                     [[KKGameStateManager sharedManager] setGamePoints:gamepoints+10];
                                                                     [[KKGameStateManager sharedManager] setSharePoint:sharePoints-1];
                                                                 }
                                                             }
                                                         }];
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

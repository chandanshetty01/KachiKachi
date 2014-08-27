//
//  KKGameSceneController.m
//  KachiKachi
//
//  Created by Chandan on 08/08/2013.
//  Copyright (c) 2014 Chanddan. All rights reserved.
//

#import "KKGameSceneController.h"
#import "TTBase.h"
#import "Utility.h"
#import "SoundManager.h"
#import <Math.h>
#import "AppDelegate.h"
#import "KKMailComposerManager.h"
#import "KKItemModal.h"
#import "KKGameStateManager.h"
#import <Crashlytics/Crashlytics.h>
#import <Social/Social.h>
#import "MKStoreManager.h"
#import "KKCustomAlertViewController.h"
#import "Utility.h"
#import "TTMagicStick.h"

#define RANDOM_SEED() srandom((unsigned)time(NULL))
#define RANDOM_INT(__MIN__, __MAX__) ((__MIN__) + random() % ((__MAX__+1) - (__MIN__)))
#define RADIANS(degrees) ((degrees * M_PI) / 180.0)

#define LEVEL_INFO @"levelInfo"
#define LEVEL_INFO_LIFE @"levelLife"
#define LEVEL_WON @"levelWon"

const NSInteger kPointsToUnlockLevel = 100;
const NSInteger kMagicStickUsageCount = 5;
const NSInteger kMaxMagicStick = 3;

typedef enum {
    eGameWonAlertID = 100,
    eGameLostAlertID,
    eTutorialAlertID,
    eUnlockNextLevelID,
    ePurchasePointsID
}ALERT_ID;

typedef enum {
    ePurchasePoints100ID,
    ePurchasePoints200ID,
    ePurchasePoints400ID
}PURCHASEPOINTS_ID;

@interface KKGameSceneController ()

@property(nonatomic,strong) NSMutableArray *deletedElements;
@property(nonatomic,assign) BOOL isGameFinished;
@property(nonatomic,weak) TTBase* topElement;
@property (weak, nonatomic) IBOutlet UILabel *timerLabel;
@property (weak, nonatomic) IBOutlet UILabel *pointsEarned;
@property (weak, nonatomic) IBOutlet UIButton *magicStick;
@property (assign, nonatomic) BOOL isMagicStickMode;
@property (weak, nonatomic) IBOutlet UIButton *magicStickBtn;
@property (strong, nonatomic)  TTMagicStick *magicStickAnimation;
@property(nonatomic,assign)NSInteger magicStickCounter;
@property (weak, nonatomic) IBOutlet UIView *magicStickHolder;
@property (weak, nonatomic) IBOutlet UILabel *magicStickLabel;
@end

typedef void (^completionBlk)(BOOL);

@implementation KKGameSceneController

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
    _elements = [[NSMutableArray alloc] init];
    self.deletedElements = [[NSMutableArray alloc] init];
    
    self.currentLevel = [[KKGameStateManager sharedManager] currentLevelNumber];
    self.currentStage = [[KKGameStateManager sharedManager] currentStageNumber];
    self.points = [[KKGameStateManager sharedManager] gamePoints];
    [self updatePointsEarned:0];
    
#ifndef DEVELOPMENT_MODE
    BOOL canRemoveAds = [[KKGameStateManager sharedManager] getCanRemoveAds];
    if([MKStoreManager isFeaturePurchased:kTimedMode] || [MKStoreManager isFeaturePurchased:kAdvancedMode] || canRemoveAds){
        //If purchased do not show any Ads
    }
    else{
        //show Ads
        self.adViewController = [[UIStoryboard storyboardWithName:@"Main_iPad" bundle:nil] instantiateViewControllerWithIdentifier:@"adViewController"];
        [self.view addSubview:self.adViewController.view];
        self.adViewController.delegate = self;
        CGRect frame = self.adViewController.view.frame;
        frame.origin = CGPointZero;
        self.adViewController.view.frame = frame;
    }
#endif

    self.gameMode = (EGAMEMODE)[[KKGameConfigManager sharedManager] gameModeForLevel:self.currentLevel stage:self.currentStage];
    
    _isGameFinished = FALSE;
    self.noOfLifesRemaining = self.levelModel.life;
    self.duration = self.levelModel.duration;
    
    CGRect pointsFrame = self.pointsEarned.frame;
    if(self.gameMode == eTimerMode){
        [self showTutorial:2];
        [self updateTimer:self.levelModel.duration];
    }
    else{
        self.pointsEarned.textAlignment = NSTextAlignmentCenter;
        pointsFrame.origin.x = 387;
        [self showTutorial:1];
    }
    self.pointsEarned.frame = pointsFrame;
    
    [self addElements];
    
#ifdef DEVELOPMENT_MODE
    _switchBtn.hidden = NO;
    _saveBtn.hidden = NO;
    _mailButton.hidden = NO;
    _addButton.hidden = NO;
#else
    _switchBtn.hidden = YES;
    _saveBtn.hidden = YES;
    _mailButton.hidden = YES;
    _addButton.hidden = YES;
#endif
    
    [_switchBtn setOn:NO];
    
    [[SoundManager sharedManager] playMusic:@"lovesong"];
    [self updateUI];
    
    if(self.gameMode == eTimerMode){
    }
    else{
        self.timerLabel.hidden = YES;
    }

    //testing code
//    [[KKGameStateManager sharedManager] setMagicStickUsageCount:3];
    //till here
    
    self.magicStickCounter = 0;
    
    [self updateMagicStic];
    [self stageInformationFlurry];
    [self updateMagicStickBtnPosition];
}

-(void)setMagicStickCounter:(NSInteger)magicStickCounter
{
    _magicStickCounter = magicStickCounter;
    if(self.magicStickAnimation){
        [self.magicStickAnimation updateCount:magicStickCounter];
    }
}

-(void)updateMagicStickBtnPosition
{
    [self.view bringSubviewToFront:self.magicStickHolder];
    CGRect frame = self.magicStickHolder.frame;
    switch (self.currentLevel) {
        case 4:{
            frame.origin = CGPointMake(50,self.view.bounds.size.width-frame.size.height-50);
        }
            break;

        case 5:{
            frame.origin = CGPointMake(self.view.bounds.size.height-frame.size.width-100,self.view.bounds.size.width-frame.size.height-100);
        }
            break;

        case 18:{
            frame.origin = CGPointMake(0,100);
        }
            break;
            
        default:{
            frame.origin = CGPointMake(self.view.bounds.size.height-frame.size.width, 0);
        }
            break;
    }
    self.magicStickHolder.frame = frame;
}

-(void)showMagicStickAnimation
{
    if(!self.magicStickAnimation){
        self.magicStickAnimation = [[TTMagicStick alloc] initWithFrame:self.view.bounds];
        [self.view addSubview:self.magicStickAnimation];
        [self.magicStickAnimation startAnimation];
    }
}

-(void)removeMagicStickAnimation
{
    if(self.magicStickAnimation){
        [self.magicStickAnimation stopAnimation];
        [self.magicStickAnimation removeFromSuperview];
        self.magicStickAnimation = nil;
    }
}

-(void)setIsMagicStickMode:(BOOL)isMagicStickMode
{
    _isMagicStickMode = isMagicStickMode;
    if(isMagicStickMode){
        [self showMagicStickAnimation];
    }
    else{
        [self removeMagicStickAnimation];
    }
}

-(void)updateMagicStic
{
    NSInteger usageCount = [[KKGameStateManager sharedManager] getmagicStickUsageCount];
    NSString *title = [NSString stringWithFormat:NSLocalizedString(@"MAGIC_STICK",nil),usageCount];
    [self.magicStick setTitle:title forState:UIControlStateNormal];
    self.magicStickLabel.text = [NSString stringWithFormat:@"%ld",(long)usageCount];
    if(usageCount > 0){
        self.magicStick.alpha = 1.0;
    }
    else{
        self.magicStick.alpha = 0.7;
    }
}

- (IBAction)handleMagicStickAction:(id)sender
{
    if(self.isMagicStickMode)
        return;
    
    NSInteger usageCount = [[KKGameStateManager sharedManager] getmagicStickUsageCount];
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main_iPad" bundle:nil];
    KKCustomAlertViewController *alertview = [storyBoard instantiateViewControllerWithIdentifier:@"KKCustomAlertViewController"];
    if(usageCount > 0){
        [alertview addButtonWithTitle:NSLocalizedString(@"OK", nil)];
        [alertview addButtonWithTitle:NSLocalizedString(@"CANCEL", nil)];
        [alertview showAlertWithTitle:NSLocalizedString(@"MAGIC_STICK_USAGE", nil)
                              message:[NSString stringWithFormat:NSLocalizedString(@"MAGIC_STICK_USAGE_DESC",nil),kMagicStickUsageCount]
                          buttonTitle:NSLocalizedString(@"OK", nil)
                         inController:self
                           completion:^(NSInteger index) {
                               if(index == 0){
                                   [Flurry logEvent:@"magicstick_used"];
                                   self.isMagicStickMode = YES;
                                   [[KKGameStateManager sharedManager] setMagicStickUsageCount:usageCount-1];
                                   self.magicStickCounter = kMagicStickUsageCount;
                               }
                           }];
    }
    else{

        [alertview showAlertWithTitle:NSLocalizedString(@"MAGIC_STICK_NO_POINTS_TITLE", nil)
                              message:NSLocalizedString(@"MAGIC_STICK_NO_POINTS_DESC", nil)
                          buttonTitle:NSLocalizedString(@"OK", nil)
                         inController:self
                           completion:nil];
    }
}

-(void)stageInformationFlurry
{
    NSMutableDictionary *levelInfo = [[NSMutableDictionary alloc] init];
    [levelInfo setObject:[NSString stringWithFormat:@"%@",self.levelModel.name] forKey:[NSString stringWithFormat:@"%ld",(long)self.currentStage]];
    [Flurry logEvent:@"stage_information" withParameters:levelInfo];
}

-(void)showTutorial : (NSInteger)tutorialID
{
    if(tutorialID == 1){
        BOOL isTutorialShown = [[[NSUserDefaults standardUserDefaults] objectForKey:@"TUTORIAL_1"] boolValue];
        if(!isTutorialShown){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"HOW_TO_PLAY", nil)
                                                            message:NSLocalizedString(@"TUTORIAL_1", nil)
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            
            [alert show];
            [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:@"TUTORIAL_1"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
    else if(tutorialID == 2){
        BOOL isTutorialShown = [[[NSUserDefaults standardUserDefaults] objectForKey:@"TUTORIAL_2"] boolValue];
        if(!isTutorialShown){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"HOW_TO_PLAY", nil)
                                                            message:NSLocalizedString(@"TUTORIAL_2", nil)
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            alert.tag = eTutorialAlertID;
            [alert show];
            [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:@"TUTORIAL_2"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        else{
            [self startTimer];
        }
    }
}

-(void)startTimer
{
    if(self.gameMode == eTimerMode){
        self.timer = [[TimerObject alloc] initWithDuration:self.levelModel.duration fireInterval:1.0f];
        [self.timer startTimer];
        self.timer.delegate = self;
        self.timerLabel.hidden = NO;
    }
}

-(void)stopTimer
{
    if(self.gameMode == eTimerMode){
        if(self.timer){
            [self.timer pauseTimer];
            self.timer = nil;
        }
    }
}

-(void)updatePointsEarned:(NSInteger)inPoints
{
    self.points = self.points + inPoints;
    [[KKGameStateManager sharedManager] setGamePoints:self.points];
    self.pointsEarned.text = [NSString stringWithFormat:NSLocalizedString(@"POINTSEARNED", nil),self.points];
}

-(void)updateTimer:(NSInteger)remainingTime
{
    NSString *time = [NSString stringWithFormat:NSLocalizedString(@"TIME", @"time remainging %d"),(long)remainingTime];
    [self.timerLabel setText:time];
}

#pragma mark - Timer delegates -
-(void)timerDidCompleted:(TimerObject*)timer
{
    self.levelModel.duration = 0;
    [self updateTimer:self.levelModel.duration];
    [self validateGamePlay:^(BOOL finished) {
        _currentElement = nil;
    }];
}

-(void)timerDidTick:(NSTimeInterval)remainingInteval andTimer:(TimerObject*)timer
{
    self.levelModel.duration = remainingInteval;
    [self updateTimer:self.levelModel.duration];
}

-(void)postFlurry:(NSString*)status
{
    NSMutableDictionary *levelInfo = [[NSMutableDictionary alloc] init];
    if(self.gameMode == eTimerMode)
        [levelInfo setObject:[NSNumber numberWithInt:(int)self.levelModel.duration] forKey:@"duration"];
    [levelInfo setObject:status forKey:@"status"];
    [levelInfo setObject:[NSNumber numberWithInt:(int)self.levelModel.life] forKey:@"remaining_life"];
    
    NSString *key = [NSString stringWithFormat:@"Level(%@)Stage(%ld)",self.levelModel.name,(long)self.levelModel.stageID];
    [Flurry logEvent:key withParameters:levelInfo];
}

-(void)addElements
{
    [self.levelModel.items enumerateObjectsUsingBlock:^(KKItemModal *obj, NSUInteger idx, BOOL *stop) {
        [self generateElement:obj];
    }];
    
    self.topElement = [self.elements lastObject];
    
    UIImage *image = [UIImage imageNamed:self.levelModel.backgroundImage];
    self.background.image = image;
    
    [self.levelModel.baskets enumerateObjectsUsingBlock:^(NSDictionary *basket, NSUInteger idx, BOOL *stop) {
        UIImage *image = [UIImage imageNamed:[basket objectForKey:@"basket"]];
        CGRect frame = CGRectZero;
        frame.origin =CGPointFromString([basket objectForKey:@"basket_frame"]);
        frame.size = image.size;

        UIImageView *basketView = [[UIImageView alloc] initWithFrame:frame];
        basketView.image = image;
        
        KKItemModal *item = [self.levelModel.items objectAtIndex:0];
        if([item.className isEqualToString:@"TTBird"] ||
           ([item.className isEqualToString:@"TTCandle"] && [[basket objectForKey:@"basket"] isEqualToString:@"candle_basket2.png"]) ||
           ([item.className isEqualToString:@"TTDvd"] && [[basket objectForKey:@"basket"] isEqualToString:@"cd_basket1.png"]) ||
           ([item.className isEqualToString:@"TTUmbrella"]) || ([item.className isEqualToString:@"TTKey"]) ||
           ([item.className isEqualToString:@"TTBrush"] && ([[basket objectForKey:@"basket"] isEqualToString:@"toothbrush_container1.png"] || [[basket objectForKey:@"basket"] isEqualToString:@"toothbrush_container2.png"])))
        {
            [self.view insertSubview:basketView aboveSubview:self.background];
        }
        else
        {
            [self.view addSubview:basketView];
            [self.view bringSubviewToFront:self.bottomStrip];
        }
    }];
}

-(void)generateElement:(KKItemModal*)itemModel
{
    TTBase *object = [[NSClassFromString(itemModel.className) alloc] init];
    [object initWithModal:itemModel];
    if(object.image){
        [self.view addSubview:object];
        if(object.isPicked){
            [object setPickedObjectPosition];
        }
        [_elements addObject:object];
    }
}

-(BOOL)isGameOver
{
    BOOL gameOver = FALSE;
    
    NSMutableArray *intersectedElements = [self intersectedElements:_currentElement];
    
#ifdef DEVELOPMENT_MODE
    return gameOver;
#endif
    
    NSInteger currentElementIndex = [_elements indexOfObject:_currentElement];
    for (TTBase *element in intersectedElements) {
        NSInteger index = [_elements indexOfObject:element];
        if(currentElementIndex < index && !self.isMagicStickMode)
        {
            [_currentElement shakeAnimation];
            self.currentElement = nil;
            gameOver = true;
            break;
        }
    }
    
    if(gameOver == false && self.gameMode == eTimerMode)
    {
        if(self.levelModel.duration <= 0)
            gameOver = true;
    }
    
    return gameOver;
}

-(NSInteger)noOfObjectsToBePicked
{
    __block int count = 0;
    [self.elements enumerateObjectsUsingBlock:^(TTBase *obj, NSUInteger idx, BOOL *stop) {
        if(!obj.isPicked)
            count++;
    }];
    return count;
}

-(BOOL)isGameWon
{
#ifdef DEVELOPMENT_MODE
    return false;
#endif
    if([self noOfObjectsToBePicked] <= 1)
        return TRUE;
    return FALSE;
}


-(CGFloat)degreesToRadian:(CGFloat)angle{
    return angle * (3.14/180);
}

-(CGFloat)radianToDegree:(CGFloat)radian{
    return radian * (180/3.14);
}

-(void)showElementDissapearAnimation:(completionBlk)block
{
    [self.deletedElements enumerateObjectsUsingBlock:^(TTBase *obj, NSUInteger idx, BOOL *stop) {
        if(!obj.isPicked){
            obj.isPicked = YES;
            self.view.userInteractionEnabled = NO;
            [obj showAnimation:^(BOOL canRemoveObject) {
                [self.deletedElements removeObject:obj];
                self.view.userInteractionEnabled = YES;
                block(YES);
            }];
        }
    }];
}

-(void)updateUI
{
    self.lifeLabel.text = [NSString stringWithFormat:NSLocalizedString(@"LIFE", nil),self.noOfLifesRemaining];
}

-(void)saveLevelData
{
    NSMutableDictionary *levelDict = [self.levelModel savedDictionary];
    
    if([self.elements count] > 0)
    {
        NSMutableArray *elements = [NSMutableArray array];
        [self.elements enumerateObjectsUsingBlock:^(TTBase *obj, NSUInteger idx, BOOL *stop) {
            NSMutableDictionary *itemDict = [obj saveDictionary];
            [elements addObject:itemDict];
        }];
        [levelDict setObject:elements forKey:@"elements"];
    }
    
    [[KKGameStateManager sharedManager] setData:levelDict level:self.currentLevel stage:self.currentStage];
    
    [[KKGameStateManager sharedManager]save];
}

-(void)showUnlockAlert
{
    //Unlock Next Level
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"UNLOCK_NEXT_LEVEL", nil)
                                                    message:NSLocalizedString(@"UNLOCK_TEXT", nil)
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"CANCEL", nil)
                                          otherButtonTitles:NSLocalizedString(@"UNLOCK", nil), nil];
    //[alert addButtonWithTitle:NSLocalizedString(@"REPLAY", nil)];
    alert.tag = eUnlockNextLevelID;
    [alert show];
}

-(void)showGameOverAlert:(NSDictionary*)data
{
    [[SoundManager sharedManager] playSound:@"wrong" looping:NO];
    NSString *msg = [data objectForKey:@"msg"];
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main_iPad" bundle:nil];
    KKCustomAlertViewController *alertview = [storyBoard instantiateViewControllerWithIdentifier:@"KKCustomAlertViewController"];
    alertview.view.tag = 1;
    alertview.canDismissOnButtonPress = NO;
    
    BOOL isNextLevelUnlocked = [self isNextLevelUnlocked];
    if(!isNextLevelUnlocked){
        [alertview addButtonWithTitle:NSLocalizedString(@"MAIN_MENU", nil)];
        [alertview showAlertWithTitle:NSLocalizedString(@"GAME_OVER", nil)
                              message:msg
                          buttonTitle:NSLocalizedString(@"UNLOCK_NEXT_LEVEL", nil)
                         inController:self
                           completion:^(NSInteger index) {
                               if(index == 0){
                                   [self showUnlockAlert];
                               }
                               else if(index == 1){
                                   [alertview removeController:^(NSInteger index) {
                                       //Main Menu
                                       _isGameFinished = NO;
                                       [self moveToLevelSelectScene];
                                   }];
                               }
                               else if(index == 2){
                                   [self replayLevel];
                               }
                           }];
    }
    else{
        [alertview showAlertWithTitle:NSLocalizedString(@"GAME_OVER", nil)
                              message:msg
                          buttonTitle:NSLocalizedString(@"MAIN_MENU", nil)
                         inController:self
                           completion:^(NSInteger index) {
                               if(index == 0){
                                   [alertview removeController:^(NSInteger index) {
                                       //Main Menu
                                       _isGameFinished = NO;
                                       [self moveToLevelSelectScene];
                                   }];
                               }
                           }];
    }

}

#pragma mark - social integration

-(void)facebookShare
{
    SLComposeViewController *fbController=[SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
    
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
    {
        SLComposeViewControllerCompletionHandler __block completionHandler=^(SLComposeViewControllerResult result){
            
            [fbController dismissViewControllerAnimated:YES completion:nil];
            
            switch(result){
                case SLComposeViewControllerResultCancelled:
                default:
                {
                    [Flurry logEvent:@"facebook-cancelled"];
                    [self moveToLevelSelectScene];
                }
                    break;
                case SLComposeViewControllerResultDone:
                {
                    [Flurry logEvent:@"facebook-posted"];
                    [self moveToLevelSelectScene];
                }
                    break;
            }};
        
        NSString *mode = @"Easy";
        switch (self.currentStage) {
            case 2:
                mode = @"Timed";
                break;
            case 3:
                mode = @"Hard";
                break;
            default:
                break;
        }
        NSString *msg = [NSString stringWithFormat:NSLocalizedString(@"FB_SHARE_MSG", nil),self.levelModel.name,mode];
        //[fbController addImage:[UIImage imageNamed:@"share_icon.png"]];
        [fbController setInitialText:msg];
        [fbController addURL:[NSURL URLWithString:APP_URL]];
        [fbController setCompletionHandler:completionHandler];
        [self presentViewController:fbController animated:YES completion:nil];
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"FB_NOT_CONFIGURED_TITLE", nil)
                                                        message:NSLocalizedString(@"FB_NOT_CONFIGURED_MSG", nil)
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
        [alert show];
    }
    
}

-(void)twitterShare
{
    SLComposeViewController *shareController=[SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
    
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewControllerCompletionHandler __block completionHandler=^(SLComposeViewControllerResult result){
            
            [shareController dismissViewControllerAnimated:YES completion:nil];
            
            switch(result){
                case SLComposeViewControllerResultCancelled:
                default:
                {
                    [Flurry logEvent:@"Twitter-cancelled"];
                    [self moveToLevelSelectScene];
                    
                }
                    break;
                case SLComposeViewControllerResultDone:
                {
                    [Flurry logEvent:@"Twitter-posted"];
                    [self moveToLevelSelectScene];
                }
                    break;
            }};
        
        NSString *mode = @"Easy";
        switch (self.currentStage) {
            case 2:
                mode = @"Timed";
                break;
            case 3:
                mode = @"Hard";
                break;
            default:
                break;
        }
        NSString *msg = [NSString stringWithFormat:NSLocalizedString(@"TWITTER_SHARE_MSG", nil),self.levelModel.name,mode];
        //[shareController addImage:[UIImage imageNamed:@"share_icon.png"]];
        [shareController setInitialText:msg];
        [shareController addURL:[NSURL URLWithString:APP_URL]];
        [shareController setCompletionHandler:completionHandler];
        [self presentViewController:shareController animated:YES completion:nil];
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"TWITTER_NOT_CONFIGURED_TITLE", nil)
                                                        message:NSLocalizedString(@"TWITTER_NOT_CONFIGURED_MSG", nil)
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

-(void)showGameWonAlert:(BOOL)canShowMagicStickMsg
{
    [[SoundManager sharedManager] playSound:@"won" looping:NO];

    NSString *btnTitle = NSLocalizedString(@"PLAY_NEXT_LEVEL", nil);
    NSString *magicStick = @"";
    if(self.levelModel.noOfStars == 3 && canShowMagicStickMsg){
        magicStick = NSLocalizedString(@"WON_MAGIC_STICK", nil);
    }

    NSString *msg = [NSString stringWithFormat:NSLocalizedString(@"CONGRATS_LEVEL_COMPLETION", nil),self.levelModel.noOfStars,magicStick] ;
    if(self.currentLevel >= [[KKGameConfigManager sharedManager] totalNumberOfLevelsInStage:self.currentStage]-1){
        msg = [NSString stringWithFormat:NSLocalizedString(@"CONGRATS_STAGE_COMPLETION", nil),self.levelModel.noOfStars,magicStick];
        btnTitle = NSLocalizedString(@"PLAY_NEXT_STAGE", nil);
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"GAME_WON", nil)
                                                    message:msg
                                                   delegate:self
                                          cancelButtonTitle:btnTitle
                                          otherButtonTitles:nil];
    alert.tag = eGameWonAlertID;
    [alert addButtonWithTitle:NSLocalizedString(@"FACEBOOK_SHARE", nil)];
    [alert addButtonWithTitle:NSLocalizedString(@"TWEET", nil)];
    [alert show];
}

-(void)playSound:(NSString*)soundFile
{
    [[SoundManager sharedManager] playSound:soundFile looping:NO];
}

-(void)saveGame
{
    [self saveLevelData];
}

-(void)validateGamePlay:(completionBlk)block
{
    if([self isGameOver] && !_isGameFinished)
    {
        NSDictionary *data = @{@"msg":NSLocalizedString(@"GAME_OVER_MSG", nil)};

        BOOL canShowGameOverAlert = NO;
        if (self.gameMode == eTimerMode) {
            if(self.levelModel.duration <= 0){
                data = @{@"msg":NSLocalizedString(@"GAME_OVER_MSG_TIME", nil)};
                canShowGameOverAlert = YES;
            }
        }

        self.noOfLifesRemaining--;
        self.levelModel.life = self.noOfLifesRemaining;
        [[KKGameStateManager sharedManager] setRemainingLife:self.noOfLifesRemaining];
        [[SoundManager sharedManager] playSound:@"wrong" looping:NO];
        [self updateUI];
        
        if(self.noOfLifesRemaining <= 0){
            canShowGameOverAlert = YES;
        }
        
        if(canShowGameOverAlert){
            [self postFlurry:@"LOST"];
            [self stopTimer];
            self.currentElement = nil;
            _isGameFinished = YES;
            NSInteger stars = self.levelModel.noOfStars;
            [self restartGame];
            self.levelModel.noOfStars = stars;
            [self saveGame];
            [self performSelector:@selector(showGameOverAlert:) withObject:data afterDelay:0.5];
        }
        block(YES);
    }
    else if([self isGameWon])
    {
        NSInteger starWon = [self getStarWon];
        NSInteger stars = [self updateStars];
        [self unlockNextLevel];
        //Add level save related data after unlockNextLevel
        self.levelModel.noOfStars = stars;
        [self saveGame];
        [self stopTimer];
        
        BOOL showMagicStickMsg = NO;
        if(starWon == 3){
            showMagicStickMsg = YES;
        }
        [self showGameWonAlert:showMagicStickMsg];
        
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        [dictionary setObject:[NSString stringWithFormat:@"%ld(l)_%ld(s)[%ld(star)]",(long)self.currentLevel,(long)self.currentStage,(long)stars] forKey:@"level"];
        [Flurry logEvent:@"stars" withParameters:dictionary];
        
        [self postFlurry:@"WON"];
        
        block(YES);
    }
    else if(_currentElement != nil)
    {
        [self playSound:self.levelModel.soundfile];
#ifndef DEVELOPMENT_MODE
        [self.deletedElements addObject:_currentElement];
        [self showElementDissapearAnimation:block];
        
        if(self.isMagicStickMode){
            self.magicStickCounter--;
            if(self.magicStickCounter == 0){
                self.isMagicStickMode = FALSE;
                self.magicStickCounter = 0;
            }
            [self updateMagicStic];
        }
#endif
    }
}

-(void)updatePoints:(NSInteger)oldStar andNewStar:(NSInteger)newStar
{
    NSInteger points = 0;
    if(oldStar == -1)
        oldStar = 0;
        
    points = (newStar-oldStar)*10;
    if(points > 0){
        [self updatePointsEarned:points];
    }
}

-(NSInteger)getStarWon
{
    NSInteger newStar = 1;
    NSInteger life = [[KKGameConfigManager sharedManager] noOfLifesInLevel:self.currentLevel stage:self.currentStage];
    CGFloat lifePercentage = ((self.levelModel.life)/(CGFloat)life)*100;
    
    if(self.gameMode == eTimerMode){
        CGFloat duration = [[KKGameConfigManager sharedManager] durationForLevel:self.currentLevel stage:self.currentStage];
        CGFloat timeRemainingPercentage = ((self.levelModel.duration)/(CGFloat)duration)*100;

        if((timeRemainingPercentage >= 25 && lifePercentage >= 66) || (lifePercentage == 100) || (timeRemainingPercentage >=50 )){
            newStar = 3;
           }
        else if((timeRemainingPercentage >= 25 && timeRemainingPercentage <= 50) || (timeRemainingPercentage <= 25 && lifePercentage >= 66)){
            newStar = 2;
        }
        else{
            newStar = 1;
        }
    }
    else{
        if(lifePercentage >= 100)
            newStar = 3;
        else if(lifePercentage >= 50)
            newStar = 2;
        else
            newStar = 1;
    }
    
    return newStar;
}

-(NSInteger)updateStars
{
    NSInteger oldStar = self.levelModel.noOfStars;
    NSInteger newStar = [self getStarWon];
    [self updatePoints:oldStar andNewStar:newStar];
    
    if(newStar == 3){
        //get a magic stic
        NSInteger count = [[KKGameStateManager sharedManager] getmagicStickUsageCount];
        count = count+1;
        if(count > kMaxMagicStick)
            count = kMaxMagicStick;
        [[KKGameStateManager sharedManager] setMagicStickUsageCount:count];
    }

    if (newStar > oldStar) {
        oldStar = newStar;
    }
    return oldStar;
}

-(void)restartGame
{
    [self.elements removeAllObjects];
    KKGameConfigManager *config = [KKGameConfigManager sharedManager];
    NSDictionary *level = [config levelWithID:self.currentLevel andStage:self.currentStage];
    BOOL isLevelCompleted = self.levelModel.isLevelCompleted;
    self.levelModel = [[KKLevelModal alloc] initWithDictionary:level];
    self.levelModel.levelID = self.currentLevel;
    self.levelModel.stageID =  self.currentStage;
    self.levelModel.isLevelUnlocked = YES;
    self.levelModel.isLevelCompleted = isLevelCompleted;
}

-(BOOL)isNextLevelUnlocked
{
    BOOL isUnlocked = NO;
    NSInteger nextlevel = self.currentLevel+1;
    NSInteger noOfLevels = [[KKGameConfigManager sharedManager] totalNumberOfLevelsInStage:self.currentStage];
    if(nextlevel <= noOfLevels){
        isUnlocked = [[KKGameStateManager sharedManager] isLevelUnlocked:self.currentLevel+1 stage:self.currentStage];
    }
    else{
        isUnlocked = ![[KKGameStateManager sharedManager] isStageLocked:self.currentStage+1];
    }
    return isUnlocked;
}

-(void)unlockNextLevel
{
    //Dont reset the entire thing... just reset items
    [self.elements removeAllObjects];
    KKGameConfigManager *config = [KKGameConfigManager sharedManager];
    NSDictionary *level = [config levelWithID:self.currentLevel andStage:self.currentStage];
    self.levelModel = [[KKLevelModal alloc] initWithDictionary:level];
    self.levelModel.isLevelUnlocked = YES;
    self.levelModel.isLevelCompleted = YES;
    
    self.levelModel.duration = [[KKGameConfigManager sharedManager] durationForLevel:self.currentLevel stage:self.currentStage];
    NSInteger nextlevel = self.currentLevel+1;
    NSInteger noOfLevels = [[KKGameConfigManager sharedManager] totalNumberOfLevelsInStage:self.currentStage];
    if(nextlevel <= noOfLevels){
        [[KKGameStateManager sharedManager] markUnlocked:self.currentLevel stage:self.currentStage];
        [[KKGameStateManager sharedManager] markUnlocked:self.currentLevel+1 stage:self.currentStage];
    }
    else{
        [[KKGameStateManager sharedManager] unlockStage:self.currentStage+1];
    }
}

-(NSMutableArray*)intersectedElements:(TTBase*)currentElement
{
    NSMutableArray *intersectedElements = [NSMutableArray array];
    
    NSMutableArray *polygonB = [NSMutableArray array];
    for(NSString *point in currentElement.touchPoints){
        CGPoint cPoint = CGPointFromString(point);
        cPoint.x = cPoint.x+currentElement.frame.origin.x;
        cPoint.y = cPoint.y+currentElement.frame.origin.y;
        // CGPoint rotatedPoint = [self rotatePoint:cPoint andAngle:self.angle];
        [polygonB addObject:NSStringFromCGPoint(cPoint)];
    }
    
    for (TTBase *element in _elements) {
        if(![element isEqual:currentElement] && !element.isPicked){
            
            NSMutableArray *polygonA = [NSMutableArray array];
            for(NSString *point in element.touchPoints){
                CGPoint cPoint = CGPointFromString(point);
                cPoint.x = cPoint.x+element.frame.origin.x;
                cPoint.y = cPoint.y+element.frame.origin.y;
                // CGPoint rotatedPoint = [self rotatePoint:cPoint andAngle:self.angle];
                [polygonA addObject:NSStringFromCGPoint(cPoint)];
            }
            
            BOOL isIntersected = [Utility isPolygonIntersected:polygonA andPolygon:polygonB];
            if(isIntersected)
                [intersectedElements addObject:element];
        }
    }
    
    return intersectedElements;
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(self.isGameFinished)
        return;
    
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchLocation = [touch locationInView:self.view];
    
    for (int i = (int)[_elements count]-1; i >= 0; i--) {
        TTBase *element = (TTBase*)[_elements objectAtIndex:i];
        if([element canHandleTouch:touchLocation]){
            _currentElement = element;
            [_currentElement handleTouchesBegan:touches withEvent:event];
            break;
        }
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(_currentElement.userInteractionEnabled){
        if([self.switchBtn isOn])
            _currentElement.canSaveTouchPoints = YES;
        else
            _currentElement.canSaveTouchPoints = NO;
        
        if(_currentElement)
            [_currentElement handleTouchesEnded:touches withEvent:event];
        
        [self validateGamePlay:^(BOOL finished) {
            _currentElement = nil;
        }];
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(_currentElement)
        [_currentElement handleTouchesMoved:touches withEvent:event];
}

-(void)moveToLevelSelectScene
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)purchase:(PURCHASEPOINTS_ID)inID
{
    NSString *featureID = nil;
    if(inID == ePurchasePoints100ID)
        featureID = kBuy100Points;
    else if(inID == ePurchasePoints200ID)
        featureID = kBuy200Points;
    else
        featureID = kBuy400Points;

    [[MKStoreManager sharedManager] buyFeature:featureID
                                    onComplete:^(NSString* purchasedFeature,
                                                 NSData* purchasedReceipt,
                                                 NSArray* availableDownloads)
     {
         [[KKGameStateManager sharedManager] setCanRemoveAds:YES];
         [Flurry logEvent:[NSString stringWithFormat:@"Bought %@",featureID]];
         [self provideContent:inID];
     }
                                   onCancelled:^
     {
         [Flurry logEvent:[NSString stringWithFormat:@"Cancelled Buying %@",featureID]];
     }];
}

-(void)provideContent:(PURCHASEPOINTS_ID)inID
{
    NSInteger points = 100;
    if(inID == ePurchasePoints100ID){
        points = 100;
    }
    else if(inID == ePurchasePoints200ID){
        points = 200;
    }
    else if(inID == ePurchasePoints400ID){
        points = 400;
    }
    [self updatePointsEarned:points];
    
    NSString *msg = [NSString stringWithFormat:NSLocalizedString(@"POINTS_SUCCESS_MSG", nil),points,[[KKGameStateManager sharedManager] gamePoints]];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"POINTS_SUCCESS", nil)
                                                    message:msg
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                          otherButtonTitles:nil];
    [alert show];
}

-(void)unlockNextLevelThroughPoints
{
    if(self.points >= kPointsToUnlockLevel){
        
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        [dictionary setObject:[NSString stringWithFormat:@"%ld:%ld",(long)self.currentLevel,(long)self.currentStage] forKey:@"level"];
        [Flurry logEvent:@"unlocklevel_byPoints" withParameters:dictionary];

        [self updatePointsEarned:-kPointsToUnlockLevel];
        [self unlockNextLevel];
        [self saveGame];
        [self stopTimer];
        _isGameFinished = NO;
        [self moveToLevelSelectScene];
    }
    else{
        NSString *money1 = @"0.99$";
        NSString *money2 = @"1.99$";
        NSString *money3 = @"2.99$";

        SKProduct *product = nil;
        product = [[Utility sharedManager] productWithID:kBuy100Points];
        if(product){
            NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
            [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
            [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
            [numberFormatter setLocale:product.priceLocale];
            money1 = [numberFormatter stringFromNumber:product.price];
        }
        
        product = [[Utility sharedManager] productWithID:kBuy200Points];
        if(product){
            NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
            [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
            [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
            [numberFormatter setLocale:product.priceLocale];
            money2 = [numberFormatter stringFromNumber:product.price];
        }
        
        product = [[Utility sharedManager] productWithID:kBuy400Points];
        if(product){
            NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
            [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
            [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
            [numberFormatter setLocale:product.priceLocale];
            money3 = [numberFormatter stringFromNumber:product.price];
        }
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"NO_POINTS_TITLE", nil)
                                                        message:NSLocalizedString(@"NO_POINTS", nil)
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:nil];
        [alert addButtonWithTitle:[NSString stringWithFormat:NSLocalizedString(@"BUY_POINTS", "Buy %d Points for %@"),100,money1]];
        [alert addButtonWithTitle:[NSString stringWithFormat:NSLocalizedString(@"BUY_POINTS", "Buy %d Points for %@"),200,money2]];
        [alert addButtonWithTitle:[NSString stringWithFormat:NSLocalizedString(@"BUY_POINTS", "Buy %d Points for %@"),400,money3]];
        [alert addButtonWithTitle:NSLocalizedString(@"CANCEL", nil)];
        alert.tag = ePurchasePointsID;
        [alert show];
    }
}

-(void)replayLevel
{
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [[SoundManager sharedManager] playSound:@"tap" looping:NO];

    switch (alertView.tag) {
        case eGameWonAlertID:
        {
            switch (buttonIndex) {
                case 0:
                {
                    _isGameFinished = NO;
                    [self moveToLevelSelectScene];
                }
                    break;
                case 1:
                    [self facebookShare];
                    break;
                case 2:
                    [self twitterShare];
                    break;
                    
                default:
                    break;
            }
        }
            break;

        case eUnlockNextLevelID:{
            switch (buttonIndex) {
                case 0:{
                    //Cancel
                }
                    break;
                case 1:{
                    [self unlockNextLevelThroughPoints];
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
            
        case eTutorialAlertID:
        {
            [self startTimer];
        }
            break;
            
        case ePurchasePointsID:{
            switch (buttonIndex) {
                case 0:{
                    [self purchase:ePurchasePoints100ID];
                }
                    break;
                case 1:{
                    [self purchase:ePurchasePoints200ID];
                }
                    break;
                case 2:{
                    [self purchase:ePurchasePoints400ID];
                }
                    break;
                case 3:{

                }
                    break;
                    
                default:
                    break;
            }

        }
            
        default:
            break;
    }
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(_currentElement)
        [_currentElement touchesCancelled:touches withEvent:event];
    _currentElement = nil;
}

- (IBAction)backButtonAction:(id)sender
{
    [[SoundManager sharedManager] playSound:@"tap" looping:NO];

    [self postFlurry:@"LEFT"];
    [self saveGame];
    AppDelegate *appdelegate = APP_DELEGATE;
    [appdelegate.navigationController popViewControllerAnimated:YES];
}

- (IBAction)restartButtonAction:(id)sender
{
    
}

- (void)dealloc
{
    self.currentElement = nil;
    [_deletedElements removeAllObjects];
    [_elements enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj removeFromSuperview];
        [_elements removeObject:obj];;
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)handleSwitchBtn:(id)sender
{
    
}

- (IBAction)handleAddBtn:(id)sender
{
    RANDOM_SEED();
    int r = abs(arc4random() % [_elements count]-1);
    
    TTBase *tObject = [_elements objectAtIndex:r];
    KKItemModal *itemModel = tObject.itemModal;
    
    CGRect frame = itemModel.frame;
    frame.origin = CGPointMake(100, 100);
    itemModel.frame = frame;
    
    TTBase *newObject = [[NSClassFromString(itemModel.className) alloc] init];
    [newObject initWithModal:itemModel];
    if(newObject.image){
        [self.view addSubview:newObject];
        [_elements addObject:newObject];
    }
}

- (IBAction)handleSaveBtn:(id)sender
{    
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    NSMutableArray *tElements = [NSMutableArray array];
    for (TTBase *element in _elements) {
        [tElements addObject:[element saveDictionary]];
    }
    
    [data setObject:tElements forKey:@"elements"];
    [data writeToFile:@"/Users/chandanshettysp/Desktop/savedData.plist" atomically:YES];
}

-(void)pauseGame
{
    [self stopTimer];
}

-(void)resumeGame
{
    [self startTimer];
}

- (IBAction)handleMailBtn:(id)sender
{
    NSString* plistPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"savedData.plist"];
    
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    NSMutableArray *tElements = [NSMutableArray array];
    for (TTBase *element in _elements) {
        [tElements addObject:[element saveDictionary]];
    }
    [data setObject:tElements forKey:@"data"];
    [data writeToFile:plistPath atomically:YES];
    
    // Attach an image to the email
    NSData *myData = [NSData dataWithContentsOfFile:plistPath];
    NSString *attachmentMime = @"text/xml";
    NSString *attachmentName = @"savedData.plist";
    
    // Fill out the email body text
    NSString *emailBody = @"Hi, \n\n Check out new level data! \n\n\nRegards, \nKachi-Kachi";
    NSString *emailSub = [NSString stringWithFormat:@"KACHI KACHI: Level %ld Stage %ld",(long)self.currentLevel,(long)self.currentStage];
    
    NSArray *toRecipients = [NSArray arrayWithObject:@"chandanshetty01@gmail.com"];
    NSArray *ccRecipients = [NSArray arrayWithObjects:@"26anil.kushwaha@gmail.com", @"ashishpra.pra@gmail.com", nil];
    [[KKMailComposerManager sharedManager] displayMailComposerSheet:self
                                                       toRecipients:toRecipients
                                                       ccRecipients:ccRecipients
                                                     attachmentData:myData
                                                 attachmentMimeType:attachmentMime
                                                 attachmentFileName:attachmentName
                                                          emailBody:emailBody
                                                       emailSubject:emailSub
                                                         completion:nil];
}

#pragma - mark iAd delegates -

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
    [self pauseGame];
    return YES;
}

- (void)bannerViewActionDidFinish:(ADBannerView *)banner
{
    [self resumeGame];
}


@end

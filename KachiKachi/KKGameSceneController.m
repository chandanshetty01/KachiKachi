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
#import "InstantMessageManager.h"
#import "GeneralSettings.h"
#import "KKGameOverViewController.h"

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
    ePurchasePointsID
}ALERT_ID;

typedef enum {
    ePurchasePoints100ID,
    ePurchasePoints200ID,
    ePurchasePoints400ID
}PURCHASEPOINTS_ID;

static int testCounter = 0;

@interface KKGameSceneController ()

@property(nonatomic,strong) NSMutableArray *deletedElements;
@property(nonatomic,strong) NSMutableArray *tempElements;
@property(nonatomic,strong) NSMutableArray *basketElements;
@property(nonatomic,assign) BOOL isGameFinished;
@property(weak, nonatomic) IBOutlet UILabel *timerLabel;
@property(weak, nonatomic) IBOutlet UIButton *magicStick;
@property(assign, nonatomic) BOOL isMagicStickMode;
@property(weak, nonatomic) IBOutlet UIButton *magicStickBtn;
@property(strong, nonatomic)  TTMagicStick *magicStickAnimation;
@property(nonatomic,assign)NSInteger magicStickCounter;
@property(weak, nonatomic) IBOutlet UIView *magicStickHolder;
@property(weak, nonatomic) IBOutlet UILabel *magicStickLabel;
@property(nonatomic,assign) NSInteger wrongPickCount;
@property(nonatomic,assign)NSTimeInterval oldTimeInterval;
@property(nonatomic,assign)NSInteger winningStreak;
@property(nonatomic,assign)BOOL topObjectSelected;
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

-(void)loadLevel
{
    [[KKGameStateManager sharedManager] loadLevelData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self loadLevel];
    [self loadlevelData];
    
    [self.homeButton setTitle:NSLocalizedString(@"BACK", "back") forState:UIControlStateNormal];
    
#ifndef DEVELOPMENT_MODE
    BOOL canRemoveAds = [[GeneralSettings sharedManager] getCanRemoveAds];
    if([MKStoreManager isFeaturePurchased:kTimedMode] || [MKStoreManager isFeaturePurchased:kAdvancedMode] || canRemoveAds){
        //If purchased do not show any Ads
    }
    else{
        //show Ads
        NSString *name = @"Main_iPad";
        if(!IS_IPAD){
            name = @"Main_iPhone";
        }
        self.adViewController = [[UIStoryboard storyboardWithName:name bundle:nil] instantiateViewControllerWithIdentifier:@"adViewController"];

        [self.view addSubview:self.adViewController.view];
        self.adViewController.delegate = self;
        CGRect frame = self.adViewController.view.frame;
        frame.origin = CGPointZero;
        self.adViewController.view.frame = frame;
    }
#endif

    [self showTutorial:1];
    
#ifdef DEVELOPMENT_MODE
    _switchBtn.hidden = NO;
    _saveBtn.hidden = NO;
    _mailButton.hidden = NO;
    _addButton.hidden = NO;
    [_switchBtn setOn:NO];
#else
    _switchBtn.hidden = YES;
    _saveBtn.hidden = YES;
    _mailButton.hidden = YES;
    _addButton.hidden = YES;
#endif
    
    [[SoundManager sharedManager] playMusic:@"lovesong"];
}

-(void)loadlevelData
{
    [self removeAllElements];
    
    self.wrongPickCount = 0;
    self.currentLevel = [KKGameStateManager sharedManager].currentLevel;
    self.currentStage = [KKGameStateManager sharedManager].currentStage;
    [self updatePointsEarned:0];
    
    _elements = [[NSMutableArray alloc] init];
    self.basketElements = [[NSMutableArray alloc] init];
    self.deletedElements = [[NSMutableArray alloc] init];
    
    _isGameFinished = FALSE;
    self.duration = self.levelModel.duration;
    
    [self updateUI];
    [self addElements];

    self.magicStickCounter = 0;
    self.isMagicStickMode = NO;
    self.winningStreak = 0;
    self.wrongPickCount = 0;
    self.topObjectSelected = 0;
    self.oldTimeInterval = 0;
    testCounter = 0;
    
    [self updateMagicStic];
    [self updateMagicStickBtnPosition];
}

-(NSTimeInterval)timeTakenInSeconds
{
    NSTimeInterval diff = [[NSDate date] timeIntervalSince1970]-self.oldTimeInterval;
    return diff;
}

-(void)updateScore
{
    const NSInteger kBaseScore = 5;
    const NSInteger kMinDuration = 1.5;
    
    NSInteger tScore = kBaseScore;
    CGFloat timeTaken = [self timeTakenInSeconds];
    
    if(self.topObjectSelected){
        if(timeTaken <= kMinDuration && timeTaken > 0){
            self.winningStreak += 1;
            self.winningStreak = MIN(self.winningStreak, 7);
        }
        tScore += self.winningStreak;
    }
    else{
        tScore = -2;
        self.winningStreak = 0;
    }
    
    self.levelModel.score = self.levelModel.score + tScore;
    
    if(_currentElement){
        [self showScore:tScore];
    }
    [self updateUI];
}

-(void)showScore:(NSInteger)score
{
    if(_currentElement){
        NSString *msg =[NSString stringWithFormat:@"+%ld",score];
        if(score< 0){
            msg =[NSString stringWithFormat:@"%ld",score];
        }
        [[InstantMessageManager sharedManager] showMessage:msg
                                                    inView:self.view
                                                  duration:2
                                                      rect:CGRectMake(_currentElement.center.x, _currentElement.center.y, 40, 40)
                                                     color:(score>0)?[UIColor blueColor]:[UIColor redColor]
                                                      font:[UIFont boldSystemFontOfSize:14]];
    }
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
    if(IS_IPAD){
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
    NSInteger usageCount = [[GeneralSettings sharedManager] getmagicStickUsageCount];
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
    
    NSInteger usageCount = [[GeneralSettings sharedManager] getmagicStickUsageCount];
    NSString *name = @"Main_iPad";
    if(!IS_IPAD){
        name = @"Main_iPhone";
    }
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:name bundle:nil];
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
                                   [[GeneralSettings sharedManager] setMagicStickUsageCount:usageCount-1];
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

-(void)showTutorial : (NSInteger)tutorialID
{
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

-(void)updatePointsEarned:(NSInteger)inPoints
{

}

-(void)updateUI
{
    self.timerLabel.text = [NSString stringWithFormat:NSLocalizedString(@"SCORE","score"),self.levelModel.score];
}

-(void)addElements
{
    [self.levelModel.items enumerateObjectsUsingBlock:^(KKItemModal *obj, NSUInteger idx, BOOL *stop) {
        [self generateElement:obj];
    }];
    
    UIImage *image = [UIImage imageNamed:self.levelModel.backgroundImage];
    self.background.image = image;
    
    [self.levelModel.baskets enumerateObjectsUsingBlock:^(NSDictionary *basket, NSUInteger idx, BOOL *stop) {
        UIImage *image = [UIImage imageNamed:[basket objectForKey:@"basket"]];
        CGRect frame = CGRectZero;
        frame.origin =CGPointFromString([basket objectForKey:@"basket_frame"]);
        frame.size = image.size;
        
        UIImageView *basketView = [[UIImageView alloc] initWithFrame:frame];
        basketView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
        basketView.image = image;
        [self.basketElements addObject:basketView];
        
        if(IS_IPAD){
            //for iPad
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
        }
        else{
            //iPhone related changes
            KKItemModal *item = [self.levelModel.items objectAtIndex:0];
            if(([item.className isEqualToString:@"TTFish"] && !(([[basket objectForKey:@"basket"] isEqualToString:@"iPh_bucket_front_part.png"]) || ([[basket objectForKey:@"basket"] isEqualToString:@"iPh_handel.png"]))) || ([item.className isEqualToString:@"TTChoc"] && [[basket objectForKey:@"basket"] isEqualToString:@"iPh_candy_back_part.png"]) || [item.className isEqualToString:@"TTBird"] || ([item.className isEqualToString:@"TTCandle"] && [[basket objectForKey:@"basket"] isEqualToString:@"iph_candle_stand1.png"]) || ([item.className isEqualToString:@"TTDvd"] && ![[basket objectForKey:@"basket"] isEqualToString:@"iph_cd_holder2.png"]) || ([item.className isEqualToString:@"TTUmbrella"]) || ([item.className isEqualToString:@"TTBrush"] && ([[basket objectForKey:@"basket"] isEqualToString:@"iPh_brush1_cup1.png"] || [[basket objectForKey:@"basket"] isEqualToString:@"iPh_brush1_cup2.png"])) || [item.className isEqualToString:@"TTKey"])
            {
                [self.view insertSubview:basketView aboveSubview:self.background];
            }
            else
            {
                [self.view addSubview:basketView];
                [self.view bringSubviewToFront:self.bottomStrip];
            }
        }
    }];
}

-(void)generateElement:(KKItemModal*)itemModel
{
    TTBase *object = [[NSClassFromString(itemModel.className) alloc] init];
    [object initWithModal:itemModel];
    if(object.image){
        [self.view addSubview:object];
        if(itemModel.isPicked){
            [object setPickedObjectPosition];
        }
        [_elements addObject:object];
    }
}

-(void)showMessage:(TTBase*)object
{
    static int i = 0;
    if(i == 0){
        /*
        [[InstantMessageManager sharedManager] showMessage:@"SELECT TOP OBJECT"
                                                    inView:self.view
                                                  duration:3
                                                      rect:CGRectMake(object.center.x, object.center.y, 120, 20)
                                                     color:[UIColor blueColor]];
         */
        
        //i++;
    }
}

-(void)showGameCompletionScreen
{
    NSString *name = @"Main_iPad";
    if(!IS_IPAD){
        name = @"Main_iPhone";
    }
    self.gameOverController = [[UIStoryboard storyboardWithName:name bundle:nil] instantiateViewControllerWithIdentifier:@"KKGameOverViewController"];
    [self.view addSubview:self.gameOverController.view];
    self.gameOverController.delegate = self;
    self.gameOverController.view.alpha = 0;
    [UIView animateWithDuration:0.2f
                     animations:^{
                         self.gameOverController.view.alpha = 1;
                     }
                     completion:^(BOOL finished) {
                     }];
}

-(void)removeGameOverScreen
{
    self.gameOverController.view.alpha = 1;
    [UIView animateWithDuration:0.2f
                     animations:^{
                         self.gameOverController.view.alpha = 0;
                     }
                     completion:^(BOOL finished) {
                         [self.gameOverController.view removeFromSuperview];
                         self.gameOverController = nil;
                     }];
}

#pragma mark - Game over screen delegates - 

- (void)facebookAction
{
    
}

- (void)twitterAction
{
    
}

- (void)gameCenterAction
{
    
}

- (void)nextLevelAction
{
    [[KKGameStateManager sharedManager] completeLevel];
    [self saveGame];
    [self removeGameOverScreen];
    [self continuePlaying:NO];
}

- (void)replayAction
{
    [self removeGameOverScreen];
    [self continuePlaying:YES];
}

- (void)mainMenuAction
{
    [[KKGameStateManager sharedManager] completeLevel];
    [self removeGameOverScreen];
    [self saveGame];
    AppDelegate *appdelegate = APP_DELEGATE;
    [appdelegate.navigationController popViewControllerAnimated:YES];
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
            gameOver = true;
            break;
        }
    }
    
    if(gameOver){
        self.topObjectSelected = NO;
        [_currentElement shakeAnimation];
        [self updateWrongPick];
        [self updateScore];
        self.currentElement = nil;
    }
    else{
        self.topObjectSelected = YES;
        self.wrongPickCount = 0;
        [self updateScore];
    }
    
    if(self.topObjectSelected){
        self.oldTimeInterval = [[NSDate date] timeIntervalSince1970];
    }

    return gameOver;
}

-(NSInteger)noOfObjectsToBePicked
{
    __block int count = 0;
    [self.levelModel.items enumerateObjectsUsingBlock:^(KKItemModal *obj, NSUInteger idx, BOOL *stop) {
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
        if(!obj.itemModal.isPicked){
            obj.itemModal.isPicked = YES;
            self.view.userInteractionEnabled = NO;
            [obj showAnimation:^(BOOL canRemoveObject) {
                [self.deletedElements removeObject:obj];
                self.view.userInteractionEnabled = YES;
                block(YES);
            }];
        }
    }];
}

-(void)saveLevelData
{
    [[KKGameStateManager sharedManager] saveData];
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

-(void)playSound:(NSString*)soundFile
{
    [[SoundManager sharedManager] playSound:soundFile looping:NO];
}

-(void)saveGame
{
    [self saveLevelData];
}

-(void)highlightTopObject
{
    NSEnumerator *enumerator = [_elements reverseObjectEnumerator];
    for (TTBase *obj in enumerator) {
        if(!obj.itemModal.isPicked){
            obj.isHighlighted = YES;
            [self showMessage:obj];
            break;
        }
    }
}

-(void)updateWrongPick
{
    NSInteger wrongObjCount = 3;
    if(self.currentStage == 1){
        if(self.currentLevel == 1){
            wrongObjCount = 1;
        }
        else if(self.currentLevel == 2){
            wrongObjCount = 2;
        }
    }
    
    self.wrongPickCount++;
    if(self.wrongPickCount == wrongObjCount){
        [self highlightTopObject];
        self.wrongPickCount = 0;
    }
}

-(void)validateGamePlay:(completionBlk)block
{
    if([self isGameOver] && !_isGameFinished)
    {
        [[SoundManager sharedManager] playSound:@"wrong" looping:NO];
        [self updateUI];
        block(YES);
    }
    else if([self isGameWon])
    {
        //NSInteger starWon = [self getStarWon];
        NSInteger stars = [self updateStars];
        self.levelModel.noOfStars = stars;
        [self saveGame];
        [[SoundManager sharedManager] playSound:@"won" looping:NO];
        [self showGameCompletionScreen];
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
    return newStar;
}

-(NSInteger)updateStars
{
    NSInteger oldStar = self.levelModel.noOfStars;
    NSInteger newStar = [self getStarWon];
    [self updatePoints:oldStar andNewStar:newStar];
    
    if(newStar == 3){
        //get a magic stic
        NSInteger count = [[GeneralSettings sharedManager] getmagicStickUsageCount];
        count = count+1;
        if(count > kMaxMagicStick)
            count = kMaxMagicStick;
        [[GeneralSettings sharedManager] setMagicStickUsageCount:count];
    }

    if (newStar > oldStar) {
        oldStar = newStar;
    }
    return oldStar;
}

-(void)unlockNextLevel
{
    
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
        if(![element isEqual:currentElement] && !element.itemModal.isPicked){
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

-(TTBase*)getNearestItem:(CGPoint)touchLocation
{
    TTBase *item = nil;
    
    for (int i = (int)[_elements count]-1; i >= 0; i--) {
        TTBase *element = (TTBase*)[_elements objectAtIndex:i];
        if([element canHandleTouch:touchLocation radius:15]){
            item = element;
            break;
        }
    }
    
    return item;
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(self.isGameFinished)
        return;
    
    _currentElement = nil;
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchLocation = [touch locationInView:self.view];
    
//    for (int i = (int)[_elements count]-1; i >= 0; i--) {
//        TTBase *element = (TTBase*)[_elements objectAtIndex:i];
//        if([element canHandleTouch:touchLocation]){
//            _currentElement = element;
//            [_currentElement handleTouchesBegan:touches withEvent:event];
//            break;
//        }
//    }
    
    if(!_currentElement){
        _currentElement = [self getNearestItem:touchLocation];
        [_currentElement handleTouchesBegan:touches withEvent:event];
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(_currentElement.userInteractionEnabled){
        if([self.switchBtn isOn])
            _currentElement.canSaveTouchPoints = YES;
        else
            _currentElement.canSaveTouchPoints = NO;
        
        if(_currentElement){
            [_currentElement handleTouchesEnded:touches withEvent:event];
        }
        
        [self validateGamePlay:^(BOOL finished) {
            _currentElement = nil;
        }];
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(_currentElement){
        [_currentElement handleTouchesMoved:touches withEvent:event];
    }
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(_currentElement){
        [_currentElement handleTouchesCancelled:touches withEvent:event];
    }
    _currentElement = nil;
}

-(void)moveToLevelSelectScene
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(KKLevelModal*)currentLevelData
{
    KKLevelModal *levelModel = nil;
    KKGameConfigManager *config = [KKGameConfigManager sharedManager];
    NSDictionary *tLevel = [config levelWithID:self.currentLevel andStage:self.currentStage];
    levelModel = [[KKLevelModal alloc] initWithDictionary:tLevel];
    levelModel.levelID = self.currentLevel;
    levelModel.stageID =  self.currentStage;
    return levelModel;
}

-(void)removeAllElements
{
    [self.tempElements enumerateObjectsUsingBlock:^(TTBase *obj, NSUInteger idx, BOOL *stop) {
        [obj removeFromSuperview];
    }];
    [self.tempElements removeAllObjects];
    
    [self.elements enumerateObjectsUsingBlock:^(TTBase *obj, NSUInteger idx, BOOL *stop) {
        [obj removeFromSuperview];
    }];
    [self.elements removeAllObjects];
    
    [self.basketElements enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj removeFromSuperview];
    }];
    [self.basketElements removeAllObjects];
    
    [self.deletedElements enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj removeFromSuperview];
    }];
    [self.deletedElements removeAllObjects];
}

-(void)logReplayEvent
{
    NSMutableDictionary *levelInfo = [[NSMutableDictionary alloc] init];
    [levelInfo setObject:[NSString stringWithFormat:@"%@",self.levelModel.name] forKey:[NSString stringWithFormat:@"%ld",(long)self.currentStage]];
    [Flurry logEvent:@"replay" withParameters:levelInfo];
}

-(void)setLevelModel:(KKLevelModal *)levelModel
{
    _levelModel = levelModel;
}

-(void)continuePlaying:(BOOL)isRestart
{
    if(isRestart){
        [[KKGameStateManager sharedManager] resetLevelData];
        [self logReplayEvent];
    }
    else{
        self.levelModel = [[KKGameStateManager sharedManager] loadNextLevel];
    }
    
    self.levelModel.isLevelUnlocked = YES;
    [self loadlevelData];
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
            
        case eTutorialAlertID:
        {
        }
            break;
                        
        default:
            break;
    }
}

- (IBAction)backButtonAction:(id)sender
{
    [[SoundManager sharedManager] playSound:@"tap" looping:NO];
    [self saveGame];
    AppDelegate *appdelegate = APP_DELEGATE;
    [appdelegate.navigationController popViewControllerAnimated:YES];
}

- (void)dealloc
{
    [[InstantMessageManager sharedManager] removeAllMessages];
    self.currentElement = nil;
    [self removeAllElements];
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
    testCounter++;
    if(testCounter >= _elements.count){
        testCounter = 0;
    }
    
    TTBase *tObject = [_elements objectAtIndex:testCounter];
    KKItemModal *itemModel = tObject.itemModal;
    
    CGRect frame = itemModel.frame;
    frame.origin = CGPointMake(10, 10);
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

}

-(void)pauseGame
{
    
}

-(void)resumeGame
{
    
}

- (IBAction)handleMailBtn:(id)sender
{
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

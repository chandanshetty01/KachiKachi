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

#define RANDOM_SEED() srandom(time(NULL))
#define RANDOM_INT(__MIN__, __MAX__) ((__MIN__) + random() % ((__MAX__+1) - (__MIN__)))
#define RADIANS(degrees) ((degrees * M_PI) / 180.0)

#define LEVEL_INFO @"levelInfo"
#define LEVEL_INFO_LIFE @"levelLife"
#define LEVEL_WON @"levelWon"

@interface KKGameSceneController ()

@property(nonatomic,strong) NSMutableArray *deletedElements;
@property(nonatomic,assign) BOOL isGameFinished;
@property(nonatomic,weak) TTBase* topElement;
@property (weak, nonatomic) IBOutlet UILabel *timerLabel;

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
    
    self.adViewController = [[UIStoryboard storyboardWithName:@"Main_iPad" bundle:nil] instantiateViewControllerWithIdentifier:@"adViewController"];
    [self.view addSubview:self.adViewController.view];
    CGRect frame = self.adViewController.view.frame;
    frame.origin = CGPointZero;
    self.adViewController.view.frame = frame;
    
    _elements = [[NSMutableArray alloc] init];
    self.deletedElements = [[NSMutableArray alloc] init];
    
    self.currentLevel = [[KKGameStateManager sharedManager] currentLevelNumber];
    self.currentStage = [[KKGameStateManager sharedManager] currentStageNumber];
    self.gameMode = [[KKGameConfigManager sharedManager] gameModeForLevel:self.currentLevel stage:self.currentStage];
    
    _isGameFinished = FALSE;
    self.noOfLifesRemaining = self.levelModel.life;
    self.duration = self.levelModel.duration;
    
    if(self.gameMode == eTimerMode){
        [self updateTimer:self.levelModel.duration];
    }
    else{
    }
    
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
    
    [[SoundManager sharedManager] playMusic:@"track2" looping:YES];
    [self updateUI];
    
    if(self.gameMode == eTimerMode){
        [self startTimer];
    }
    else{
        self.timerLabel.hidden = YES;
    }
    
    [self levelStartedFlurryLog];
    [self startLifeInfoFlurryEvent];
}

-(void)startTimer
{
    self.timer = [[TimerObject alloc] initWithDuration:self.levelModel.duration fireInterval:1.0f];
    [self.timer startTimer];
    self.timer.delegate = self;
    self.timerLabel.hidden = NO;
}

-(void)stopTimer
{
    if(self.timer){
        [self.timer pauseTimer];
        self.timer = nil;
    }
}

-(void)updateTimer:(NSInteger)remainingTime
{
    NSString *time = [NSString stringWithFormat:@"%d",remainingTime];
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

-(void)levelStartedFlurryLog
{
    NSNumber *level = [NSNumber numberWithInt:self.currentLevel];
    NSNumber *stage = [NSNumber numberWithInt:self.currentStage];
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjects:@[level,stage]
                                                     forKeys:@[@"level", @"stage"]];
    [Flurry logEvent:LEVEL_INFO withParameters:dict timed:YES];
}

-(void)levelEndedFlurryLog:(NSNumber*)status
{
    NSDictionary *dict = nil;
    NSNumber *level = [NSNumber numberWithInt:self.currentLevel];
    NSNumber *stage = [NSNumber numberWithInt:self.currentStage];
    if([status intValue] == 1)
    {
        NSString *wonMsg = [NSString stringWithFormat:@"stage%dLevel%d-LOST",self.currentStage,self.currentLevel];
        [Flurry logEvent:wonMsg];
        dict = [NSDictionary dictionaryWithObjects:@[level,stage,@"LOST"]
                                                         forKeys:@[@"level", @"stage",@"status"]];
    }
    else if([status intValue] == 2)
    {
        NSString *wonMsg = [NSString stringWithFormat:@"stage%dLevel%d-WON",self.currentStage,self.currentLevel];
        [Flurry logEvent:wonMsg];
        dict = [NSDictionary dictionaryWithObjects:@[level,stage,@"WON"]
                                           forKeys:@[@"level", @"stage",@"status"]];
    }
    else
    {
        NSString *wonMsg = [NSString stringWithFormat:@"stage%dLevel%d-LEFT",self.currentStage,self.currentLevel];
        [Flurry logEvent:wonMsg];
        dict = [NSDictionary dictionaryWithObjects:@[level,stage,@"LEFT"]
                                           forKeys:@[@"level", @"stage",@"status"]];
    }

    [Flurry endTimedEvent:LEVEL_INFO withParameters:dict];
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
        if(currentElementIndex < index)
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

-(BOOL)noOfObjectsToBePicked
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
    self.lifeLabel.text = [NSString stringWithFormat:@"LIFE: %d",self.noOfLifesRemaining];
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

-(void)showGameOverAlert:(NSDictionary*)data
{
    [self levelEndedFlurryLog:@1];
    
    NSString *msg = [data objectForKey:@"msg"];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Game Over"
                                                    message:msg
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    
    [alert show];
}

-(void)startLifeInfoFlurryEvent
{
    NSNumber *level = [NSNumber numberWithInt:self.currentLevel];
    NSNumber *stage = [NSNumber numberWithInt:self.currentStage];
    NSNumber *life = [NSNumber numberWithInt:self.noOfLifesRemaining];
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjects:@[level,stage,life]
                                                     forKeys:@[@"level", @"stage",@"life"]];
    [Flurry logEvent:LEVEL_INFO_LIFE withParameters:dict timed:YES];
}

-(void)endLifeInfoFlurryEvent
{
    NSNumber *level = [NSNumber numberWithInt:self.currentLevel];
    NSNumber *stage = [NSNumber numberWithInt:self.currentStage];
    NSNumber *life = [NSNumber numberWithInt:self.noOfLifesRemaining];
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjects:@[level,stage,life]
                                       forKeys:@[@"level", @"stage",@"life"]];
    [Flurry endTimedEvent:LEVEL_INFO_LIFE withParameters:dict];
}


-(void)validateGamePlay:(completionBlk)block
{
    if([self isGameOver] && !_isGameFinished)
    {
        NSDictionary *data = @{@"msg":@"You haven't selected the top item!"};

        BOOL canShowGameOverAlert = NO;
        if (self.gameMode == eTimerMode) {
            if(self.levelModel.duration <= 0){
                data = @{@"msg":@"You ran out of TIME!"};
                canShowGameOverAlert = YES;
            }
        }

        self.noOfLifesRemaining--;
        self.levelModel.life = self.noOfLifesRemaining;
        [[KKGameStateManager sharedManager] setRemainingLife:self.noOfLifesRemaining];
        [[SoundManager sharedManager] playSound:@"sound2" looping:NO];
        [self updateUI];
        
        [self endLifeInfoFlurryEvent];
        [self startLifeInfoFlurryEvent];
        
        if(self.noOfLifesRemaining <= 0){
            canShowGameOverAlert = YES;
        }
        
        if(canShowGameOverAlert){
            
            [self stopTimer];
            self.currentElement = nil;
            _isGameFinished = YES;
            [self restartGame];
            [self saveLevelData];
            [self performSelector:@selector(showGameOverAlert:) withObject:data afterDelay:0.5];
        }
        block(YES);
    }
    else if([self isGameWon])
    {
        [self levelEndedFlurryLog:@2];

        NSNumber *level = [NSNumber numberWithInt:self.currentLevel];
        NSNumber *stage = [NSNumber numberWithInt:self.currentStage];
        NSNumber *life = [NSNumber numberWithInt:self.noOfLifesRemaining];
        NSDictionary *dict = [NSDictionary dictionaryWithObjects:@[level,stage,life]
                                                         forKeys:@[@"level", @"stage",@"life"]];
        [Flurry logEvent:LEVEL_WON withParameters:dict];
        
        [self unlockNextLevel];
        [self saveLevelData];
        [[SoundManager sharedManager] playSound:@"sound2" looping:NO];
        [self stopTimer];

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Game Won"
                                                        message:@"Game completed"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        block(YES);
    }
    else if(_currentElement != nil)
    {
#ifndef DEVELOPMENT_MODE
        [self.deletedElements addObject:_currentElement];
        [[SoundManager sharedManager] playSound:@"sound1" looping:NO];
        [self showElementDissapearAnimation:block];
#endif
    }
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
    
    for (int i = [_elements count]-1; i >= 0; i--) {
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

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    _isGameFinished = NO;
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(_currentElement)
        [_currentElement touchesCancelled:touches withEvent:event];
    _currentElement = nil;
}

- (IBAction)backButtonAction:(id)sender {
    [self levelEndedFlurryLog:@3];
    [self saveLevelData];
    AppDelegate *appdelegate = APP_DELEGATE;
    [appdelegate.navigationController popViewControllerAnimated:YES];
}

- (IBAction)restartButtonAction:(id)sender {
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
    NSString *emailSub = [NSString stringWithFormat:@"KACHI KACHI: Level %d Stage %d",self.currentLevel,self.currentStage];
    
    NSArray *toRecipients = [NSArray arrayWithObject:@"chandanshetty01@gmail.com"];
    NSArray *ccRecipients = [NSArray arrayWithObjects:@"26anil.kushwaha@gmail.com", @"ashishpra.pra@gmail.com", nil];
    [[KKMailComposerManager sharedManager] displayMailComposerSheet:self
                                                       toRecipients:toRecipients
                                                       ccRecipients:ccRecipients
                                                     attachmentData:myData
                                                 attachmentMimeType:attachmentMime
                                                 attachmentFileName:attachmentName
                                                          emailBody:emailBody
                                                       emailSubject:emailSub];
}

@end

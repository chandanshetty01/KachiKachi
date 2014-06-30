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

#define RANDOM_SEED() srandom(time(NULL))
#define RANDOM_INT(__MIN__, __MAX__) ((__MIN__) + random() % ((__MAX__+1) - (__MIN__)))
#define RADIANS(degrees) ((degrees * M_PI) / 180.0)

@interface KKGameSceneController ()

@property(nonatomic,strong) NSMutableArray *deletedElements;
@property(nonatomic,assign) BOOL isGameFinished;
@property(nonatomic,weak) TTBase* topElement;

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
    
    _isGameFinished = FALSE;
    self.noOfLifesRemaining = self.levelModel.life;
    
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
           ([item.className isEqualToString:@"TTUmbrella"]) ||
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

-(void)showGameOverAlert
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Game Over"
                                                    message:@"You haven't selected the top item"
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

-(void)validateGamePlay:(completionBlk)block
{
    if([self isGameOver] && !_isGameFinished)
    {
        self.noOfLifesRemaining--;
        self.levelModel.life = self.noOfLifesRemaining;
        [[KKGameStateManager sharedManager] setRemainingLife:self.noOfLifesRemaining];
        [[SoundManager sharedManager] playSound:@"sound2" looping:NO];
        [self updateUI];
        
        if(self.noOfLifesRemaining <= 0)
        {
            self.currentElement = nil;
            _isGameFinished = YES;
            [self restartGame];
            [self saveLevelData];
            [self performSelector:@selector(showGameOverAlert) withObject:nil afterDelay:0.5];
        }

        block(YES);
    }
    else if([self isGameWon])
    {
        self.levelModel.isLevelCompleted = YES;
        [[KKGameStateManager sharedManager] markUnlocked:self.currentLevel+1 stage:self.currentStage];
        [self saveLevelData];
        [[SoundManager sharedManager] playSound:@"sound2" looping:NO];
        
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
    self.levelModel = [[KKLevelModal alloc] initWithDictionary:level];
    self.levelModel.levelID = self.currentLevel;
    self.levelModel.stageID =  self.currentStage;
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
        if(![element isEqual:currentElement]){
            
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

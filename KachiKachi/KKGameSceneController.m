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

#define RADIANS(degrees) ((degrees * M_PI) / 180.0)

@interface KKGameSceneController ()

@property(nonatomic,strong) NSMutableArray *deletedElements;
@property(nonatomic,strong) NSMutableArray *elements;
@property(nonatomic,assign) TTBase *currentElement;
@property(nonatomic,assign) BOOL isGameFinished;

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
    _deletedElements = [[NSMutableArray alloc] init];
    
    _currentLevel = 1;
    _isGameFinished = FALSE;
    
    [self addElements];
    
#ifdef DEVELOPMENT_MODE
    _switchBtn.hidden = NO;
    _saveBtn.hidden = NO;
    _mailButton.hidden = NO;
#else
    _switchBtn.hidden = YES;
    _saveBtn.hidden = YES;
    _mailButton.hidden = YES;
#endif
    
    [_switchBtn setOn:NO];
    
    [[SoundManager sharedManager] playMusic:@"track2" looping:YES];
}

- (IBAction)handleSwitchBtn:(id)sender
{
    
}

- (IBAction)handleSaveBtn:(id)sender
{
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    NSMutableArray *tElements = [NSMutableArray array];
    for (TTBase *element in _elements) {
        [tElements addObject:[element saveDictionary]];
    }
    [data setObject:tElements forKey:@"data"];
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
    NSString *emailSub = [NSString stringWithFormat:@"KACHI KACHI: Level %d Item %d",self.currentLevel,self.currentItemID];

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

-(void)addElements
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSMutableDictionary *element = [appDelegate.configuration elementForLevel:_currentLevel forItem:_currentItemID];
    NSMutableArray *elements = [element objectForKey:@"elements"];
    [elements enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
        [self generateElement:obj];
    }];
    
    UIImage *image = [UIImage imageNamed:[element objectForKey:@"background"]];
    self.background.image = image;
    
    image = [UIImage imageNamed:[element objectForKey:@"basket"]];
    CGRect frame = CGRectZero;
    frame.origin =CGPointFromString([element objectForKey:@"basket_frame"]);
    frame.size = image.size;
    
    _basketImageView = [[UIImageView alloc] initWithFrame:frame];
    _basketImageView.image = image;
    [self.view addSubview:_basketImageView];
}

-(void)generateElement:(NSDictionary*)data
{
    TTBase *object = [[NSClassFromString([data objectForKey:@"class"]) alloc] init];
    [object setData:data];
    [self.view addSubview:object];
    [_elements addObject:object];
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
            gameOver = true;
            break;
        }
    }
    
    return gameOver;
}

-(BOOL)isGameWon
{
    if([_elements count] == 1)
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
    [_deletedElements enumerateObjectsUsingBlock:^(TTBase *obj, NSUInteger idx, BOOL *stop) {
        self.view.userInteractionEnabled = NO;
        [obj showAnimation:^(BOOL canRemoveObject) {
            if(canRemoveObject){
                [obj removeFromSuperview];
            }
            self.view.userInteractionEnabled = YES;
            [_deletedElements removeObject:obj];
            block(YES);
        }];
    }];
}

-(void)validateGamePlay:(completionBlk)block
{
    if([self isGameOver] && !_isGameFinished){
        
        [[SoundManager sharedManager] playSound:@"sound2" looping:NO];
        
        _isGameFinished = YES;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Game Over"
                                                        message:@"You haven't selected the top item"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        block(YES);
    }
    else if([self isGameWon])
    {
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
        [_deletedElements addObject:_currentElement];
        [_elements removeObject:_currentElement];
        [[SoundManager sharedManager] playSound:@"sound1" looping:NO];
        [self showElementDissapearAnimation:block];
#endif
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
    AppDelegate *appdelegate = APP_DELEGATE;
    [appdelegate.navigationController popViewControllerAnimated:YES];
}

- (void)dealloc
{
    [_deletedElements enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj removeFromSuperview];
        [_deletedElements removeObject:obj];;
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end

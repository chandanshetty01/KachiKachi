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

@interface KKGameSceneController ()


@property(nonatomic,strong) NSMutableArray *elements;
@property(nonatomic,strong) TTBase *currentElement;
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
    _elements = [[NSMutableArray alloc] init];
    _currentLevel = 1;
    _isGameFinished = FALSE;
    
    [self addElements];
    
#ifdef DEVELOPMENT_MODE
    _switchBtn.hidden = NO;
    _saveBtn.hidden = NO;
#else
    _switchBtn.hidden = YES;
    _saveBtn.hidden = YES;
#endif
    
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
}

-(void)generateElement:(NSDictionary*)data
{
    TTBase *base = [[TTBase alloc] initWithData:data];
    [self.view addSubview:base];
    [_elements addObject:base];
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

-(void)validateGamePlay:(completionBlk)block
{
    if([self isGameOver] && !_isGameFinished){
        _isGameFinished = YES;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Game Over"
                                                        message:@"You haven't selected the top pencil"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        block(YES);
    }
    else if([self isGameWon])
    {
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
        [UIView animateWithDuration:.5f animations:^{
            _currentElement.alpha = 0;
        } completion:^(BOOL finished) {
            if(finished){
                [_elements removeObject:_currentElement];
                block(YES);
            }
        }];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end

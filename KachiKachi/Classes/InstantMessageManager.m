//
//  InstantMessageManager.m
//  KachiKachi
//
//  Created by Chandan on 08/08/2013.
//  Copyright (c) 2014 Chanddan. All rights reserved.
//

#import "InstantMessageManager.h"
#import "InstantMessageView.h"

@interface InstantMessageManager ()
@property(nonatomic,strong)NSMutableArray *messageArray;
@end

@implementation InstantMessageManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.messageArray = [NSMutableArray array];
    }
    return self;
}

+ (id) sharedManager
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

-(void)showMessage:(NSString*)message
            inView:(UIView*)view
          duration:(NSInteger)duration
              rect:(CGRect)rect
             color:(UIColor*)color
              font:(UIFont*)font
{
    InstantMessageView *msg = [[InstantMessageView alloc] initWithFrame:rect];
    [view addSubview:msg];
    [self.messageArray addObject:msg];
    [msg showMessage:message
            duration:duration
               color:color
                font:font
          completion:^(BOOL val) {
        [self.messageArray removeObject:msg];
    }];
}

-(void)removeAllMessages
{
    [self.messageArray enumerateObjectsUsingBlock:^(UIView *obj, NSUInteger idx, BOOL *stop) {
        [obj removeFromSuperview];
    }];
    [self.messageArray removeAllObjects];
}

@end

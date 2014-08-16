//
//  KKCustomAlertViewController.h
//  KachiKachi
//
//  Created by Chandan on 08/08/2013.
//  Copyright (c) 2014 Chanddan. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^completionBlkWithInteger)(NSInteger index);

@interface KKCustomAlertViewController : UIViewController
{
    
}
@property(nonatomic,assign)BOOL canDismissOnButtonPress;

-(void)showAlertWithTitle:(NSString*)title
                  message:(NSString*)message
              buttonTitle:(NSString*)btnTitle
             inController:(UIViewController*)controller
               completion:(completionBlkWithInteger)blk;
-(void)removeController:(completionBlkWithInteger)blk;
-(void)addButtonWithTitle:(NSString *)title;

@end


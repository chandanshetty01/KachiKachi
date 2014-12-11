//
//  InstantMessageView.h
//  KachiKachi
//
//  Created by Chandan on 08/08/2013.
//  Copyright (c) 2014 Chanddan. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^completionBlk)(BOOL);

@interface InstantMessageView : UIView
{
    
}

-(void)showMessage:(NSString*)message
          duration:(NSInteger)duration
             color:(UIColor*)color
              font:(UIFont*)font
        completion:(completionBlk)blk;

@end

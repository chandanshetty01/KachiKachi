//
//  InstantMessageManager.h
//  KachiKachi
//
//  Created by Chandan on 08/08/2013.
//  Copyright (c) 2014 Chanddan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InstantMessageManager : NSObject

+(id)sharedManager;
-(void)removeAllMessages;
-(void)showMessage:(NSString*)message
            inView:(UIView*)view
          duration:(NSInteger)duration
              rect:(CGRect)rect
             color:(UIColor*)color
              font:(UIFont*)font;
@end

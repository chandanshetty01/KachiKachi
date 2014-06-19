//
//  AppDelegate.h
//  KachiKachi
//
//  Created by Chandan on 08/08/2013.
//  Copyright (c) 2014 Chanddan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KKGameConfigManager.h"

#define APP_DELEGATE (AppDelegate *)[[UIApplication sharedApplication] delegate]


@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic,readonly) KKGameConfigManager *configuration;
@property  (nonatomic,strong) UINavigationController *navigationController;

@end

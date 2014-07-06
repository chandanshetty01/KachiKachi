//
//  KKCollectionViewCell.h
//  KachiKachi
//
//  Created by Chandan on 08/08/2013.
//  Copyright (c) 2014 Chanddan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KKCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *menuImage;
@property (weak, nonatomic) IBOutlet UIView *lockHolderView;
@property (weak, nonatomic) IBOutlet UIImageView *lockImageBg;
@property (weak, nonatomic) IBOutlet UIImageView *lockBg;

@end

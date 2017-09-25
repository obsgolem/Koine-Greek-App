//
//  TopVC.h
//  Koine Greek Flash Cards
//
//  Created by Josiah Bills on 11/30/16.
//  Copyright © 2016 Josiah Bills. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DeckTableVC;
@class DictTableVC;
@class DictContainerVC;

@interface TopVC : UIViewController

	@property (strong, nonatomic) UINavigationController *deck_nav;
	@property (strong, nonatomic) UINavigationController *dict_nav;
	@property (strong, nonatomic) UITabBarController *tab;
	@property (strong, nonatomic) DeckTableVC *deck_table;
	@property (strong, nonatomic) DictContainerVC *dict_table;

@end


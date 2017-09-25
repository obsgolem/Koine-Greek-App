//
//  DictContainerVC.h
//  Koine Greek Flash Cards
//
//  Created by Josiah Bills on 2/23/17.
//  Copyright © 2017 Josiah Bills. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DictTableVC;

@interface DictContainerVC : UIViewController <UISearchBarDelegate>
	@property (strong, nonatomic) DictTableVC *table;
	@property (strong, nonatomic) UISearchBar *search;
@end

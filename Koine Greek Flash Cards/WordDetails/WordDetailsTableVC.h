//
//  WordDetailsTableVC.h
//  Koine Greek Flash Cards
//
//  Created by Josiah Bills on 12/8/16.
//  Copyright © 2016 Josiah Bills. All rights reserved.
//

#import <UIKit/UIKit.h>

namespace Dictionary {
	struct Word;
}

@class FormDetailsTableVC;
@class OptionTableVC;

@interface WordDetailsTableVC : UITableViewController
	@property (strong, nonatomic) OptionTableVC *picker;
	@property (strong, nonatomic) UINavigationController *picker_nav_controller;

	@property (strong, nonatomic) FormDetailsTableVC *form_details;

	@property (nonatomic) Dictionary::Word *word;
@end

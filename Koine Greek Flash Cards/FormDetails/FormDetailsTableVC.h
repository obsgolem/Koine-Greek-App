//
//  FormDetailsTableVC.h
//  Koine Greek Flash Cards
//
//  Created by Josiah Bills on 12/12/16.
//  Copyright © 2016 Josiah Bills. All rights reserved.
//

#import <UIKit/UIKit.h>

namespace Dictionary {
	struct Word;
	struct Form;
}

enum struct PickerMode {
	Case,
	Number,
	Gender,
	Tense,
	Voice,
	Mood,
	Person,
	Suffix,
	VerbExtra,

	MandatoryCase,
	MandatoryNumber,
	MandatoryGender,
	MandatoryPerson,
};

@class OptionTableVC;

@interface FormDetailsTableVC : UITableViewController
	@property (nonatomic) uint8_t *modifying;
	@property (nonatomic) PickerMode mode;
	@property (strong, nonatomic) OptionTableVC *picker;
	@property (strong, nonatomic) UINavigationController *picker_nav_controller;

	@property (nonatomic) Dictionary::Form *form;
	@property (nonatomic) Dictionary::Word *word;

	@property (nonatomic) BOOL dirty;

	- (void)addForm:(NSString *) name word:(Dictionary::Word *) word navigation:(UINavigationController *) nav;
	- (void)updateWord:(Dictionary::Word *) word navigation:(UINavigationController *) nav;
@end

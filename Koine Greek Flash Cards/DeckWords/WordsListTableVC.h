//
//  WordsListTableVC.h
//  Koine Greek Flash Cards
//
//  Created by Josiah Bills on 2/25/17.
//  Copyright © 2017 Josiah Bills. All rights reserved.
//

#import <UIKit/UIKit.h>

namespace Dictionary {
	struct Word;
}
struct Deck;

@class FormSelectTableVC;

@interface WordsListTableVC : UITableViewController

	@property (strong, nonatomic) FormSelectTableVC *form_select;

	@property (nonatomic) Deck *deck;
	@property (nonatomic) Dictionary::Word **results;

@end

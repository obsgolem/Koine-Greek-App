//
//  DictTableViewController.h
//  Koine Greek Flash Cards
//
//  Created by Josiah Bills on 12/7/16.
//  Copyright © 2016 Josiah Bills. All rights reserved.
//

#import <UIKit/UIKit.h>

#include "SelectedWordProtocol.h"

namespace Dictionary {
	struct Word;
};
struct WordData;

@class WordDetailsTableVC;

@interface DictTableVC : UITableViewController

	// @property (strong, nonatomic) WordDetailsTableVC *details;

	@property (nonatomic) Dictionary::Word *results;

	@property (nonatomic) BOOL is_word_selector;
	@property (nonatomic) Deck *deck;
	@property (nonatomic) WordData *word_selections;
	@property (nonatomic, weak) id<FinishedWordSelectProtocol> finished_delegate;

@end

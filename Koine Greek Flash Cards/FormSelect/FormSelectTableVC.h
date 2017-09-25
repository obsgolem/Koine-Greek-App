//
//  FormSelectTableViewController.h
//  Koine Greek Flash Cards
//
//  Created by Josiah Bills on 2/15/17.
//  Copyright © 2017 Josiah Bills. All rights reserved.
//

#import <UIKit/UIKit.h>

#include "SelectedWordProtocol.h"

namespace Dictionary {
	struct Word;
}

struct Deck;
struct WordData;

@interface FormSelectTableVC : UITableViewController
	@property (nonatomic, weak) id<FinishedWordSelectProtocol> finished_delegate;

	@property (nonatomic) Deck *deck;
	@property (nonatomic) WordData *word_data;
	@property (nonatomic) Dictionary::Word *word;
@end

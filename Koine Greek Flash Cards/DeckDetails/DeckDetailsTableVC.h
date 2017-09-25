//
//  DeckDetailsTableVC.h
//  Koine Greek Flash Cards
//
//  Created by Josiah Bills on 2/13/17.
//  Copyright © 2017 Josiah Bills. All rights reserved.
//

#import <UIKit/UIKit.h>

#include "SelectedWordProtocol.h"

namespace Dictionary {
	struct Word;
}
struct Deck;

@class WordsContVC;

@class WordQuizVC;

@interface DeckDetailsTableVC : UITableViewController

	@property (strong, nonatomic) UINavigationController *quiz_nav_controller;
	@property (strong, nonatomic) WordQuizVC *word_quiz;

	@property (strong, nonatomic) WordsContVC *word_list;

	@property (nonatomic) Deck *deck;
	@property (nonatomic) Dictionary::Word *words;

@end

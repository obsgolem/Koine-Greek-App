//
//  DeckWordsVC.h
//  Koine Greek Flash Cards
//
//  Created by Josiah Bills on 2/25/17.
//  Copyright © 2017 Josiah Bills. All rights reserved.
//

#import <UIKit/UIKit.h>

#include "SelectedWordProtocol.h"

@class WordsListTableVC;
@class DictContainerVC;

@interface WordsContVC : UIViewController <UISearchBarDelegate, FinishedWordSelectProtocol>

	@property (strong, nonatomic) WordsListTableVC *table;

	@property (strong, nonatomic) DictContainerVC *word_select;

	@property (strong, nonatomic) UISearchBar *search;

@end

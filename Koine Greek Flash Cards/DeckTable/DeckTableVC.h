//
// DeckTableViewController.h
//  Koine Greek Flash Cards
//
//  Created by Josiah Bills on 11/30/16.
//  Copyright © 2016 Josiah Bills. All rights reserved.
//

#import <UIKit/UIKit.h>

namespace Dictionary {
    struct Dictionary;
}

struct Deck;

@class DeckDetailsTableVC;

@interface DeckTableVC : UITableViewController
	@property (strong, nonatomic) DeckDetailsTableVC *deck_details;

	@property (nonatomic) Deck *decks;

	- (void)addDeck:(NSString *) name;

@end

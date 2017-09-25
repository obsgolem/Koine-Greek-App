//
//  AppDelegate.h
//  Koine Greek Flash Cards
//
//  Created by Josiah Bills on 11/30/16.
//  Copyright © 2016 Josiah Bills. All rights reserved.
//

#import <UIKit/UIKit.h>

#define DELEGATE ((AppDelegate *)[UIApplication sharedApplication].delegate)

namespace Dictionary {
	struct Dictionary;
	struct Word;
};

struct Deck;

@class WordDetailsTableVC;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

	@property (strong, nonatomic) UIWindow *window;

	@property (nonatomic) Dictionary::Dictionary *dict;

	// 0 is usage, 1 is strongs.
	@property (nonatomic) int current_sort_order;
	@property (nonatomic) Dictionary::Word *words;

	@property (strong, nonatomic) WordDetailsTableVC *details;

	-(void) reloadWordSort;

@end


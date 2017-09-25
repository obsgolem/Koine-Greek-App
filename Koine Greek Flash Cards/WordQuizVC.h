//
//  WordQuizVC.h
//  Koine Greek Flash Cards
//
//  Created by Josiah Bills on 2/21/17.
//  Copyright © 2017 Josiah Bills. All rights reserved.
//

#import <UIKit/UIKit.h>

struct Deck;
namespace Dictionary {
	struct Word;
};

enum struct QuizMode {
	Word,
	Root,
	Form,
};

struct QuizForm {
	Dictionary::Word *word;
	uint64_t form_index;
};

@interface WordQuizVC : UIViewController

	@property (nonatomic) QuizMode mode;

	@property (nonatomic) Deck *deck;
	@property (nonatomic) uint64_t position;
	@property (nonatomic) Dictionary::Word **words;
	@property (nonatomic) QuizForm *forms;

	@property (strong, nonatomic) UIView *container;

	@property (strong, nonatomic) UILabel *word_label;
	@property (strong, nonatomic) UILabel *definition_label;

	-(BOOL) fillForms;

@end

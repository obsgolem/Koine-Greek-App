//
//  WordQuizVC.m
//  Koine Greek Flash Cards
//
//  Created by Josiah Bills on 2/21/17.
//  Copyright © 2017 Josiah Bills. All rights reserved.
//

#import "AppDelegate.h"
#import "WordQuizVC.h"

#import "dictionary/dictionary.h"

#import "deck.h"

@interface WordQuizVC ()

@end

@implementation WordQuizVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.container = [[UIView alloc] init];
    self.container.translatesAutoresizingMaskIntoConstraints = NO;

    self.word_label = [[UILabel alloc] init];
    self.word_label.textAlignment = NSTextAlignmentCenter;
    self.word_label.font = [self boldFontWithFont:[UIFont preferredFontForTextStyle:UIFontTextStyleTitle1]];
    self.word_label.translatesAutoresizingMaskIntoConstraints = NO;

    self.definition_label = [[UILabel alloc] init];
    self.definition_label.numberOfLines = 0;
    self.definition_label.textAlignment = NSTextAlignmentCenter;
    self.definition_label.translatesAutoresizingMaskIntoConstraints = NO;

    [self.container addSubview:self.word_label];
    [self.container addSubview:self.definition_label];

    [self.view addSubview:self.container];

    [self.view.widthAnchor constraintEqualToAnchor:self.container.widthAnchor].active = YES;
    [self.view.centerYAnchor constraintEqualToAnchor:self.container.centerYAnchor].active = YES;
    [self.view.centerXAnchor constraintEqualToAnchor:self.container.centerXAnchor].active = YES;

    [self.word_label.topAnchor constraintEqualToAnchor:self.container.topAnchor].active = YES;
    [self.word_label.centerXAnchor constraintEqualToAnchor:self.container.centerXAnchor].active = YES;
    [self.word_label.widthAnchor constraintEqualToAnchor:self.container.widthAnchor].active = YES;

    [self.definition_label.topAnchor constraintEqualToAnchor:self.word_label.bottomAnchor].active = YES;
    [self.definition_label.bottomAnchor constraintEqualToAnchor:self.container.bottomAnchor].active = YES;
    [self.definition_label.centerXAnchor constraintEqualToAnchor:self.container.centerXAnchor].active = YES;
    [self.definition_label.widthAnchor constraintEqualToAnchor:self.container.widthAnchor].active = YES;

    self.view.backgroundColor = UIColor.groupTableViewBackgroundColor;

    UITapGestureRecognizer *singleFingerTap =
	[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
	[self.view addGestureRecognizer:singleFingerTap];
}

- (void)viewWillAppear:(BOOL) animated {
	[super viewWillAppear:animated];

	self.position = 0;

	if(self.mode != QuizMode::Form) {
		uint64 count = NARRAY_SIZE(self.deck->words);

		NARRAY_FREE(self.words);
		self.words = NARRAY_NEW(Dictionary::Word *, count);
		NARRAY_SIZE_WRITABLE(self.words) = count;

		for(uint32 i = 0; i < count; ++i) {
			uint64 j = arc4random_uniform(i+1);
			if(j != i) {
				NARRAYITEM(self.words, i) = NARRAYITEM(self.words, j);
			}

			NARRAYITEM(self.words, j) = NARRAYITEM(self.deck->words, i);
		}

		Dictionary::Word *word = NARRAYITEM(self.words, 0);
		if(self.mode == QuizMode::Root && word->root) {
			self.word_label.text = [NSString stringWithUTF8String: word->root];
		}
		else {
			self.word_label.text = [NSString stringWithUTF8String: word->lemma];
		}

		char *str = word->definition;
		if(word->gloss) {
			str = word->gloss;
		}

		self.definition_label.text = [NSString stringWithUTF8String: str];
	}

	self.definition_label.alpha = 0.0;
}

- (void)viewWillDisappear:(BOOL) animated {
	[super viewWillDisappear: animated];

	NARRAY_FREE(self.words);
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
	if(self.definition_label.alpha == 1.0) {
		self.position++;
		if(self.mode != QuizMode::Form) {
			self.position %= NARRAY_SIZE(self.words);
			Dictionary::Word *word = NARRAYITEM(self.words, self.position);

			[UIView transitionWithView:self.definition_label duration:.5f options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionTransitionCrossDissolve animations:^{
				self.definition_label.alpha = 0.0;
				char *str = word->definition;
				if(word->gloss) {
					str = word->gloss;
				}
				self.definition_label.text = [NSString stringWithUTF8String:str];
			} completion: nil];
			[UIView transitionWithView:self.word_label duration:.5f options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionTransitionCrossDissolve animations:^{
				if(self.mode == QuizMode::Root && word->root) {
					self.word_label.text = [NSString stringWithUTF8String: word->root];
				}
				else {
					self.word_label.text = [NSString stringWithUTF8String: word->lemma];
				}
			} completion: nil];
		}
		else {
			self.position %= NARRAY_SIZE(self.forms);
			[self updateForForm: &NARRAYITEM(self.forms, self.position) animated:YES];
		}
	}
	else {
		[UIView animateWithDuration: 0.5 animations: ^(){
			self.definition_label.alpha = 1.0;
		}];
	}
}

- (UIFont *)boldFontWithFont:(UIFont *)font {
    UIFontDescriptor * fontD = [font.fontDescriptor fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold];
    return [UIFont fontWithDescriptor:fontD size:0];
}

- (void)updateForForm:(QuizForm *) quiz_form animated:(BOOL) animated {
	NSString *name;
	NSString *def;

	if(quiz_form->word->part == Dictionary::Part::N || quiz_form->word->part == Dictionary::Part::A || quiz_form->word->part == Dictionary::Part::T) {
		Dictionary::CNGForm *form = &NARRAYITEM(quiz_form->word->cng_forms, quiz_form->form_index);
		name = [NSString stringWithUTF8String: form->form.str];


		const char *case_ = Dictionary::case_names[(uint8) form->case_];
		const char *number = Dictionary::number_names[(uint8) form->number];
		const char *gender = Dictionary::gender_names[(uint8) form->gender];

		const char *suffix = "";
		const char *suffix_connector = "";
		if(form->suffix != Dictionary::Suffix::X) {
			if(!(form->gender == Dictionary::Gender::X && form->number == Dictionary::Number::X && form->case_ == Dictionary::Case::X)) {
				suffix_connector = ", ";
			}
			suffix = Dictionary::suffix_names[(uint8) form->suffix];
		}
		def = [NSString stringWithFormat:@"%s %s %s%s%s form of %@", case_, number, gender, suffix_connector, suffix, [NSString stringWithUTF8String: quiz_form->word->lemma]];
	}
	else if(quiz_form->word->part == Dictionary::Part::V) {
		Dictionary::VerbForm *form = &NARRAYITEM(quiz_form->word->verb_forms, quiz_form->form_index);
		name = [NSString stringWithUTF8String: form->form.str];


		const char *tense = Dictionary::tense_names[(uint8) form->tense];
		const char *voice = Dictionary::voice_names[(uint8) form->voice];
		const char *mood = Dictionary::mood_names[(uint8) form->mood];
		const char *verb_extra = "";

		const char *mood_connector = "";
		const char *person_connector = "";
		const char *case_connector = "";
		const char *number_connector = "";
		const char *gender_connector = "";

		const char *case_ = "";
		const char *number = "";
		const char *gender = "";
		const char *person = "";

		if(form->mood == Dictionary::Mood::I || form->mood == Dictionary::Mood::S || form->mood == Dictionary::Mood::O || form->mood == Dictionary::Mood::M) {
			person = Dictionary::person_names[form->person];
			number = Dictionary::number_names[(uint8) form->number];
			mood_connector = " ";
			person_connector = " person ";
			if(form->verb_extra != Dictionary::VerbExtra::X) {
				number_connector = ", ";
				verb_extra = Dictionary::verb_extra_names[(uint8) form->verb_extra];
			}
        }
        else {
        	case_ = Dictionary::case_names[(uint8) form->case_];
			number = Dictionary::number_names[(uint8) form->number];
			gender = Dictionary::gender_names[(uint8) form->gender];
			mood_connector = " ";
			case_connector = " ";
			number_connector = " ";
			if(form->verb_extra != Dictionary::VerbExtra::X) {
				gender_connector = ", ";
				verb_extra = Dictionary::verb_extra_names[(uint8) form->verb_extra];
			}
        }

        def = [NSString stringWithFormat:@"%s %s %s%s%s%s%s%s%s%s%s%s%s form of %@", tense, voice, mood, mood_connector, person, person_connector, case_, case_connector, number, number_connector, gender, gender_connector, verb_extra, [NSString stringWithUTF8String: quiz_form->word->lemma]];
	}
	else if(quiz_form->word->part == Dictionary::Part::P || quiz_form->word->part == Dictionary::Part::R || quiz_form->word->part == Dictionary::Part::C || quiz_form->word->part == Dictionary::Part::D || quiz_form->word->part == Dictionary::Part::K || quiz_form->word->part == Dictionary::Part::I || quiz_form->word->part == Dictionary::Part::X || quiz_form->word->part == Dictionary::Part::Q || quiz_form->word->part == Dictionary::Part::F) {
		Dictionary::ProForm *form = &NARRAYITEM(quiz_form->word->pro_forms, quiz_form->form_index);
		name = [NSString stringWithUTF8String: form->form.str];

		const char *person = "";
		const char *person_connector = "";

		const char *case_ = Dictionary::case_names[(uint8) form->case_];
		const char *number = Dictionary::number_names[(uint8) form->number];
		const char *number_connector = "";

		const char *gender = "";

		if(form->person != Dictionary::NO_PERSON) {
			person_connector = " person ";
			person = Dictionary::person_names[form->person];
		}

		if(form->gender != Dictionary::Gender::X) {
			number_connector = " ";
			gender = Dictionary::gender_names[(uint8) form->gender];
		}

		const char *suffix = "";
		const char *suffix_connector = "";
		if(form->suffix != Dictionary::Suffix::X) {
			suffix_connector = ", ";
			suffix = Dictionary::suffix_names[(uint8) form->suffix];
		}

        def = [NSString stringWithFormat:@"%s%s%s %s%s%s%s%s form of %@", person, person_connector, case_, number, number_connector, gender, suffix_connector, suffix, [NSString stringWithUTF8String: quiz_form->word->lemma]];
	}
	else if(quiz_form->word->part == Dictionary::Part::S) {
		Dictionary::PossesiveProForm *form = &NARRAYITEM(quiz_form->word->pos_pro_forms, quiz_form->form_index);
		name = [NSString stringWithUTF8String: form->form.str];

		const char *person_possesor = Dictionary::person_names[form->person_possesor];
		const char *number_possesor = Dictionary::number_names[(uint8) form->number_possesor];
		const char *case_possesed = Dictionary::case_names[(uint8) form->case_possesed];
		const char *number_possesed = Dictionary::number_names[(uint8) form->number_possesed];
		const char *gender_possesed = Dictionary::gender_names[(uint8) form->gender_possesed];

		def = [NSString stringWithFormat:@"%s %s %s %s %s form of %@", person_possesor, number_possesor, case_possesed, number_possesed, gender_possesed, [NSString stringWithUTF8String: quiz_form->word->lemma]];
	}
	else {
		Dictionary::OtherForm *form = &NARRAYITEM(quiz_form->word->other_forms, quiz_form->form_index);
		name = [NSString stringWithUTF8String: form->form.str];

		const char *info = "This word needs no parsing.";

		if(form->suffix != Dictionary::Suffix::X) {
			info = Dictionary::suffix_names[(uint8) form->suffix];
		}

		def = [NSString stringWithUTF8String: info];
	}

	if(animated) {
		[UIView transitionWithView:self.definition_label duration:.5f options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionTransitionCrossDissolve animations:^{
			self.definition_label.alpha = 0.0;
			self.definition_label.text = def;
		} completion: nil];
		[UIView transitionWithView:self.word_label duration:.5f options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionTransitionCrossDissolve animations:^{
			self.word_label.text = name;
		} completion: nil];
	}
	else {
		self.word_label.text = name;
		self.definition_label.text = def;
	}
}

-(BOOL) fillForms {
	self.forms = NARRAY_NEW(QuizForm);

	FOR(i, word, self.deck->words) {
		Dictionary::loadAllForms(DELEGATE.dict, *word);

		WordData *word_data = 0;
		FOR(j, data, self.deck->word_data) {
			if(data->word_id == (*word)->id) {
				word_data = data;
				break;
			}
		}

		for(uint64 j = 0; j < NARRAY_SIZE((*word)->forms_pointer); ++j) {
			Dictionary::Form *form = getFormFromForms(*word, j);

			FOR(k, form_id, word_data->form_ids) {
				if(*form_id == form->id) {
					QuizForm t = {*word, j};
					NARRAY_PUSH(self.forms, t);
					break;
				}
			}
		}
	}

	if(NARRAY_SIZE(self.forms) == 0) {
		return NO;
	}

	uint64 count = NARRAY_SIZE(self.forms);

	for(uint64 i = count-1; i >= 1; --i) {
		uint64 j = arc4random_uniform(i+1);

		QuizForm temp = NARRAYITEM(self.forms, j);
		NARRAYITEM(self.forms, j) = NARRAYITEM(self.forms, i);
		NARRAYITEM(self.forms, i) = temp;
	}

	[self updateForForm: &NARRAYITEM(self.forms, 0) animated:NO];
	return YES;
}

@end

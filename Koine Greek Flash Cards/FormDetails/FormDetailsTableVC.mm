//
//  FormDetailsTableVC.m
//  Koine Greek Flash Cards
//
//  Created by Josiah Bills on 12/12/16.
//  Copyright © 2016 Josiah Bills. All rights reserved.
//

#import "AppDelegate.h"
#import "FormDetailsTableVC.h"
#import "../OptionTableVC.h"

#import "../dictionary/dictionary.h"

using Dictionary::Part;
using Dictionary::CNGForm;
using Dictionary::VerbForm;
using Dictionary::ProForm;
using Dictionary::PossesiveProForm;
using Dictionary::OtherForm;

@interface FormDetailsTableVC ()

@end

@implementation FormDetailsTableVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.cellLayoutMarginsFollowReadableWidth = false;

    self.picker = [[OptionTableVC alloc] init];
    UIBarButtonItem* cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(pickerCancelPushed:)];
    UIBarButtonItem* SaveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(pickerSavePushed:)];
    self.picker.navigationItem.leftBarButtonItem = cancelButton;
    self.picker.navigationItem.rightBarButtonItem = SaveButton;
    self.picker_nav_controller = [[UINavigationController alloc] initWithRootViewController:self.picker];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.navigationItem.title = [NSString stringWithUTF8String: self.form->str];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    Dictionary::updateForm(DELEGATE.dict, self.form);
    if(self.word->part == Dictionary::Part::N || self.word->part == Dictionary::Part::A || self.word->part == Dictionary::Part::T) {
        Dictionary::updateCNGForm(DELEGATE.dict, (CNGForm *) self.form);
    }
    else if(self.word->part == Dictionary::Part::V) {
        Dictionary::updateVerbForm(DELEGATE.dict, (VerbForm *) self.form);
    }
    else if(self.word->part == Dictionary::Part::P || self.word->part == Dictionary::Part::R || self.word->part == Dictionary::Part::C || self.word->part == Dictionary::Part::D || self.word->part == Dictionary::Part::K || self.word->part == Dictionary::Part::I || self.word->part == Dictionary::Part::X || self.word->part == Dictionary::Part::Q || self.word->part == Dictionary::Part::F) {
        Dictionary::updateProForm(DELEGATE.dict, (ProForm *) self.form);
    }
    else if(self.word->part == Dictionary::Part::S) {
        Dictionary::updatePossesiveProForm(DELEGATE.dict, (PossesiveProForm *) self.form);
    }
    else {
        Dictionary::updateOtherForm(DELEGATE.dict, (OtherForm *) self.form);
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if(self.word->part == Part::N || self.word->part == Part::A || self.word->part == Part::T) {
        return 4;
    }
    else if(self.word->part == Part::V) {
        VerbForm *form = (VerbForm *) self.form;

        if(form->mood == Dictionary::Mood::I || form->mood == Dictionary::Mood::S || form->mood == Dictionary::Mood::O || form->mood == Dictionary::Mood::M) {
            return 6;
        }
        else if(form->mood == Dictionary::Mood::N) {
            return 3;

        }
        else {
            return 7;
        }
    }
    else if(self.word->part == Part::P || self.word->part == Part::R || self.word->part == Part::C || self.word->part == Part::D || self.word->part == Part::K || self.word->part == Part::I || self.word->part == Part::X || self.word->part == Part::Q || self.word->part == Part::F) {
        return 5;
    }
    else if(self.word->part == Part::S) {
        return 6;
    }
    else {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(self.word->part == Part::N || self.word->part == Part::A || self.word->part == Part::T) {
        if(section == 0) {
            return @"Case";
        }
        else if(section == 1) {
            return @"Number";
        }
        else if(section == 2) {
            return @"Gender";
        }
        else {
            return @"Suffix";
        }
    }
    else if(self.word->part == Part::V) {
        if(section == 0) {
            return @"Tense";
        }
        else if(section == 1) {
            return @"Voice";
        }
        else if(section == 2) {
            return @"Mood";
        }
        else {
            VerbForm *form = (VerbForm *) self.form;
            if(form->mood == Dictionary::Mood::I || form->mood == Dictionary::Mood::S || form->mood == Dictionary::Mood::O || form->mood == Dictionary::Mood::M) {
                if(section == 3) {
                    return @"Person";
                }
                else if(section == 4) {
                    return @"Number";
                }
                else {
                    return @"Extra";
                }
            }
            else {
                if(section == 3) {
                    return @"Case";
                }
                else if(section == 4) {
                    return @"Number";
                }
                else if(section == 5) {
                    return @"Gender";
                }
                else {
                    return @"Extra";
                }
            }
        }
    }
    else if(self.word->part == Part::P || self.word->part == Part::R || self.word->part == Part::C || self.word->part == Part::D || self.word->part == Part::K || self.word->part == Part::I || self.word->part == Part::X || self.word->part == Part::Q || self.word->part == Part::F) {
        if(section == 0) {
            return @"Person";
        }
        else if(section == 1) {
            return @"Case";
        }
        else if(section == 2) {
            return @"Number";
        }
        else if(section == 3) {
            return @"Gender";
        }
        else {
            return @"Suffix";
        }
    }
    else if(self.word->part == Part::S) {
        if(section == 0) {
            return @"Possesor Person";
        }
        else if(section == 1) {
            return @"Possesor Number";
        }
        else if(section == 2) {
            return @"Case of Possesed";
        }
        else if(section == 3) {
            return @"Number of Possesed";
        }
        else if(section == 4) {
            return @"Gender of Possesed";
        }
        else {
            return @"Suffix";
        }
    }
    else {
        return @"Suffix";
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"form";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];

    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }

    if(self.word->part == Part::N || self.word->part == Part::A || self.word->part == Part::T) {
        CNGForm *form = (CNGForm *) self.form;
        if(indexPath.section == 0) {
            cell.textLabel.text = [NSString stringWithUTF8String: Dictionary::case_names[(uint8) form->case_]];
        }
        else if(indexPath.section == 1) {
            cell.textLabel.text = [NSString stringWithUTF8String: Dictionary::number_names[(uint8) form->number]];
        }
        else if(indexPath.section == 2) {
            cell.textLabel.text = [NSString stringWithUTF8String: Dictionary::gender_names[(uint8) form->gender]];
        }
        else if(indexPath.section == 3) {
            cell.textLabel.text = [NSString stringWithUTF8String: (Dictionary::suffix_names[(uint8) form->suffix])];
        }
    }
    else if(self.word->part == Part::V) {
        VerbForm *form = (VerbForm *) self.form;
        if(indexPath.section == 0) {
            cell.textLabel.text = [NSString stringWithUTF8String: Dictionary::tense_names[(uint8) form->tense]];
        }
        else if(indexPath.section == 1) {
            cell.textLabel.text = [NSString stringWithUTF8String: Dictionary::voice_names[(uint8) form->voice]];
        }
        else if(indexPath.section == 2) {
            cell.textLabel.text = [NSString stringWithUTF8String: Dictionary::mood_names[(uint8) form->mood]];
        }
        else {
            VerbForm *form = (VerbForm *) self.form;
            if(form->mood == Dictionary::Mood::I || form->mood == Dictionary::Mood::S || form->mood == Dictionary::Mood::O || form->mood == Dictionary::Mood::M) {
                if(indexPath.section == 3) {
                    cell.textLabel.text = [NSString stringWithUTF8String: Dictionary::person_names[((uint8) form->person)]];
                }
                else if(indexPath.section == 4) {
                    cell.textLabel.text = [NSString stringWithUTF8String: Dictionary::number_names[(uint8) form->number]];
                }
                else {
                    cell.textLabel.text = [NSString stringWithUTF8String: (Dictionary::verb_extra_names[(uint8) form->verb_extra])];
                }
            }
            else {
                if(indexPath.section == 3) {
                    cell.textLabel.text = [NSString stringWithUTF8String: Dictionary::case_names[(uint8) form->case_]];
                }
                else if(indexPath.section == 4) {
                    cell.textLabel.text = [NSString stringWithUTF8String: Dictionary::number_names[(uint8) form->number]];
                }
                else if(indexPath.section == 5) {
                    cell.textLabel.text = [NSString stringWithUTF8String: Dictionary::gender_names[(uint8) form->gender]];
                }
                else {
                    cell.textLabel.text = [NSString stringWithUTF8String: (Dictionary::verb_extra_names[(uint8) form->verb_extra])];
                }
            }
        }
    }
    else if(self.word->part == Part::P || self.word->part == Part::R || self.word->part == Part::C || self.word->part == Part::D || self.word->part == Part::K || self.word->part == Part::I || self.word->part == Part::X || self.word->part == Part::Q || self.word->part == Part::F) {
        ProForm *form = (ProForm *) self.form;
        if(indexPath.section == 0) {
            cell.textLabel.text = [NSString stringWithUTF8String: Dictionary::person_names[((uint8) form->person)]];
        }
        else if(indexPath.section == 1) {
            cell.textLabel.text = [NSString stringWithUTF8String: Dictionary::case_names[(uint8) form->case_]];
        }
        else if(indexPath.section == 2) {
            cell.textLabel.text = [NSString stringWithUTF8String: Dictionary::number_names[(uint8) form->number]];
        }
        else if(indexPath.section == 3) {
            cell.textLabel.text = [NSString stringWithUTF8String: Dictionary::gender_names[(uint8) form->gender]];
        }
        else if(indexPath.section == 4) {
            cell.textLabel.text = [NSString stringWithUTF8String: (Dictionary::suffix_names[(uint8) form->suffix])];
        }
    }
    else if(self.word->part == Part::S) {
        PossesiveProForm *form = (PossesiveProForm *) self.form;
        if(indexPath.section == 0) {
            cell.textLabel.text = [NSString stringWithUTF8String: Dictionary::person_names[((uint8) form->person_possesor)]];
        }
        else if(indexPath.section == 1) {
            cell.textLabel.text = [NSString stringWithUTF8String: Dictionary::number_names[(uint8) form->number_possesor]];
        }
        else if(indexPath.section == 2) {
            cell.textLabel.text = [NSString stringWithUTF8String: Dictionary::case_names[(uint8) form->case_possesed]];
        }
        else if(indexPath.section == 3) {
            cell.textLabel.text = [NSString stringWithUTF8String: Dictionary::number_names[(uint8) form->number_possesed]];
        }
        else if(indexPath.section == 4) {
            cell.textLabel.text = [NSString stringWithUTF8String: Dictionary::gender_names[(uint8) form->gender_possesed]];
        }
        else if(indexPath.section == 5) {
            cell.textLabel.text = [NSString stringWithUTF8String: (Dictionary::suffix_names[(uint8) form->suffix])];
        }
    }
    else {
        OtherForm *form = (OtherForm *) self.form;
        cell.textLabel.text = [NSString stringWithUTF8String: (Dictionary::suffix_names[(uint8) form->suffix])];
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];

    if(self.word->part == Part::N || self.word->part == Part::A || self.word->part == Part::T) {
        CNGForm *form = (CNGForm *) self.form;
        if(indexPath.section == 0) {
            self.modifying = (uint8 *) &form->case_;
            [self updatePickerData:PickerMode::MandatoryCase startValue: ((uint8) form->case_)-1];
        }
        else if(indexPath.section == 1) {
            self.modifying = (uint8 *) &form->number;
            [self updatePickerData:PickerMode::MandatoryNumber startValue: ((uint8) form->number)-1];
        }
        else if(indexPath.section == 2) {
            self.modifying = (uint8 *) &form->gender;
            [self updatePickerData:PickerMode::MandatoryGender startValue: ((uint8) form->gender)-1];
        }
        else if(indexPath.section == 3) {
            self.modifying = (uint8 *) &form->suffix;
            [self updatePickerData:PickerMode::Suffix startValue: (uint8) form->suffix];
        }
    }
    else if(self.word->part == Part::V) {
        VerbForm *form = (VerbForm *) self.form;
        if(indexPath.section == 0) {
            self.modifying = (uint8 *) &form->tense;
            [self updatePickerData:PickerMode::Tense startValue: ((uint8) form->tense)-1];
        }
        else if(indexPath.section == 1) {
            self.modifying = (uint8 *) &form->voice;
            [self updatePickerData:PickerMode::Voice startValue: ((uint8) form->voice)-1];
        }
        else if(indexPath.section == 2) {
            self.modifying = (uint8 *) &form->mood;
            [self updatePickerData:PickerMode::Mood startValue: ((uint8) form->mood)];
            [self.tableView reloadData];
        }
        else {
            if(form->mood == Dictionary::Mood::I || form->mood == Dictionary::Mood::S || form->mood == Dictionary::Mood::O || form->mood == Dictionary::Mood::M) {
                if(indexPath.section == 3) {
                    self.modifying = (uint8 *) &form->person;
                    [self updatePickerData:PickerMode::MandatoryPerson startValue: ((uint8) form->person)-1];
                }
                else if(indexPath.section == 4) {
                    self.modifying = (uint8 *) &form->number;
                    [self updatePickerData:PickerMode::MandatoryNumber startValue: ((uint8) form->number)-1];
                }
                else {
                    self.modifying = (uint8 *) &form->verb_extra;
                    [self updatePickerData:PickerMode::VerbExtra startValue: (uint8) form->verb_extra];
                }
            }
            else {
                if(indexPath.section == 3) {
                    self.modifying = (uint8 *) &form->case_;
                    [self updatePickerData:PickerMode::MandatoryCase startValue: ((uint8) form->case_)-1];
                }
                else if(indexPath.section == 4) {
                    self.modifying = (uint8 *) &form->number;
                    [self updatePickerData:PickerMode::MandatoryNumber startValue: ((uint8) form->number)-1];
                }
                else if(indexPath.section == 5) {
                    self.modifying = (uint8 *) &form->gender;
                    [self updatePickerData:PickerMode::MandatoryGender startValue: ((uint8) form->gender)-1];
                }
                else {
                    self.modifying = (uint8 *) &form->verb_extra;
                    [self updatePickerData:PickerMode::VerbExtra startValue: (uint8) form->verb_extra];
                }
            }
        }
    }
    else if(self.word->part == Part::P || self.word->part == Part::R || self.word->part == Part::C || self.word->part == Part::D || self.word->part == Part::K || self.word->part == Part::I || self.word->part == Part::X || self.word->part == Part::Q || self.word->part == Part::F) {
        ProForm *form = (ProForm *) self.form;
        if(indexPath.section == 0) {
            self.modifying = (uint8 *) &form->person;
            [self updatePickerData:PickerMode::Person startValue: (uint8) form->person];
        }
        else if(indexPath.section == 1) {
            self.modifying = (uint8 *) &form->case_;
            [self updatePickerData:PickerMode::Case startValue: (uint8) form->case_];
        }
        else if(indexPath.section == 2) {
            self.modifying = (uint8 *) &form->number;
            [self updatePickerData:PickerMode::Number startValue: (uint8) form->number];
        }
        else if(indexPath.section == 3) {
            self.modifying = (uint8 *) &form->gender;
            [self updatePickerData:PickerMode::Gender startValue: (uint8) form->gender];
        }
        else if(indexPath.section == 4) {
            self.modifying = (uint8 *) &form->suffix;
            [self updatePickerData:PickerMode::Suffix startValue: (uint8) form->suffix];
        }
    }
    else if(self.word->part == Part::S) {
        PossesiveProForm *form = (PossesiveProForm *) self.form;
        if(indexPath.section == 0) {
            self.modifying = (uint8 *) &form->person_possesor;
            [self updatePickerData:PickerMode::MandatoryPerson startValue: ((uint8) form->person_possesor)-1];
        }
        else if(indexPath.section == 1) {
            self.modifying = (uint8 *) &form->number_possesor;
            [self updatePickerData:PickerMode::MandatoryNumber startValue: ((uint8) form->number_possesor)-1];
        }
        else if(indexPath.section == 2) {
            self.modifying = (uint8 *) &form->case_possesed;
            [self updatePickerData:PickerMode::MandatoryCase startValue: ((uint8) form->case_possesed)-1];
        }
        else if(indexPath.section == 3) {
            self.modifying = (uint8 *) &form->number_possesed;
            [self updatePickerData:PickerMode::Number startValue: ((uint8) form->number_possesed)-1];
        }
        else if(indexPath.section == 4) {
            self.modifying = (uint8 *) &form->gender_possesed;
            [self updatePickerData:PickerMode::MandatoryGender startValue: ((uint8) form->gender_possesed)-1];
        }
        else if(indexPath.section == 5) {
            self.modifying = (uint8 *) &form->suffix;
            [self updatePickerData:PickerMode::Suffix startValue: (uint8) form->suffix];
        }
    }
    else {
        OtherForm *form = (OtherForm *) self.form;
        self.modifying = (uint8 *) &form->suffix;
        [self updatePickerData:PickerMode::Suffix startValue: (uint8) form->suffix];
    }
}


// Helpers

- (void)addForm:(NSString *) name word:(Dictionary::Word *) word navigation:(UINavigationController *) nav {
    if(word->part == Part::N || word->part == Part::A || word->part == Part::T) {
        if(!word->cng_forms) {
            word->cng_forms = NARRAY_NEW(CNGForm);
        }

        CNGForm form = {};
        form.form.str = allocAndCopyString(name.UTF8String);
        Dictionary::addCNGForm(DELEGATE.dict, word, &form);

        NARRAY_PUSH(word->cng_forms, form);
        self.form = &(&NARRAY_LAST(word->cng_forms))->form;
    }
    else if(word->part == Part::V) {
        if(!word->verb_forms) {
            word->verb_forms = NARRAY_NEW(VerbForm);
        }

        VerbForm form = {};
        form.form.str = allocAndCopyString(name.UTF8String);
        Dictionary::addVerbForm(DELEGATE.dict, word, &form);

        NARRAY_PUSH(word->verb_forms, form);
        self.form = &(&NARRAY_LAST(word->verb_forms))->form;
    }
    else if(word->part == Part::P || word->part == Part::R || word->part == Part::C || word->part == Part::D || word->part == Part::K || word->part == Part::I || word->part == Part::X || word->part == Part::Q || word->part == Part::F) {
        if(!word->pro_forms) {
            word->pro_forms = NARRAY_NEW(ProForm);
        }

        ProForm form = {};
        form.form.str = allocAndCopyString(name.UTF8String);
        Dictionary::addProForm(DELEGATE.dict, word, &form);

        NARRAY_PUSH(word->pro_forms, form);
        self.form = &(&NARRAY_LAST(word->pro_forms))->form;
    }
    else if(word->part == Part::S) {
        if(!word->pos_pro_forms) {
            word->pos_pro_forms = NARRAY_NEW(PossesiveProForm);
        }

        PossesiveProForm form = {};
        form.form.str = allocAndCopyString(name.UTF8String);
        Dictionary::addPossesiveProForm(DELEGATE.dict, word, &form);

        NARRAY_PUSH(word->pos_pro_forms, form);
        self.form = &(&NARRAY_LAST(word->pos_pro_forms))->form;
    }
    else {
        if(!word->other_forms) {
            word->other_forms = NARRAY_NEW(OtherForm);
        }

        OtherForm form = {};
        form.form.str = allocAndCopyString(name.UTF8String);
        Dictionary::addOtherForm(DELEGATE.dict, word, &form);

        NARRAY_PUSH(word->other_forms, form);
        self.form = &(&NARRAY_LAST(word->other_forms))->form;
    }

    [self updateWord:word navigation:nav];
}

- (void) updateWord:(Dictionary::Word *) word navigation:(UINavigationController *) nav {
    self.word = word;
    [self.tableView reloadData];
    [nav pushViewController:self animated:YES];
}


// Picker stuff

- (void)updatePickerData:(PickerMode) mode startValue:(uint8) start_value {
    if(mode == PickerMode::Case) {
        self.picker.default_cell = start_value;
        self.picker.data = Dictionary::case_names;
        self.picker.count = 6;
    }
    else if(mode == PickerMode::Number) {
        self.picker.default_cell = start_value;
        self.picker.data = Dictionary::number_names;
        self.picker.count = 3;
    }
    else if(mode == PickerMode::Gender) {
        self.picker.default_cell = start_value;
        self.picker.data = Dictionary::gender_names;
        self.picker.count = 4;
    }
    else if(mode == PickerMode::Tense) {
        self.picker.default_cell = start_value;
        self.picker.data = Dictionary::tense_names+1;
        self.picker.count = 10;
    }
    else if(mode == PickerMode::Voice) {
        self.picker.default_cell = start_value;
        self.picker.data = Dictionary::voice_names+1;
        self.picker.count = 8;
    }
    else if(mode == PickerMode::Mood) {
        self.picker.default_cell = start_value;
        self.picker.data = Dictionary::mood_names;
        self.picker.count = 7;
    }
    else if(mode == PickerMode::Person) {
        self.picker.default_cell = start_value;
        self.picker.data = Dictionary::person_names;
        self.picker.count = 4;
    }
    else if(mode == PickerMode::Suffix) {
        self.picker.default_cell = start_value;
        self.picker.data = Dictionary::suffix_names;
        self.picker.count = 9;
    }
    else if(mode == PickerMode::VerbExtra) {
        self.picker.default_cell = start_value;
        self.picker.data = Dictionary::verb_extra_names;
        self.picker.count = 8;
    }
    else if(mode == PickerMode::MandatoryPerson) {
        self.picker.default_cell = start_value;
        self.picker.data = Dictionary::person_names+1;
        self.picker.count = 3;
    }
    else if(mode == PickerMode::MandatoryCase) {
        self.picker.default_cell = start_value;
        self.picker.data = Dictionary::case_names+1;
        self.picker.count = 5;
    }
    else if(mode == PickerMode::MandatoryNumber) {
        self.picker.default_cell = start_value;
        self.picker.data = Dictionary::number_names+1;
        self.picker.count = 2;
    }
    else if(mode == PickerMode::MandatoryGender) {
        self.picker.default_cell = start_value;
        self.picker.data = Dictionary::gender_names+1;
        self.picker.count = 3;
    }

    self.mode = mode;

    [self presentViewController:self.picker_nav_controller animated:YES completion:nil];
}

-(void)pickerSavePushed:(UIBarButtonItem *)sender {
    uint8 row = [self.picker.tableView indexPathForSelectedRow].row;

    if(row != self.picker.default_cell) {
        self.dirty = YES;
        if(self.mode == PickerMode::Case) {
            Dictionary::Case *modifying = (Dictionary::Case *) self.modifying;
            *modifying = (Dictionary::Case) row;
        }
        else if(self.mode == PickerMode::Number) {
            Dictionary::Number *modifying = (Dictionary::Number *) self.modifying;
            *modifying = (Dictionary::Number) row;
        }
        else if(self.mode == PickerMode::Gender) {
            Dictionary::Gender *modifying = (Dictionary::Gender *) self.modifying;
            *modifying = (Dictionary::Gender) row;
        }
        else if(self.mode == PickerMode::Tense) {
            Dictionary::Tense *modifying = (Dictionary::Tense *) self.modifying;
            *modifying = (Dictionary::Tense) (row+1);
        }
        else if(self.mode == PickerMode::Voice) {
            Dictionary::Voice *modifying = (Dictionary::Voice *) self.modifying;
            *modifying = (Dictionary::Voice) (row+1);
        }
        else if(self.mode == PickerMode::Mood) {
            Dictionary::Mood *modifying = (Dictionary::Mood *) self.modifying;
            *modifying = (Dictionary::Mood) row;
        }
        else if(self.mode == PickerMode::Person) {
            *self.modifying = row;
        }
        else if(self.mode == PickerMode::Suffix) {
            Dictionary::Suffix *modifying = (Dictionary::Suffix *) self.modifying;
            *modifying = (Dictionary::Suffix) row;
        }
        else if(self.mode == PickerMode::VerbExtra) {
            Dictionary::VerbExtra *modifying = (Dictionary::VerbExtra *) self.modifying;
            *modifying = (Dictionary::VerbExtra) row;
        }
        else if(self.mode == PickerMode::MandatoryPerson) {
            *self.modifying = (row+1);
        }
        else if(self.mode == PickerMode::MandatoryCase) {
            Dictionary::Case *modifying = (Dictionary::Case *) self.modifying;
            *modifying = (Dictionary::Case) (row+1);
        }
        else if(self.mode == PickerMode::MandatoryNumber) {
            Dictionary::Number *modifying = (Dictionary::Number *) self.modifying;
            *modifying = (Dictionary::Number) (row+1);
        }
        else if(self.mode == PickerMode::MandatoryGender) {
            Dictionary::Gender *modifying = (Dictionary::Gender *) self.modifying;
            *modifying = (Dictionary::Gender) (row+1);
        }
    }

    [self.tableView reloadData];
    [self.picker_nav_controller dismissViewControllerAnimated: YES completion:nil];
}

-(void)pickerCancelPushed:(UIBarButtonItem *)sender {
    [self.picker_nav_controller dismissViewControllerAnimated: YES completion:nil];
}

@end

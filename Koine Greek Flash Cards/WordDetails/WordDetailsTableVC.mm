//
//  WordDetailsTableVC.m
//  Koine Greek Flash Cards
//
//  Created by Josiah Bills on 12/8/16.
//  Copyright © 2016 Josiah Bills. All rights reserved.
//

#import "../AppDelegate.h"
#import "../WordDetails/WordDetailsTableVC.h"
#import "../FormDetails/FormDetailsTableVC.h"
#import "../OptionTableVC.h"

#import "../dictionary/dictionary.h"

@interface WordDetailsTableVC ()

@end

@implementation WordDetailsTableVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.cellLayoutMarginsFollowReadableWidth = false;

    self.tableView.estimatedRowHeight = 88.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;

    self.tableView.allowsSelectionDuringEditing = YES;

    self.form_details = [[FormDetailsTableVC alloc] initWithStyle:UITableViewStyleGrouped];

    self.picker = [[OptionTableVC alloc] init];
    UIBarButtonItem* cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(pickerCancelPushed:)];
    UIBarButtonItem* SaveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(pickerSavePushed:)];
    self.picker.navigationItem.leftBarButtonItem = cancelButton;
    self.picker.navigationItem.rightBarButtonItem = SaveButton;
    self.picker_nav_controller = [[UINavigationController alloc] initWithRootViewController:self.picker];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    Dictionary::loadAllForms(DELEGATE.dict, self.word);
    [self.tableView reloadData];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];

    self.navigationItem.title = [NSString stringWithUTF8String: self.word->lemma];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if(self.word->part == Dictionary::Part::N || self.word->part == Dictionary::Part::V) {
        return 9;
    }
    else {
        return 8;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if([self isFormsSection: section]) {
        return NARRAY_SIZE(self.word->forms_pointer)+1;
    }
    else {
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.25;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(section == 0) {
        return @"Lemma";
    }
    else if(section == 1) {
        return @"Root";
    }
    else if(section == 2) {
        return @"Gloss";
    }
    else if(section == 3) {
        return @"Definition";
    }
    else if(section == 4) {
        return @"Strongs";
    }
    else if(section == 5) {
        return @"Usage Count";
    }
    else if(section == 6) {
        return @"Part of Speech";
    }
    else if(self.word->part == Dictionary::Part::N && section == 7) {
        return @"Declension";
    }
    else if(self.word->part == Dictionary::Part::V && section == 7) {
        return @"Conjugation";
    }
    else {
        return @"Forms";
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;

    if(indexPath.section == 0) {
        cell = [self getBasicCell];

        cell.textLabel.text = [NSString stringWithUTF8String: self.word->lemma];
    }
    else if(indexPath.section == 1) {
        cell = [self getBasicCell];

        if(self.word->root) {
            cell.textLabel.text = [NSString stringWithUTF8String: self.word->root];
        }
        else {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeContactAdd];
            [button setUserInteractionEnabled:NO];
            cell.accessoryView = button;
            cell.textLabel.text = @"Add Root";
        }
    }
    else if(indexPath.section == 2) {
        cell = [self getBasicCell];

        if(self.word->gloss) {
            cell.textLabel.text = [NSString stringWithUTF8String: self.word->gloss];
            cell.textLabel.numberOfLines = 0;
            cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        }
        else {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeContactAdd];
            [button setUserInteractionEnabled:NO];
            cell.accessoryView = button;
            cell.textLabel.text = @"Add Gloss";
        }
    }
    else if(indexPath.section == 3) {
        cell = [self getBasicCell];

        cell.textLabel.text = [NSString stringWithUTF8String: self.word->definition];

        cell.textLabel.numberOfLines = 0;
        cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    }
    else if(indexPath.section == 4) {
        cell = [self getBasicCell];

        cell.textLabel.text = [NSString stringWithFormat:@"%lld", self.word->strongs];
    }
    else if(indexPath.section == 5) {
        cell = [self getBasicCell];

        cell.textLabel.text = [NSString stringWithFormat:@"%lld", self.word->count];
    }
    else if(indexPath.section == 6) {
        cell = [self getBasicCell];

        const char *part_name = Dictionary::part_names[(uint8) self.word->part];
        cell.textLabel.text = [NSString stringWithUTF8String: part_name];
    }
    else if((self.word->part == Dictionary::Part::N || self.word->part == Dictionary::Part::V) && indexPath.section == 7) {
        cell = [self getBasicCell];

        cell.textLabel.text = [NSString stringWithUTF8String: Dictionary::declconj_names[(uint8) self.word->declconj]];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else {
        cell = [self getBasicCell];

        if(indexPath.row == NARRAY_SIZE(self.word->forms_pointer)) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeContactAdd];
            [button setUserInteractionEnabled:NO];
            cell.accessoryView = button;
            cell.textLabel.text = @"Add Form";
        }
        else {
            char *name = Dictionary::getFormFromForms(self.word, indexPath.row)->str;
            cell.textLabel.text = [NSString stringWithUTF8String: name];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];

    if(indexPath.section == 1) {
        if(self.word->root)  {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Edit" message:@"" preferredStyle:UIAlertControllerStyleAlert];

            [alert addAction:[UIAlertAction actionWithTitle:@"Done" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                free(self.word->root);

                self.word->root = allocAndCopyString(alert.textFields.firstObject.text.UTF8String);
                Dictionary::updateWord(DELEGATE.dict, self.word);

                [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:1]] withRowAnimation:UITableViewRowAnimationNone];
            }]];
            [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler: nil]];

            [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
                textField.text = [NSString stringWithUTF8String: self.word->root];
                textField.placeholder = @"Enter Root:";
            }];

            [self presentViewController:alert animated:YES completion:nil];
        }
        else {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Add" message:@"" preferredStyle:UIAlertControllerStyleAlert];

            [alert addAction:[UIAlertAction actionWithTitle:@"Add" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                self.word->root = allocAndCopyString(alert.textFields.firstObject.text.UTF8String);
                Dictionary::updateWord(DELEGATE.dict, self.word);

                [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:1]] withRowAnimation:UITableViewRowAnimationNone];
            }]];
            [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler: nil]];

            [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
                textField.placeholder = @"Enter Root:";
            }];

            [self presentViewController:alert animated:YES completion:nil];
        }
    }
    else if(indexPath.section == 2) {
        if(self.word->gloss)  {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Edit" message:@"" preferredStyle:UIAlertControllerStyleAlert];

            [alert addAction:[UIAlertAction actionWithTitle:@"Done" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                free(self.word->gloss);

                self.word->gloss = allocAndCopyString(alert.textFields.firstObject.text.UTF8String);
                Dictionary::updateWord(DELEGATE.dict, self.word);

                [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:2]] withRowAnimation:UITableViewRowAnimationNone];
            }]];
            [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler: nil]];

            [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
                textField.text = [NSString stringWithUTF8String: self.word->gloss];
                textField.placeholder = @"Enter Gloss:";
            }];

            [self presentViewController:alert animated:YES completion:nil];
        }
        else {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Add" message:@"" preferredStyle:UIAlertControllerStyleAlert];

            [alert addAction:[UIAlertAction actionWithTitle:@"Add" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                self.word->gloss = allocAndCopyString(alert.textFields.firstObject.text.UTF8String);
                Dictionary::updateWord(DELEGATE.dict, self.word);

                [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:2]] withRowAnimation:UITableViewRowAnimationNone];
            }]];
            [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler: nil]];

            [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
                textField.placeholder = @"Enter Gloss:";
            }];

            [self presentViewController:alert animated:YES completion:nil];
        }
    }
    else if((self.word->part == Dictionary::Part::N || self.word->part == Dictionary::Part::V) && indexPath.section == 6) {
        [self.picker.tableView reloadData];
        if(self.word->part == Dictionary::Part::N) {
            self.picker.navigationItem.title = @"Declension";
            self.picker.data = Dictionary::declconj_names+2;
            self.picker.count = 3;
            self.picker.default_cell = (uint8) self.word->declconj-2;
        }
        else {
            self.picker.navigationItem.title = @"Conjugation";
            self.picker.data = Dictionary::declconj_names+2;
            self.picker.count = 2;
            self.picker.default_cell = (uint8) self.word->declconj;
        }
        [self presentViewController:self.picker_nav_controller animated:YES completion:nil];
    }
    else if([self isFormsSection:indexPath.section]) {
        if(indexPath.row == NARRAY_SIZE(self.word->forms_pointer)) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Add Form" message:@"" preferredStyle:UIAlertControllerStyleAlert];

            [alert addAction:[UIAlertAction actionWithTitle:@"Add" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [self.form_details addForm:alert.textFields.firstObject.text word:self.word navigation:self.navigationController];

                [self.tableView reloadData];
            }]];

            [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler: nil]];
            [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
                textField.placeholder = @"Enter Form:";
            }];

            [self presentViewController:alert animated:YES completion:nil];
        }
        else {
            self.form_details.form = Dictionary::getFormFromForms(self.word, indexPath.row);
            [self.form_details updateWord:self.word navigation:self.navigationController];
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section >= 7 || indexPath.section == 1 || indexPath.section == 2) {
        return YES;
    }

    return NO;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if([self isFormsSection:indexPath.section] && indexPath.row != NARRAY_SIZE(self.word->forms_pointer)) {
        return YES;
    }
    else {
        return NO;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Dictionary::deleteForm(DELEGATE.dict, self.word, indexPath.row);

        if(self.word->part == Dictionary::Part::N || self.word->part == Dictionary::Part::A || self.word->part == Dictionary::Part::T) {
            NARRAY_REMOVE(self.word->cng_forms, indexPath.row);
        }
        else if(self.word->part == Dictionary::Part::V) {
            NARRAY_REMOVE(self.word->verb_forms, indexPath.row);
        }
        else if(self.word->part == Dictionary::Part::P || self.word->part == Dictionary::Part::R || self.word->part == Dictionary::Part::C || self.word->part == Dictionary::Part::D || self.word->part == Dictionary::Part::K || self.word->part == Dictionary::Part::I || self.word->part == Dictionary::Part::X || self.word->part == Dictionary::Part::Q || self.word->part == Dictionary::Part::F) {
            NARRAY_REMOVE(self.word->pro_forms, indexPath.row);
        }
        else if(self.word->part == Dictionary::Part::S) {
            NARRAY_REMOVE(self.word->pos_pro_forms, indexPath.row);
        }
        else {
            NARRAY_REMOVE(self.word->other_forms, indexPath.row);
        }

        if(NARRAY_SIZE(self.word->forms_pointer) == 0) {
            NARRAY_FREE(self.word->forms_pointer);
        }

        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (BOOL) isFormsSection:(uint64) section {
    return (((self.word->part == Dictionary::Part::N || self.word->part == Dictionary::Part::V) && section == 8) || (!(self.word->part == Dictionary::Part::N || self.word->part == Dictionary::Part::V) && section == 7));
}

- (UITableViewCell *) getBasicCell {
    static NSString *identifier = @"word_details";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:identifier];

    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }

    cell.accessoryView = nil;
    cell.accessoryType = UITableViewCellAccessoryNone;

    cell.textLabel.numberOfLines = 1;
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;

    return cell;
}


// Picker stuff

-(void)pickerSavePushed:(UIBarButtonItem *)sender {
    uint8 row = [self.picker.tableView indexPathForSelectedRow].row;

    bool update = false;

    if(self.word->part == Dictionary::Part::N) {
        if(self.word->declconj != (Dictionary::DeclConj) (row+2)) {
            update = true;
        }
        self.word->declconj = (Dictionary::DeclConj) (row+2);
    }
    else {
        if(self.word->declconj != (Dictionary::DeclConj) row) {
            update = true;
        }
        self.word->declconj = (Dictionary::DeclConj) row;
    }

    if(update) {
        updateWord(DELEGATE.dict, self.word);
    }

    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:6]] withRowAnimation:UITableViewRowAnimationNone];
    [self.picker_nav_controller dismissViewControllerAnimated: YES completion:nil];
}

-(void)pickerCancelPushed:(UIBarButtonItem *)sender {
    [self.picker_nav_controller dismissViewControllerAnimated: YES completion:nil];
}

@end

//
//  FormSelectTableViewController.m
//  Koine Greek Flash Cards
//
//  Created by Josiah Bills on 2/15/17.
//  Copyright © 2017 Josiah Bills. All rights reserved.
//

#import "AppDelegate.h"
#import "FormSelectTableVC.h"

#import "../WordDetails/WordDetailsTableVC.h"

#include "../dictionary/dictionary.h"
#include "../deck.h"

@interface FormSelectTableVC ()

@end

@implementation FormSelectTableVC

- (void)viewDidLoad {
    [super viewDidLoad];

    UIBarButtonItem* detailsButton = [[UIBarButtonItem alloc] initWithTitle:@"Details" style:UIBarButtonItemStylePlain target:self action:@selector(detailsPushed:)];
    self.navigationItem.rightBarButtonItem = detailsButton;

    self.tableView.cellLayoutMarginsFollowReadableWidth = false;

    self.tableView.allowsMultipleSelection = true;
    self.clearsSelectionOnViewWillAppear = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    NSArray<NSIndexPath *> *rows = [self.tableView indexPathsForSelectedRows];

    int *form_ids = 0;

    for (uint64 i = 0; i < [rows count]; ++i) {
        if(!form_ids) {
            form_ids = NARRAY_NEW(int);
        }

        uint64 row = [rows objectAtIndex:i].row;

        NARRAY_PUSH(form_ids, getFormFromForms(self.word, row)->id);
    }

    NARRAY_FREE(self.word_data->form_ids);
    self.word_data->form_ids = form_ids;

    updateWordForms(DELEGATE.dict, self.word_data);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    Dictionary::clearWordFormListMemory(self.word);
    Dictionary::loadAllForms(DELEGATE.dict, self.word);
    [self.tableView reloadData];

    self.navigationItem.title = [NSString stringWithUTF8String: self.word->lemma];

    FOR(i, form_id, self.word_data->form_ids) {
        uint64 index = 0;
        bool found = false;

        for(uint64 j = 0; j < NARRAY_SIZE(self.word->forms_pointer); ++j) {
            if(getFormFromForms(self.word, j)->id == *form_id) {
                index = j;
                found = true;
                break;
            }
        }

        if(found) {
            NSIndexPath *path = [NSIndexPath indexPathForRow:index inSection:0];
            [self.tableView selectRowAtIndexPath: path animated: NO scrollPosition:UITableViewScrollPositionNone];
            [self tableView:self.tableView didSelectRowAtIndexPath: path];
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return NARRAY_SIZE(self.word->forms_pointer);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"form_select";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];

    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }

    cell.accessoryType = UITableViewCellAccessoryNone;

    cell.textLabel.text = [NSString stringWithUTF8String: getFormFromForms(self.word, indexPath.row)->str];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryNone;
}


-(void)detailsPushed:(UIBarButtonItem *)sender {
    DELEGATE.details.word = self.word;
    [self.navigationController pushViewController:DELEGATE.details animated:YES];
}

@end

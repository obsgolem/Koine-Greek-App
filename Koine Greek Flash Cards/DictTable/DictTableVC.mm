//
//  DictTableVC.m
//  Koine Greek Flash Cards
//
//  Created by Josiah Bills on 12/7/16.
//  Copyright © 2016 Josiah Bills. All rights reserved.
//

#import "../AppDelegate.h"
#import "../WordDetails/WordDetailsTableVC.h"

#import "DictTableVC.h"
#import "WordCell.h"
#include "SelectedWordProtocol.h"

#import "../dictionary/dictionary.h"
#import "../deck.h"

@interface DictTableVC ()

@end

@implementation DictTableVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.cellLayoutMarginsFollowReadableWidth = false;

    if(self.is_word_selector) {
        self.tableView.allowsMultipleSelection = true;
        self.clearsSelectionOnViewWillAppear = YES;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    if(!self.is_word_selector) {
        return;
    }

    sqlite3_stmt *stmt = 0;
    sqlite3_prepare_v2(DELEGATE.dict->db, "insert into DeckWord(deck, word, word_row_index) values (?, ?, ?)", -1, &stmt, 0);

    Dictionary::Word **words = 0;

    FOR(i, selected, self.word_selections) {
        FOR(j, word, self.deck->word_data) {
            if(word->word_id == selected->word_id) {
                selected->id = word->id;
                selected->form_ids = word->form_ids;
                word->id = -1;

                break;
            }
        }

        if(!words) {
            words = NARRAY_NEW(Dictionary::Word *);
        }

        FOR(j, word, DELEGATE.words) {
            if(selected->word_id == word->id) {
                if(!word->search_string) {
                    getWordSearchString(DELEGATE.dict, word);
                }

                NARRAY_PUSH(words, word);
                break;
            }
        }

        if(selected->id == -1) {
            sqlite3_bind_int64(stmt, 1, selected->deck_id);
            sqlite3_bind_int64(stmt, 2, selected->word_id);
            sqlite3_step(stmt);

            selected->id = sqlite3_last_insert_rowid(DELEGATE.dict->db);
            sqlite3_reset(stmt);
        }
    }

    NARRAY_FREE(self.deck->words);
    self.deck->words = words;

    sqlite3_finalize(stmt);

    sqlite3_prepare_v2(DELEGATE.dict->db, "delete from DeckWord where rowid = ?", -1, &stmt, 0);

    FOR(j, word, self.deck->word_data) {
        if(word->id != -1) {
            NARRAY_FREE(word->form_ids);
            updateWordForms(DELEGATE.dict, word);
            sqlite3_bind_int64(stmt, 1, word->id);
            sqlite3_step(stmt);
            sqlite3_reset(stmt);
        }
    }

    sqlite3_finalize(stmt);

    NARRAY_FREE(self.deck->word_data);

    self.deck->word_data = self.word_selections;

    [self.finished_delegate finishedWordSelect];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if(self.is_word_selector) {
        self.word_selections = NARRAY_NEW(WordData);

        FOR(i, word, self.deck->word_data) {
            NARRAY_PUSH(self.word_selections, *word);
        }

        [self.tableView reloadData];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(self.results) {
        return NARRAY_SIZE(self.results);
    }
    else {
        return DELEGATE.dict->word_count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"dict";
    WordCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];

    if(cell == nil) {
        cell = [[WordCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
        cell.detailTextLabel.textColor = UIColor.grayColor;
    }


    if(self.results) {
        cell.word = &NARRAYITEM(self.results, indexPath.row);
    }
    else {
        cell.word = &NARRAYITEM(DELEGATE.words, indexPath.row);
    }

    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.textLabel.text = [NSString stringWithUTF8String: cell.word->lemma];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%lld", cell.word->count];

    bool unselect = true;
    if(self.results) {
        FOR(i, selection, self.word_selections) {
            if(selection->word_id == cell.word->id) {
                [self.tableView selectRowAtIndexPath: indexPath animated: NO scrollPosition:UITableViewScrollPositionNone];
                unselect = false;
                cell.accessoryType = UITableViewCellAccessoryCheckmark;

                break;
            }
        }
    }
    else {
        FOR(i, selection, self.word_selections) {
            if(selection->word_id == cell.word->id) {
                [self.tableView selectRowAtIndexPath: indexPath animated: NO scrollPosition:UITableViewScrollPositionNone];
                unselect = false;
                cell.accessoryType = UITableViewCellAccessoryCheckmark;

                break;
            }
        }
    }

    if(unselect) {
        [self.tableView deselectRowAtIndexPath: indexPath animated: NO];
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    WordCell *cell = [tableView cellForRowAtIndexPath:indexPath];

    if(self.is_word_selector) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;

        WordData word = {};
        word.id = -1;
        word.deck_id = self.deck->id;
        word.word_id = cell.word->id;
        word.form_ids = 0;

        NARRAY_PUSH(self.word_selections, word);
    }
    else {
        DELEGATE.details.word = cell.word;
        [self.navigationController pushViewController:DELEGATE.details animated:YES];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(self.is_word_selector) {
        WordCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryNone;

        FOR(i, word, self.word_selections) {
            if(word->word_id == cell.word->id) {
                NARRAY_REMOVE(self.word_selections, i);
                break;
            }
        }
    }
}

@end

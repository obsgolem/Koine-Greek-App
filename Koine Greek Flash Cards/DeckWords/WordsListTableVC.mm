//
//  WordsListTableVC.m
//  Koine Greek Flash Cards
//
//  Created by Josiah Bills on 2/25/17.
//  Copyright © 2017 Josiah Bills. All rights reserved.
//

#import "AppDelegate.h"
#import "WordsListTableVC.h"

#import "../DictTable/WordCell.h"

#import "../FormSelect/FormSelectTableVC.h"

#include "../dictionary/dictionary.h"
#include "../deck.h"

@interface WordsListTableVC ()

@end

@implementation WordsListTableVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.cellLayoutMarginsFollowReadableWidth = false;

    self.form_select = [[FormSelectTableVC alloc] init];
    self.form_select.hidesBottomBarWhenPushed = YES;
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
        return NARRAY_SIZE(self.deck->words);
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        WordCell *cell = [tableView cellForRowAtIndexPath:indexPath];

        FOR(i, word, self.deck->word_data) {
            if(word->word_id == cell.word->id) {
                NARRAY_FREE(word->form_ids);
                updateWordForms(DELEGATE.dict, word);

                sqlite3_stmt *stmt = 0;
                sqlite3_prepare_v2(DELEGATE.dict->db, "delete from DeckWord where rowid = ?", -1, &stmt, 0);
                sqlite3_bind_int64(stmt, 1, word->id);
                sqlite3_step(stmt);
                sqlite3_reset(stmt);
                sqlite3_finalize(stmt);

                NARRAY_REMOVE(self.deck->word_data, i);
                NARRAY_REMOVE(self.deck->words, indexPath.row);

                break;
            }
        }

        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"word_list";
    WordCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];

    if(cell == nil) {
        cell = [[WordCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }

    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    if(self.results) {
        cell.word = NARRAYITEM(self.results, indexPath.row);
    }
    else {
        cell.word = NARRAYITEM(self.deck->words, indexPath.row);
    }

    cell.textLabel.text = [NSString stringWithUTF8String: cell.word->lemma];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];

    WordCell *cell = [tableView cellForRowAtIndexPath:indexPath];

    self.form_select.deck = self.deck;
    FOR(i, word, self.deck->word_data) {
        if(word->word_id == cell.word->id) {
            self.form_select.word_data = word;
            break;
        }
    }
    self.form_select.word = cell.word;
    [self.navigationController pushViewController:self.form_select animated:YES];
}

@end

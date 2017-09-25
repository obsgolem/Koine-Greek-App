//
//  DeckDetailsTableVC.m
//  Koine Greek Flash Cards
//
//  Created by Josiah Bills on 2/13/17.
//  Copyright © 2017 Josiah Bills. All rights reserved.
//

#import "AppDelegate.h"
#import "DeckDetailsTableVC.h"
#import "../DeckWords/WordsContVC.h"
#import "../DeckWords/WordsListTableVC.h"
#import "../WordQuizVC.h"

#include "../dictionary/dictionary.h"

#include "../deck.h"

@interface DeckDetailsTableVC ()

@end

@implementation DeckDetailsTableVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.cellLayoutMarginsFollowReadableWidth = false;

    self.word_quiz = [[WordQuizVC alloc] init];
    self.quiz_nav_controller = [[UINavigationController alloc] initWithRootViewController:self.word_quiz];
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(quizDone:)];
    self.word_quiz.navigationItem.rightBarButtonItem = doneButton;

    self.word_list = [[WordsContVC alloc] init];
    self.word_list.hidesBottomBarWhenPushed = YES;
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.navigationItem.title = [NSString stringWithUTF8String: self.deck->name];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(section == 0) {
        return @"Start";
    }
    else {
        return nil;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0) {
        return 3;
    }
    else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"deck";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];

    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }

    cell.accessoryView = nil;
    cell.accessoryType = UITableViewCellAccessoryNone;

    if(indexPath.section == 0) {
        if(indexPath.row == 0) {
            cell.textLabel.text = @"Start word quiz";
        }
        else if(indexPath.row == 1) {
            cell.textLabel.text = @"Start root quiz";
        }
        else {
            cell.textLabel.text = @"Start form parsing quiz";
        }
    }
    else {
        cell.textLabel.text = @"Words";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }

    return cell;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];

    if(indexPath.section == 0) {
        if(indexPath.row == 0) {
            if(NARRAY_SIZE(self.deck->word_data) == 0) {
                return;
            }

            self.word_quiz.mode = QuizMode::Word;
            self.word_quiz.deck = self.deck;
            self.quiz_nav_controller.viewControllers = @[self.word_quiz];
            [self presentViewController:self.quiz_nav_controller animated:YES completion:nil];
        }
        else if(indexPath.row == 1) {
            if(NARRAY_SIZE(self.deck->word_data) == 0) {
                return;
            }

            self.word_quiz.mode = QuizMode::Root;
            self.word_quiz.deck = self.deck;
            self.quiz_nav_controller.viewControllers = @[self.word_quiz];
            [self presentViewController:self.quiz_nav_controller animated:YES completion:nil];
        }
        else {
            if(NARRAY_SIZE(self.deck->word_data) == 0) {
                return;
            }

            self.word_quiz.mode = QuizMode::Form;
            self.word_quiz.deck = self.deck;
            self.quiz_nav_controller.viewControllers = @[self.word_quiz];
            if([self.word_quiz fillForms]) {
                [self presentViewController:self.quiz_nav_controller animated:YES completion:nil];
            }
        }
    }
    else {
        self.word_list.table.deck = self.deck;
        [self.word_list.table.tableView reloadData];
        [self.navigationController pushViewController:self.word_list animated:YES];

    }
}

-(void)quizDone:(UIBarButtonItem *)sender {
    [self.quiz_nav_controller dismissViewControllerAnimated: YES completion:nil];
}

@end

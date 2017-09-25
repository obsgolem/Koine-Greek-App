//
//  WordsContVC.m
//  Koine Greek Flash Cards
//
//  Created by Josiah Bills on 2/25/17.
//  Copyright © 2017 Josiah Bills. All rights reserved.
//

#import "AppDelegate.h"
#import "WordsContVC.h"

#import "WordsListTableVC.h"

#import "../DictTable/DictContainerVC.h"
#import "../DictTable/DictTableVC.h"

#include "../dictionary/dictionary.h"
#include "../deck.h"

int32 usageCompare(const void *a, const void *b);
int32 strongsCompare(const void *a, const void *b);

@interface WordsContVC ()

@end

@implementation WordsContVC

- (id) init {
	if(self == [super init]) {
	    self.table = [[WordsListTableVC alloc] init];
	}
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    UIBarButtonItem* addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addWords:)];
    self.navigationItem.rightBarButtonItem = addButton;

    self.word_select = [[DictContainerVC alloc] init];
    self.word_select.hidesBottomBarWhenPushed = YES;

    self.word_select.table.is_word_selector = YES;
    self.word_select.table.finished_delegate = self;

    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.definesPresentationContext = YES;

    self.table.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.table.tableView.translatesAutoresizingMaskIntoConstraints = NO;

    self.search = [[UISearchBar alloc] init];
    self.search.delegate = self;
    self.search.showsScopeBar = YES;
    self.search.scopeButtonTitles = @[@"Usage", @"Strongs"];
    [self.search sizeToFit];
    self.search.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;

    UIView *container = [[UIView alloc] init];
    [container addSubview: self.search];

    container.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    container.translatesAutoresizingMaskIntoConstraints = NO;

    [self.view addSubview: container];
    [self.view addSubview: self.table.tableView];

    // [self.view.topAnchor constraintEqualToAnchor:self.topLayoutGuide.topAnchor].active = YES;
    [container.topAnchor constraintEqualToAnchor:self.topLayoutGuide.bottomAnchor].active = YES;
    [container.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [container.widthAnchor constraintEqualToAnchor:self.view.widthAnchor].active = YES;
    [container.widthAnchor constraintEqualToAnchor:self.search.widthAnchor].active = YES;
    [container.heightAnchor constraintEqualToAnchor:self.search.heightAnchor].active = YES;

    [self.table.tableView.topAnchor constraintEqualToAnchor:container.bottomAnchor].active = YES;
    [self.table.tableView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [self.table.tableView.widthAnchor constraintEqualToAnchor:self.view.widthAnchor].active = YES;
    [self.table.tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;

    [self addChildViewController: self.table];
    [self.table didMoveToParentViewController: self];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
	self.search.showsScopeBar = NO;
    [self.search sizeToFit];
	[self.search setShowsCancelButton:YES animated:YES];
	[self.navigationController setNavigationBarHidden: YES animated:YES];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
	self.search.showsScopeBar = YES;
    [self.search sizeToFit];
	[self.search setShowsCancelButton:NO animated:YES];
	[self.navigationController setNavigationBarHidden: NO animated:YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.search.text = @"";
    [self.search endEditing: YES];

	[self searchBar:self.search textDidChange: self.search.text];
}

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)scope {
	if(scope == 0) {
		qsort(self.table.deck->words, NARRAY_SIZE(self.table.deck->words), sizeof(Dictionary::Word *), usageCompare);
	}
	else {
		qsort(self.table.deck->words, NARRAY_SIZE(self.table.deck->words), sizeof(Dictionary::Word *), strongsCompare);
	}

    [self.table.tableView reloadData];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)text {
    NARRAY_FREE(self.table.results);

    if([text length] == 0) {
        [self.table.tableView reloadData];
        [self.table.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
    else {
    	self.table.results = NARRAY_NEW(Dictionary::Word *);

		const char *text_utf = [text stringByFoldingWithOptions:NSDiacriticInsensitiveSearch | NSCaseInsensitiveSearch locale:[NSLocale currentLocale]].UTF8String;
		uint64 count = strlen(text_utf);

    	FOR(i, word, self.table.deck->words) {
	    	if(strncmp((*word)->search_string, text_utf, count) == 0) {
	    		NARRAY_PUSH(self.table.results, *word);
	    	}
    	}
        [self.table.tableView reloadData];
    }

}

-(void)finishedWordSelect {
    // Resort if necessary.
    if(self.search.selectedScopeButtonIndex == 1) {
        qsort(self.table.deck->words, NARRAY_SIZE(self.table.deck->words), sizeof(Dictionary::Word *), strongsCompare);
    }

    [self.table.tableView reloadData];
}

-(void)addWords:(UIBarButtonItem *)sender {
    self.word_select.table.deck = self.table.deck;
    [self.navigationController pushViewController:self.word_select animated:YES];
}

@end

int32 usageCompare(const void *a, const void *b) {
	Dictionary::Word *word_a = *((Dictionary::Word **) a);
	Dictionary::Word *word_b = *((Dictionary::Word **) b);

	return ((int32)word_b->count) - ((int32)word_a->count);
}

int32 strongsCompare(const void *a, const void *b) {
	Dictionary::Word *word_a = *((Dictionary::Word **) a);
	Dictionary::Word *word_b = *((Dictionary::Word **) b);

	return ((int32)word_a->strongs) - ((int32)word_b->strongs);
}
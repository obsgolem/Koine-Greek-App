//
//  DictContainerVC.m
//  Koine Greek Flash Cards
//
//  Created by Josiah Bills on 2/23/17.
//  Copyright © 2017 Josiah Bills. All rights reserved.
//

#import "AppDelegate.h"
#import "DictContainerVC.h"

#import "DictTableVC.h"

#include "../dictionary/dictionary.h"

@interface DictContainerVC ()

@end

@implementation DictContainerVC

- (id) init {
	if(self == [super init]) {
	    self.table = [[DictTableVC alloc] init];
	}
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	if(self.search.selectedScopeButtonIndex != DELEGATE.current_sort_order) {
		DELEGATE.current_sort_order = self.search.selectedScopeButtonIndex;
        [DELEGATE reloadWordSort];
	}
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
    DELEGATE.current_sort_order = self.search.selectedScopeButtonIndex;
    [DELEGATE reloadWordSort];

    [self.table.tableView reloadData];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)text {
    FOR(i, word, self.table.results) {
        Dictionary::clearWordMemory(word);
    }

    NARRAY_FREE(self.table.results);

    if([text length] == 0) {
        [self.table.tableView reloadData];
        [self.table.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
    else {
        self.table.results = Dictionary::getWordSearch(DELEGATE.dict, [text stringByFoldingWithOptions:NSDiacriticInsensitiveSearch | NSCaseInsensitiveSearch locale:[NSLocale currentLocale]].UTF8String);
        [self.table.tableView reloadData];
    }

}

@end

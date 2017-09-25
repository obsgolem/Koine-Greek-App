//
//  ViewController.m
//  Koine Greek Flash Cards
//
//  Created by Josiah Bills on 11/30/16.
//  Copyright © 2016 Josiah Bills. All rights reserved.
//

#import "TopVC.h"
#import "DeckTable/DeckTableVC.h"
#import "DictTable/DictTableVC.h"
#import "DictTable/DictContainerVC.h"

@interface TopVC ()

@end

@implementation TopVC


- (void)viewDidLoad {
    [super viewDidLoad];

	self.deck_table = [[DeckTableVC alloc] init];
    self.deck_table.navigationItem.title = @"Decks";
    self.deck_table.navigationItem.leftBarButtonItem = self.editButtonItem;
    self.deck_table.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addDeckButtonPushed:)];

    self.dict_table = [[DictContainerVC alloc] init];
    self.dict_table.navigationItem.title = @"Dictionary";

    self.deck_nav = [[UINavigationController alloc] initWithRootViewController:self.deck_table];
    self.deck_nav.tabBarItem.title = @"Decks";
    self.dict_nav = [[UINavigationController alloc] initWithRootViewController:self.dict_table];
    self.dict_nav.tabBarItem.title = @"Dictionary";

    self.tab = [[UITabBarController alloc] init];
    self.tab.viewControllers = @[self.deck_nav, self.dict_nav];

    [self addChildViewController:self.tab];

    [self.view addSubview:self.tab.view];
}

-(void)addDeckButtonPushed:(UIBarButtonItem *)sender {
	UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Add" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Add" style:UIAlertActionStyleDefault handler:
    	^(UIAlertAction *action){
			[self.deck_table addDeck:alert.textFields.firstObject.text];
		}]];
	[alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler: nil]];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Enter Name:";
    }];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)setEditing:(BOOL)editing animated:(BOOL)animated {
	[super setEditing:editing animated:animated];

	[self.deck_table setEditing:editing animated:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end

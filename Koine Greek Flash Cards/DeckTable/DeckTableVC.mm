//
// DeckTableVC.m
//  Koine Greek Flash Cards
//
//  Created by Josiah Bills on 11/30/16.
//  Copyright © 2016 Josiah Bills. All rights reserved.
//

#import "../AppDelegate.h"
#import "DeckTableVC.h"
#import "../DeckDetails/DeckDetailsTableVC.h"

#import "../deck.h"

@interface DeckTableVC ()

@end

@implementation DeckTableVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.cellLayoutMarginsFollowReadableWidth = false;

    self.decks = loadAllDecks(DELEGATE.dict);

    self.deck_details = [[DeckDetailsTableVC alloc] initWithStyle:UITableViewStyleGrouped];
    self.deck_details.hidesBottomBarWhenPushed = YES;

    self.tableView.allowsSelectionDuringEditing = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return NARRAY_SIZE(self.decks);
}

- (NSString *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"reuse";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];

    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }

    // cell.selectionStyle = UITableViewCellSelectionStyleNone;

    Deck *deck = &NARRAYITEM(self.decks, indexPath.row);
    cell.textLabel.text = [NSString stringWithUTF8String: deck->name];

    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        removeDeck(DELEGATE.dict, &NARRAYITEM(self.decks, indexPath.row));
        FOR_FROM(i, indexPath.row+1, deck, self.decks) {
            deck->sort_index--;
            updateDeck(DELEGATE.dict, deck);
        }
        NARRAY_REMOVE(self.decks, indexPath.row);

        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    Deck temp = NARRAYITEM(self.decks, fromIndexPath.row);

    Deck shift = NARRAYITEM(self.decks, toIndexPath.row);

    uint64 last = NARRAY_SIZE(self.decks)-1;
    if(fromIndexPath.row < toIndexPath.row) {
        NARRAY_REMOVE(self.decks, fromIndexPath.row);
        NARRAY_PUSH(self.decks, {});
    }
    else {
        last = fromIndexPath.row;
    }

    temp.sort_index = toIndexPath.row;
    NARRAYITEM(self.decks, toIndexPath.row) = temp;
    updateDeck(DELEGATE.dict, &temp);

    for(uint64 i = toIndexPath.row; i < last; ++i) {
        shift.sort_index = i+1;
        updateDeck(DELEGATE.dict, &shift);

        Deck shift_temp = NARRAYITEM(self.decks, i+1);
        NARRAYITEM(self.decks, i+1) = shift;
        shift = shift_temp;
    }

}

- (void)addDeck:(NSString *) name {
    Deck deck = createDeck(DELEGATE.dict, name, NARRAY_SIZE(self.decks));
    NARRAY_PUSH(self.decks, deck);
    [self.tableView reloadData];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];

    if(self.editing) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Rename" message:@"" preferredStyle:UIAlertControllerStyleAlert];

        [alert addAction:[UIAlertAction actionWithTitle:@"Rename" style:UIAlertActionStyleDefault handler:
            ^(UIAlertAction *action){
                NSString *name = alert.textFields.firstObject.text;
                Deck *deck = (&NARRAYITEM(self.decks, indexPath.row));

                if(deck->handle_memory) {
                    free(deck->name);
                }

                deck->name = allocAndCopyString(name.UTF8String);
                updateDeck(DELEGATE.dict, deck);

                [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];

            }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler: nil]];
        [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.text = [self.tableView cellForRowAtIndexPath:indexPath].textLabel.text;
            textField.placeholder = @"Enter Name:";
        }];

        [self presentViewController:alert animated:YES completion:nil];
    }
    else {
        self.deck_details.deck = &NARRAYITEM(self.decks, indexPath.row);
        loadAllWordData(DELEGATE.dict, self.deck_details.deck);
        getDictWordsForDeck(DELEGATE.dict, self.deck_details.deck, DELEGATE.words);
        [self.navigationController pushViewController:self.deck_details animated:YES];
    }
}

@end

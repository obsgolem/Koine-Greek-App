//
//  OptionTableVC.m
//  Koine Greek Flash Cards
//
//  Created by Josiah Bills on 2/11/17.
//  Copyright © 2017 Josiah Bills. All rights reserved.
//

#import "OptionTableVC.h"

@interface OptionTableVC ()

@end

@implementation OptionTableVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.cellLayoutMarginsFollowReadableWidth = false;
    self.tableView.allowsMultipleSelection = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self.tableView reloadData];

    NSIndexPath *path = [NSIndexPath indexPathForRow:self.default_cell inSection:0];
    [self.tableView selectRowAtIndexPath: path animated: NO scrollPosition:UITableViewScrollPositionNone];
    [self tableView:self.tableView didSelectRowAtIndexPath: path];
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
    return self.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"option";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];

    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }

    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.textLabel.text = [NSString stringWithUTF8String: self.data[indexPath.row]];

    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath   *)indexPath
{
    [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;
}

@end

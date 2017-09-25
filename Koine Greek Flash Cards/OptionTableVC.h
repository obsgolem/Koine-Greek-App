//
//  OptionTableVC.h
//  Koine Greek Flash Cards
//
//  Created by Josiah Bills on 2/11/17.
//  Copyright © 2017 Josiah Bills. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OptionTableVC : UITableViewController
	@property (nonatomic) const char **data;
	@property (nonatomic) uint64_t count;
	@property (nonatomic) uint64_t default_cell;
@end

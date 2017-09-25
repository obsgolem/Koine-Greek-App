//
//  WordCell.h
//  Koine Greek Flash Cards
//
//  Created by Josiah Bills on 2/18/17.
//  Copyright © 2017 Josiah Bills. All rights reserved.
//

#import <UIKit/UIKit.h>

namespace Dictionary {
	struct Word;
};

@interface WordCell : UITableViewCell
	@property (nonatomic) Dictionary::Word *word;
@end

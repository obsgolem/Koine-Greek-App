//
//  FinishedWordSelectProtocol.h
//  Koine Greek Flash Cards
//
//  Created by Josiah Bills on 2/14/17.
//  Copyright © 2017 Josiah Bills. All rights reserved.
//

#pragma once

namespace Dictionary {
	struct Word;
}

struct WordData;

@protocol FinishedWordSelectProtocol <NSObject>
@required
-(void)finishedWordSelect;

@end

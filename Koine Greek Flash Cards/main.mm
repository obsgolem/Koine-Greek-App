//
//  main.m
//  Koine Greek Flash Cards
//
//  Created by Josiah Bills on 11/30/16.
//  Copyright © 2016 Josiah Bills. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

int main(int argc, char * argv[]) {
	[[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithObjects:@"el", nil] forKey:@"AppleLanguages"];

	[[NSUserDefaults standardUserDefaults] synchronize];
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}

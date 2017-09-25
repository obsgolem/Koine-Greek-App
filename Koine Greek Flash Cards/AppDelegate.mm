//
//  AppDelegate.m
//  Koine Greek Flash Cards
//
//  Created by Josiah Bills on 11/30/16.
//  Copyright © 2016 Josiah Bills. All rights reserved.
//

#import "AppDelegate.h"

#import "WordDetailsTableVC.h"

#define COMMON_IMPL
#define DICT_IMPL
#import "dictionary/dictionary.h"
#undef DICT_IMPL
#undef COMMON_IMPL

#define DECK_IMPL
#import "deck.h"
#undef DECK_IMPL


@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,  NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];

    NSString *dict_path = [documentsDirectory stringByAppendingPathComponent:@"dictionary.db"];
    if(![[NSFileManager defaultManager] fileExistsAtPath:dict_path]) {
        [[NSFileManager defaultManager] copyItemAtPath:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"dictionary.db"] toPath:dict_path error:nil];
    }

    self.dict = Dictionary::open(dict_path.UTF8String);

    self.current_sort_order = 0;
    self.words = Dictionary::getAllWordsByCount(self.dict);

    self.details = [[WordDetailsTableVC alloc] initWithStyle:UITableViewStyleGrouped];
    self.details.hidesBottomBarWhenPushed = YES;

    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
}

-(void) reloadWordSort {
    FOR(i, word, self.words) {
        Dictionary::clearWordMemory(word);
    }
    NARRAY_FREE(self.words);

    if(self.current_sort_order == 0) {
        self.words = Dictionary::getAllWordsByCount(self.dict);
    }
    else {
        self.words = Dictionary::getAllWordsByStrongs(self.dict);
    }
}

@end

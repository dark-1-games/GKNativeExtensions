//
//  GKNativePlayerLitener.m
//  GKNativeExtensions
//
//  Created by Kristijan Trajkovski on 3/13/19.
//  Copyright © 2019 Kristijan Trajkovski. All rights reserved.
//

#import "CommonTypes.h"
#import "GKNativePlayerListener.h"
#import "SaveDataCache.h"

@implementation GKNativePlayerListener

- (id) initWithCallbacks:(savedGamesCallbackFunc)conflictCb modifiedCallback:(savedGameCallbackFunc)modifiedCb
{
    self = [super init];
    if(self) {
        conflictCallback = conflictCb;
        modifiedSaveCallback = modifiedCb;
    }
    return self;
}

- (void)player:(GKPlayer *)player hasConflictingSavedGames:(NSArray<GKSavedGame *> *)savedGames {
    SaveDataCache* sdc = [SaveDataCache sharedManager];
    [sdc setConflictingSaves:savedGames];
    SavedGameData * savedGameData = new SavedGameData[savedGames.count];
    
    NSLog(@"Conflicting saved games");
    
    for(int i=0; i < savedGames.count; ++i) {
        savedGameData[i] = SavedGameData(savedGames[i]);
    }
    conflictCallback(savedGameData, savedGames.count);
}

- (void)player:(GKPlayer *)player didModifySavedGame:(nonnull GKSavedGame *)savedGame {
    SavedGameData * savedGameData = new SavedGameData(savedGame);
    
    NSLog(@"Modified saved game");
    modifiedSaveCallback(savedGameData);
}
@end

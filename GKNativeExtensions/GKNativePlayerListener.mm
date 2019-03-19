//
//  GKNativePlayerLitener.m
//  GKNativeExtensions
//
//  Created by Kristijan Trajkovski on 3/13/19.
//  Copyright © 2019 Kristijan Trajkovski. All rights reserved.
//

#import "CommonTypes.h"
#import "GKNativePlayerListener.h"

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
    conflictingSaves = savedGames;
    SavedGameData * savedGameData = new SavedGameData[savedGames.count];
    
    for(int i=0; i < savedGames.count; ++i) {
        savedGameData[i] = SavedGameData(savedGames[i]);
    }
    conflictCallback(savedGameData, savedGames.count);
}

- (void)player:(GKPlayer *)player didModifySavedGame:(nonnull GKSavedGame *)savedGame {
    SavedGameData * savedGameData = new SavedGameData(savedGame);
    modifiedSaveCallback(savedGameData);
}
@end

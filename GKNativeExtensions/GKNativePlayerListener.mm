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

- (id) initWithCallback:(savedGamesCallbackFunc) cb
{
    self = [super init];
    if(self) {
        conflictCallback = cb;
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
@end

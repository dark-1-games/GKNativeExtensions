//
//  GKNativePlayerLitener.h
//  GKNativeExtensions
//
//  Created by Kristijan Trajkovski on 3/13/19.
//  Copyright © 2019 Kristijan Trajkovski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>
#import "CommonTypes.h"

NS_ASSUME_NONNULL_BEGIN

@interface GKNativePlayerListener : NSObject <GKLocalPlayerListener>
{
    savedGamesCallbackFunc conflictCallback;
}

- (id) initWithCallback:(savedGamesCallbackFunc) cb;
- (void) player:(GKPlayer *)player hasConflictingSavedGames:(NSArray<GKSavedGame *> *)savedGames;
@end

NS_ASSUME_NONNULL_END

//
//  GKNativeExtensions.mm
//  GKNativeExtension
//
//  Created by Kristijan Trajkovski on 2/22/19.
//  Copyright © 2019 Kristijan Trajkovski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GKNativeExtensions.h"
#import <GameKit/GameKit.h>

extern "C" {
    void _TestCall() {
        
    }
    
    void _GKLoadGame(byteArrayPtrCallbackFunc callback) {
        [GKLocalPlayer.localPlayer fetchSavedGamesWithCompletionHandler:^(NSArray<GKSavedGame *> * _Nullable savedGames, NSError * _Nullable error) {
            if(error == NULL || savedGames == nil || savedGames.count == 0) {
                callback(NULL);
            } else {
                [savedGames[0] loadDataWithCompletionHandler:^(NSData * _Nullable data, NSError * _Nullable error) {
                    if(error == NULL) {
                        callback(NULL);
                    } else {
                        callback(data);
                    }
                }];
            }
        }];
    }
    
    void _GKSaveGame(NSData * saveData, NSString * saveName, boolCallbackFunc callback) {
        [GKLocalPlayer.localPlayer saveGameData:saveData withName:saveName completionHandler:^(GKSavedGame * _Nullable savedGame, NSError * _Nullable error) {
            if(callback != NULL) {
                if(error != NULL) {
                    callback(false);
                } else {
                    callback(true);
                }
            }
        }];
    }
}

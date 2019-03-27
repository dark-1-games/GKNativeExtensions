/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/. */

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>
#import "GKNativeExtensions.h"
#import "CommonTypes.h"
#import "GKNativePlayerListener.h"

extern "C" {
    void _GKInit(savedGamesCallbackFunc conflictCallback, savedGameCallbackFunc modifiedCallback){
        GKNativePlayerListener* npl = [[GKNativePlayerListener alloc] initWithCallbacks:conflictCallback modifiedCallback:modifiedCallback];
        [GKLocalPlayer.localPlayer registerListener:npl];
    }
    
    void _GKResolveConflictingSaves(SavedGameData * sgData, int sgLength, const char* saveArray, int length, boolCallbackFunc callback) {
        NSData *saveData = [NSData dataWithBytes:saveArray length:length];
        //Conflicting games may either be in the cached saved games or cached conflicted games :/
        NSMutableArray<GKSavedGame *> * mergedArrays = [[NSMutableArray alloc] init];
        if(conflictingSaves != NULL) {
            [mergedArrays addObjectsFromArray:conflictingSaves];
        }
        if(cachedSaves != NULL) {
            [mergedArrays addObjectsFromArray:cachedSaves];
        }
        
        //Find saved games in the merged array
        NSMutableArray<GKSavedGame *> * locatedEntries = [[NSMutableArray alloc] init];
        for(int i=0; i<sgLength; ++i) {
            for(int j=0; j<mergedArrays.count; ++j) {
                if(sgData[i].compareToSavedGame(mergedArrays[j])) {
                    [locatedEntries addObject:mergedArrays[j]];
                    break;
                }
            }
        }
        
        
        [GKLocalPlayer.localPlayer resolveConflictingSavedGames:locatedEntries withData:saveData completionHandler:^(NSArray<GKSavedGame *> * _Nullable savedGames, NSError * _Nullable error) {
            if(error != NULL){
                NSLog(@"%@",[error localizedDescription]);
                callback(false);
                return;
            }
            callback(true);
        }];
    }
    
    void _GKFetchSavedGames(savedGamesCallbackFunc callback) {
        [GKLocalPlayer.localPlayer fetchSavedGamesWithCompletionHandler:^(NSArray<GKSavedGame *> * _Nullable savedGames, NSError * _Nullable error) {
            cachedSaves = savedGames;
            
            if(error != NULL){
                NSLog(@"%@",[error localizedDescription]);
                callback(NULL, 0);
                return;
            }
            
            SavedGameData * savedGameData = new SavedGameData[savedGames.count];
            
            for(int i=0; i < savedGames.count; ++i) {
                savedGameData[i] = SavedGameData (savedGames[i]);
            }
            
            callback(savedGameData, savedGames.count);
            delete[] savedGameData;
        }];
    }
    
    void _GKDeleteGame(char * saveName, boolCallbackFunc callback){
        NSString* saveNameStr = [NSString stringWithUTF8String:saveName];
        [GKLocalPlayer.localPlayer deleteSavedGamesWithName:saveNameStr completionHandler:^(NSError * _Nullable error) {
            if(error != NULL){
                NSLog(@"%@",[error localizedDescription]);
                callback(false);
                return;
            }
            callback(true);
        }];
    }

    void _GKSaveGame(const char* saveArray, int length, const char* saveName, savedGameCallbackFunc callback) {
        NSData *saveData = [NSData dataWithBytes:saveArray length:length];
        NSString* saveNameStr = [NSString stringWithUTF8String:saveName];
        
        NSLog(@"Trying to save under name %@", saveNameStr);
        
        [GKLocalPlayer.localPlayer saveGameData:saveData withName:saveNameStr completionHandler:^(GKSavedGame * _Nullable savedGame, NSError * _Nullable error) {
            if(callback != NULL) {
                if(error != NULL) {
                    NSLog(@"%@",[error localizedDescription]);
                    callback(NULL);
                } else {
                    SavedGameData * savedGameData = new SavedGameData(savedGame);
                    callback(savedGameData);
                }
            }
        }];
    }
    
    void _GKLoadGame(SavedGameData * savedGameData, byteArrayPtrCallbackFunc callback) {
        [GKLocalPlayer.localPlayer fetchSavedGamesWithCompletionHandler:^(NSArray<GKSavedGame *> * _Nullable savedGames, NSError * _Nullable error) {
            
            GKSavedGame * savedGame = NULL;
            for(int i=0; i<savedGames.count; ++i) {
                if(savedGameData->compareToSavedGame(savedGames[i])) {
                    savedGame = savedGames[i];
                }
            }
            
            if(error != NULL || savedGame == NULL) {
                if(error != NULL) {
                    NSLog(@"%@", error.localizedDescription);
                }
                callback(NULL, 0);
            } else {
                [savedGame loadDataWithCompletionHandler:^(NSData * _Nullable data, NSError * _Nullable error) {
                    if(error != NULL) {
                        NSLog(@"%@",[error localizedDescription]);
                        callback(NULL, 0);
                    } else {
                        callback((char*)[data bytes], (int)[data length]);
                    }
                }];
            }
        }];
    }
}

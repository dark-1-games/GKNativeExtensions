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
    
    void _GKResolveConflictingSaves(SavedGameData * sgData, int sgLength, char* saveArray, int length, boolCallbackFunc callback) {
        NSMutableArray<GKSavedGame*>* conflictingGames = [NSMutableArray new];
        
        for(int i=0; i<length; ++i) {
            NSDate* date = [[NSDate alloc] initWithTimeIntervalSince1970:sgData[i].modificationDate];
            NSString* name = [NSString stringWithUTF8String:sgData[i].name];
            NSString* deviceName = [NSString stringWithUTF8String:sgData[i].deviceName];
            
            for(int j=0; j<conflictingGames.count; ++j) {
                if([conflictingGames[j].modificationDate isEqualToDate:date] && [conflictingGames[j].deviceName isEqualToString:deviceName] &&
                   [conflictingGames[i].name  isEqualToString:name]) {
                    
                    [conflictingGames addObject:conflictingGames[j]];
                }
            }
        }
        NSData *saveData = [NSData dataWithBytes:saveArray length:length];
        
        [GKLocalPlayer.localPlayer resolveConflictingSavedGames:conflictingGames withData:saveData completionHandler:^(NSArray<GKSavedGame *> * _Nullable savedGames, NSError * _Nullable error) {
            if(error != NULL){
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
                callback(false);
                return;
            }
            callback(true);
        }];
    }
    
    void _GKSaveGame(char* saveArray, int length, char * saveName, savedGameCallbackFunc callback) {
        NSData *saveData = [NSData dataWithBytes:saveArray length:length];
        NSString* saveNameStr = [NSString stringWithUTF8String:saveName];
        
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

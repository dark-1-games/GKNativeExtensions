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
    
    void _GKDeleteGame(boolCallbackFunc callback, char* saveName){
        NSString* saveNameStr = [NSString stringWithUTF8String:saveName];
        NSLog(@"Deleting  = %@", saveNameStr);
        [GKLocalPlayer.localPlayer deleteSavedGamesWithName:saveNameStr completionHandler:^(NSError * _Nullable error) {
            if(error != NULL){
                callback(false);
                return;
            }
            callback(true);
        }];
    }
    
    void _GKFetchSavedGames(saveGamesCallbackFunc callback) {
        [GKLocalPlayer.localPlayer fetchSavedGamesWithCompletionHandler:^(NSArray<GKSavedGame *> * _Nullable savedGames, NSError * _Nullable error) {
            
            if(error != NULL){
                callback(NULL, 0);
                return;
            }
            
            SavedGameData * savedGameData = new SavedGameData[savedGames.count];
            
            for(int i=0; i < savedGames.count; ++i) {
                NSString* deviceNameStr = savedGames[i].deviceName;
                NSString* nameStr = savedGames[i].name;
                
                const char* deviceName = deviceNameStr.UTF8String;
                const char* name =  nameStr.UTF8String;
                double modificationDate = savedGames[i].modificationDate.timeIntervalSince1970;
                
                savedGameData[i] = SavedGameData {
                    .deviceName = deviceName,
                    .name = name,
                    .modificationDate = modificationDate
                };
            }
            callback(savedGameData, savedGames.count);
            delete[] savedGameData;
        }];
    }
    
    void _GKLoadGame(byteArrayPtrCallbackFunc callback, char* saveName) {
        NSString* name = [NSString stringWithUTF8String:saveName];
        NSLog(@"Loading  = %@", name);
        
        [GKLocalPlayer.localPlayer fetchSavedGamesWithCompletionHandler:^(NSArray<GKSavedGame *> * _Nullable savedGames, NSError * _Nullable error) {
            
            GKSavedGame * savedGame = NULL;
            for(int i=0; i<savedGames.count; ++i) {
                if([savedGames[i].name isEqualToString:name]) {
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
    
    void _GKSaveGame(char* saveArray, int length, char* saveName, boolCallbackFunc callback) {
        NSData *saveData = [NSData dataWithBytes:saveArray length:length];
        NSString* saveNameStr = [NSString stringWithUTF8String:saveName];
        NSLog(@"Saving  = %@", saveNameStr);
        [GKLocalPlayer.localPlayer saveGameData:saveData withName:saveNameStr completionHandler:^(GKSavedGame * _Nullable savedGame, NSError * _Nullable error) {
            if(callback != NULL) {
                if(error != NULL) {
                    NSLog(@"%@",[error localizedDescription]);
                    callback(false);
                } else {
                    callback(true);
                }
            }
        }];
    }
}

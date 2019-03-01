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
    
    void _GKFetchSavedGames(byteArrayPtrCallbackFunc callback) {
        [GKLocalPlayer.localPlayer fetchSavedGamesWithCompletionHandler:^(NSArray<GKSavedGame *> * _Nullable savedGames, NSError * _Nullable error) {
            
            for(int i=0; i < savedGames.count; ++i) {
                
            }
            
            NSString* deviceNameStr = savedGames[0].deviceName;
            NSString* nameStr = savedGames[0].name;
            
            const char* deviceName = deviceNameStr.UTF8String;
            const char* name =  [nameStr UTF8String];
            double modificationDate = savedGames[0].modificationDate.timeIntervalSince1970;
            struct SavedGameData savedGameData = {
                .deviceName = deviceName,
                .name = name,
                .modificationDate = modificationDate
            };
        }];
    }
    
    void _GKLoadGame(byteArrayPtrCallbackFunc callback) {
        [GKLocalPlayer.localPlayer fetchSavedGamesWithCompletionHandler:^(NSArray<GKSavedGame *> * _Nullable savedGames, NSError * _Nullable error) {
            if(error != nil || savedGames == nil || savedGames.count == 0) {
                if(error != nil) {
                    NSLog(@"%@",[error localizedDescription]);
                }
                callback(NULL, 0);
            } else {
                NSLog(@"Loading first saved game");
                [savedGames[0] loadDataWithCompletionHandler:^(NSData * _Nullable data, NSError * _Nullable error) {
                    NSLog(@"Done loading");
                    if(error != nil) {
                        NSLog(@"%@",[error localizedDescription]);
                        callback(NULL, 0);
                    } else {
                        NSString *myString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                        NSLog(@"loaded data length = %lu", (unsigned long)[myString length]);
                        NSLog(@"loaded data = %@", myString);
                        callback((char*)[data bytes], (int)[data length]);
                    }
                }];
            }
        }];
    }
    
    void _GKSaveGame(char* saveArray, int length, char* saveName, boolCallbackFunc callback) {
        NSData *saveData = [NSData dataWithBytes:saveArray length:length];
        NSString* saveNameStr = [NSString stringWithCString:saveName encoding:NSUTF8StringEncoding];
        NSLog(@"data = %@", [NSString stringWithCString:saveArray encoding:NSUTF8StringEncoding]);
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

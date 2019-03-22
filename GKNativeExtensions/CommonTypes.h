//
//  CommonTypes.h
//  GKNativeExtensions
//
//  Created by Kristijan Trajkovski on 3/13/19.
//  Copyright © 2019 Kristijan Trajkovski. All rights reserved.
//
#import <GameKit/GameKit.h>

#ifndef CommonTypes_h
#define CommonTypes_h

#ifdef __cplusplus
extern "C" {
#endif
    class SavedGameData {
    public: 
        const char* _Nullable deviceName;
        const char* _Nullable name;
        double modificationDate;
        
        SavedGameData(){}
        
        SavedGameData(GKSavedGame* _Nullable savedGame) {
            const char* deviceName = savedGame.deviceName.UTF8String;
            const char* name =  savedGame.name.UTF8String;
            double modificationDate = savedGame.modificationDate.timeIntervalSince1970;
            
            this->deviceName = deviceName;
            this->name = name;
            this->modificationDate = modificationDate;
        }
        
        bool compareToSavedGame(GKSavedGame* _Nullable savedGame) {
            NSString* deviceNameStr = [NSString stringWithUTF8String:this->deviceName];
            NSString* nameStr = [NSString stringWithUTF8String:this->name];
            
            return [savedGame.deviceName isEqualToString:deviceNameStr] &&
            [savedGame.name isEqualToString:nameStr] &&
            fabs([savedGame.modificationDate timeIntervalSince1970] - this->modificationDate) < 0.01f;
        }
    };
    
    typedef void (*byteArrayPtrCallbackFunc)(char * _Nullable, int length);
    typedef void (*boolCallbackFunc)(const bool);
    typedef void (*savedGamesCallbackFunc)(SavedGameData * _Nullable games, int length);
    typedef void (*savedGameCallbackFunc)(SavedGameData * _Nullable game);
    
    
    NSArray<GKSavedGame *> * _Nullable conflictingSaves;
    NSArray<GKSavedGame *> * _Nullable cachedSaves;
#ifdef __cplusplus
}
#endif

#endif /* CommonTypes_h */

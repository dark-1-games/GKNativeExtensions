//
//  GKNativeExtensions.h
//  GKNativeExtensions
//
//  Created by Kristijan Trajkovski on 2/22/19.
//  Copyright © 2019 Kristijan Trajkovski. All rights reserved.
//
#import <Foundation/Foundation.h>

#ifdef __cplusplus
extern "C" {
#endif
    struct SavedGameData {
        const char* deviceName;
        const char* name;
        const double modificationDate;
    };
    
    typedef void (*byteArrayPtrCallbackFunc)(char * _Nullable, int length);
    typedef void (*boolCallbackFunc)(const bool);
    typedef void (*saveGameArrayPtrCallbackFunc)(const SavedGameData ** savedGameDataArray);
#ifdef __cplusplus
}
#endif

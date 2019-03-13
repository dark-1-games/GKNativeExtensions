/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/. */

#import <Foundation/Foundation.h>

#ifdef __cplusplus
extern "C" {
#endif
    typedef struct SavedGameData {
        const char* _Nullable deviceName;
        const char* _Nullable name;
        double modificationDate;
    } SavedGameData;
    
    typedef void (*byteArrayPtrCallbackFunc)(char * _Nullable, int length);
    typedef void (*boolCallbackFunc)(const bool);
    typedef void (*saveGamesCallbackFunc)(SavedGameData * _Nullable games, unsigned long length);
#ifdef __cplusplus
}
#endif

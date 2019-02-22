//
//  GKNativeExtensions.h
//  GKNativeExtensions
//
//  Created by Kristijan Trajkovski on 2/22/19.
//  Copyright © 2019 Kristijan Trajkovski. All rights reserved.
//
#import <Foundation/Foundation.h>

#ifndef GKNativeExtensions_h
#define GKNativeExtensions_h

extern "C" {
    typedef void (*byteArrayPtrCallbackFunc)(NSData * _Nullable);
    typedef void (*boolCallbackFunc)(const bool);
}

#endif /* GKNativeExtensions_h */

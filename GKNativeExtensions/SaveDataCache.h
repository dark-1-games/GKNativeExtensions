#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>

@interface SaveDataCache : NSObject {
    NSArray<GKSavedGame *> * _Nullable conflictingSaves;
}

@property (nonatomic, retain) NSArray<GKSavedGame *> * _Nullable conflictingSaves;

+ (id _Nonnull)sharedManager;
- (NSArray<GKSavedGame *> * _Nullable) getConflictingSaves;
- (void) setConflictingSaves:(NSArray<GKSavedGame *> * _Nullable) saves;

@end

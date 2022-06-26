#import "SaveDataCache.h"

@implementation SaveDataCache

@synthesize conflictingSaves;

#pragma mark Singleton Methods

+ (id)sharedManager {
    static SaveDataCache *sharedSaveDataCache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedSaveDataCache = [[self alloc] init];
    });
    return sharedSaveDataCache;
}

- (NSArray<GKSavedGame *> *) getConflictingSaves {
    return conflictingSaves;
}
- (void) setConflictingSaves:(NSArray<GKSavedGame *> *) saves {
    conflictingSaves = saves;
}

- (id)init {
  if (self = [super init]) {
      conflictingSaves = [[NSArray alloc] init];
  }
  return self;
}

- (void)dealloc {
  // Should never be called, but just here for clarity really.
}

@end

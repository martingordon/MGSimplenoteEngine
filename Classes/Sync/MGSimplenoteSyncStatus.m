//
//  MGSimplenoteSyncStatus.m
//  MGSimpleNoteEngine
//
//  Created by Martin Gordon on 4/12/10.
//  Copyright 2010 Martin Gordon. All rights reserved.
//

#import "MGSimplenoteSyncStatus.h"

static MGSimplenoteSyncStatus *notStartedStatus = nil;
static MGSimplenoteSyncStatus *completeStatus = nil;
static MGSimplenoteSyncStatus *completeWithErrorsStatus = nil;
static MGSimplenoteSyncStatus *inProgressStatus = nil;
static MGSimplenoteSyncStatus *inProgressWithErrorsStatus = nil;
static MGSimplenoteSyncStatus *failedStatus = nil;


@implementation MGSimplenoteSyncStatus

+ (MGSimplenoteSyncStatus *)notStartedStatus {
	@synchronized(self) {
        if (notStartedStatus == nil)
			notStartedStatus = [[self alloc] init];
    }
    return notStartedStatus;
	
}

+ (MGSimplenoteSyncStatus *)completeStatus {
	@synchronized(self) {
        if (completeStatus == nil)
			completeStatus = [[self alloc] init];
    }
    return completeStatus;
}

+ (MGSimplenoteSyncStatus *)completeWithErrorsStatus {
	@synchronized(self) {
        if (completeWithErrorsStatus == nil)
			completeWithErrorsStatus = [[self alloc] init];
    }
    return completeWithErrorsStatus;
}

+ (MGSimplenoteSyncStatus *)inProgressStatus {
	@synchronized(self) {
        if (inProgressStatus == nil)
			inProgressStatus = [[self alloc] init];
    }
    return inProgressStatus;
}

+ (MGSimplenoteSyncStatus *)inProgressWithErrorsStatus {
	@synchronized(self) {
        if (inProgressWithErrorsStatus == nil)
			inProgressWithErrorsStatus = [[self alloc] init];
    }
    return inProgressWithErrorsStatus;
}

+ (MGSimplenoteSyncStatus *)failedStatus {
	@synchronized(self) {
        if (failedStatus == nil)
			failedStatus = [[self alloc] init];
    }
    return failedStatus;
}

@end

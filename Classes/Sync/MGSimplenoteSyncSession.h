//
//  MGSimplenoteSyncSession.h
//  MGSimpleNoteEngine
//
//  Created by Martin Gordon on 4/12/10.
//  Copyright 2010 Martin Gordon. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MGSimplenoteSyncStatus;

@interface MGSimplenoteSyncSession : NSObject {
	NSInteger completedItems, failedItems, totalItems;
	NSMutableArray *errors;
	MGSimplenoteSyncStatus *status;
}

@property (nonatomic, assign) NSInteger completedItems, failedItems, totalItems;
@property (nonatomic, readonly) NSMutableArray *errors;
@property (nonatomic, retain) MGSimplenoteSyncStatus *status;

- (void)beginWithTotalItemCount:(NSInteger)count;
- (void)replaceCompleted:(NSInteger)completeCount failed:(NSInteger)failedCount;
- (void)updateCompleted:(NSInteger)completeCount failed:(NSInteger)failedCount;
- (void)complete;

- (BOOL)allItemsComplete;

@end

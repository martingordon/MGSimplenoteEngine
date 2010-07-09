//
//  MGSimplenoteController.h
//  Split Pea
//
//  Created by Martin Gordon on 4/11/10.
//  Copyright 2010 Martin Gordon. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MGSimplenoteLogin, MGSimplenoteIndex, MGSimplenoteSyncSession;

@interface MGSimplenoteController : NSObject {
	MGSimplenoteLogin *login;
	MGSimplenoteIndex *index;
	NSMutableArray *notes;
	
	MGSimplenoteSyncSession *session;
	BOOL indexPullError;
	NSInteger notePullErrorCount;
}

@property (nonatomic, readonly) MGSimplenoteLogin *login;
@property (nonatomic, readonly) MGSimplenoteIndex *index;
@property (nonatomic, readonly) NSMutableArray *notes;

@property (nonatomic, readonly) MGSimplenoteSyncSession *session;

+ (MGSimplenoteController *)sharedController;

- (void)syncWithTarget:(id)target begin:(SEL)begin complete:(SEL)complete progress:(SEL)progress inBackground:(BOOL)background;
- (void)prepareSync;

// Subclasses should override. Default implementation does nothing.
- (void)performSync;
- (void)finishSync;

@end

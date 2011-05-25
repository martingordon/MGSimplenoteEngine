//
//  MGSimplenoteIndex.h
//  MGSimplenoteEngine
//
//  Created by Martin Gordon on 4/5/10.
//  Copyright 2010 Martin Gordon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MGSNObject.h"

/**
 * This class represents the Simplenote index, which contains basic information about the user's notes.
 *
 * Sample usage:
 *   // Assume the app has a valid auth token.
 *   MGSimplenoteIndex *index = [[MGSimplenoteIndex alloc] init];
 *   [index addObserver:self forSelector:@selector(pullFromRemote) 
 *	            success:@selector(showSuccessMsg:) failure:@selector(showFailureMsg:)];
 *   [index pullFromRemote];
 *   ...
 *   - (void)showSuccessMsg:(NSNotification *)notif {
 *       NSArray *contents = [[[notif userInfo] valueForKey:@"MGSimplenoteIndex"] contents];
 *       // Process notes, etc.
 *   }
 */
@interface MGSimplenoteIndex : MGSNObject {
	NSArray *contents, *fullContents;

    NSInteger length;
    NSString *mark;
    NSDate *since;
}

/**
 * The retrieved array of MGSimplenote objects. The array does not contain "full" notes, it contains
 * notes populated with only the data available from the index.
 */
@property (nonatomic, readonly) NSArray *contents;

// Retrieves the full note object for contents array.
// NOT YET IMPLEMENTED
@property (nonatomic, readonly) NSArray *fullContents;

// The number of records to request from the index. Parameter will be ignored if set to <= 0.
@property (nonatomic) NSInteger length;

// When the index is pulled, the mark will be auto-populated from the response (nil if no mark).
@property (nonatomic, copy) NSString *mark;

@property (nonatomic, retain) NSDate *since;

// Retrieves the index from the Simplenote server.
- (void)pullFromRemote;

@end

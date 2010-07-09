//
//  MGSimplenoteSyncStatus.h
//  MGSimpleNoteEngine
//
//  Created by Martin Gordon on 4/12/10.
//  Copyright 2010 Martin Gordon. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MGSimplenoteSyncStatus : NSObject {

}

+ (MGSimplenoteSyncStatus *)notStartedStatus;

+ (MGSimplenoteSyncStatus *)completeStatus;
+ (MGSimplenoteSyncStatus *)completeWithErrorsStatus;

+ (MGSimplenoteSyncStatus *)inProgressStatus;
+ (MGSimplenoteSyncStatus *)inProgressWithErrorsStatus;

+ (MGSimplenoteSyncStatus *)failedStatus;

@end

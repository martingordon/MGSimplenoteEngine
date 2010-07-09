//
//  MGSimplenoteController.m
//  Split Pea
//
//  Created by Martin Gordon on 4/11/10.
//  Copyright 2010 Martin Gordon. All rights reserved.
//

#import "MGSimplenoteController.h"
#import "MGSimplenoteIndex.h"
#import "MGSimplenoteLogin.h"
#import "MGSimplenoteSyncSession.h"
#import "MGSimplenoteSyncStatus.h"
#import "MGSimplenote.h"

static MGSimplenoteController *sharedInstance = nil;

@implementation MGSimplenoteController

@synthesize login, index, notes, session;

+ (MGSimplenoteController *)sharedController {
    @synchronized(self) {
        if (sharedInstance == nil)
			sharedInstance = [[self alloc] init];
    }
    return sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [super allocWithZone:zone];
            return sharedInstance;  // assignment and return on first allocation
        }
    }
    return nil; // on subsequent allocation attempts return nil
}

- (id)init {
	if (self = [super init]) {
		indexPullError = NO;
		notePullErrorCount = 0;
		session = [[MGSimplenoteSyncSession alloc] init];
	}
	return self;
}

- (void)dealloc {
	[index release];
	[login release];
	[notes release];
	[session release];
	
	[super dealloc];
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (id)retain {
    return self;
}

- (unsigned)retainCount {
    return UINT_MAX;  // denotes an object that cannot be released
}

- (void)release {
    //do nothing
}

- (id)autorelease {
    return self;
}

- (MGSimplenoteIndex *)index {
	if (index == nil) {
		index = [[MGSimplenoteIndex alloc] init];
	}
	return index;
}

- (MGSimplenoteLogin *)login {
	if (login == nil) {
		login = [[MGSimplenoteLogin alloc] init];
	}
	return login;
}

- (NSMutableArray *)notes {
	if (notes == nil) {
		notes = [[NSMutableArray alloc] init];
	}
	return notes;
}

- (void)syncWithTarget:(id)target begin:(SEL)begin complete:(SEL)complete progress:(SEL)progress inBackground:(BOOL)background {
	[[NSNotificationCenter defaultCenter] addObserver:target selector:begin name:@"MGSimplenoteSyncBeginNotification" object:self];
	[[NSNotificationCenter defaultCenter] addObserver:target selector:complete name:@"MGSimplenoteSyncCompleteNotification" object:self];
	[[NSNotificationCenter defaultCenter] addObserver:target selector:progress name:@"MGSimplenoteSyncProgressNotification" object:self];

	if (session.status != [MGSimplenoteSyncStatus notStartedStatus]) {
		[session release];
		session = [[MGSimplenoteSyncSession alloc] init];
	}
	[self prepareSync];
}


- (void)prepareSync {
	[self.session beginWithTotalItemCount:0];
	
	[self.login addObserver:self forSelector:@selector(login) success:@selector(loginSucceeded:) failure:@selector(loginFailed:)];
	[self.login login];
}


- (void)performSync {
	[self.session updateCompleted:0 failed:0];
	[self finishSync];
}


- (void)finishSync {
	[self.session complete];
}


- (void)loginSucceeded:(NSNotification *)notif {
	[self.index addObserver:self forSelector:@selector(pullFromRemote) success:@selector(indexPullSucceeded:) failure:@selector(indexPullFailed:)];
	[self.index pullFromRemote];
}

- (void)loginFailed:(NSNotification *)notif {
	NSLog(@"Login failed: %@", [[notif userInfo] objectForKey:@"error"]);
}

- (void)indexPullSucceeded:(NSNotification *)notif {
	indexPullError = NO;

	for (MGSimplenote *note in [self.index contents]) {
		[note addObserver:self forSelector:@selector(pullFromRemote) success:@selector(notePullSucceeded:) failure:@selector(notePullFailed:)];
		[note pullFromRemote];
	}
}

- (void)indexPullFailed:(NSNotification *)notif {
	indexPullError = YES;
}


- (void)notePullSucceeded:(NSNotification *)notif {
	[self.notes addObject:[[notif userInfo] objectForKey:@"MGSimplenote"]];
	
	if ([[self.index contents] count] == ([self.notes count] + notePullErrorCount)) {
		[self performSync];
	}
}


- (void)notePullFailed:(NSNotification *)notif {
	notePullErrorCount++;
}



@end

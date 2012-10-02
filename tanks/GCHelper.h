//
//  GCHelper.h
//  tanks
//
//  Created by Cullen O'Neill on 2/12/12.
//  Copyright (c) 2012 Lot18. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>

@protocol GCHelperDelegate 
- (void)matchStarted;
- (void)matchEnded;
- (void)match:(GKMatch *)match didReceiveData:(NSData *)data 
   fromPlayer:(NSString *)playerID;
- (void)inviteReceived;
@end


@interface GCHelper : NSObject <GKMatchmakerViewControllerDelegate, GKMatchDelegate> {
    BOOL gameCenterAvailable;
    BOOL userAuthenticated;
    UIViewController *presentingViewController;
    GKMatch *match;
    BOOL matchStarted;
    id <GCHelperDelegate> delegate;
    NSMutableDictionary *playersDict;
    GKInvite *pendingInvite;
    NSArray *pendingPlayersToInvite;
    NSError *lastError;
}

@property (assign, readonly) BOOL gameCenterAvailable;
@property (retain) UIViewController *presentingViewController;
@property (retain) GKMatch *match;
@property (assign) id <GCHelperDelegate> delegate;
@property (retain) NSMutableDictionary *playersDict;
@property (retain) GKInvite *pendingInvite;
@property (retain) NSArray *pendingPlayersToInvite;
@property (nonatomic, readonly) NSError* lastError;

+ (GCHelper *)sharedInstance;
- (void)authenticateLocalUser;
- (void)findMatchWithMinPlayers:(int)minPlayers maxPlayers:(int)maxPlayers 
                 viewController:(UIViewController *)viewController 
                       delegate:(id<GCHelperDelegate>)theDelegate;
- (void)sendDataToAllPlayers:(void*)data length:(NSUInteger)length;



@end

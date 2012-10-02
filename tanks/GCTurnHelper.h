//
//  GCTurnHelper.h
//  tanks
//
//  Created by Cullen O'Neill on 5/12/12.
//  Copyright (c) 2012 Lot18. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>


@protocol GCTurnBasedMatchHelperDelegate
- (void)enterNewGame:(GKTurnBasedMatch *)match;
- (void)layoutMatch:(GKTurnBasedMatch *)match;
- (void)takeTurn:(GKTurnBasedMatch *)match;
- (void)recieveEndGame:(GKTurnBasedMatch *)match;
- (void)sendNotice:(NSString *)notice 
          forMatch:(GKTurnBasedMatch *)match;
@end


@interface GCTurnHelper : NSObject <GKTurnBasedMatchmakerViewControllerDelegate , GKTurnBasedEventHandlerDelegate> {
    BOOL gameCenterAvailable;
    BOOL userAuthenticated;
    UIViewController *presentingViewController;
    
    GKTurnBasedMatch *currentMatch;
    
    id <GCTurnBasedMatchHelperDelegate> delegate;
}

@property (nonatomic, retain) 
id <GCTurnBasedMatchHelperDelegate> delegate;
@property (assign, readonly) BOOL gameCenterAvailable;
@property (nonatomic, retain) GKTurnBasedMatch *currentMatch;


+ (GCTurnHelper *)sharedInstance;
- (void)authenticateLocalUser;
- (void)authenticationChanged;
- (void)findMatchWithMinPlayers:(int)minPlayers maxPlayers:(int)maxPlayers viewController:(UIViewController *)viewController;


@end

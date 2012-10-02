//
//  GCTurnHelper.m
//  tanks
//
//  Created by Cullen O'Neill on 5/12/12.
//  Copyright (c) 2012 Lot18. All rights reserved.
//

#import "GCTurnHelper.h"

@implementation GCTurnHelper

@synthesize currentMatch;
@synthesize delegate;

#pragma mark Initialization

static GCTurnHelper *sharedHelper = nil;
+ (GCTurnHelper *) sharedInstance {
    if (!sharedHelper) {
        sharedHelper = [[GCTurnHelper alloc] init];
    }
    return sharedHelper;
}

- (BOOL)isGameCenterAvailable {
    // check for presence of GKLocalPlayer API
    Class gcClass = (NSClassFromString(@"GKLocalPlayer"));
    
    // check if the device is running iOS 4.1 or later
    NSString *reqSysVer = @"4.1";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    BOOL osVersionSupported = ([currSysVer compare:reqSysVer     
                                           options:NSNumericSearch] != NSOrderedAscending);
    
    return (gcClass && osVersionSupported);
}


- (id)init {
    if ((self = [super init])) {
        gameCenterAvailable = [self isGameCenterAvailable];
        if (gameCenterAvailable) {
            NSNotificationCenter *nc = 
            [NSNotificationCenter defaultCenter];
            [nc addObserver:self 
                   selector:@selector(authenticationChanged) 
                       name:GKPlayerAuthenticationDidChangeNotificationName 
                     object:nil];
        }
    }
    return self;
}

- (void)authenticationChanged {    
    
    if ([GKLocalPlayer localPlayer].isAuthenticated && 
        !userAuthenticated) {
        NSLog(@"Authentication changed: player authenticated.");
        userAuthenticated = TRUE;           
    } else if (![GKLocalPlayer localPlayer].isAuthenticated && 
               userAuthenticated) {
        NSLog(@"Authentication changed: player not authenticated");
        userAuthenticated = FALSE;
    }
    
}

#pragma mark User functions

- (void)authenticateLocalUser { 
    
    if (!gameCenterAvailable) return;
    
    void (^setGKEventHandlerDelegate)(NSError *) = ^ (NSError *error)
    {
        GKTurnBasedEventHandler *ev = 
        [GKTurnBasedEventHandler sharedTurnBasedEventHandler];
        ev.delegate = self;
    };
    
    NSLog(@"Authenticating local user...");
    if ([GKLocalPlayer localPlayer].authenticated == NO) {     
        [[GKLocalPlayer localPlayer] 
         authenticateWithCompletionHandler:^(NSError * error) {
             [GKTurnBasedMatch loadMatchesWithCompletionHandler:
              ^(NSArray *matches, NSError *error){
                  for (GKTurnBasedMatch *match in matches) { 
                      NSLog(@"%@", match.matchID); 
                      [match removeWithCompletionHandler:^(NSError *error){
                          NSLog(@"%@", error);}]; 
                  }}];
         }];        
    } else {
        NSLog(@"Already authenticated!");
    }
}

- (void)findMatchWithMinPlayers:(int)minPlayers 
                     maxPlayers:(int)maxPlayers 
                 viewController:(UIViewController *)viewController {
    if (!gameCenterAvailable) return;               
    
    presentingViewController = viewController;
    
    GKMatchRequest *request = [[GKMatchRequest alloc] init]; 
    request.minPlayers = minPlayers;     
    request.maxPlayers = maxPlayers;
    
    GKTurnBasedMatchmakerViewController *mmvc = 
    [[GKTurnBasedMatchmakerViewController alloc] 
     initWithMatchRequest:request];    
    mmvc.turnBasedMatchmakerDelegate = self;
    mmvc.showExistingMatches = YES;
    
    [presentingViewController presentModalViewController:mmvc 
                                                animated:YES];
}

#pragma mark GKTurnBasedMatchmakerViewControllerDelegate

-(void)turnBasedMatchmakerViewController: 
(GKTurnBasedMatchmakerViewController *)viewController 
                            didFindMatch:(GKTurnBasedMatch *)match {
    [presentingViewController 
     dismissModalViewControllerAnimated:YES];
    self.currentMatch = match;
    [match loadMatchDataWithCompletionHandler:^(NSData *matchData, NSError *error)
    {
        /*NSDictionary *myDict = [NSPropertyListSerialization
                                propertyListFromData:match.matchData mutabilityOption:NSPropertyListImmutable format:nil
                                errorDescription:nil];*/
        //[gameDictionary addEntriesFromDictionary: myDict];
        //[self populateExistingGameBoard];
        if (error) {
            NSLog(@"loadMatchData - %@", [error localizedDescription]);
        }
    }];
    
    GKTurnBasedParticipant *firstParticipant = 
    [match.participants objectAtIndex:0];
    for (int i = 0; i < [match.participants count]; i++) {
        GKTurnBasedParticipant *part = [match.participants objectAtIndex:i];
        NSLog(@"player %d:%@",i,part.playerID);
    }
    
    if (firstParticipant.lastTurnDate == NULL) {
        // It's a new game!
        NSLog(@"new game started");
        [delegate enterNewGame:match];
        
        if ([firstParticipant.playerID isEqualToString:[GKLocalPlayer localPlayer].playerID]) {
            // It's your turn!
            NSLog(@"it's your turn");
            [delegate takeTurn:match];
        } else {
            // It's not your turn, just display the game state.
            [delegate layoutMatch:match];
            NSLog(@"it's your opponent's turn");
        }  
    } else {
        if ([match.currentParticipant.playerID 
             isEqualToString:[GKLocalPlayer localPlayer].playerID]) {
            // It's your turn!
            NSLog(@"it's your turn");
            [delegate takeTurn:match];
        } else {
            // It's not your turn, just display the game state.
            [delegate layoutMatch:match];
            NSLog(@"it's your opponent's turn");
        }        
    }
    
    NSLog(@"match found");
}

-(void)turnBasedMatchmakerViewControllerWasCancelled: 
(GKTurnBasedMatchmakerViewController *)viewController {
    [presentingViewController 
     dismissModalViewControllerAnimated:YES];
    NSLog(@"has cancelled");
}

-(void)turnBasedMatchmakerViewController: 
(GKTurnBasedMatchmakerViewController *)viewController 
                        didFailWithError:(NSError *)error {
    [presentingViewController 
     dismissModalViewControllerAnimated:YES];
    NSLog(@"Error finding match: %@", error.localizedDescription);
}

-(void)turnBasedMatchmakerViewController: 
(GKTurnBasedMatchmakerViewController *)viewController 
                      playerQuitForMatch:(GKTurnBasedMatch *)match {
    NSUInteger currentIndex = 
    [match.participants indexOfObject:match.currentParticipant];
    GKTurnBasedParticipant *part;
    
    for (int i = 0; i < [match.participants count]; i++) {
        part = [match.participants objectAtIndex:
                (currentIndex + 1 + i) % match.participants.count];
        if (part.matchOutcome != GKTurnBasedMatchOutcomeQuit) {
            break;
        } 
    }
    NSLog(@"playerquitforMatch, %@, %@", 
          match, match.currentParticipant);
    [match participantQuitInTurnWithOutcome:
     GKTurnBasedMatchOutcomeQuit nextParticipant:part 
                                  matchData:match.matchData completionHandler:nil];
}

- (void)sendTurnWithData:(NSDictionary *)data {
    GKTurnBasedMatch *currentMatch = 
    [[GCTurnHelper sharedInstance] currentMatch];
    
    NSData *dataToSend = [NSKeyedArchiver archivedDataWithRootObject:data];
    NSUInteger currentIndex = [currentMatch.participants 
                               indexOfObject:currentMatch.currentParticipant];
    GKTurnBasedParticipant *nextParticipant;
    
    NSUInteger nextIndex = (currentIndex + 1) % 
    [currentMatch.participants count];
    nextParticipant = [currentMatch.participants objectAtIndex:nextIndex];
    
    for (int i = 0; i < [currentMatch.participants count]; i++) {
        nextParticipant = [currentMatch.participants 
                           objectAtIndex:((currentIndex + 1 + i) % 
                                          [currentMatch.participants count ])];
        if (nextParticipant.matchOutcome != GKTurnBasedMatchOutcomeQuit) {
            NSLog(@"isnt' quit %@", nextParticipant);
            break;
        } else {
            NSLog(@"nex part %@", nextParticipant);
        }
    }
    
    if ([dataToSend length] > 1000000) {
        for (GKTurnBasedParticipant *part in currentMatch.participants) {
            part.matchOutcome = GKTurnBasedMatchOutcomeTied;
        }
        [currentMatch endMatchInTurnWithMatchData:dataToSend 
                                completionHandler:^(NSError *error) {
                                    if (error) {
                                        NSLog(@"%@", error);
                                    }
                                }];
        //statusLabel.text = @"Game has ended";
    } else {
        
        [currentMatch endTurnWithNextParticipant:nextParticipant 
                                       matchData:dataToSend completionHandler:^(NSError *error) {
                                           if (error) {
                                               NSLog(@"%@", error);
                                               //statusLabel.text = @"Oops, there was a problem.  Try that again.";
                                           } else {
                                               //statusLabel.text = @"Your turn is over.";
                                               //textInputField.enabled = NO;
                                           }
                                       }];
    }
    NSLog(@"Send Turn, %@, %@", dataToSend, nextParticipant);
    
}

- (void)sendTurn:(id)sender {
    GKTurnBasedMatch *currentMatch = 
    [[GCTurnHelper sharedInstance] currentMatch];
    NSString *newStoryString;
    if (/*[textInputField.text length]*/1 > 250) {
        //newStoryString = [textInputField.text substringToIndex:249];
    } else {
        //newStoryString = textInputField.text;
    }
    
    NSString *sendString = [NSString stringWithFormat:@"%@", 
                            /*mainTextController.text,*/ newStoryString];
    NSData *data = [sendString dataUsingEncoding:NSUTF8StringEncoding ];
    //mainTextController.text = sendString;
    
    NSUInteger currentIndex = [currentMatch.participants 
                               indexOfObject:currentMatch.currentParticipant];
    GKTurnBasedParticipant *nextParticipant;
    
    NSUInteger nextIndex = (currentIndex + 1) % 
    [currentMatch.participants count];
    nextParticipant = [currentMatch.participants objectAtIndex:nextIndex];
    
    for (int i = 0; i < [currentMatch.participants count]; i++) {
        nextParticipant = [currentMatch.participants 
                           objectAtIndex:((currentIndex + 1 + i) % 
                                          [currentMatch.participants count ])];
        if (nextParticipant.matchOutcome != GKTurnBasedMatchOutcomeQuit) {
            NSLog(@"isnt' quit %@", nextParticipant);
            break;
        } else {
            NSLog(@"nex part %@", nextParticipant);
        }
    }
    
    if ([data length] > 3800) {
        for (GKTurnBasedParticipant *part in currentMatch.participants) {
            part.matchOutcome = GKTurnBasedMatchOutcomeTied;
        }
        [currentMatch endMatchInTurnWithMatchData:data 
                                completionHandler:^(NSError *error) {
                                    if (error) {
                                        NSLog(@"%@", error);
                                    }
                                }];
        //statusLabel.text = @"Game has ended";
    } else {
        
        [currentMatch endTurnWithNextParticipant:nextParticipant 
                                       matchData:data completionHandler:^(NSError *error) {
                                           if (error) {
                                               NSLog(@"%@", error);
                                               //statusLabel.text = @"Oops, there was a problem.  Try that again.";
                                           } else {
                                               //statusLabel.text = @"Your turn is over.";
                                               //textInputField.enabled = NO;
                                           }
                                       }];
    }
    NSLog(@"Send Turn, %@, %@", data, nextParticipant);
    //textInputField.text = @"";
    //characterCountLabel.text = @"250";
    //characterCountLabel.textColor = [UIColor blackColor];
}
#pragma mark GKTurnBasedEventHandlerDelegate

-(void)handleInviteFromGameCenter:(NSArray *)playersToInvite {
    [presentingViewController 
     dismissModalViewControllerAnimated:YES];
    GKMatchRequest *request = 
    [[[GKMatchRequest alloc] init] autorelease]; 
    request.playersToInvite = playersToInvite;
    request.maxPlayers = 12;
    request.minPlayers = 2;
    GKTurnBasedMatchmakerViewController *viewController =
    [[GKTurnBasedMatchmakerViewController alloc] 
     initWithMatchRequest:request];
    viewController.showExistingMatches = NO;
    viewController.turnBasedMatchmakerDelegate = self;
    [presentingViewController 
     presentModalViewController:viewController animated:YES];
}

-(void)handleTurnEventForMatch:(GKTurnBasedMatch *)match {
    NSLog(@"Turn has happened");
    if ([match.matchID isEqualToString:currentMatch.matchID]) {
        if ([match.currentParticipant.playerID 
             isEqualToString:[GKLocalPlayer localPlayer].playerID]) {
            // it's the current match and it's our turn now
            self.currentMatch = match;
            [delegate takeTurn:match];
        } else {
            // it's the current match, but it's someone else's turn
            self.currentMatch = match;
            [delegate layoutMatch:match];
        }
    } else {
        if ([match.currentParticipant.playerID 
             isEqualToString:[GKLocalPlayer localPlayer].playerID]) {
            // it's not the current match and it's our turn now
            [delegate sendNotice:@"It's your turn for another match" 
                        forMatch:match];
        } else {
            // it's the not current match, and it's someone else's 
            // turn
        }
    }
}

-(void)handleMatchEnded:(GKTurnBasedMatch *)match {
    NSLog(@"Game has ended");
    if ([match.matchID isEqualToString:currentMatch.matchID]) {
        [delegate recieveEndGame:match];
    } else {
        [delegate sendNotice:@"Another Game Ended!" forMatch:match];
    }
}

-(void)sendNotice:(NSString *)notice forMatch:
(GKTurnBasedMatch *)match {
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:
                       @"Another game needs your attention!" message:notice 
                                                delegate:self cancelButtonTitle:@"Sweet!" 
                                       otherButtonTitles:nil];
    [av show];
    [av release];
}





@end

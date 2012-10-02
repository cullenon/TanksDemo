//
//  GKTurnBasedMatchmakerViewController-LandscapeOnly.m
//  tanks
//
//  Created by Cullen O'Neill on 5/12/12.
//  Copyright (c) 2012 Lot18. All rights reserved.
//

#import "GKTurnBasedMatchmakerViewController-LandscapeOnly.h"

@implementation GKTurnBasedMatchmakerViewController (LandscapeOnly)

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation { 
    return ( UIInterfaceOrientationIsLandscape( interfaceOrientation ) );
}

@end
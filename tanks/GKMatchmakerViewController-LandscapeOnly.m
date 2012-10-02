//
//  GKMatchmakerViewController-LandscapeOnly.m
//  tanks
//
//  Created by Cullen O'Neill on 2/13/12.
//  Copyright (c) 2012 Lot18. All rights reserved.
//

#import "GKMatchmakerViewController-LandscapeOnly.h"

@implementation GKMatchmakerViewController (LandscapeOnly)

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation { 
    return ( UIInterfaceOrientationIsLandscape( interfaceOrientation ) );
}

@end
//
//  AI_Sprites.h
//  tanks
//
//  Created by Cullen O'Neill on 1/14/12.
//  Copyright 2012 Lot18. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@class Tanks;
@class HelloWorldLayer;
@class WayPoint;

@interface AI_Sprites : Tanks {
    double _timeForNextShot;
    
    
    //NSMutableArray *_targetsToRemove;
    
    //CGPoint _nearTarget;
}




+ (id)redInfantryOnLayer:(HelloWorldLayer *)layer;
+ (id)blueInfantryOnLayer:(HelloWorldLayer *)layer;
+ (id)redTankOnLayer:(HelloWorldLayer *)layer;
+ (id)blueTankOnLayer:(HelloWorldLayer *)layer;
+ (id)redTurretOnLayer:(HelloWorldLayer *)layer;
+ (id)blueTurretOnLayer:(HelloWorldLayer *)layer;


- (WayPoint *)getCurrentWaypoint;
- (WayPoint *)getNextWaypoint;

- (void)addTargetToArray:(Tanks *)target;

@end

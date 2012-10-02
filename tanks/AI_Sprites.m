//
//  AI_Sprites.m
//  tanks
//
//  Created by Cullen O'Neill on 1/14/12.
//  Copyright 2012 Lot18. All rights reserved.
//

#import "Tanks.h"
#import "AI_Sprites.h"
#import "HelloWorldLayer.h"
#import "WayPoint.h"
#import "DataModel.h"
#import "DeviceSettings.h"


@implementation AI_Sprites




+ (id)redInfantryOnLayer:(HelloWorldLayer *)layer {
    Tanks *red = [[[Tanks alloc] initWithLayer:layer type:1 team:2] autorelease];
    return red;
}

+ (id)blueInfantryOnLayer:(HelloWorldLayer *)layer {
    Tanks *blue = [[[Tanks alloc] initWithLayer:layer type:1 team:1] autorelease];
    return blue;
}

+ (id)redTankOnLayer:(HelloWorldLayer *)layer {
    Tanks *red = [[[Tanks alloc] initWithLayer:layer type:2 team:2] autorelease];
    return red;
}

+ (id)blueTankOnLayer:(HelloWorldLayer *)layer {
    Tanks *blue = [[[Tanks alloc] initWithLayer:layer type:2 team:1] autorelease];
    return blue;
}

+ (id)redTurretOnLayer:(HelloWorldLayer *)layer {
    Tanks *red = [[[Tanks alloc] initWithLayer:layer type:3 team:2] autorelease];
    return red;
}

+ (id)blueTurretOnLayer:(HelloWorldLayer *)layer {
    Tanks *blue = [[[Tanks alloc] initWithLayer:layer type:3 team:1] autorelease];
    return blue;
}



- (WayPoint *)getCurrentWaypoint{
	
	DataModel *m = [DataModel getModel];
	
	WayPoint *waypoint = (WayPoint *) [m._waypoints objectAtIndex:self.curWaypoint];
	
	return waypoint;
}

- (WayPoint *)getNextWaypoint{
	
	DataModel *m = [DataModel getModel];
	int lastWaypoint = m._waypoints.count;
    
	self.curWaypoint++;
	
	if (self.curWaypoint > lastWaypoint)
		self.curWaypoint = lastWaypoint - 1;
	
	WayPoint *waypoint = (WayPoint *) [m._waypoints objectAtIndex:self.curWaypoint];
	
	return waypoint;
}


- (id)initWithLayer:(HelloWorldLayer *)layer type:(int)type team:(int)team {
    
    if ((self = [super initWithLayer:layer type:type team:team])) {
        [self schedule:@selector(move:) interval:0.5];
    }
    return self;
    
}


- (BOOL)shouldShoot {
    
    NSLog(@"count:%d",[self.targetsInRange count]);
    
    int _nearTargetDist = self.range*10 + 1;
    for (int i = 0; i < self.targetsInRange.count; i++) {
        CCSprite *target = [self.targetsInRange objectAtIndex:0];
        float _tarDist = ccpDistance(self.position, target.position);
        
        if (_tarDist < self.range) {
            if (_tarDist*10 < _nearTargetDist) {
                _nearTargetDist = _tarDist*10;
                _nearTarget = target.position;
                NSLog(@"nearest target:%d",_nearTargetDist);
            }
        } else {
            [self.targetsToRemove addObject:target];
        }
        
    }
    
    if (_nearTargetDist >= self.range*10 + 1) {
        return NO;
    } else {
        
        CGPoint _offset = ccpSub(_nearTarget, self.position);
        [self shootToward:_offset];
        
        double SECS_BETWEEN_SHOTS = 60/self.RPM;
        if (_timeSinceLastShot > SECS_BETWEEN_SHOTS) {        
            _timeSinceLastShot = 0;
            //CGPoint _offset = ccpSub(_layer.tank.position, self.position);
            //[self shootToward:_offset];
            
            NSLog(@"x:%f y:%f",_offset.x,_offset.y);
            return YES;        
        } else {
            
            return NO;
        }
        
        //NSLog(@"x:%f y:%f",_offset.x,_offset.y);
        
    }
    
    [self.targetsInRange removeObjectsInArray:self.targetsToRemove];
    
    
    //NSLog(@"x:%f y:%f",self.position.x,self.position.y);
    
    
    
    /*
    if (ccpDistance(self.position, _layer.tank.position) < self.range) {
        
        CGPoint _offset = ccpSub(_layer.tank.position, self.position);
        [self shootToward:_offset];
        
        double SECS_BETWEEN_SHOTS = 60/self.RPM;
        if (_timeSinceLastShot > SECS_BETWEEN_SHOTS) {        
            _timeSinceLastShot = 0;
            //CGPoint _offset = ccpSub(_layer.tank.position, self.position);
            //[self shootToward:_offset];
            
            NSLog(@"x:%f y:%f",_offset.x,_offset.y);
            return YES;        
        } else {
            
            return NO;
        }
        
        NSLog(@"x:%f y:%f",_offset.x,_offset.y);
        
        //[self shootToward:_layer.tank.position];
    } else {
        return NO;
    }//*/
    
    
    
    /*
     if (_timeSinceLastShot > _timeForNextShot) {        
     _timeSinceLastShot = 0;
     _timeForNextShot = (CCRANDOM_0_1() * 3) + 1;
     [self shootTowardPosition:_layer.tank.position];
     return YES;
     } else {
     return NO;
     }//*/
}

// From http://playtechs.blogspot.com/2007/03/raytracing-on-grid.html
- (BOOL)clearPathFromTileCoord:(CGPoint)start toTileCoord:(CGPoint)end
{
    int dx = abs(end.x - start.x);
    int dy = abs(end.y - start.y);
    int x = start.x;
    int y = start.y;
    int n = 1 + dx + dy;
    int x_inc = (end.x > start.x) ? 1 : -1;
    int y_inc = (end.y > start.y) ? 1 : -1;
    int error = dx - dy;
    dx *= 2;
    dy *= 2;
    
    for (; n > 0; --n)
    {
        if ([_layer isWallAtTileCoord:ccp(x, y)]) return FALSE;
        
        if (error > 0)
        {
            x += x_inc;
            error -= dy;
        }
        else
        {
            y += y_inc;
            error += dx;
        }
    }
    
    return TRUE;
}

- (void)calcNextMove {
    
    BOOL moveOK = NO;
    CGPoint start = [_layer tileCoordForPosition:self.position];
    CGPoint end;
    
    while (!moveOK) {
        
        end = start;
        end.x += CCRANDOM_MINUS1_1() * ((arc4random() % 10) + 3);
        end.y += CCRANDOM_MINUS1_1() * ((arc4random() % 10) + 3);
        
        moveOK = [self clearPathFromTileCoord:start toTileCoord:end];    
    }    
    
    CGPoint moveToward = [_layer positionForTileCoord:end];
    
    self.moving = YES;
    [self moveToward:moveToward];    
    
}

- (void)move:(ccTime)dt {
    
    if (self.moving && arc4random() % 3 != 0) return;    
    [self calcNextMove];
    
}


- (void)addTargetToArray:(Tanks *)target {
    
    if (!target) {
        return;
    }
    if (self.targetsInRange.count == 8) {
        return;
    } else if ([self.targetsInRange containsObject:target]) {
        return;
    } else {
        [self.targetsInRange addObject:target];
    }
    
}


- (void)didReachWP {
    _didReachWP = YES;
}


@end

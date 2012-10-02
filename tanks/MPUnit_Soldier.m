//
//  Unit_Soldier.m
//  tanks
//
//  Created by Cullen O'Neill on 5/11/12.
//  Copyright 2012 Lot18. All rights reserved.
//

#import "MPUnit_Soldier.h"
#import "TurnLayer.h"
#import "TileData.h"


@implementation MPUnit_Soldier

+(id)nodeWithTheGame:(TurnLayer *)_game tileDict:(NSMutableDictionary *)tileDict owner:(int)_owner {
    return [[[self alloc] initWithTheGame:_game tileDict:tileDict owner:_owner] autorelease];
}

-(id)initWithTheGame:(TurnLayer *)_game tileDict:(NSMutableDictionary *)tileDict owner:(int)_owner {
    if ((self=[super init])) {
        theGame = _game;
        owner= _owner;
        movementRange = 3;
        attackRange = 1;
        [self createSprite:tileDict];
        [theGame addChild:self z:3];
    }
    return self;
}

-(BOOL)canWalkOverTile:(TileData *)td {
    return YES;
}

@end

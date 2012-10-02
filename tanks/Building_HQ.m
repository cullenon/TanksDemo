//
//  Building_HQ.m
//  tanks
//
//  Created by Cullen O'Neill on 5/12/12.
//  Copyright 2012 Lot18. All rights reserved.
//

#import "Building_HQ.h"


@implementation Building_HQ

+(id)nodeWithTheGame:(TurnLayer *)_game tileDict:(NSMutableDictionary *)tileDict owner:(int)_owner {
    return [[[self alloc] initWithTheGame:_game tileDict:tileDict owner:_owner] autorelease];
}

-(id)initWithTheGame:(TurnLayer *)_game tileDict:(NSMutableDictionary *)tileDict owner:(int)_owner {
    if ((self=[super init])) {
        theGame = _game;
        owner= _owner;
        [self createSprite:tileDict];
        [theGame addChild:self z:1];
    }
    return self;
}

@end

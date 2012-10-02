//
//  TileData.m
//  tanks
//
//  Created by Cullen O'Neill on 5/11/12.
//  Copyright 2012 Lot18. All rights reserved.
//

#import "TileData.h"
#import "TurnLayer.h"


@implementation TileData

@synthesize parentTile,position,selectedForAttack,selectedForMovement,gScore,hScore,movementCost,tileType;

+ (id)nodeWithTheGame:(TurnLayer *)_game movementCost:(int)_movementCost position:(CGPoint)_position tileType:(NSString *)_tileType {
return [[[self alloc] initWithTheGame:_game movementCost:_movementCost position:_position tileType:_tileType] autorelease];
}

- (id)initWithTheGame:(TurnLayer *)_game movementCost:(int)_movementCost position:(CGPoint)_position tileType:(NSString *)_tileType {
if ((self=[super init])) {
    theGame = _game;
    selectedForMovement = NO;
    movementCost = _movementCost;
    tileType = _tileType;
    position = _position;
    parentTile = nil;
    [theGame addChild:self];
}
return self;
}

-(int)getGScore {
int parentCost = 0;
if (parentTile) {
    parentCost = [parentTile getGScore];
}
return movementCost + parentCost;

}

-(int)getGScoreForAttack {
int parentCost = 0;
if(parentTile) {
    parentCost = [parentTile getGScoreForAttack];
}
return 1 + parentCost;
}

-(int)fScore {
return self.gScore + self.hScore;
}

-(NSString *)description {
return [NSString stringWithFormat:@"%@  pos=[%.0f;%.0f]  g=%d  h=%d  f=%d", [super description], self.position.x, self.position.y, self.gScore, self.hScore, [self fScore]];
}

@end

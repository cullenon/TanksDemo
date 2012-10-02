//
//  TileData.h
//  tanks
//
//  Created by Cullen O'Neill on 5/11/12.
//  Copyright 2012 Lot18. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@class TurnLayer;

@interface TileData : CCNode {
    TurnLayer * theGame;
    BOOL selectedForMovement;
    BOOL selectedForAttack;
    int movementCost;
    CGPoint position;
    TileData * parentTile;
    int hScore;
    int gScore;
    int fScore;
    NSString * tileType;
}

@property (nonatomic,readwrite) CGPoint position;
@property (nonatomic,assign) TileData * parentTile;
@property (nonatomic,readwrite) int movementCost;
@property (nonatomic,readwrite) BOOL selectedForAttack;
@property (nonatomic,readwrite) BOOL selectedForMovement;
@property (nonatomic,readwrite) int hScore;
@property (nonatomic,readwrite) int gScore;
@property (nonatomic,assign) NSString * tileType;

+ (id)nodeWithTheGame:(TurnLayer *)_game movementCost:(int)_movementCost position:(CGPoint)_position tileType:(NSString *)_tileType;
- (id)initWithTheGame:(TurnLayer *)_game movementCost:(int)_movementCost position:(CGPoint)_position tileType:(NSString *)_tileType;
- (int)getGScore;
- (int)getGScoreForAttack;
- (int)fScore;

@end

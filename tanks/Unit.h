//
//  Unit.h
//  tanks
//
//  Created by Cullen O'Neill on 5/11/12.
//  Copyright 2012 Lot18. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "PublicEnums.h"

@class TurnLayer;
@class TileData;

@interface Unit : CCNode <CCTargetedTouchDelegate> {
    TurnLayer * theGame;
    CCSprite * mySprite;
    touchState state;
    int owner;
    BOOL hasRangedWeapon;
    BOOL moving;
    int movementRange;
    int attackRange;
    //TileData * tileDataBeforeMovement;
    int hp;
    CCLabelBMFont * hpLabel;
    NSMutableArray *spOpenSteps;
    NSMutableArray *spClosedSteps;
    NSMutableArray * movementPath;
    BOOL movedThisTurn;
    BOOL attackedThisTurn;
    BOOL selectingMovement;
    BOOL selectingAttack;
}

@property (nonatomic,assign)CCSprite * mySprite;
@property (nonatomic,readwrite) int owner;
@property (nonatomic,readwrite) BOOL hasRangedWeapon;
@property (nonatomic,readwrite) BOOL selectingMovement;
@property (nonatomic,readwrite) BOOL selectingAttack;
@property (readwrite) TileData *tileDataBeforeMovement;


+ (id)nodeWithTheGame:(TurnLayer *)_game tileDict:(NSMutableDictionary *)tileDict owner:(int)_owner;
- (void)createSprite:(NSMutableDictionary *)tileDict;
- (void)selectUnit;
- (void)unselectUnit;
- (void)unMarkPossibleMovement;
- (void)markPossibleAction:(int)action;
- (void)insertOrderedInOpenSteps:(TileData *)tile;
- (int)computeHScoreFromCoord:(CGPoint)fromCoord toCoord:(CGPoint)toCoord;
- (int)costToMoveFromTile:(TileData *)fromTile toAdjacentTile:(TileData *)toTile;
- (void)constructPathAndStartAnimationFromStep:(TileData *)tile;
- (void)popStepAndAnimate;
- (void)doMarkedMovement:(TileData *)targetTileData;
- (void)startTurn;
- (void)unMarkPossibleAttack;
- (void)doMarkedAttack:(TileData *)targetTileData;
- (void)attackedBy:(Unit *)attacker firstAttack:(BOOL)firstAttack;
- (void)dealDamage:(NSMutableDictionary *)damageData;
- (void)removeExplosion:(CCSprite *)e;

@end

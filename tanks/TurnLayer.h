//
//  TurnLayer.h
//  tanks
//
//  Created by Cullen O'Neill on 5/11/12.
//  Copyright 2012 Lot18. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@class HKTMXTiledMap;
@class HKTMXLayer;
@class TileData;
@class Unit;
@class Building;

@interface TurnLayer : CCLayer {
    
    CCTMXTiledMap *tileMap;
    CCTMXLayer *bgLayer;
    CCTMXLayer *objectLayer; 
    NSMutableArray * tileDataArray;
    NSMutableArray *p1Units;
    NSMutableArray *p2Units;
    int playerTurn;
    Unit *selectedUnit;
    CCMenu *actionsMenu;
    CCSprite *contextMenuBck;
    CCMenuItemImage *endTurnBtn;
    CCLabelBMFont *turnLabel;
    NSMutableArray *p1Buildings;
    NSMutableArray *p2Buildings;
    
}

@property (nonatomic, assign) NSMutableArray *tileDataArray;
@property (nonatomic, assign) NSMutableArray *p1Units;
@property (nonatomic, assign) NSMutableArray *p2Units;
@property (nonatomic, readwrite) int playerTurn;
@property (nonatomic, assign) Unit *selectedUnit;
@property (nonatomic, assign) CCMenu *actionsMenu;
@property (retain) NSMutableDictionary *mapData;

- (void)createTileMap;
- (int)spriteScale;
- (int)getTileHeightForRetina;
- (CGPoint)tileCoordForPosition:(CGPoint)position;
- (CGPoint)positionForTileCoord:(CGPoint)position;
- (NSMutableArray *)getTilesNextToTile:(CGPoint)tileCoord;
- (TileData *)getTileData:(CGPoint)tileCoord;
- (Unit *)otherUnitInTile:(TileData *)tile;
- (Unit *)otherEnemyUnitInTile:(TileData *)tile unitOwner:(int)owner;
- (BOOL)paintMovementTile:(TileData *)tData;
- (void)unPaintMovementTile:(TileData *)tileData;
- (void)selectUnit:(Unit *)unit;
- (void)unselectUnit;
- (void)showActionsMenu:(Unit *)unit canAttack:(BOOL)canAttack;
- (void)removeActionsMenu;
- (void)addMenu;
- (void)doEndTurn;
- (void)setPlayerTurnLabel;
- (void)showEndTurnTransition;
- (void)beginTurn;
- (void)removeLayer:(CCNode *)n;
- (void)activateUnits:(NSMutableArray *)units;
- (BOOL)checkAttackTile:(TileData *)tData unitOwner:(int)owner;
- (BOOL)paintAttackTile:(TileData *)tData;
- (void)unPaintAttackTiles;
- (void)unPaintAttackTile:(TileData *)tileData;
- (int)calculateDamageFrom:(Unit *)attacker onDefender:(Unit *)defender;
- (void)checkForMoreUnits;
- (void)showEndGameMessageWithWinner:(int)winningPlayer;
- (void)restartGame;
- (void)loadBuildings:(int)player;
- (Building *)buildingInTile:(TileData *)tile;

@end

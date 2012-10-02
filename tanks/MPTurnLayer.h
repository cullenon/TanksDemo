//
//  MPTurnLayer.h
//  tanks
//
//  Created by Cullen O'Neill on 5/12/12.
//  Copyright 2012 Lot18. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "GCTurnHelper.h"


@class HKTMXTiledMap;
@class HKTMXLayer;
@class TileData;
@class MPUnit;
@class Building;

@interface MPTurnLayer : CCLayer <GCTurnBasedMatchHelperDelegate> {
    
    CCTMXTiledMap *tileMap;
    CCTMXLayer *bgLayer;
    CCTMXLayer *objectLayer; 
    NSMutableArray * tileDataArray;
    NSMutableArray *p1Units;
    NSMutableArray *p2Units;
    int playerTurn;
    MPUnit *selectedUnit;
    CCMenu *actionsMenu;
    CCSprite *contextMenuBck;
    CCMenuItemImage *endTurnBtn;
    CCLabelBMFont *turnLabel;
    NSMutableArray *p1Buildings;
    NSMutableArray *p2Buildings;
    int _moveCounter;
    
}

@property (nonatomic, assign) NSMutableArray *tileDataArray;
@property (nonatomic, assign) NSMutableArray *p1Units;
@property (nonatomic, assign) NSMutableArray *p2Units;
@property (nonatomic, readwrite) int playerTurn;
@property (nonatomic, assign) MPUnit *selectedUnit;
@property (nonatomic, assign) CCMenu *actionsMenu;
@property (retain) NSMutableDictionary *mapData;
//@property (retain) NSMutableDictionary *playerUnits;
//@property (retain) NSMutableDictionary *playerBuildings;

- (void)createTileMap;
- (int)spriteScale;
- (int)getTileHeightForRetina;
- (CGPoint)tileCoordForPosition:(CGPoint)position;
- (CGPoint)positionForTileCoord:(CGPoint)position;
- (NSMutableArray *)getTilesNextToTile:(CGPoint)tileCoord;
- (TileData *)getTileData:(CGPoint)tileCoord;
- (MPUnit *)otherUnitInTile:(TileData *)tile;
- (MPUnit *)otherEnemyUnitInTile:(TileData *)tile unitOwner:(int)owner;
- (BOOL)paintMovementTile:(TileData *)tData;
- (void)unPaintMovementTile:(TileData *)tileData;
- (void)selectUnit:(MPUnit *)unit;
- (void)unselectUnit;
- (void)showActionsMenu:(MPUnit *)unit canAttack:(BOOL)canAttack;
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
- (int)calculateDamageFrom:(MPUnit *)attacker onDefender:(MPUnit *)defender;
- (void)checkForMoreUnits;
- (void)showEndGameMessageWithWinner:(int)winningPlayer;
- (void)restartGame;
- (void)loadBuildings:(int)player;
- (Building *)buildingInTile:(TileData *)tile;

@end

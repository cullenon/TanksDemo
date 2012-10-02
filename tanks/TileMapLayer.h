//
//  TileMapLayer.h
//  tanks
//
//  Created by Cullen O'Neill on 2/17/12.
//  Copyright 2012 Lot18. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "GCHelper.h"
#import "PublicEnums.h"

@class Tanks;
@class ProximityManager;
@class Bullet;
@class HKTMXTiledMap;
@class HKTMXLayer;
@class TankMob;
@class HeroTank;




// HelloWorldLayer
@interface TileMapLayer : CCLayer <GCHelperDelegate> {
    
    uint32_t ourRandom;   
    BOOL receivedRandom;
    BOOL isPlayer1;
    NSString *otherPlayerID;
    GameState gameState;
    
    BOOL _isReady;
    
    NSString * _mapKey;
    
    HKTMXTiledMap * _tileMap;
    HKTMXLayer * _bgLayer;
    HKTMXLayer * _treeLayer;
    //CCTMXTiledMap * _tileMap;
    //CCTMXLayer * _bgLayer;
    //CCTMXLayer * _treeLayer;
    //NSMutableArray * _enemyTanks;
    
    CCParticleSystemQuad * _explosion;
    CCParticleSystemQuad * _explosion2;
    BOOL _gameOver;
    CCSprite * _exit;
    
    CGPoint _moveOffset;
    CGPoint _shotOffset;
    
    int _troopCounter;
    
    BOOL _parsing;
    int _switch;
    
    int _playerCount;
    int _bBulTankCount;
    int _bBulTurCount;
    int _rBulTankCount;
    int _rBulTurCount;
    int _p1BulCount;
    int _p2BulCount;
    int _p3BulCount;
    int _p4BulCount;
    int _sBulCount;
    
    double _syncTimer;
    
    int _levelCounter;
        
}

@property (assign) int currentPlayerValue;
@property (retain) HeroTank * tank;
@property (retain) HeroTank * tank2;
//@property (retain) TankMob * tank;
@property (retain) CCSpriteBatchNode * batchNode;
@property (retain) NSMutableDictionary * blueMobs;
@property (retain) NSMutableDictionary * redMobs;
@property (retain) CCArray * actBlueMobs;
@property (retain) CCArray * actRedMobs;
@property (retain) HKTMXTiledMap * tileMap;
@property (retain) NSMutableDictionary * bullets;
@property (retain) ProximityManager * proxManager;
//@property (retain) NSDictionary * waypoints;
@property (retain) NSDictionary *testDict;
@property (assign) AbilityNumber abilityFlagTouch;

// returns a CCScene that contains the HelloWorldLayer as the only child

+(id)gameLayerWithKey:(NSString *)key numPlayers:(int)num;
-(id)initLayerWithKey:(NSString *)key numPlayers:(int)num;

+(id)gameLayerWithKey:(NSString *)key playerData:(NSDictionary *)data;
-(id)initLayerWithKey:(NSString *)key playerData:(NSDictionary *)data;

- (void)createBulletsForScenario:(GameType)gametype;
- (void)createP2Bullets;
- (void)createP3Bullets;
- (void)createP4Bullets;

- (float)tileMapHeight;
- (float)tileMapWidth;
- (BOOL)isValidPosition:(CGPoint)position;
- (BOOL)isValidTileCoord:(CGPoint)tileCoord;
- (CGPoint)tileCoordForPosition:(CGPoint)position;
- (CGPoint)positionForTileCoord:(CGPoint)tileCoord;
- (void)setViewpointCenter:(CGPoint) position;
- (BOOL)isProp:(NSString*)prop atTileCoord:(CGPoint)tileCoord forLayer:(HKTMXLayer *)layer;
- (BOOL)isProp:(NSString*)prop atPosition:(CGPoint)position forLayer:(HKTMXLayer *)layer;
- (BOOL)isWallAtTileCoord:(CGPoint)tileCoord;
- (BOOL)isWallAtPosition:(CGPoint)position;
- (BOOL)isWallAtRect:(CGRect)rect;
- (void)updateTankOffset;
- (void)updateTankShot;
- (void)setMove:(CGPoint)moveOff;
- (void)setShot:(CGPoint)shotOff;
- (void)startWave;



- (Bullet *)getBullet:(BulletType)type;
- (Bullet *)getBulletWithKey:(NSString *)key;
- (BOOL)intersectBetweenCircle1:(CGPoint)center1 rad1:(float)rad1 Circle2:(CGPoint)center2 rad2:(float)rad2;
- (void)mobDidGetHit:(Tanks *)tank Damage:(int)dmg;

- (void)sendGameBegin;
- (void)sendSpawnEnemy:(CGPoint)location type:(EnemyType)type;
- (void)sendP1Move:(CGPoint)location;
- (void)sendP2Move:(CGPoint)location;
- (void)sendP3Move:(CGPoint)location;
- (void)sendP4Move:(CGPoint)location;
- (void)syncCurTank;

- (void)sendP1Shoot:(CGPoint)location;
- (void)sendP2Shoot:(CGPoint)location;

- (void)sendP1Ability:(CGPoint)location Num:(AbilityNumber)num;
- (void)sendP2Ability:(CGPoint)location Num:(AbilityNumber)num;
- (void)sendAbility:(CGPoint)location Num:(AbilityNumber)num;

- (void)tank1ShootDelay;
- (void)tank2ShootDelay;

- (void)createAbilityMenu:(TankType)tank;
- (void)useAbility1;
- (void)useAbility2;
- (void)useAbility3;
- (void)stopShooting:(int)player;
- (void)startShooting:(int)player;

- (void)createGameLogic;
- (void)tryStartGame;

- (void)createLongMapLogic;
- (void)createWorld1_1Logic;



@end

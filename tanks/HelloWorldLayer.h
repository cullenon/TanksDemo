//
//  HelloWorldLayer.h
//  tanks
//
//  Created by Cullen O'Neill on 1/2/12.
//  Copyright Lot18 2012. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "GCHelper.h"
#import "PublicEnums.h"

@class Tanks;
@class ProximityManager;
@class Bullet;
@class HKTMXTiledMap;
@class HKTMXLayer;
@class TankMob;



// HelloWorldLayer
@interface HelloWorldLayer : CCLayer <GCHelperDelegate> {
    
    uint32_t ourRandom;   
    BOOL receivedRandom;
    BOOL isPlayer1;
    NSString *otherPlayerID;
    GameState gameState;
    
    BOOL _isReady;
    
    
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
    
    int _bBulletCount;
    int _rBulletCount;
    
    double _syncTimer;
    
}

@property (assign) int currentPlayerValue;
@property (retain) Tanks * tank;
@property (retain) Tanks * tank2;
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

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;
+(id)gameLayerWithKey:(NSString *)key;
-(id)initLayerWithKey:(NSString *)key;


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

- (void)checkBluePositions;
- (void)checkRedPositions;
- (void)checkPositions;
- (void)checkProximity;

- (Bullet *)getBullet:(BulletType)type;
- (BOOL)intersectBetweenCircle1:(CGPoint)center1 rad1:(float)rad1 Circle2:(CGPoint)center2 rad2:(float)rad2;
- (void)mobDidGetHit:(Tanks *)tank Damage:(int)dmg;


- (void)sendP1Move:(CGPoint)location;
- (void)sendP2Move:(CGPoint)location;
- (void)sendP3Move:(CGPoint)location;
- (void)sendP4Move:(CGPoint)location;
- (void)syncCurTank;
    

@end

//
//  Tanks.h
//  tanks
//
//  Created by Cullen O'Neill on 1/3/12.
//  Copyright 2012 Lot18. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "PublicEnums.h"

//@class HelloWorldLayer;
@class TileMapLayer;
@class Bullet;

@interface Tanks : CCNode {
    //int _type;
    NSDictionary *_data;
    TileMapLayer * _layer;
    //CGPoint _targetPosition;
    CGPoint _shootVector;
    CGPoint _moveVector;
    double _timeSinceLastShot;
    //CCSprite * _turret;
    //CCSprite *_base;
    
    BOOL _didReachWP;
    BOOL _parsing;
    BOOL _ready;
    BOOL _isCasting;
    
    //CCArray *_baseStrings;
    int _moveCounter;
    float _xMove, _yMove;
    double _timeInactive;
    
    
    CGPoint _nearTarget;
    
    CCArray *_bullets;
    int _bulletCounter;
}

@property (retain) CCArray *baseStrings;
@property (retain) CCSprite * turret;
@property (retain) CCSprite * base;
@property (assign) BOOL moving;
@property (assign) int hp;
@property (assign) int speed;
@property (assign) BOOL shooting;
@property (assign) double RPM;
@property (assign) double range;
@property (assign) double projSpeed;
@property (assign) int curWaypoint;
@property (assign) int mobLane;
@property (assign) int team;
@property (assign) int type;
@property (assign) int radius;
@property (assign) int damage;
@property (retain) CCArray *targetsInRange;
@property (retain) CCArray *targetsToRemove;
@property (retain) Tanks *curTarget;
@property (assign) BulletType bulletType;
@property (assign) CGPoint targetPosition;
@property (retain) NSString *bulletStr;
@property (assign) BOOL isActive;

- (void)shootToward:(CGPoint)targetPosition;
- (void)shootTowardPosition:(CGPoint)targetPosition;
- (void)shootNow;

+ (id)heroTankWithLayer:(TileMapLayer *)layer team:(int)team hero:(int)hero;
+ (id)shadowTankWithLayer:(TileMapLayer *)layer team:(int)team;
+ (id)flashTankWithLayer:(TileMapLayer *)layer team:(int)team;
+ (id)blueTankWithLayer:(TileMapLayer *)layer team:(int)team;
+ (id)redTankWithLayer:(TileMapLayer *)layer team:(int)team;
+ (id)blueTurretWithLayer:(TileMapLayer *)layer team:(int)team;
+ (id)redTurretWithLayer:(TileMapLayer *)layer team:(int)team;
- (id)initWithKey:(NSString *)key layer:(TileMapLayer *)layer;
- (id)initWithLayer:(TileMapLayer *)layer type:(int)type team:(int)team;
- (void)moveToward:(CGPoint)targetPosition;

//- (NSString *)defaultBulletForTank;

- (void)setShootVector:(CGPoint)vector;


- (void)moveToNextWaypoint;
- (void)checkPositions;
- (void)addTargetToArray:(Tanks *)target;
- (void)addTargetArrayToArray:(CCArray *)targetArray;
- (void)changeCurrentTarget:(Tanks *)target;

- (void)setLayerAbilityFlag:(AbilityNumber)flag;
- (void)setTargetPosition:(CGPoint)position;

+ (id)enemyMobWithLayer:(TileMapLayer *)layer key:(NSString *)key team:(int)team;
- (void)adjustMoveVectorEnemy;
- (void)scheduleLogicForType;

@end

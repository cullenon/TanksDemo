//
//  PublicEnums.h
//  tanks
//
//  Created by Cullen O'Neill on 2/17/12.
//  Copyright (c) 2012 Lot18. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum tagState {
	kStateGrabbed,
	kStateUngrabbed
} touchState;

typedef enum {
    kBackground = 0,
    kTankBase,
    kTankBullet,
    kTankTurret,
    kEffect
} GameLayers;

typedef enum {
    kSinglePlayer = 0,
    kMultiCoop,
    kMultiVs
} GameType;

typedef enum {
    kAbilityNone = 0,
    kAbilityOne,
    kAbilityTwo,
    kAbilityThree
} AbilityNumber;

typedef enum {
    kShadow = 0,
    kFlash,
    kBlaze,
    kIceberg
} TankType;

typedef enum {
    kTank1 = 0
} EnemyType;

typedef enum {
    kNone = 0,
    kShadowBullet,
    kShadowHandGrab,
    kShadowVoidZone,
    kFlashBullet,
    kFlashBlink,
    kFlashFlash
} AbilityFlag;

typedef enum {
    kEndReasonWin,
    kEndReasonLose,
    kEndReasonDisconnect
} EndReason;

typedef enum {
    kBlueTank,
    kRedTank,
    kBlueTurret,
    kRedTurret,
    kP1Tank,
    kP2Tank,
    kP3Tank,
    kP4Tank,
    kBlue,
    kRed,
    kHero
} BulletType;

typedef enum {
    kBasicElement,
    kShadowHand,
    kFlashTrail,
    kBlazeInferno,
    kFrostIceWall
} Projectile;

typedef enum {
    kGameStateWaitingForMatch = 0,
    kGameStateWaitingForRandomNumber,
    kGameStateWaitingForStart,
    kGameStateWaitingForMap,
    kGameStateActive,
    kGameStateDone
} GameState;

typedef enum {
    kMessageTypeRandomNumber = 0,
    kMessageTypeLoadMap,
    kMessageTypeGameBegin,
    kMessageTypeMapActive,
    kMessageTypeMove,
    kMessageTypeGameOver,
    kMessageTypeP1ReadySelect,
    kMessageTypeP2ReadySelect,
    kMessageTypeP3ReadySelect,
    kMessageTypeP4ReadySelect,
    kMessageTypeP1CancelSelect,
    kMessageTypeP2CancelSelect,
    kMessageTypeP3CancelSelect,
    kMessageTypeP4CancelSelect,
    kMessageTypeP1ReadyMap,
    kMessageTypeP2ReadyMap,
    kMessageTypeP3ReadyMap,
    kMessageTypeP4ReadyMap,
    kMessageTypeP1Move,
    kMessageTypeP2Move,
    kMessageTypeP3Move,
    kMessageTypeP4Move,
    kMessageTypeP1Sync,
    kMessageTypeP2Sync,
    kMessageTypeP3Sync,
    kMessageTypeP4Sync,
    kMessageTypeP1Shoot,
    kMessageTypeP2Shoot,
    kMessageTypeP3Shoot,
    kMessageTypeP4Shoot,
    kMessageTypeP1Ability,
    kMessageTypeP2Ability,
    kMessageTypeP3Ability,
    kMessageTypeP4Ability,
    kMessageTypeSpawnEnemy
} MessageType;

typedef struct {
    MessageType messageType;
} Message;

typedef struct {
    Message message;
    uint32_t randomNumber;
} MessageRandomNumber;

typedef struct {
    Message message;
} MessageGameBegin;

typedef struct {
    Message message;
} MessageMove;

typedef struct {
    Message message;
    BOOL player1Won;
} MessageGameOver;

typedef struct {
    Message message;
    CGPoint playerMove;
} MessagePlayerMove;

typedef struct {
    Message message;
    CGPoint playerPos;
} MessagePlayerSync;

typedef struct {
    Message message;
    CGPoint shootPos;
} MessagePlayerShoot;

typedef struct {
    Message message;
    AbilityNumber abilityNum;
    CGPoint abilityPos;
} MessagePlayerAbility;

typedef struct {
    Message message;
    int selectedTank;
} MessageReadySelect;

typedef struct {
    Message message;
} MessageCancelSelect;

typedef struct {
    Message message;
    int map;
    TankType p1;
    TankType p2;
    TankType p3;
    TankType p4;
} MessageLoadMap;

typedef struct {
    Message message;
} MessageMapLoaded;

typedef struct {
    Message message;
    EnemyType enemyType;
    CGPoint spawnLoc;
} MessageSpawnEnemy;


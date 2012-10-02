//
//  LevelSelectLayer.h
//  tanks
//
//  Created by Cullen O'Neill on 3/4/12.
//  Copyright 2012 Lot18. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "GCHelper.h"
#import "PublicEnums.h"

@interface LevelSelectLayer : CCLayer <GCHelperDelegate> {
    
    uint32_t ourRandom;   
    BOOL receivedRandom;
    BOOL isPlayer1;
    NSString *otherPlayerID;
    GameState gameState;
    
    BOOL _isReady;
    BOOL _playerOneReady;
    BOOL _playerTwoReady;
    BOOL _playerThreeReady;
    BOOL _playerFourReady;
    
    TankType _oneTank;
    TankType _twoTank;
    TankType _threeTank;
    TankType _fourTank;
    
    
    CCSpriteBatchNode *_batchNode;
    CCSpriteBatchNode *_batchNode2;
    
    int _levelIndex;
    int _numPlayers;
    
    
}

@property (assign) int currentPlayerValue;
@property (retain) CCArray *levelSprites;
@property (retain) CCArray *levelStrings;
@property (retain) CCSprite *levelImg;
@property (retain) NSDictionary *levelSelectDict;

+ (id)singlePlayerSelect;
+ (id)multiPlayerSelect:(int)players;
- (id)initWithMulti:(BOOL)YesMulti;
- (id)initWithNum:(int)players curPID:(int)playID;

- (void)level1;
- (void)level2;
- (void)level3;
- (void)level4;
- (void)goNextLevel;
- (void)goBackLevel;

- (void)tank1;
- (void)tank2;
- (void)tank3;
- (void)tank4;

//- (void)playerReady:(int)player;
- (void)runMap;

- (void)lobbyRefresh;


@end

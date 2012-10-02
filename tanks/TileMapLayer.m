//
//  TileMapLayer.m
//  tanks
//
//  Created by Cullen O'Neill on 2/17/12.
//  Copyright 2012 Lot18. All rights reserved.
//

#import "TileMapLayer.h"
#import "AppDelegate.h"
#import "RootViewController.h"
#import "ZJoystick.h"
#import "Tanks.h"
#import "SimpleAudioEngine.h"
#import "DeviceSettings.h"
//#import "RandomTank.h"
#import "AI_Sprites.h"
#import "DataModel.h"
#import "WayPoint.h"
#import "SceneManager.h"
#import "ProximityManager.h"
#import "Bullet.h"
#import "HKTMXTiledMap.h"
#import "HKTMXLayer.h"
#import "GCHelper.h"
#import "HeroTank.h"
#import "SpriteDictionary.h"


// HelloWorldLayer implementation
@implementation TileMapLayer

//@synthesize batchNode = _batchNode;
@synthesize tank = _tank;
@synthesize tank2 = _tank2;
@synthesize blueMobs = _blueMobs;
@synthesize redMobs = _redMobs;
@synthesize tileMap = _tileMap;

@synthesize actBlueMobs = _actBlueMobs;
@synthesize actRedMobs = _actRedMobs;
@synthesize bullets = _bullets;
@synthesize proxManager = _proxManager;
@synthesize currentPlayerValue = _currentPlayerValue;
@synthesize testDict = _testDict;
@synthesize abilityFlagTouch = _abilityFlagTouch;

- (void)sendData:(NSData *)data {
    NSError *error;
    BOOL success = [[GCHelper sharedInstance].match sendDataToAllPlayers:data withDataMode:GKMatchSendDataReliable error:&error];
    Message *message = (Message *) [data bytes];
    NSLog(@"message:%d",message->messageType);
    if (!success) {
        CCLOG(@"Error sending init packet");
        [self matchEnded];
    }
}

- (void)sendRandomNumber {
    NSLog(@"rand # sent");
    MessageRandomNumber message;
    message.message.messageType = kMessageTypeRandomNumber;
    message.randomNumber = ourRandom;
    NSData *data = [NSData dataWithBytes:&message length:sizeof(MessageRandomNumber)];    
    [self sendData:data];
}

- (void)sendGameBegin {
    [self unschedule:@selector(sendGameBegin)];
    NSLog(@"send game begin");
    MessageGameBegin message;
    message.message.messageType = kMessageTypeGameBegin;
    NSData *data = [NSData dataWithBytes:&message length:sizeof(MessageGameBegin)];    
    [self sendData:data];
    
}

- (void)sendMove {
    NSLog(@"send move");
    MessageMove message;
    message.message.messageType = kMessageTypeMove;
    NSData *data = [NSData dataWithBytes:&message length:sizeof(MessageMove)];    
    [self sendData:data];
    
}

- (void)sendGameOver:(BOOL)player1Won {
    
    MessageGameOver message;
    message.message.messageType = kMessageTypeGameOver;
    message.player1Won = player1Won;
    NSData *data = [NSData dataWithBytes:&message length:sizeof(MessageGameOver)];    
    [self sendData:data];
    
}

- (void)sendP1Move:(CGPoint)location {
    MessagePlayerMove message;
    message.message.messageType = kMessageTypeP1Move;
    message.playerMove = ccp(location.x/ADJUST_COORD(1),location.y/ADJUST_COORD(1));
    [[GCHelper sharedInstance] sendDataToAllPlayers:&message length:sizeof(MessagePlayerMove)];
    //NSData *data = [NSData dataWithBytes:&message length:sizeof(MessagePlayerMove)];
    //[self sendData:data];
    //NSLog(@"p1 move sent");
}

- (void)sendP2Move:(CGPoint)location {
    MessagePlayerMove message;
    message.message.messageType = kMessageTypeP2Move;
    message.playerMove = ccp(location.x/ADJUST_COORD(1),location.y/ADJUST_COORD(1));
    [[GCHelper sharedInstance] sendDataToAllPlayers:&message length:sizeof(MessagePlayerMove)];
    //NSData *data = [NSData dataWithBytes:&message length:sizeof(MessagePlayerMove)];
    //[self sendData:data];
    //NSLog(@"p2 move sent");
}

- (void)sendP3Move:(CGPoint)location {
    MessagePlayerMove message;
    message.message.messageType = kMessageTypeP3Move;
    message.playerMove = location;
    [[GCHelper sharedInstance] sendDataToAllPlayers:&message length:sizeof(MessagePlayerMove)];
    //NSData *data = [NSData dataWithBytes:&message length:sizeof(MessagePlayerMove)];
    //[self sendData:data];
}

- (void)sendP4Move:(CGPoint)location {
    MessagePlayerMove message;
    message.message.messageType = kMessageTypeP4Move;
    message.playerMove = location;
    [[GCHelper sharedInstance] sendDataToAllPlayers:&message length:sizeof(MessagePlayerMove)];
    //NSData *data = [NSData dataWithBytes:&message length:sizeof(MessagePlayerMove)];
    //[self sendData:data];
}

- (void)syncCurTank {
    MessagePlayerSync message;
    switch (_currentPlayerValue) {
        case 1:
            message.message.messageType = kMessageTypeP1Sync;
            message.playerPos = ccp(self.tank.position.x/ADJUST_COORD(1),self.tank.position.y/ADJUST_COORD(1));
            break;
        case 2:
            message.message.messageType = kMessageTypeP2Sync;
            message.playerPos = ccp(self.tank2.position.x/ADJUST_COORD(1),self.tank2.position.y/ADJUST_COORD(1));
            break;
    }
    NSData *data = [NSData dataWithBytes:&message length:sizeof(MessagePlayerMove)];
    [self sendData:data];
    NSLog(@"sync sent");
    //[[GCHelper sharedInstance] sendDataToAllPlayers:&message length:sizeof(message)];
}


- (void)sendP1Sync:(CGPoint)location {
    MessagePlayerMove message;
    message.message.messageType = kMessageTypeP1Move;
    message.playerMove = location;
    NSData *data = [NSData dataWithBytes:&message length:sizeof(MessagePlayerMove)];
    [self sendData:data];
    //NSLog(@"p1 move sent");
}

- (void)sendP2Sync:(CGPoint)location {
    MessagePlayerMove message;
    message.message.messageType = kMessageTypeP2Move;
    message.playerMove = location;
    NSData *data = [NSData dataWithBytes:&message length:sizeof(MessagePlayerMove)];
    [self sendData:data];
    //NSLog(@"p2 move sent");
}

- (void)sendP1Shoot:(CGPoint)location {
    MessagePlayerShoot message;
    message.message.messageType = kMessageTypeP1Shoot;
    message.shootPos = location;
    [[GCHelper sharedInstance] sendDataToAllPlayers:&message length:sizeof(MessagePlayerShoot)];
}

- (void)sendP2Shoot:(CGPoint)location {
    MessagePlayerShoot message;
    message.message.messageType = kMessageTypeP2Shoot;
    message.shootPos = location;
    [[GCHelper sharedInstance] sendDataToAllPlayers:&message length:sizeof(MessagePlayerShoot)];
}

- (void)sendP1Ability:(CGPoint)location Num:(AbilityNumber)num {
    MessagePlayerAbility message;
    message.message.messageType = kMessageTypeP1Ability;
    message.abilityPos = location;
    message.abilityNum = num;
    [[GCHelper sharedInstance] sendDataToAllPlayers:&message length:sizeof(MessagePlayerAbility)];
}

- (void)sendP2Ability:(CGPoint)location Num:(AbilityNumber)num {
    MessagePlayerAbility message;
    message.message.messageType = kMessageTypeP2Ability;
    message.abilityPos = location;
    message.abilityNum = num;
    [[GCHelper sharedInstance] sendDataToAllPlayers:&message length:sizeof(MessagePlayerAbility)];
}

- (void)sendAbility:(CGPoint)location Num:(AbilityNumber)num {
    MessagePlayerAbility message;
    message.abilityPos = ccp(location.x/ADJUST_COORD(1),location.y/ADJUST_COORD(1));
    message.abilityNum = num;
    switch (_currentPlayerValue) {
        case 1:
            message.message.messageType = kMessageTypeP1Ability;
            break;
        case 2:
            message.message.messageType = kMessageTypeP2Ability;
            break;
    }
    [[GCHelper sharedInstance] sendDataToAllPlayers:&message length:sizeof(MessagePlayerAbility)];
}

- (void)sendSpawnEnemy:(CGPoint)location type:(EnemyType)type {
    //NSLog(@"spawn sent");
    MessageSpawnEnemy message;
    message.message.messageType = kMessageTypeSpawnEnemy;
    message.spawnLoc = ccp(location.x/ADJUST_COORD(1), location.y/ADJUST_COORD(1));
    message.enemyType = type;
    //[[GCHelper sharedInstance] sendDataToAllPlayers:&message length:sizeof(message)];
    NSData *data = [NSData dataWithBytes:&message length:sizeof(MessageSpawnEnemy)];
    [self sendData:data];
}


- (void)tryStartGame {
    NSLog(@"try start game");
    /*if (gameState == kGameStateWaitingForStart) {
        [self setGameState:kGameStateActive];
        [self sendGameBegin];
    }//*/
    
    [self sendGameBegin];
    [self schedule:@selector(startWave) interval:5];
    [self schedule:@selector(checkProximity) interval:1/20];
    
}


- (float)tileMapHeight {
    return _tileMap.mapSize.height * _tileMap.tileSize.height/CC_CONTENT_SCALE_FACTOR();
}

- (float)tileMapWidth {
    return _tileMap.mapSize.width * _tileMap.tileSize.width/CC_CONTENT_SCALE_FACTOR();
}

- (BOOL)isValidPosition:(CGPoint)position {
    if (position.x < 0 ||
        position.y < 0 ||
        position.x > [self tileMapWidth] ||
        position.y > [self tileMapHeight]) {
        return FALSE;
    } else {
        return TRUE;
    }
}

- (BOOL)isValidTileCoord:(CGPoint)tileCoord {
    if (tileCoord.x < 0 || 
        tileCoord.y < 0 || 
        tileCoord.x >= _tileMap.mapSize.width ||
        tileCoord.y >= _tileMap.mapSize.height) {
        return FALSE;
    } else {
        return TRUE;
    }
}

- (CGPoint)tileCoordForPosition:(CGPoint)position {    
    
    if (![self isValidPosition:position]) return ccp(-1,-1);
    
    int x = position.x / (_tileMap.tileSize.width/CC_CONTENT_SCALE_FACTOR());
    int y = ([self tileMapHeight] - position.y) / (_tileMap.tileSize.height/CC_CONTENT_SCALE_FACTOR());
    
    return ccp(x, y);
}

- (CGPoint)positionForTileCoord:(CGPoint)tileCoord {
    
    int x = (tileCoord.x * _tileMap.tileSize.width/CC_CONTENT_SCALE_FACTOR()) + _tileMap.tileSize.width/2/CC_CONTENT_SCALE_FACTOR();
    int y = [self tileMapHeight] - (tileCoord.y * _tileMap.tileSize.height/CC_CONTENT_SCALE_FACTOR()) - _tileMap.tileSize.height/2/CC_CONTENT_SCALE_FACTOR();
    return ccp(x, y);
    
}

-(void)setViewpointCenter:(CGPoint) position {
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    int x = MAX(position.x, winSize.width / 2 / self.scale);
    int y = MAX(position.y, winSize.height / 2 / self.scale);
    x = MIN(x, [self tileMapWidth] - winSize.width / 2 / self.scale);
    y = MIN(y, [self tileMapHeight] - winSize.height/ 2 / self.scale);
    CGPoint actualPosition = ccp(x, y);
    
    CGPoint centerOfView = ccp(winSize.width/2, winSize.height/2);
    CGPoint viewPoint = ccpSub(centerOfView, actualPosition);
    
    _tileMap.position = viewPoint;
    
}

-(BOOL)isProp:(NSString*)prop atTileCoord:(CGPoint)tileCoord forLayer:(HKTMXLayer *)layer {
    if (![self isValidTileCoord:tileCoord]) return NO;
    int gid = [layer tileGIDAt:tileCoord];
    NSDictionary * properties = [_tileMap propertiesForGID:gid];
    if (properties == nil) return NO;   
    return [properties objectForKey:prop] != nil;
}

-(BOOL)isProp:(NSString*)prop atPosition:(CGPoint)position forLayer:(HKTMXLayer *)layer {
    CGPoint tileCoord = [self tileCoordForPosition:position];
    return [self isProp:prop atTileCoord:tileCoord forLayer:layer];
}

- (BOOL)isWallAtTileCoord:(CGPoint)tileCoord {
    
    /*BOOL _isWall = NO;
     if ([self isProp:@"wall" atTileCoord:tileCoord forLayer:_treeLayer] || [self isProp:@"wall" atTileCoord:tileCoord forLayer:_bgLayer]) {
     _isWall = YES;
     }
     return _isWall;//*/
    
    return [self isProp:@"wall" atTileCoord:tileCoord forLayer:_bgLayer];
}

- (BOOL)isWallAtPosition:(CGPoint)position {
    CGPoint tileCoord = [self tileCoordForPosition:position];
    if (![self isValidPosition:tileCoord]) return TRUE;
    return [self isWallAtTileCoord:tileCoord];
}

- (BOOL)isWallAtRect:(CGRect)rect {
    CGPoint lowerLeft = ccp(rect.origin.x, rect.origin.y);
    CGPoint upperLeft = ccp(rect.origin.x, rect.origin.y+rect.size.height);
    CGPoint lowerRight = ccp(rect.origin.x+rect.size.width, rect.origin.y);
    CGPoint upperRight = ccp(rect.origin.x+rect.size.width, rect.origin.y+rect.size.height);
    
    return ([self isWallAtPosition:lowerLeft] || [self isWallAtPosition:upperLeft] ||
            [self isWallAtPosition:lowerRight] || [self isWallAtPosition:upperRight]);
}

- (BOOL)isWarpAtTileCoord:(CGPoint)tileCoord {
    
    return [self isProp:@"warp" atTileCoord:tileCoord forLayer:_bgLayer];
}

- (BOOL)isWarpAtPosition:(CGPoint)position {
    CGPoint tileCoord = [self tileCoordForPosition:position];
    if (![self isValidPosition:tileCoord]) return TRUE;
    //NSLog(@"x:%f y:%f",tileCoord.x,tileCoord.y);
    return [self isWarpAtTileCoord:tileCoord];
}

- (void)checkWarp {
    if ([self isWarpAtPosition:self.tank.position]) {
        [self unschedule:@selector(checkWarp)];
        [self endScene:kEndReasonWin];
        [self sendGameOver:YES];
        NSLog(@"warp hit");
    } else if ([self isWarpAtPosition:self.tank2.position]) {
        [self unschedule:@selector(checkWarp)];
        [self endScene:kEndReasonWin];
        [self sendGameOver:YES];
    }
    
}


#define INFANTRY_MAX 20
#define TANK_MAX 16
#define BULLET_MAX 40

+(id)gameLayerWithKey:(NSString *)key playerData:(NSDictionary *)data {
    TileMapLayer *layer = [[[TileMapLayer alloc] initLayerWithKey:key playerData:data] autorelease];
    return layer;
}

-(id)initLayerWithKey:(NSString *)key playerData:(NSDictionary *)data {
    
    if ((self = [super init])) {
        
        _mapKey = key;
        
        _testDict = [[NSDictionary alloc] initWithDictionary:data];
        
        _playerCount = [[data objectForKey:@"numPlayers"] intValue];
        if (_playerCount > 1) {
            //AppDelegate * delegate = (AppDelegate *) [UIApplication sharedApplication].delegate;                
            //[[GCHelper sharedInstance] findMatchWithMinPlayers:2 maxPlayers:2 viewController:delegate.viewController delegate:self];
            //ourRandom = arc4random();
            //[self setGameState:kGameStateWaitingForMap];
            [GCHelper sharedInstance].delegate = self;
            _isReady = YES;
            _syncTimer = 0;
            /*if (_currentPlayerValue == 1) {
                [self schedule:@selector(sendGameBegin) interval:4];
            }//*/
        } else {
            _currentPlayerValue = 1;
        }
        
        self.proxManager = [[ProximityManager alloc] initProxWithSize:ADJUST_COORD(40)];
        [self addChild:self.proxManager];
        
        _tileMap = [HKTMXTiledMap tiledMapWithTMXFile:SD_OR_HD_TMX(key)];
        [self addChild:_tileMap];
        
        _bgLayer = [_tileMap layerNamed:@"Background"];
        
        CGPoint spawnTileCoord;
        
        if ([_mapKey isEqualToString:@"long_map.tmx"]) {
            spawnTileCoord = ccp(4,4);
        } else if ([_mapKey isEqualToString:@"square_map.tmx"]) {
            spawnTileCoord = ccp(10,10);
        } else if ([_mapKey isEqualToString:@"world1_1.tmx"]) {
            _levelCounter = 1;
            spawnTileCoord = ccp(4,3);
        } else if ([_mapKey isEqualToString:@"world1_10.tmx"]) {
            _levelCounter = 10;
            spawnTileCoord = ccp(4,3);
        }
        
        
        CGSize winSize = [CCDirector sharedDirector].winSize;
        
        
        CGPoint spawnPos = [self positionForTileCoord:spawnTileCoord];
        [self setViewpointCenter:spawnPos];
        
        //_batchNode = [CCSpriteBatchNode batchNodeWithFile:SD_OR_HD_PVR(@"sprites.pvr.ccz")];
        //[_tileMap addChild:_batchNode];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:SD_OR_HD_PLIST(@"sprites.plist")];
        //[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:SD_OR_HD_PLIST(@"sprite_animations.plist")];
        
        
        int p1 = [[data objectForKey:@"p1"] intValue];
        int p2;
        int p3;
        int p4;
        NSLog(@"tank:%d",p1);
        
        self.tank = [HeroTank heroTankWithLayer:self team:1 hero:p1];
        
        self.tank.position = spawnPos;
        //[_batchNode addChild:self.tank z:1];
        [_tileMap addChild:self.tank z:1];
        [self.proxManager addObject:self.tank];
        self.tank.bulletType = kP1Tank;
        
        if (_playerCount > 1) {
            switch (_playerCount) {
                case 2:
                    p2 = [[data objectForKey:@"p2"] intValue];
                    self.tank2 = [HeroTank heroTankWithLayer:self team:1 hero:p2];
                    self.tank2.position = spawnPos;
                    //[_batchNode addChild:self.tank2 z:1];
                    [_tileMap addChild:self.tank2 z:1];
                    [self.proxManager addObject:self.tank2];
                    self.tank2.bulletType = kP2Tank;
                    break;
                case 3:
                    p2 = [[data objectForKey:@"p2"] intValue];
                    self.tank2 = [HeroTank heroTankWithLayer:self team:1 hero:p2];
                    self.tank2.position = spawnPos;
                    [_tileMap addChild:self.tank2 z:1];
                    [self.proxManager addObject:self.tank2];
                    self.tank2.bulletType = kP2Tank;
                    break;
                case 4:
                    p2 = [[data objectForKey:@"p2"] intValue];
                    self.tank2 = [HeroTank heroTankWithLayer:self team:1 hero:p2];
                    self.tank2.position = spawnPos;
                    [_tileMap addChild:self.tank2 z:1];
                    [self.proxManager addObject:self.tank2];
                    self.tank2.bulletType = kP2Tank;
                    break;
            }
            
        }
        
        
        self.isTouchEnabled = YES;
        [self scheduleUpdate];
        
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"bgMusic.caf"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"explode.wav"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"tank1Shoot.wav"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"tank2Shoot.wav"];
        
        //self.scale = 0.5;
        
        
                
        //[self schedule:@selector(startWave) interval:5];
        //[self schedule:@selector(checkProximity) interval:1/20];
        
        _explosion = [CCParticleSystemQuad particleWithFile:@"explosion.plist"];
        [_explosion stopSystem];
        [_tileMap addChild:_explosion z:kEffect];
        
        _explosion2 = [CCParticleSystemQuad particleWithFile:@"explosion2.plist"];
        [_explosion2 stopSystem];
        [_tileMap addChild:_explosion2 z:kEffect];
        
        CCLabelTTF *backLabel = [CCLabelTTF labelWithString:@"back" fontName:@"Arial" fontSize:HD_PIXELS(24)];
        
        CCMenuItemLabel *goBack = [CCMenuItemLabel itemWithLabel:backLabel target:self selector:@selector(onBack:)];
		
		CCMenu *menu = [CCMenu menuWithItems:goBack, nil];
		menu.position = ccp(winSize.width*0.9, winSize.height*0.9);
		[menu alignItemsVerticallyWithPadding: 20.0f];
		[self addChild:menu];
        
        
        
        
        [[SpriteDictionary sharedDictionary] loadFlashAnimations];
        [[SpriteDictionary sharedDictionary] loadShadowAnimations];
        [[SpriteDictionary sharedDictionary] loadIcebergAnimations];
        
        
        
        
    }
    
    return self;
}

- (void)createGameLogic {
    if ([_mapKey isEqualToString:@"long_map.tmx"]) {
        [self createLongMapLogic];
    } else if ([_mapKey isEqualToString:@"square_map.tmx"]) {
    } else if ([_mapKey isEqualToString:@"world1_1.tmx"]) {
        [self createWorld1_1Logic];
    } else if ([_mapKey isEqualToString:@"world1_10.tmx"]) {
        [self createWorld1_1Logic];
    }
}

- (void)createLongMapLogic {
    
    _bBulTankCount = 0;
    _bBulTurCount = 0;
    _rBulTankCount = 0;
    _rBulTurCount = 0;
    _p1BulCount = 0;
    _p2BulCount = 0;
    _p3BulCount = 0;
    _p4BulCount = 0;
    _sBulCount = 0;
    
    
    self.blueMobs = [[NSMutableDictionary alloc] init];
    self.redMobs = [[NSMutableDictionary alloc] init];
    
    self.actBlueMobs = [[CCArray alloc] init];
    self.actRedMobs = [[CCArray alloc] init];
    
    self.bullets = [[NSMutableDictionary alloc] init];
    
    [_actBlueMobs addObject:self.tank];
    [_actBlueMobs addObject:self.tank2];
    
    for (int i = 0; i < 2; i++) {
        CCArray *mobArray = [CCArray array];
        NSString *key;
        for (int z = 0; z < INFANTRY_MAX/2; z++) {
            Tanks *soldier = [Tanks blueTankWithLayer:self team:1];
            switch (i) {
                case 0:
                    soldier.mobLane = 1;
                    key = @"TopMob";
                    break;
                case 1:
                    soldier.mobLane = 3;
                    key = @"BotMob";
                    break;
            }
            soldier.visible = NO;
            soldier.position = ccp(0, 0);
            soldier.bulletType = kBlueTank;
            [mobArray addObject:soldier];
            [_tileMap addChild:soldier z:1];
            [self.actBlueMobs addObject:soldier];
            [self.proxManager addObject:soldier];
        }
        [self.blueMobs setObject:mobArray forKey:key];
    }
    for (int i = 0; i < 2; i++) {
        CCArray *mobArray = [CCArray array];
        NSString *key;
        for (int z = 0; z < INFANTRY_MAX/2; z++) {
            Tanks *soldier = [Tanks redTankWithLayer:self team:2];
            switch (i) {
                case 0:
                    soldier.mobLane = 1;
                    key = @"TopMob";
                    break;
                case 1:
                    soldier.mobLane = 3;
                    key = @"BotMob";
                    break;
            }
            soldier.visible = NO;
            soldier.position = ccp(0, 0);
            soldier.bulletType = kRedTank;
            [mobArray addObject:soldier];
            [_tileMap addChild:soldier z:1];
            [self.actRedMobs addObject:soldier];
            [self.proxManager addObject:soldier];
        }
        [self.redMobs setObject:mobArray forKey:key];
    }
    
    
    NSDictionary *turPosDict = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"turret_pos" ofType:@"plist"]];
    NSDictionary *turPos = [turPosDict objectForKey:@"long_map"];// needs to be linked to key, maybe creating a setting in devicesettings?
    
    for (int i = 0; i < 2; i++) {
        CCArray *redTurrets = [CCArray array];
        CCArray *blueTurrets = [CCArray array];
        NSDictionary *turPosBlue;
        NSDictionary *turPosRed;
        CCArray *turBlue;
        CCArray *turRed;
        NSString *keyBlue;
        NSString *keyRed;
        
        
        switch (i) {
            case 0:
                keyBlue = @"blue_top";
                keyRed = @"red_top";
                break;
            case 1:
                keyBlue = @"blue_bot";
                keyRed = @"red_bot";
                break;
        }
        
        turBlue = [turPos objectForKey:keyBlue];
        turRed = [turPos objectForKey:keyRed];
        
        for (int z = 0; z < 2; z++) {
            
            turPosBlue = [turBlue objectAtIndex:z];
            turPosRed = [turRed objectAtIndex:z];
            
            int bx = [[turPosBlue valueForKey:@"x"] intValue];
            int by = [[turPosBlue valueForKey:@"y"] intValue];
            CGPoint tilePos1 = ccp(bx, by);
            
            
            Tanks *bturret = [Tanks blueTurretWithLayer:self team:1];
            bturret.position = [self positionForTileCoord:tilePos1];
            
            bturret.visible = YES;
            bturret.bulletType = kBlueTurret;
            [blueTurrets addObject:bturret];
            [_tileMap addChild:bturret z:1];
            [self.actBlueMobs addObject:bturret];
            [self.proxManager addStaticObject:bturret];
            //[self.proxManager addObject:bturret];
            
            
            int rx = [[turPosRed valueForKey:@"x"] intValue];
            int ry = [[turPosRed valueForKey:@"y"] intValue];
            CGPoint tilePos2 = ccp(rx, ry);
            
            Tanks *rturret = [Tanks redTurretWithLayer:self team:2];
            rturret.position = [self positionForTileCoord:tilePos2];; 
            
            rturret.visible = YES;
            rturret.bulletType = kRedTurret;
            [redTurrets addObject:rturret];
            [_tileMap addChild:rturret z:1];
            [self.actRedMobs addObject:rturret];
            [self.proxManager addStaticObject:rturret];
            //[self.proxManager addObject:rturret];
            
            NSLog(@"bx:%d, by:%d, rx:%d, ry:%d",bx,by,rx,ry);
            
            
        }//
        
        [_blueMobs setObject:blueTurrets forKey:keyBlue];
        [_redMobs setObject:redTurrets forKey:keyRed];
        
        
    }
    
    [self createBulletsForScenario:kMultiVs];
    [turPosDict release];
    
    if (_playerCount == 1) {
        _isReady = YES;
        //[self createAbilityMenu:p1];
        [self schedule:@selector(startWave) interval:5];
        [self schedule:@selector(checkProximity) interval:1/20];
    } else if (_currentPlayerValue == 1) {
        [self tryStartGame];
    }

    
}

static double _timeNextSpawn;

- (float)randomValueBetween:(float)low andValue:(float)high {
    return (((float) arc4random() / 0xFFFFFFFFu) * (high - low)) + low;
}

- (CGPoint)randomNonWallPointFrom:(CGPoint)location min:(int)minDist max:(int)maxDist {
    
    int newX, newY;
    newX = MAX((arc4random()%ADJUST_COORD(maxDist) + 1),ADJUST_COORD(minDist));
    newY = MAX((arc4random()%ADJUST_COORD(maxDist) + 1),ADJUST_COORD(minDist));
    if (arc4random()%2 == 1) {
        newX = -newX;
    }
    if (arc4random()%2 == 1) {
        newY = -newY;
    }
    CGPoint newLoc = ccp(location.x+newX, location.y+newY);
    
    while ([self isWallAtPosition:newLoc]) {
        newX = MAX((arc4random()%ADJUST_COORD(maxDist) + 1),ADJUST_COORD(minDist));
        newY = MAX((arc4random()%ADJUST_COORD(maxDist) + 1),ADJUST_COORD(minDist));
        if (arc4random()%2 == 1) {
            newX = -newX;
        }
        if (arc4random()%2 == 1) {
            newY = -newY;
        }
        newLoc = ccp(location.x+newX, location.y+newY);
    }
    
    return newLoc;
}

static CGPoint _nextEnemyLoc;

- (void)scheduleEnemySpawn {
    if (_currentPlayerValue == 1) {
        
        [self unschedule:@selector(scheduleEnemySpawn)];
        _timeNextSpawn = [self randomValueBetween:0.25 andValue:2];
        
        _troopCounter++;
        
        if (_troopCounter >= INFANTRY_MAX) {
            _troopCounter = 0;
        }
        
        CCArray *enemies = [self.redMobs objectForKey:@"enemy"];
        Tanks *enemy = [enemies objectAtIndex:_troopCounter];
        
        enemy.visible = YES;
        enemy.isActive = YES;
        int r = arc4random()%101;
        int g = arc4random()%101;
        int b = arc4random()%101;
        enemy.turret.color = ccc3(150+r, 150+g, 150+b);
        enemy.base.color =  ccc3(150+r, 150+g, 150+b);
        
        
        if (_playerCount == 1) {
            enemy.position = [self randomNonWallPointFrom:self.tank.position min:10 max:200];
            enemy.targetPosition = enemy.position;
        } else {
            Tanks *target;
            int spawnSwitch = arc4random() % _playerCount;
            switch (spawnSwitch) {
                case 0:
                    target = self.tank;
                    break;
                case 1:
                    target = self.tank2;
                    break;
            }
            enemy.position = [self randomNonWallPointFrom:target.position min:10 max:200];
            [self sendSpawnEnemy:enemy.position type:kTank1];
            enemy.targetPosition = enemy.position;
        }
        
        
        
        
        //enemy.position = self.tank.position;
        
        [self schedule:@selector(scheduleEnemySpawn) interval:_timeNextSpawn];
        
        
    } else {
        
        _troopCounter++;
        
        if (_troopCounter >= INFANTRY_MAX) {
            _troopCounter = 0;
        }
        CCArray *enemies = [self.redMobs objectForKey:@"enemy"];
        Tanks *enemy = [enemies objectAtIndex:_troopCounter];
        enemy.visible = YES;
        enemy.isActive = YES;
        enemy.position = _nextEnemyLoc;
        enemy.targetPosition = enemy.position;
        int r = arc4random()%101;
        int g = arc4random()%101;
        int b = arc4random()%101;
        enemy.turret.color = ccc3(150+r, 150+g, 150+b);
        enemy.base.color = ccc3(150+r, 150+g, 150+b);
    }
    
    
    
}

- (void)createWorld1_1Logic {
    
    _rBulTankCount = 0;
    _rBulTurCount = 0;
    _p1BulCount = 0;
    _p2BulCount = 0;
    _p3BulCount = 0;
    _p4BulCount = 0;
    _sBulCount = 0;
    
    self.blueMobs = [[NSMutableDictionary alloc] init];
    self.redMobs = [[NSMutableDictionary alloc] init];
    
    self.actBlueMobs = [[CCArray alloc] init];
    self.actRedMobs = [[CCArray alloc] init];
    
    self.bullets = [[NSMutableDictionary alloc] init];
    
    [_actBlueMobs addObject:self.tank];
    if (_playerCount == 2) {
        [_actBlueMobs addObject:self.tank2];
    } else if (_playerCount == 3) {
        [_actBlueMobs addObject:self.tank2];
    } else if (_playerCount == 4) {
        [_actBlueMobs addObject:self.tank2];
    }
    
    CCArray *mobArray = [CCArray array];
    NSString *key = @"enemy";
    for (int z = 0; z < INFANTRY_MAX; z++) {
        Tanks *soldier = [Tanks enemyMobWithLayer:self key:@"tank1" team:2];
        soldier.visible = NO;
        soldier.position = ccp(0, 0);
        soldier.bulletType = kRedTank;
        soldier.turret.color = ccc3(255, 255, 100);
        soldier.base.color = ccc3(255, 255, 100);
        [mobArray addObject:soldier];
        [_tileMap addChild:soldier z:kTankBase];
        [self.actRedMobs addObject:soldier];
        [self.proxManager addObject:soldier];
    }
    [self.redMobs setObject:mobArray forKey:key];
    
    /*NSDictionary *turPosDict = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"turret_pos" ofType:@"plist"]];
    NSDictionary *turPos = [turPosDict objectForKey:@"long_map"];// needs to be linked to key, maybe creating a setting in devicesettings?
    
    for (int i = 0; i < 2; i++) {
        CCArray *redTurrets = [CCArray array];
        NSDictionary *turPosRed;
        CCArray *turRed;
        NSString *keyRed;
        
        
        switch (i) {
            case 0:
                keyRed = @"red_top";
                break;
            case 1:
                keyRed = @"red_bot";
                break;
        }
        
        turRed = [turPos objectForKey:keyRed];
        
        for (int z = 0; z < 2; z++) {
            
            turPosRed = [turRed objectAtIndex:z];
            
            int rx = [[turPosRed valueForKey:@"x"] intValue];
            int ry = [[turPosRed valueForKey:@"y"] intValue];
            CGPoint tilePos2 = ccp(rx, ry);
            
            Tanks *rturret = [Tanks redTurretWithLayer:self team:2];
            rturret.position = [self positionForTileCoord:tilePos2];; 
            
            rturret.visible = YES;
            rturret.bulletType = kRedTurret;
            [redTurrets addObject:rturret];
            [_tileMap addChild:rturret z:1];
            [self.actRedMobs addObject:rturret];
            [self.proxManager addStaticObject:rturret];
            
        }//
        
        [_redMobs setObject:redTurrets forKey:keyRed];
        
    }//*/
    
    [self createBulletsForScenario:kMultiCoop];
    //[turPosDict release];
    
    
    
    if (_currentPlayerValue == 1) {
        _isReady = YES;
        //[self createAbilityMenu:p1];
        [self schedule:@selector(scheduleEnemySpawn) interval:2];
        [self schedule:@selector(checkProximity) interval:1/20];
        [self schedule:@selector(checkWarp) interval:1/2];
    } else {
        _isReady = YES;
        [self schedule:@selector(checkProximity) interval:1/20];
        [self schedule:@selector(checkWarp) interval:1/2];
    }

    
}

- (void)createAbilityMenu:(TankType)tank {
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    CCSprite *abilNorm1;
    CCSprite *abilSelect1;
    CCSprite *abilDis1;
    CCSprite *abilNorm2;
    CCSprite *abilSelect2;
    CCSprite *abilDis2;
    CCSprite *abilNorm3;
    CCSprite *abilSelect3;
    CCSprite *abilDis3;
    
    switch (tank) {
        case kShadow:
            abilNorm1 = [CCSprite spriteWithSpriteFrameName:@"shadow_base.png"];
            abilNorm2 = [CCSprite spriteWithSpriteFrameName:@"shadow_base.png"];
            abilNorm3 = [CCSprite spriteWithSpriteFrameName:@"shadow_base.png"];
            abilSelect1 = [CCSprite spriteWithSpriteFrameName:@"shadow_base.png"];
            abilSelect2 = [CCSprite spriteWithSpriteFrameName:@"shadow_base.png"];
            abilSelect3 = [CCSprite spriteWithSpriteFrameName:@"shadow_base.png"];
            abilDis1 = [CCSprite spriteWithSpriteFrameName:@"shadow_base.png"];
            abilDis2 = [CCSprite spriteWithSpriteFrameName:@"shadow_base.png"];
            abilDis3 = [CCSprite spriteWithSpriteFrameName:@"shadow_base.png"];
            break;
        case kFlash:
            abilNorm1 = [CCSprite spriteWithSpriteFrameName:@"flash_base.png"];
            abilNorm2 = [CCSprite spriteWithSpriteFrameName:@"flash_base.png"];
            abilNorm3 = [CCSprite spriteWithSpriteFrameName:@"flash_base.png"];
            abilSelect1 = [CCSprite spriteWithSpriteFrameName:@"flash_base.png"];
            abilSelect2 = [CCSprite spriteWithSpriteFrameName:@"flash_base.png"];
            abilSelect3 = [CCSprite spriteWithSpriteFrameName:@"flash_base.png"];
            abilDis1 = [CCSprite spriteWithSpriteFrameName:@"flash_base.png"];
            abilDis2 = [CCSprite spriteWithSpriteFrameName:@"flash_base.png"];
            abilDis3 = [CCSprite spriteWithSpriteFrameName:@"flash_base.png"];
            break;
        case kBlaze:
            abilNorm1 = [CCSprite spriteWithSpriteFrameName:@"blaze_base.png"];
            abilNorm2 = [CCSprite spriteWithSpriteFrameName:@"blaze_base.png"];
            abilNorm3 = [CCSprite spriteWithSpriteFrameName:@"blaze_base.png"];
            abilSelect1 = [CCSprite spriteWithSpriteFrameName:@"blaze_base.png"];
            abilSelect2 = [CCSprite spriteWithSpriteFrameName:@"blaze_base.png"];
            abilSelect3 = [CCSprite spriteWithSpriteFrameName:@"blaze_base.png"];
            abilDis1 = [CCSprite spriteWithSpriteFrameName:@"blaze_base.png"];
            abilDis2 = [CCSprite spriteWithSpriteFrameName:@"blaze_base.png"];
            abilDis3 = [CCSprite spriteWithSpriteFrameName:@"blaze_base.png"];
            break;
        case kIceberg:
            abilNorm1 = [CCSprite spriteWithSpriteFrameName:@"iceberg_base.png"];
            abilNorm2 = [CCSprite spriteWithSpriteFrameName:@"iceberg_base.png"];
            abilNorm3 = [CCSprite spriteWithSpriteFrameName:@"iceberg_base.png"];
            abilSelect1 = [CCSprite spriteWithSpriteFrameName:@"iceberg_base.png"];
            abilSelect2 = [CCSprite spriteWithSpriteFrameName:@"iceberg_base.png"];
            abilSelect3 = [CCSprite spriteWithSpriteFrameName:@"iceberg_base.png"];
            abilDis1 = [CCSprite spriteWithSpriteFrameName:@"iceberg_base.png"];
            abilDis2 = [CCSprite spriteWithSpriteFrameName:@"iceberg_base.png"];
            abilDis3 = [CCSprite spriteWithSpriteFrameName:@"iceberg_base.png"];
            break;
    }
    
    
    [abilNorm1 setColor:ccc3(0, 100, 100)];
    [abilNorm2 setColor:ccc3(100, 100, 0)];
    [abilSelect1 setColor:ccGRAY];
    [abilSelect2 setColor:ccGRAY];
    [abilSelect3 setColor:ccGRAY];
    [abilDis1 setColor:ccGRAY];
    [abilDis2 setColor:ccGRAY];
    [abilDis3 setColor:ccGRAY];
    
    CCMenuItemSprite *abil1 = [CCMenuItemSprite itemFromNormalSprite:abilNorm1 selectedSprite:abilSelect1 disabledSprite:abilDis1 target:self selector:@selector(useAbility1)];
    CCMenuItemSprite *abil2 = [CCMenuItemSprite itemFromNormalSprite:abilNorm2 selectedSprite:abilSelect2 disabledSprite:abilDis2 target:self selector:@selector(useAbility2)];
    CCMenuItemSprite *abil3 = [CCMenuItemSprite itemFromNormalSprite:abilNorm3 selectedSprite:abilSelect3 disabledSprite:abilDis3 target:self selector:@selector(useAbility3)];
    
    CCMenu *menu = [CCMenu menuWithItems:abil3,abil2,abil1, nil];
    [menu alignItemsHorizontallyWithPadding:ADJUST_COORD(16)];
    menu.position = ccp(winSize.width/2, winSize.height*0.1);
    [self addChild:menu];
    
}

- (void)useAbility1 {
    
    HeroTank *hero;
    switch (_currentPlayerValue) {
        case 1:
            hero = self.tank;
            break;
        case 2:
            hero = self.tank2;
            break;
    }
    [hero abilityOneForType:hero.tankType];
    
}
- (void)useAbility2 {
    
    HeroTank *hero;
    switch (_currentPlayerValue) {
        case 1:
            hero = self.tank;
            break;
        case 2:
            hero = self.tank2;
            break;
    }
    [hero abilityTwoForType:hero.tankType];
    
}
- (void)useAbility3 {
    
    HeroTank *hero;
    switch (_currentPlayerValue) {
        case 1:
            hero = self.tank;
            break;
        case 2:
            hero = self.tank2;
            break;
    }
    [hero abilityThreeForType:hero.tankType];
    
}


- (void)createBulletsForScenario:(GameType)gametype {
    
    if (gametype == kMultiVs) {
        CCArray *rTankBullet = [CCArray array];
        CCArray *rTurBullet = [CCArray array];
        CCArray *bTankBullet = [CCArray array];
        CCArray *bTurBullet = [CCArray array];
        
        CCArray *p1Bullet = [CCArray array];
        
        CCArray *bTanks = [self.blueMobs objectForKey:@"TopMob"];
        CCArray *rTanks = [self.redMobs objectForKey:@"TopMob"];
        
        CCArray *bSpecial = [CCArray array];
        
        for (int i = 0; i < 10; i++) {
            Bullet *sbullet = [Bullet bulletWithKey:@"tank1_bullet.png"];
            sbullet.visible = NO;
            [_tileMap addChild:sbullet z:2];
            [bSpecial addObject:sbullet];
        }
        [_bullets setObject:bSpecial forKey:@"sBullet"];
        
        
        for (int i = 0; i < 20; i++) {
            Bullet *bbullet = [Bullet bulletWithKey:((Tanks*)[bTanks objectAtIndex:0]).bulletStr];
            Bullet *rbullet = [Bullet bulletWithKey:((Tanks*)[rTanks objectAtIndex:0]).bulletStr];
            bbullet.visible = NO;
            rbullet.visible = NO;
            [_tileMap addChild:bbullet z:kTankBullet];
            [_tileMap addChild:rbullet z:kTankBullet];
            [bTankBullet addObject:bbullet];
            [rTankBullet addObject:rbullet];
            
        }
        
        [_bullets setObject:bTankBullet forKey:@"bTank"];
        [_bullets setObject:rTankBullet forKey:@"rTank"];
        
        CCArray *bTurrets = [self.blueMobs objectForKey:@"blue_top"];
        CCArray *rTurrets = [self.redMobs objectForKey:@"red_top"];
        
        for (int i = 0; i < 20; i++) {
            Bullet *bbullet = [Bullet bulletWithKey:((Tanks*)[bTurrets objectAtIndex:0]).bulletStr];
            Bullet *rbullet = [Bullet bulletWithKey:((Tanks*)[rTurrets objectAtIndex:0]).bulletStr];
            bbullet.visible = NO;
            rbullet.visible = NO;
            [_tileMap addChild:bbullet z:(kTankBase-1)];
            [_tileMap addChild:rbullet z:(kTankBase-1)];
            [bTurBullet addObject:bbullet];
            [rTurBullet addObject:rbullet];
            
        }
        
        [_bullets setObject:bTurBullet forKey:@"bTur"];
        [_bullets setObject:rTurBullet forKey:@"rTur"];
        
        NSLog(@"p1:%@",self.tank.bulletStr);
        
        for (int i = 0; i < 10; i++) {
            //Bullet *bullet = [self.tank defaultBulletForTank];
            Bullet *bullet = [Bullet bulletWithKey:self.tank.bulletStr];
            bullet.visible = NO;
            [_tileMap addChild:bullet z:kTankBullet];
            [p1Bullet addObject:bullet];
        }
        
        [_bullets setObject:p1Bullet forKey:@"p1"];
        
        if (_playerCount > 1) {
            switch (_playerCount) {
                case 2:
                    [self createP2Bullets];
                    break;
                    
            }
        }
    } else if (gametype == kMultiCoop) {
        CCArray *rTankBullet = [CCArray array];
        CCArray *rTurBullet = [CCArray array];
        
        CCArray *p1Bullet = [CCArray array];
        
        CCArray *rTanks = [self.redMobs objectForKey:@"enemy"];
        
        CCArray *bSpecial = [CCArray array];
        
        for (int i = 0; i < 10; i++) {
            Bullet *sbullet = [Bullet bulletWithKey:@"tank1_bullet.png"];
            sbullet.visible = NO;
            [_tileMap addChild:sbullet z:2];
            [bSpecial addObject:sbullet];
        }
        [_bullets setObject:bSpecial forKey:@"sBullet"];
        
        for (int i = 0; i < 20; i++) {
            Bullet *rbullet = [Bullet bulletWithKey:((Tanks*)[rTanks objectAtIndex:0]).bulletStr];
            rbullet.visible = NO;
            [_tileMap addChild:rbullet z:kTankBullet];
            [rTankBullet addObject:rbullet];
        }
        [_bullets setObject:rTankBullet forKey:@"rTank"];
        /*
        CCArray *rTurrets = [self.redMobs objectForKey:@"red_top"];
        for (int i = 0; i < 20; i++) {
            Bullet *rbullet = [Bullet bulletWithKey:((Tanks*)[rTurrets objectAtIndex:0]).bulletStr];
            rbullet.visible = NO;
            [_tileMap addChild:rbullet z:(kTankBase-1)];
            [rTurBullet addObject:rbullet];
        }
        [_bullets setObject:rTurBullet forKey:@"rTur"];//*/
        
        for (int i = 0; i < 10; i++) {
            //Bullet *bullet = [self.tank defaultBulletForTank];
            Bullet *bullet = [Bullet bulletWithKey:self.tank.bulletStr];
            bullet.visible = NO;
            [_tileMap addChild:bullet z:kTankBullet];
            [p1Bullet addObject:bullet];
        }
        
        [_bullets setObject:p1Bullet forKey:@"p1"];
        
        if (_playerCount > 1) {
            switch (_playerCount) {
                case 2:
                    [self createP2Bullets];
                    break;
                    
            }
        }
    }
    
}

- (void)createP2Bullets {
    CCArray *p2Bullet = [CCArray array];
    for (int i = 0; i < 10; i++) {
        Bullet *bullet = [Bullet bulletWithKey:self.tank2.bulletStr];
        bullet.visible = NO;
        [_tileMap addChild:bullet z:kTankBullet];
        [p2Bullet addObject:bullet];
    }
    
    [_bullets setObject:p2Bullet forKey:@"p2"];
    
}

- (void)createP3Bullets {
    CCArray *p3Bullet = [CCArray array];
    for (int i = 0; i < 10; i++) {
        Bullet *bullet = [Bullet bulletWithKey:self.tank2.bulletStr];
        bullet.visible = NO;
        [_tileMap addChild:bullet z:kTankBullet];
        [p3Bullet addObject:bullet];
    }
    
    [_bullets setObject:p3Bullet forKey:@"p3"];
    
}

- (void)createP4Bullets {
    CCArray *p4Bullet = [CCArray array];
    for (int i = 0; i < 10; i++) {
        Bullet *bullet = [Bullet bulletWithKey:self.tank2.bulletStr];
        bullet.visible = NO;
        [_tileMap addChild:bullet z:kTankBullet];
        [p4Bullet addObject:bullet];
    }
    
    [_bullets setObject:p4Bullet forKey:@"p4"];
    
}


+(id)gameLayerWithKey:(NSString *)key numPlayers:(int)num {
    TileMapLayer *layer = [[[TileMapLayer alloc] initLayerWithKey:key numPlayers:num] autorelease];
    return layer;
}

/*
-(id)initLayerWithKey:(NSString *)key numPlayers:(int)num {
    
    if ((self = [super init])) {
        
        _playerCount = num;
        if (_playerCount > 1) {
            AppDelegate * delegate = (AppDelegate *) [UIApplication sharedApplication].delegate;                
            [[GCHelper sharedInstance] findMatchWithMinPlayers:2 maxPlayers:2 viewController:delegate.viewController delegate:self];
            ourRandom = arc4random();
            [self setGameState:kGameStateWaitingForMatch];
            _isReady = NO;
            _syncTimer = 0;
        } else {
            _currentPlayerValue = 1;
        }
        
        self.proxManager = [[ProximityManager alloc] initProxWithSize:ADJUST_COORD(40)];
        [self addChild:self.proxManager];
        
        _tileMap = [HKTMXTiledMap tiledMapWithTMXFile:SD_OR_HD_TMX(key)];
        [self addChild:_tileMap];
        
        _bgLayer = [_tileMap layerNamed:@"Background"];
        
        CGSize winSize = [CCDirector sharedDirector].winSize;
        
        CGPoint spawnTileCoord = ccp(4,4);
        CGPoint spawnPos = [self positionForTileCoord:spawnTileCoord];
        [self setViewpointCenter:spawnPos];
        
        _batchNode = [CCSpriteBatchNode batchNodeWithFile:SD_OR_HD_PVR(@"sprites.pvr.ccz")];
        [_tileMap addChild:_batchNode];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:SD_OR_HD_PLIST(@"sprites.plist")];
        
        self.tank = [Tanks flashTankWithLayer:self team:1];
        
        self.tank.position = spawnPos;
        [_batchNode addChild:self.tank];
        [self.proxManager addObject:self.tank];
        
        self.tank2 = [Tanks shadowTankWithLayer:self team:1];
        self.tank2.position = spawnPos;
        [_batchNode addChild:self.tank2];
        
        
        
        
        self.isTouchEnabled = YES;
        [self scheduleUpdate];
        
        //self.scale = 0.5;
        //_bBulletCount = 0;
        //_rBulletCount = 0;
        
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"bgMusic.caf"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"explode.wav"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"tank1Shoot.wav"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"tank2Shoot.wav"];
        
        
        self.blueMobs = [[NSMutableDictionary alloc] init];
        self.redMobs = [[NSMutableDictionary alloc] init];
        
        self.actBlueMobs = [[CCArray alloc] init];
        self.actRedMobs = [[CCArray alloc] init];
        
        self.bullets = [[NSMutableDictionary alloc] init];
        
        [_actBlueMobs addObject:self.tank];
        
        
        
        for (int i = 0; i < 2; i++) {
            CCArray *mobArray = [CCArray array];
            NSString *key;
            for (int z = 0; z < INFANTRY_MAX/2; z++) {
                Tanks *soldier = [Tanks blueTankWithLayer:self team:1];
                switch (i) {
                    case 0:
                        soldier.mobLane = 1;
                        key = @"TopMob";
                        break;
                    case 1:
                        soldier.mobLane = 3;
                        key = @"BotMob";
                        break;
                }
                soldier.visible = NO;
                soldier.position = ccp(0, 0);
                [mobArray addObject:soldier];
                [_batchNode addChild:soldier];
                [self.actBlueMobs addObject:soldier];
                [self.proxManager addObject:soldier];
            }
            [self.blueMobs setObject:mobArray forKey:key];
        }
        for (int i = 0; i < 2; i++) {
            CCArray *mobArray = [CCArray array];
            NSString *key;
            for (int z = 0; z < INFANTRY_MAX/2; z++) {
                Tanks *soldier = [Tanks redTankWithLayer:self team:2];
                switch (i) {
                    case 0:
                        soldier.mobLane = 1;
                        key = @"TopMob";
                        break;
                    case 1:
                        soldier.mobLane = 3;
                        key = @"BotMob";
                        break;
                }
                soldier.visible = NO;
                soldier.position = ccp(0, 0);
                [mobArray addObject:soldier];
                [_batchNode addChild:soldier];
                [self.actRedMobs addObject:soldier];
                [self.proxManager addObject:soldier];
            }
            [self.redMobs setObject:mobArray forKey:key];
        }
        
        
        CCArray *rbullets = [CCArray array];
        CCArray *bbullets = [CCArray array];
        NSString *rkey = @"red_bullets";
        NSString *bkey = @"blue_bullets";
        
        for (int i = 0; i < BULLET_MAX; i++) {
            Bullet *rbullet = [Bullet bulletWithKey:@"red_tank_bullet.png"];
            Bullet *bbullet = [Bullet bulletWithKey:@"blue_tank_bullet.png"];
            rbullet.visible = NO;
            bbullet.visible = NO;
            [_batchNode addChild:rbullet];
            [_batchNode addChild:bbullet];
            [rbullets addObject:rbullet];
            [bbullets addObject:bbullet];
            
        }
        
        [self.bullets setObject:rbullets forKey:rkey];
        [self.bullets setObject:bbullets forKey:bkey];
        
        
        NSDictionary *turPosDict = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"turret_pos" ofType:@"plist"]];
        NSDictionary *turPos = [turPosDict objectForKey:@"long_map"];// needs to be linked to key, maybe creating a setting in devicesettings?
        
        for (int i = 0; i < 2; i++) {
            CCArray *redTurrets = [CCArray array];
            CCArray *blueTurrets = [CCArray array];
            NSDictionary *turPosBlue;
            NSDictionary *turPosRed;
            CCArray *turBlue;
            CCArray *turRed;
            NSString *keyBlue;
            NSString *keyRed;
            
            
            switch (i) {
                case 0:
                    keyBlue = @"blue_top";
                    keyRed = @"red_top";
                    break;
                case 1:
                    keyBlue = @"blue_bot";
                    keyRed = @"red_bot";
                    break;
            }
            
            turBlue = [turPos objectForKey:keyBlue];
            turRed = [turPos objectForKey:keyRed];
            
            for (int z = 0; z < 2; z++) {
                
                turPosBlue = [turBlue objectAtIndex:z];
                turPosRed = [turRed objectAtIndex:z];
                
                int bx = [[turPosBlue valueForKey:@"x"] intValue];
                int by = [[turPosBlue valueForKey:@"y"] intValue];
                CGPoint tilePos1 = ccp(bx, by);
                
                
                Tanks *bturret = [Tanks blueTurretWithLayer:self team:1];
                bturret.position = [self positionForTileCoord:tilePos1];
                
                bturret.visible = YES;
                [blueTurrets addObject:bturret];
                [_batchNode addChild:bturret];
                [self.actBlueMobs addObject:bturret];
                [self.proxManager addStaticObject:bturret];
                //[self.proxManager addObject:bturret];
                
                
                int rx = [[turPosRed valueForKey:@"x"] intValue];
                int ry = [[turPosRed valueForKey:@"y"] intValue];
                CGPoint tilePos2 = ccp(rx, ry);
                
                Tanks *rturret = [Tanks redTurretWithLayer:self team:2];
                rturret.position = [self positionForTileCoord:tilePos2];; 
                
                rturret.visible = YES;
                [redTurrets addObject:rturret];
                [_batchNode addChild:rturret];
                [self.actRedMobs addObject:rturret];
                [self.proxManager addStaticObject:rturret];
                //[self.proxManager addObject:rturret];
                
                NSLog(@"bx:%d, by:%d, rx:%d, ry:%d",bx,by,rx,ry);
                
                
            }//
            
            [_blueMobs setObject:blueTurrets forKey:keyBlue];
            [_redMobs setObject:redTurrets forKey:keyRed];
            
            
        }
        
        [turPosDict release];
        
        //[self schedule:@selector(startWave) interval:5];
        //[self schedule:@selector(checkProximity) interval:1/20];
        
        _explosion = [CCParticleSystemQuad particleWithFile:@"explosion.plist"];
        [_explosion stopSystem];
        [_tileMap addChild:_explosion z:1];
        
        _explosion2 = [CCParticleSystemQuad particleWithFile:@"explosion2.plist"];
        [_explosion2 stopSystem];
        [_tileMap addChild:_explosion2 z:1];
        
        CCLabelTTF *backLabel = [CCLabelTTF labelWithString:@"back" fontName:@"Arial" fontSize:HD_PIXELS(24)];
        
        CCMenuItemLabel *goBack = [CCMenuItemLabel itemWithLabel:backLabel target:self selector:@selector(onBack:)];
		
		CCMenu *menu = [CCMenu menuWithItems:goBack, nil];
		menu.position = ccp(winSize.width*0.9, winSize.height*0.9);
		[menu alignItemsVerticallyWithPadding: 20.0f];
		[self addChild:menu];
        
        if (_playerCount == 1) {
            _isReady = YES;
        }
        
        
        
        
        
    }
    
    return self;
}//*/


- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (_gameOver) return;
   
    
    UITouch *touch = [touches anyObject];
    CGPoint location = [_tileMap convertTouchToNodeSpace:touch];
    CGPoint locInView = [self convertTouchToNodeSpace:touch];
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    /*if (locInView.y < ADJUST_COORD(130) && (locInView.x < ADJUST_COORD(130) || locInView.x > winSize.width - ADJUST_COORD(130))) {
        return;
    } else {
        
        if (self.abilityFlagTouch == kNone) {
            CGPoint offset;
            switch (_currentPlayerValue) {
                case 1:
                    self.tank.shooting = YES;
                    offset = ccpSub(location, self.tank.position);
                    [self.tank shootToward:offset];
                    break;
                case 2:
                    self.tank2.shooting = YES;
                    offset = ccpSub(location, self.tank2.position);
                    [self.tank2 shootToward:offset];
                    break;
                    
            }
        } else {
            
        }
        
        
    }//*/
    
    
    
    
}

- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (_gameOver) return;
    
    UITouch *touch = [touches anyObject];
    CGPoint location = [_tileMap convertTouchToNodeSpace:touch];
    CGPoint locInView = [self convertTouchToNodeSpace:touch];
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    /*if (locInView.y < ADJUST_COORD(130) && (locInView.x < ADJUST_COORD(130) || locInView.x > winSize.width - ADJUST_COORD(130))) {
        return;
    } else {
        if (self.abilityFlagTouch == kNone) {
            CGPoint offset;
            switch (_currentPlayerValue) {
                case 1:
                    self.tank.shooting = YES;
                    offset = ccpSub(location, self.tank.position);
                    [self.tank shootToward:offset];
                    break;
                case 2:
                    self.tank2.shooting = YES;
                    offset = ccpSub(location, self.tank2.position);
                    [self.tank2 shootToward:offset];
                    break;
                    
            }
        } else {
            
        }
    }//*/
    
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    //NSLog(@"flag:%d",_abilityFlagTouch);
    
    
    UITouch *touch = [touches anyObject];
    CGPoint location = [_tileMap convertTouchToNodeSpace:touch];
    CGPoint locInView = [self convertTouchToNodeSpace:touch];
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    HeroTank *heroTank;
    
    
    
    if (locInView.y < ADJUST_COORD(130) && (locInView.x < ADJUST_COORD(130) || locInView.x > winSize.width - ADJUST_COORD(130))) {
        return;
    } else if (_playerCount > 1) {
        
        switch (_currentPlayerValue) {
            case 1:
                heroTank = self.tank;
                break;
            case 2:
                heroTank = self.tank2;
                break;
        }
        
        switch (self.abilityFlagTouch) {
            case kAbilityNone:
                //[self stopShooting:_currentPlayerValue];
                break;
            case kAbilityOne:
                [heroTank useAbilityOne:location];
                [self sendAbility:location Num:kAbilityOne];
                break;
            case kAbilityTwo:
                [heroTank useAbilityTwo:location];
                [self sendAbility:location Num:kAbilityTwo];
                break;
            case kAbilityThree:
                [heroTank useAbilityThree:location];
                [self sendAbility:location Num:kAbilityThree];
                break;
        }
        
        
        /*switch (self.abilityFlagTouch) {
            case kNone:
                [self stopShooting:_currentPlayerValue];
                break;
            case kShadowBullet:
                [heroTank shadowBullet];
                break;
            case kShadowHandGrab:
                [heroTank shadowHandGrab:location];
                break;
            case kShadowVoidZone:
                [heroTank shadowVoidZone];
                break;
            case kFlashBullet:
                [heroTank flashBullet];
                break;
            case kFlashBlink:
                [heroTank flashBlink:location];
                break;
            case kFlashFlash:
                [heroTank flashFlash:location];
                break;
        }//*/
    } else {
        
        heroTank = self.tank;
        
        switch (self.abilityFlagTouch) {
            case kAbilityNone:
                [self stopShooting:_currentPlayerValue];
                break;
            case kAbilityOne:
                [heroTank useAbilityOne:location];
                break;
            case kAbilityTwo:
                [heroTank useAbilityTwo:location];
                break;
            case kAbilityThree:
                [heroTank useAbilityThree:location];
                break;
        }
        //NSLog(@"tanktype:%d",heroTank.tankType);
    }
}

- (void)stopShooting:(int)player {
    switch (player) {
        case 1:
            self.tank.shooting = NO;
            break;
        case 2:
            self.tank2.shooting = NO;
            break;
    }
}

- (void)startShooting:(int)player {
    switch (player) {
        case 1:
            self.tank.shooting = YES;
            break;
        case 2:
            self.tank2.shooting = YES;
            break;
    }
}

- (void)goMainMenu {
    [SceneManager goMenu];
}

- (void)goNextLevel {
    NSDictionary *data;
    switch (_levelCounter) {
        case 1:
            data = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:_playerCount],@"numPlayers",[NSNumber numberWithInt:self.tank.tankType],@"p1",[NSNumber numberWithInt:self.tank2.tankType],@"p2",nil];
            [SceneManager playMap:@"world1_10.tmx" Data:data CurPlayer:_currentPlayerValue];
            break;
        case 10:
            [SceneManager goMenu];//world 1 complete
            break;
    }
}

- (void)levelDidCompleteSuccessful {
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    CCLabelTTF *back = [CCLabelTTF labelWithString:@"Main Menu" fontName:@"Arial" fontSize:HD_PIXELS(20)];
    CCLabelTTF *forward = [CCLabelTTF labelWithString:@"Next Level" fontName:@"Arial" fontSize:HD_PIXELS(20)];
    //back.color = ccc3(200, 230, 250);
    //forward.color = ccc3(200, 230, 250);
    
    CCMenuItemLabel *backLabel = [CCMenuItemLabel itemWithLabel:back target:self selector:@selector(goMainMenu)];
    CCMenuItemLabel *forLabel = [CCMenuItemLabel itemWithLabel:forward target:self selector:@selector(goNextLevel)];
    
    CCMenu *menu = [CCMenu menuWithItems:backLabel, forLabel, nil];
    menu.position = ccp(winSize.width/2, winSize.height/2);
    [menu alignItemsHorizontallyWithPadding: winSize.width*0.2];
    [self addChild:menu z:10];
    
}

- (void)levelDidCompleteFailure {
    
    
    
}

- (void)levelIncompleteDisconnect {
    
    
    
}


- (void)endScene:(EndReason)endReason {
    
    switch (endReason) {
        case kEndReasonWin:
            [self levelDidCompleteSuccessful];
            break;
        case kEndReasonLose:
            [self levelDidCompleteFailure];
            break;
        case kEndReasonDisconnect:
            [self levelIncompleteDisconnect];
            break;
    }
    
    
    
    
}

- (BOOL)intersectBetweenCircle1:(CGPoint)center1 rad1:(float)rad1 Circle2:(CGPoint)center2 rad2:(float)rad2 {
    
    double circleDistanceX = fabs(center1.x - center2.x);
    double circleDistanceY = fabs(center1.y - center2.y);
    
    if (circleDistanceX > (rad1+rad2)) { return false; }
    if (circleDistanceY > (rad1+rad2)) { return false; }
    
    double pointDistance_sq = pow(circleDistanceX, 2) + pow(circleDistanceY, 2);
    
    if (pointDistance_sq <= pow((rad1+rad2),2)) { return true; }
    else { return false;}
    
}

- (void)mobDidGetHit:(Tanks *)tank Damage:(int)dmg {
    
    tank.hp -= dmg;
    if (tank.hp <= 0) {
        if (tank.type != 4) {
            tank.visible = NO;
            tank.curWaypoint = 0;
            tank.position = ccp(0,0);
        }
    }
    
}



- (void)checkProximity {
    [self.proxManager update];
    //NSMutableArray *test = [self.proxManager getExactRange:self.tank.position.x y:self.tank.position.y range:200];
	//NSLog(@"%@",test);
    
    CCArray *bBullets = [self.bullets objectForKey:@"bTank"];
    CCArray *rBullets = [self.bullets objectForKey:@"rTank"];
    CCArray *bTurBullets = [self.bullets objectForKey:@"bTur"];
    CCArray *rTurBullets = [self.bullets objectForKey:@"rTur"];
    CCArray *sBullets = [self.bullets objectForKey:@"sBullet"];
    
    for (Bullet *bullet in sBullets) {
        if (bullet.visible) {
            CCArray *hits = [self.proxManager getRoughRange:bullet.position.x y:bullet.position.y range:bullet.radius];
            [hits removeObjectsInArray:self.actBlueMobs];
            for (Tanks *rTanks in hits) {
                if ([self intersectBetweenCircle1:rTanks.position rad1:rTanks.contentSize.width/2 Circle2:bullet.position rad2:bullet.radius]) {
                    bullet.visible = NO;
                    _explosion2.position = rTanks.position;
                    [_explosion2 resetSystem];
                    [self mobDidGetHit:rTanks Damage:bullet.damage];
                    [[SimpleAudioEngine sharedEngine] playEffect:@"explode1.wav"];
                    break;
                }
            }
        }
    }
    
    
    
    for (Bullet *bullet in rTurBullets) {
        if (bullet.visible) {
            CCArray *hits = [self.proxManager getRoughRange:bullet.position.x y:bullet.position.y range:bullet.radius];
            [hits removeObjectsInArray:self.actRedMobs];
            for (Tanks *bTanks in hits) {
                if ([self intersectBetweenCircle1:bTanks.position rad1:bTanks.contentSize.width/2 Circle2:bullet.position rad2:bullet.radius]) {
                    bullet.visible = NO;
                    _explosion2.position = bTanks.position;
                    [_explosion2 resetSystem];
                    
                    [self mobDidGetHit:bTanks Damage:bullet.damage];
                    
                    
                    [[SimpleAudioEngine sharedEngine] playEffect:@"explode1.wav"];
                    break;
                }
            }
        }
    }
    
    for (Bullet *bullet in bTurBullets) {
        if (bullet.visible) {
            CCArray *hits = [self.proxManager getRoughRange:bullet.position.x y:bullet.position.y range:bullet.radius];
            [hits removeObjectsInArray:self.actBlueMobs];
            for (Tanks *rTanks in hits) {
                if ([self intersectBetweenCircle1:rTanks.position rad1:rTanks.contentSize.width/2 Circle2:bullet.position rad2:bullet.radius]) {
                    bullet.visible = NO;
                    _explosion2.position = rTanks.position;
                    [_explosion2 resetSystem];
                    
                    [self mobDidGetHit:rTanks Damage:bullet.damage];
                    
                    
                    [[SimpleAudioEngine sharedEngine] playEffect:@"explode1.wav"];
                    break;
                }
            }
        }
    }//*/
    
    for (Bullet *bullet in rBullets) {
        if (bullet.visible) {
            CCArray *hits = [self.proxManager getRoughRange:bullet.position.x y:bullet.position.y range:bullet.radius];
            [hits removeObjectsInArray:self.actRedMobs];
            for (Tanks *bTanks in hits) {
                if ([self intersectBetweenCircle1:bTanks.position rad1:bTanks.contentSize.width/2 Circle2:bullet.position rad2:bullet.radius]) {
                    bullet.visible = NO;
                    _explosion2.position = bTanks.position;
                    [_explosion2 resetSystem];
                    
                    [self mobDidGetHit:bTanks Damage:bullet.damage];
                    
                    
                    [[SimpleAudioEngine sharedEngine] playEffect:@"explode1.wav"];
                    break;
                }
            }
            
            /*if (hits.count > 0) {
             bullet.visible = NO;
             Tanks *hitTank = [hits objectAtIndex:0];
             _explosion2.position = hitTank.position;
             [_explosion2 resetSystem];
             [[SimpleAudioEngine sharedEngine] playEffect:@"explode1.wav"];
             }//*/
        }
    }
    
    for (Bullet *bullet in bBullets) {
        if (bullet.visible) {
            CCArray *hits = [self.proxManager getRoughRange:bullet.position.x y:bullet.position.y range:bullet.radius];
            [hits removeObjectsInArray:self.actBlueMobs];
            for (Tanks *rTanks in hits) {
                if ([self intersectBetweenCircle1:rTanks.position rad1:rTanks.contentSize.width/2 Circle2:bullet.position rad2:bullet.radius]) {
                    bullet.visible = NO;
                    _explosion2.position = rTanks.position;
                    [_explosion2 resetSystem];
                    
                    [self mobDidGetHit:rTanks Damage:bullet.damage];
                    
                    
                    [[SimpleAudioEngine sharedEngine] playEffect:@"explode1.wav"];
                    break;
                }
            }
        }
    }//*/
    
    CCArray *p1Bullet = [self.bullets objectForKey:@"p1"];
    CCArray *p2Bullet = [self.bullets objectForKey:@"p2"];
    //CCArray *p3Bullet = [self.bullets objectForKey:@"p3"];
    //CCArray *p4Bullet = [self.bullets objectForKey:@"p4"];
    
    for (Bullet *bullet in p1Bullet) {
        if (bullet.visible) {
            CCArray *hits = [self.proxManager getRoughRange:bullet.position.x y:bullet.position.y range:bullet.radius];
            [hits removeObjectsInArray:self.actBlueMobs];
            for (Tanks *rTanks in hits) {
                if ([self intersectBetweenCircle1:rTanks.position rad1:rTanks.contentSize.width/2 Circle2:bullet.position rad2:bullet.radius]) {
                    bullet.visible = NO;
                    _explosion2.position = rTanks.position;
                    [_explosion2 resetSystem];
                    
                    
                    [self mobDidGetHit:rTanks Damage:bullet.damage];
                    
                    
                    [[SimpleAudioEngine sharedEngine] playEffect:@"explode1.wav"];
                    break;
                }
            }
        }
    }//*/
    
    for (Bullet *bullet in p2Bullet) {
        if (bullet.visible) {
            CCArray *hits = [self.proxManager getRoughRange:bullet.position.x y:bullet.position.y range:bullet.radius];
            [hits removeObjectsInArray:self.actBlueMobs];
            for (Tanks *rTanks in hits) {
                if ([self intersectBetweenCircle1:rTanks.position rad1:rTanks.contentSize.width/2 Circle2:bullet.position rad2:bullet.radius]) {
                    bullet.visible = NO;
                    _explosion2.position = rTanks.position;
                    [_explosion2 resetSystem];
                    
                    [self mobDidGetHit:rTanks Damage:bullet.damage];
                    
                    
                    [[SimpleAudioEngine sharedEngine] playEffect:@"explode1.wav"];
                    break;
                }
            }
        }
    }//*/
    
    
    /*for (Tanks *bluemob in self.actBlueMobs) {
        if (bluemob.visible && !bluemob.curTarget && bluemob.type < 4) {
            CCArray *test = [self.proxManager getExactRange:bluemob.position.x y:bluemob.position.y range:(int)bluemob.range];
            [test removeObjectsInArray:self.actBlueMobs];
            [test removeObjectsInArray:bluemob.targetsInRange];
            [bluemob addTargetArrayToArray:test];
            
            
        }
        
        
        
    }
    
    for (Tanks *redmob in self.actRedMobs) {
        if (redmob.visible && !redmob.curTarget && (redmob.type < 4 || redmob.type == 100)) {
            CCArray *test = [self.proxManager getExactRange:redmob.position.x y:redmob.position.y range:(int)redmob.range];
            [test removeObjectsInArray:self.actRedMobs];
            [test removeObjectsInArray:redmob.targetsInRange];
            [redmob addTargetArrayToArray:test];
        }
        
    }//*/
    
    
    
}

- (Bullet *)getBullet:(BulletType)type {
    
    Bullet *b;
    NSString *key;
    int counter;
    int max;
    
    
    switch (type) {
        case kBlueTank:
            key = @"bTank";
            counter = _bBulTankCount;
            max = 20;
            break;
        case kRedTank:
            key = @"rTank";
            counter = _rBulTankCount;
            max = 20;
            break;
        case kBlueTurret:
            key = @"bTur";
            counter = _bBulTurCount;
            max = 20;
            break;
        case kRedTurret:
            key = @"rTur";
            counter = _rBulTurCount;
            max = 20;
            break;
        case kP1Tank:
            key = @"p1";
            counter = _p1BulCount;
            max = 10;
            break;
        case kP2Tank:
            key = @"p2";
            counter = _p2BulCount;
            max = 10;
            break;
        case kP3Tank:
            key = @"p3";
            counter = _p3BulCount;
            max = 10;
            break;
        case kP4Tank:
            key = @"p4";
            counter = _p4BulCount;
            max = 10;
            break;
        case kHero:
            key = @"sBullet";
            counter = _sBulCount;
            max = 10;
            break;
    }
    CCArray *bulArray = [self.bullets objectForKey:key];
    b = [bulArray objectAtIndex:counter];
    counter++;
    if (counter >= max) {
        counter = 0;
    }
    
    switch (type) {
        case kBlueTank:
            _bBulTankCount = counter;
            break;
        case kRedTank:
            _rBulTankCount = counter;
            break;
        case kBlueTurret:
            _bBulTurCount = counter;
            break;
        case kRedTurret:
            _rBulTurCount = counter;
            break;
        case kP1Tank:
            _p1BulCount = counter;
            break;
        case kP2Tank:
            _p2BulCount = counter;
            break;
        case kP3Tank:
            _p3BulCount = counter;
            break;
        case kP4Tank:
            _p4BulCount = counter;
            break;
        case kHero:
            _sBulCount = counter;
            NSLog(@"bullet:%d",_sBulCount);
            break;
    }
    
    return b;
    
}




- (void)update:(ccTime)dt {
    
    if (!_isReady && _playerCount > 1) {
        return;
    }
    
    _syncTimer += dt;
    if (_syncTimer >= 5 && _playerCount > 1) {
        [self syncCurTank];
        _syncTimer = 0;
    }
    
    
    // 1
    //if (_gameOver) return;
    
    
    
    // 3
    //CCArray * childrenToRemove = [CCArray array];
    // 4
    
    
    switch (_currentPlayerValue) {
        case 1:
            [self setViewpointCenter:self.tank.position];
            break;
        case 2:
            [self setViewpointCenter:self.tank2.position];
            break;
    }
    
}

- (void)updateTankOffset {
    
    ZJoystick *_tempJoystick = (ZJoystick *)[self getChildByTag:50];
    
    if (_tempJoystick.isControlling) {
        CGPoint _contrPos = [_tileMap convertToNodeSpace:_tempJoystick.controller.position];
        CGPoint _centPos = [_tileMap convertToNodeSpace:_tempJoystick.position];
        CGPoint _offset = ccpSub(_centPos, _contrPos);
        _offset = ccpSub(self.tank.position, _offset);
        
        
        [self.tank moveToward:_offset];
        //NSLog(@"x:%f y:%f",_offset.x,_offset.y);
    }
    
}

- (void)updateTankShot {
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    ZJoystick *_tempJoystick = (ZJoystick *)[self getChildByTag:51];
    
    if (_tempJoystick.isControlling) {
        //CGPoint _contrPos = [_tileMap convertToNodeSpace:_tempJoystick.controller.position];
        //CGPoint _centPos = [_tileMap convertToNodeSpace:_tempJoystick.position];
        CGPoint _contrPos = _tempJoystick.controller.position;
        CGPoint _centPos = _tempJoystick.position;
        float adjX = _centPos.x - winSize.width + _tempJoystick.contentSize.width/2;
        float adjX2 = _contrPos.x - _tempJoystick.contentSize.width/2;
        _contrPos = ccp(adjX2, _contrPos.y);
        _centPos = ccp(adjX, _centPos.y);
        
        CGPoint _offset = ccpSub(_contrPos, _centPos);
        
        self.tank.shooting = YES;
        [self.tank shootToward:_offset];
        //NSLog(@"x:%f y:%f width:%f",_contrPos.x,_offset.y,winSize.width);
    } else {
        self.tank.shooting = NO;
    }
    
    
    
}

- (void)setMove:(CGPoint)moveOff {
    _moveOffset = moveOff;
    
    if (_playerCount > 1) {
        switch (self.currentPlayerValue) {
            case 1:
                [self.tank moveToward:_moveOffset];
                [self sendP1Move:_moveOffset];
                //[self sendP1Sync:self.tank.position];
                break;
            case 2:
                [self.tank2 moveToward:_moveOffset];
                [self sendP2Move:_moveOffset];
                //[self sendP2Sync:self.tank2.position];
                break;
        }
    } else {
        [self.tank moveToward:_moveOffset];
    }
    
    
}


- (void)setShot:(CGPoint)shotOff {
    
    _shotOffset = shotOff;
    switch (_currentPlayerValue) {
        case 1:
            [self.tank shootToward:_shotOffset];
            [self sendP1Shoot:_shotOffset];
            break;
        case 2:
            [self.tank2 shootToward:_shotOffset];
            [self sendP2Shoot:_shotOffset];
            break;
            
    }
    
    
    //_shotOffset = shotOff;
    //[self.tank shootToward:_shotOffset];
}

- (void)startWave {
    //[self unschedule:@selector(startWave)];
    
    CCTMXObjectGroup *objects;
    NSMutableDictionary *spawnPointBlue;
    NSMutableDictionary *spawnPointRed;
    CCArray *blueArray;
    CCArray *redArray;
    
    
    for (int i = 0; i < 2; i++) {
        switch (i) {
            case 0:
                objects = [_tileMap objectGroupNamed:@"WaypointsTop"];
                spawnPointBlue = [objects objectNamed:[NSString stringWithFormat:@"wp0"]];
                spawnPointRed = [objects objectNamed:[NSString stringWithFormat:@"wp11"]];
                blueArray = [_blueMobs objectForKey:@"TopMob"];
                redArray = [_redMobs objectForKey:@"TopMob"];
                break;
            case 1:
                objects = [_tileMap objectGroupNamed:@"WaypointsBot"];
                spawnPointBlue = [objects objectNamed:[NSString stringWithFormat:@"wp0"]];
                spawnPointRed = [objects objectNamed:[NSString stringWithFormat:@"wp11"]];
                blueArray = [_blueMobs objectForKey:@"BotMob"];
                redArray = [_redMobs objectForKey:@"BotMob"];
                break;
        }
        int x = [[spawnPointBlue valueForKey:@"x"] intValue];
		int y = [[spawnPointBlue valueForKey:@"y"] intValue];
        AI_Sprites *soldier = [blueArray objectAtIndex:_troopCounter];
        soldier.position = ccp(x/CC_CONTENT_SCALE_FACTOR(), y/CC_CONTENT_SCALE_FACTOR());
        soldier.visible = YES;
        //[self.proxManager addObject:soldier];
        int rx = [[spawnPointRed valueForKey:@"x"] intValue];
		int ry = [[spawnPointRed valueForKey:@"y"] intValue];
        AI_Sprites *rsoldier = [redArray objectAtIndex:_troopCounter];
        rsoldier.position = ccp(rx/CC_CONTENT_SCALE_FACTOR(), ry/CC_CONTENT_SCALE_FACTOR());
        rsoldier.visible = YES;
        //[self.proxManager addObject:rsoldier];
        //NSLog(@"x:%d y:%d",rx,ry);
        
    }
    
    _troopCounter++;
    
    if (_troopCounter >= INFANTRY_MAX/2 - 1) {
        _troopCounter = 0;
    }
    
    
    
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
    
    [_tank release]; _tank = nil;
    [_tank2 release]; _tank2 = nil;
    //[_batchNode release]; _batchNode = nil;
    [_blueMobs release]; _blueMobs = nil;
    [_redMobs release]; _redMobs = nil;
    
    [_actRedMobs release]; _actRedMobs = nil;
    [_actBlueMobs release]; _actBlueMobs = nil;
    
    [_bullets release]; _bullets = nil;
    [_proxManager release]; _proxManager = nil;
    
    //[_tileMap release]; _tileMap = nil;
    
	[super dealloc];
}




- (void)onBack:(id)sender
{
	[SceneManager goMenu];
}

- (void)setGameState:(GameState)state {
    
    gameState = state;
    if (gameState == kGameStateWaitingForMatch) {
        NSLog(@"Waiting for match");
    } else if (gameState == kGameStateWaitingForRandomNumber) {
        NSLog(@"Waiting for rand #");
    } else if (gameState == kGameStateWaitingForMap) {
        NSLog(@"Waiting for map");
    } else if (gameState == kGameStateActive) {
        NSLog(@"Active");
    } else if (gameState == kGameStateDone) {
        NSLog(@"Done");
    } 
    
}

#pragma mark GCHelperDelegate

/*- (void)matchStarted {    
    CCLOG(@"Match started");        
    if (receivedRandom) {
        [self setGameState:kGameStateWaitingForStart];
    } else {
        [self setGameState:kGameStateWaitingForRandomNumber];
    }
    [self sendRandomNumber];
    [self tryStartGame];
}//*/

- (void)matchEnded {    
    CCLOG(@"Match ended");    
    [[GCHelper sharedInstance].match disconnect];
    [GCHelper sharedInstance].match = nil;
    [self endScene:kEndReasonDisconnect];
}

- (void)match:(GKMatch *)match didReceiveData:(NSData *)data fromPlayer:(NSString *)playerID {
    
    // Store away other player ID for later
    if (otherPlayerID == nil) {
        otherPlayerID = [playerID retain];
    }
    
    Message *message = (Message *) [data bytes];
    if (message->messageType == kMessageTypeRandomNumber) {
        
        MessageRandomNumber * messageInit = (MessageRandomNumber *) [data bytes];
        CCLOG(@"Received random number: %ud, ours %ud", messageInit->randomNumber, ourRandom);
        bool tie = false;
        
        if (messageInit->randomNumber == ourRandom) {
            CCLOG(@"TIE!");
            tie = true;
            ourRandom = arc4random();
            [self sendRandomNumber];
        } else if (ourRandom > messageInit->randomNumber) {            
            CCLOG(@"We are player 1");
            isPlayer1 = YES; 
            self.currentPlayerValue = 1;
        } else {
            CCLOG(@"We are player 2");
            isPlayer1 = NO;
            self.currentPlayerValue = 2;
        }
        
        if (!tie) {
            receivedRandom = YES;    
            if (gameState == kGameStateWaitingForRandomNumber) {
                [self setGameState:kGameStateWaitingForStart];
            }
            //[self tryStartGame];        
        }
        
    } else if (message->messageType == kMessageTypeGameBegin) {        
        
        [self setGameState:kGameStateActive];
        _isReady = YES;
        [self schedule:@selector(startWave) interval:5];
        [self schedule:@selector(checkProximity) interval:1/20];
        /*switch (_currentPlayerValue) {
            case 1:
                [self createAbilityMenu:self.tank.tankType];
                break;
            case 2:
                [self createAbilityMenu:self.tank2.tankType];
                break;
        }//*/
        
    } else if (message->messageType == kMessageTypeMove) {     
        
        CCLOG(@"Received move");
        
               
    } else if (message->messageType == kMessageTypeGameOver) {        
        
        MessageGameOver * messageGameOver = (MessageGameOver *) [data bytes];
        CCLOG(@"Received game over with player 1 won: %d", messageGameOver->player1Won);
        
        if (messageGameOver->player1Won) {
            [self endScene:kEndReasonWin];    
        } else {
            [self endScene:kEndReasonLose];    
        }
        
    } else if (message->messageType == kMessageTypeP1Move) {
        
        MessagePlayerMove *messagePlayerMove = (MessagePlayerMove *)[data bytes];
        self.tank.moving = YES;
        [self.tank moveToward:ccp(messagePlayerMove->playerMove.x*ADJUST_COORD(1),messagePlayerMove->playerMove.y*ADJUST_COORD(1))];
        //CCLOG(@"recieved p1 move");
        //NSLog(@"1: %f, %f", messagePlayerMove->playerMove.x, messagePlayerMove->playerMove.y);
        
    } else if (message->messageType == kMessageTypeP2Move) {
        
        MessagePlayerMove *messagePlayerMove = (MessagePlayerMove *)[data bytes];
        self.tank2.moving = YES;
        [self.tank2 moveToward:ccp(messagePlayerMove->playerMove.x*ADJUST_COORD(1),messagePlayerMove->playerMove.y*ADJUST_COORD(1))];
        //CCLOG(@"recieved p2 move");
        //NSLog(@"2: %f, %f", messagePlayerMove->playerMove.x, messagePlayerMove->playerMove.y);
        
    } else if (message->messageType == kMessageTypeP1Sync) {
        
        MessagePlayerSync *messagePlayerMove = (MessagePlayerSync *)[data bytes];
        self.tank.position = ccp(messagePlayerMove->playerPos.x*ADJUST_COORD(1),messagePlayerMove->playerPos.y*ADJUST_COORD(1));
        //NSLog(@"1: %f, %f", messagePlayerMove->playerPos.x, messagePlayerMove->playerPos.y);
        
    } else if (message->messageType == kMessageTypeP2Sync) {
        
        MessagePlayerSync *messagePlayerMove = (MessagePlayerSync *)[data bytes];
        self.tank2.position = ccp(messagePlayerMove->playerPos.x*ADJUST_COORD(1),messagePlayerMove->playerPos.y*ADJUST_COORD(1));
        //NSLog(@"2: %f, %f", messagePlayerMove->playerPos.x, messagePlayerMove->playerPos.y);
        
    } else if (message->messageType == kMessageTypeP1Shoot) {
        self.tank.shooting = YES;
        MessagePlayerShoot *messagePlayerShoot = (MessagePlayerShoot *)[data bytes];
        [self.tank shootToward:ccp(messagePlayerShoot->shootPos.x*ADJUST_COORD(1),messagePlayerShoot->shootPos.y*ADJUST_COORD(1))];
        CCLOG(@"recieved p1 shoot");
        NSLog(@"1: %f, %f", messagePlayerShoot->shootPos.x, messagePlayerShoot->shootPos.y);
        [self schedule:@selector(tank1ShootDelay) interval:0.05];
    } else if (message->messageType == kMessageTypeP2Shoot) {
        self.tank2.shooting = YES;
        MessagePlayerShoot *messagePlayerShoot = (MessagePlayerShoot *)[data bytes];
        [self.tank2 shootToward:ccp(messagePlayerShoot->shootPos.x*ADJUST_COORD(1),messagePlayerShoot->shootPos.y*ADJUST_COORD(1))];
        CCLOG(@"recieved p2 shoot");
        NSLog(@"2: %f, %f", messagePlayerShoot->shootPos.x, messagePlayerShoot->shootPos.y);
        [self schedule:@selector(tank2ShootDelay) interval:0.05];
    } else if (message->messageType == kMessageTypeP1Ability) {
        MessagePlayerAbility *messagePlayerAbility = (MessagePlayerAbility *)[data bytes];
        switch (messagePlayerAbility->abilityNum) {
            case kAbilityOne:
                [self.tank useAbilityOne:ccp(messagePlayerAbility->abilityPos.x*ADJUST_COORD(1),messagePlayerAbility->abilityPos.y*ADJUST_COORD(1))];
                break;
            case kAbilityTwo:
                [self.tank useAbilityTwo:ccp(messagePlayerAbility->abilityPos.x*ADJUST_COORD(1),messagePlayerAbility->abilityPos.y*ADJUST_COORD(1))];
                break;
            case kAbilityThree:
                [self.tank useAbilityThree:ccp(messagePlayerAbility->abilityPos.x*ADJUST_COORD(1),messagePlayerAbility->abilityPos.y*ADJUST_COORD(1))];
                break;
        }
    } else if (message->messageType == kMessageTypeP2Ability) {
        MessagePlayerAbility *messagePlayerAbility = (MessagePlayerAbility *)[data bytes];
        switch (messagePlayerAbility->abilityNum) {
            case kAbilityOne:
                [self.tank2 useAbilityOne:ccp(messagePlayerAbility->abilityPos.x*ADJUST_COORD(1),messagePlayerAbility->abilityPos.y*ADJUST_COORD(1))];
                break;
            case kAbilityTwo:
                [self.tank2 useAbilityTwo:ccp(messagePlayerAbility->abilityPos.x*ADJUST_COORD(1),messagePlayerAbility->abilityPos.y*ADJUST_COORD(1))];
                break;
            case kAbilityThree:
                [self.tank2 useAbilityThree:ccp(messagePlayerAbility->abilityPos.x*ADJUST_COORD(1),messagePlayerAbility->abilityPos.y*ADJUST_COORD(1))];
                break;
        }
    } else if (message->messageType == kMessageTypeSpawnEnemy) {
        MessageSpawnEnemy *messageSpawnEnemy = (MessageSpawnEnemy *)[data bytes];
        NSLog(@"spawn received");
        _nextEnemyLoc = ccp(messageSpawnEnemy->spawnLoc.x*ADJUST_COORD(1), messageSpawnEnemy->spawnLoc.y*ADJUST_COORD(1));
        [self scheduleEnemySpawn];
        
    }
}

- (void)inviteReceived {
    [self restartTapped:nil];    
}

- (void)tank1ShootDelay {
    [self unschedule:@selector(tank1ShootDelay)];
    self.tank.shooting = NO;
}

- (void)tank2ShootDelay {
    [self unschedule:@selector(tank2ShootDelay)];
    self.tank2.shooting = NO;
}


@end
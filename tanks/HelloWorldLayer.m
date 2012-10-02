//
//  HelloWorldLayer.m
//  tanks
//
//  Created by Cullen O'Neill on 1/2/12.
//  Copyright Lot18 2012. All rights reserved.
//


// Import the interfaces
#import "HelloWorldLayer.h"
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


// HelloWorldLayer implementation
@implementation HelloWorldLayer

@synthesize batchNode = _batchNode;
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

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [HelloWorldLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

- (void)sendData:(NSData *)data {
    NSError *error;
    BOOL success = [[GCHelper sharedInstance].match sendDataToAllPlayers:data withDataMode:GKMatchSendDataReliable error:&error];
    if (!success) {
        CCLOG(@"Error sending init packet");
        [self matchEnded];
    }
}

- (void)sendRandomNumber {
    
    MessageRandomNumber message;
    message.message.messageType = kMessageTypeRandomNumber;
    message.randomNumber = ourRandom;
    NSData *data = [NSData dataWithBytes:&message length:sizeof(MessageRandomNumber)];    
    [self sendData:data];
}

- (void)sendGameBegin {
    
    MessageGameBegin message;
    message.message.messageType = kMessageTypeGameBegin;
    NSData *data = [NSData dataWithBytes:&message length:sizeof(MessageGameBegin)];    
    [self sendData:data];
    
}

- (void)sendMove {
    
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
    [[GCHelper sharedInstance] sendDataToAllPlayers:&message length:sizeof(message)];
    //NSData *data = [NSData dataWithBytes:&message length:sizeof(MessagePlayerMove)];
    //[self sendData:data];
    //NSLog(@"p1 move sent");
}

- (void)sendP2Move:(CGPoint)location {
    MessagePlayerMove message;
    message.message.messageType = kMessageTypeP2Move;
    message.playerMove = ccp(location.x/ADJUST_COORD(1),location.y/ADJUST_COORD(1));
    [[GCHelper sharedInstance] sendDataToAllPlayers:&message length:sizeof(message)];
    //NSData *data = [NSData dataWithBytes:&message length:sizeof(MessagePlayerMove)];
    //[self sendData:data];
    //NSLog(@"p2 move sent");
}

- (void)sendP3Move:(CGPoint)location {
    MessagePlayerMove message;
    message.message.messageType = kMessageTypeP3Move;
    message.playerMove = location;
    [[GCHelper sharedInstance] sendDataToAllPlayers:&message length:sizeof(message)];
    //NSData *data = [NSData dataWithBytes:&message length:sizeof(MessagePlayerMove)];
    //[self sendData:data];
}

- (void)sendP4Move:(CGPoint)location {
    MessagePlayerMove message;
    message.message.messageType = kMessageTypeP4Move;
    message.playerMove = location;
    [[GCHelper sharedInstance] sendDataToAllPlayers:&message length:sizeof(message)];
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




- (void)tryStartGame {
    
    if (gameState == kGameStateWaitingForStart) {
        [self setGameState:kGameStateActive];
        [self sendGameBegin];
    }
    
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

-(void)addWaypoint {
	DataModel *m = [DataModel getModel];
	
	CCTMXObjectGroup *objects = [_tileMap objectGroupNamed:@"WaypointsMid"];
	WayPoint *wp = nil;
	
	int spawnPointCounter = 0;
	NSMutableDictionary *spawnPoint;
	while ((spawnPoint = [objects objectNamed:[NSString stringWithFormat:@"Waypoint%d", spawnPointCounter]])) {
		int x = [[spawnPoint valueForKey:@"x"] intValue];
		int y = [[spawnPoint valueForKey:@"y"] intValue];
		
        //NSLog(@"x:%d,y:%d",x,y);
        
		wp = [WayPoint node];
		wp.position = ccp(x, y);
		[m._waypoints addObject:wp];
		spawnPointCounter++;
	}
	
	NSAssert([m._waypoints count] > 0, @"Waypoint objects missing");
	wp = nil;
}


#define INFANTRY_MAX 40
#define TANK_MAX 16
#define BULLET_MAX 100


+(id)gameLayerWithKey:(NSString *)key {
    HelloWorldLayer *layer = [[[HelloWorldLayer alloc] initLayerWithKey:key] autorelease];
    return layer;
}

-(id)initLayerWithKey:(NSString *)key {
    
    if ((self = [super init])) {
        
        AppDelegate * delegate = (AppDelegate *) [UIApplication sharedApplication].delegate;                
        [[GCHelper sharedInstance] findMatchWithMinPlayers:2 maxPlayers:2 viewController:delegate.viewController delegate:self];
        
        ourRandom = arc4random();
        [self setGameState:kGameStateWaitingForMatch];
        _isReady = NO;
        _syncTimer = 0;
        
        self.proxManager = [[ProximityManager alloc] initProxWithSize:ADJUST_COORD(40)];
        [self addChild:self.proxManager];
        
        _tileMap = [HKTMXTiledMap tiledMapWithTMXFile:SD_OR_HD_TMX(key)];
        //_tileMap = [CCTMXTiledMap tiledMapWithTMXFile:SD_OR_HD_TMX(@"basic_map.tmx")];
        [self addChild:_tileMap];
        
        _bgLayer = [_tileMap layerNamed:@"Background"];
        //_treeLayer = [_tileMap layerNamed:@"Trees"];
        
        CGSize winSize = [CCDirector sharedDirector].winSize;
        
        CGPoint spawnTileCoord = ccp(4,4);
        CGPoint spawnPos = [self positionForTileCoord:spawnTileCoord];
        [self setViewpointCenter:spawnPos];
        
        _batchNode = [CCSpriteBatchNode batchNodeWithFile:SD_OR_HD_PVR(@"sprites.pvr.ccz")];
        [_tileMap addChild:_batchNode];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:SD_OR_HD_PLIST(@"sprites.plist")];
        
        //self.tank = [Tanks heroTankWithLayer:self team:1];
        self.tank = [Tanks flashTankWithLayer:self team:1];
        //self.tank = [TankMob mobWithKey:@"flash" layer:self team:1];
        
        self.tank.position = spawnPos;
        [_batchNode addChild:self.tank];
        [self.proxManager addObject:self.tank];
        
        self.tank2 = [Tanks shadowTankWithLayer:self team:1];
        self.tank2.position = spawnPos;
        [_batchNode addChild:self.tank2];
        
        
        
        
        self.isTouchEnabled = YES;
        [self scheduleUpdate];
        
        //self.scale = 0.5;
        _bBulletCount = 0;
        _rBulletCount = 0;
        
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
                //AI_Sprites *soldier = [AI_Sprites blueTankOnLayer:self];
                //TankMob *soldier = [TankMob mobWithKey:@"blue_tank1" layer:self team:1];
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
                //AI_Sprites *soldier = [AI_Sprites redTankOnLayer:self];
                //TankMob *soldier = [TankMob mobWithKey:@"red_tank1" layer:self team:2];
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
        
        
        //NSDictionary *turPos = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"turret_pos" ofType:@"plist"]];
        NSDictionary *turPosDict = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"turret_pos" ofType:@"plist"]];
        NSDictionary *turPos = [turPosDict objectForKey:@"long_map"];
        //NSDictionary *turPos = [turPosDict objectForKey:@"basic_map"];
        
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
                //AI_Sprites *bturret = [AI_Sprites blueTurretOnLayer:self];
                //TankMob *bturret = [TankMob mobWithKey:@"blue_turret1" layer:self team:1];
                bturret.position = [self positionForTileCoord:tilePos1];
                
                bturret.visible = YES;
                [blueTurrets addObject:bturret];
                [_batchNode addChild:bturret];
                [self.actBlueMobs addObject:bturret];
                [self.proxManager addStaticObject:bturret];
                //[self.proxManager addObject:bturret];
                
                //_blueTroopCounter++;
                
                int rx = [[turPosRed valueForKey:@"x"] intValue];
                int ry = [[turPosRed valueForKey:@"y"] intValue];
                CGPoint tilePos2 = ccp(rx, ry);
                
                Tanks *rturret = [Tanks redTurretWithLayer:self team:2];
                //AI_Sprites *rturret = [AI_Sprites redTurretOnLayer:self];
                //TankMob *rturret = [TankMob mobWithKey:@"red_turret1" layer:self team:2];
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
    }
    
    return self;
}




// on "init" you need to initialize your instance
-(id) init
{
    if( (self=[super init])) {
        
        self.proxManager = [[ProximityManager alloc] initProxWithSize:ADJUST_COORD(40)];
        [self addChild:self.proxManager];
        
        _tileMap = [HKTMXTiledMap tiledMapWithTMXFile:SD_OR_HD_TMX(@"long_map.tmx")];
        //_tileMap = [CCTMXTiledMap tiledMapWithTMXFile:SD_OR_HD_TMX(@"basic_map.tmx")];
        [self addChild:_tileMap];
        
        _bgLayer = [_tileMap layerNamed:@"Background"];
        //_treeLayer = [_tileMap layerNamed:@"Trees"];
        
        CGSize winSize = [CCDirector sharedDirector].winSize;
        
        CGPoint spawnTileCoord = ccp(4,4);
        CGPoint spawnPos = [self positionForTileCoord:spawnTileCoord];
        [self setViewpointCenter:spawnPos];
        
        _batchNode = [CCSpriteBatchNode batchNodeWithFile:SD_OR_HD_PVR(@"sprites.pvr.ccz")];
        [_tileMap addChild:_batchNode];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:SD_OR_HD_PLIST(@"sprites.plist")];
        
        //self.tank = [Tanks heroTankWithLayer:self team:1];
        self.tank = [Tanks flashTankWithLayer:self team:1];
        //self.tank = [TankMob mobWithKey:@"flash" layer:self team:1];
        
        self.tank.position = spawnPos;
        [_batchNode addChild:self.tank];
        [self.proxManager addObject:self.tank];
        
        self.isTouchEnabled = YES;
        [self scheduleUpdate];
        
        //self.scale = 0.5;
        _bBulletCount = 0;
        _rBulletCount = 0;
        
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"bgMusic.caf"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"explode.wav"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"tank1Shoot.wav"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"tank2Shoot.wav"];
        
        //[self addWaypoint];
        //AI_Sprites *soldier = [AI_Sprites blueInfantryOnLayer:self];
        //soldier.mobLane = 1;
        //WayPoint *waypoint = [soldier getCurrentWaypoint];
        //soldier.position = waypoint.position;
        //[_batchNode addChild:soldier z:1 tag:100];
        
        
        
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
                //AI_Sprites *soldier = [AI_Sprites blueTankOnLayer:self];
                //TankMob *soldier = [TankMob mobWithKey:@"blue_tank1" layer:self team:1];
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
                //AI_Sprites *soldier = [AI_Sprites redTankOnLayer:self];
                //TankMob *soldier = [TankMob mobWithKey:@"red_tank1" layer:self team:2];
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
        
        
        
        /*
        for (int i = 0; i < 3; i++) {
            NSMutableArray *mobArray = [NSMutableArray array];
            NSString *key;
            for (int z = 0; z < INFANTRY_MAX/3; z++) {
                AI_Sprites *soldier = [AI_Sprites blueTankOnLayer:self];
                switch (i) {
                    case 0:
                        soldier.mobLane = 1;
                        key = @"TopMob";
                        break;
                    case 1:
                        soldier.mobLane = 2;
                        key = @"MidMob";
                        break;
                    case 2:
                        soldier.mobLane = 3;
                        key = @"BotMob";
                        break;
                }
                soldier.visible = NO;
                [mobArray addObject:soldier];
                [_batchNode addChild:soldier];
                [self.actBlueMobs addObject:soldier];
            }
            [self.blueMobs setObject:mobArray forKey:key];
        }
        for (int i = 0; i < 3; i++) {
            NSMutableArray *mobArray = [NSMutableArray array];
            NSString *key;
            for (int z = 0; z < INFANTRY_MAX/3; z++) {
                AI_Sprites *soldier = [AI_Sprites redTankOnLayer:self];
                switch (i) {
                    case 0:
                        soldier.mobLane = 1;
                        key = @"TopMob";
                        break;
                    case 1:
                        soldier.mobLane = 2;
                        key = @"MidMob";
                        break;
                    case 2:
                        soldier.mobLane = 3;
                        key = @"BotMob";
                        break;
                }
                soldier.visible = NO;
                [mobArray addObject:soldier];
                [_batchNode addChild:soldier];
                [self.actRedMobs addObject:soldier];
            }
            [self.redMobs setObject:mobArray forKey:key];
        }//*/
        
        //NSDictionary *turPos = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"turret_pos" ofType:@"plist"]];
        NSDictionary *turPosDict = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"turret_pos" ofType:@"plist"]];
        NSDictionary *turPos = [turPosDict objectForKey:@"long_map"];
        //NSDictionary *turPos = [turPosDict objectForKey:@"basic_map"];
        
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
                //AI_Sprites *bturret = [AI_Sprites blueTurretOnLayer:self];
                //TankMob *bturret = [TankMob mobWithKey:@"blue_turret1" layer:self team:1];
                bturret.position = [self positionForTileCoord:tilePos1];
                
                bturret.visible = YES;
                [blueTurrets addObject:bturret];
                [_batchNode addChild:bturret];
                [self.actBlueMobs addObject:bturret];
                [self.proxManager addStaticObject:bturret];
                //[self.proxManager addObject:bturret];
                
                //_blueTroopCounter++;
                
                int rx = [[turPosRed valueForKey:@"x"] intValue];
                int ry = [[turPosRed valueForKey:@"y"] intValue];
                CGPoint tilePos2 = ccp(rx, ry);
                
                Tanks *rturret = [Tanks redTurretWithLayer:self team:2];
                //AI_Sprites *rturret = [AI_Sprites redTurretOnLayer:self];
                //TankMob *rturret = [TankMob mobWithKey:@"red_turret1" layer:self team:2];
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

        
        
        
        
        /*
        for (int i = 0; i < 3; i++) {
            NSMutableArray *redTurrets = [NSMutableArray array];
            NSMutableArray *blueTurrets = [NSMutableArray array];
            NSDictionary *turPosBlue;
            NSDictionary *turPosRed;
            NSArray *turBlue;
            NSArray *turRed;
            NSString *keyBlue;
            NSString *keyRed;
            
            
            switch (i) {
                case 0:
                    keyBlue = @"blue_top";
                    keyRed = @"red_top";
                    break;
                case 1:
                    keyBlue = @"blue_mid";
                    keyRed = @"red_mid";
                    break;
                case 2:
                    keyBlue = @"blue_bot";
                    keyRed = @"red_bot";
                    break;
            }
            
            turBlue = [turPos objectForKey:keyBlue];
            turRed = [turPos objectForKey:keyRed];
            
            /*for (int z = 0; z < 2; z++) {
                
                turPosBlue = [turBlue objectAtIndex:z];
                turPosRed = [turRed objectAtIndex:z];
                
                int bx = [[turPosBlue valueForKey:@"x"] intValue];
                int by = [[turPosBlue valueForKey:@"y"] intValue];
                CGPoint tilePos1 = ccp(bx, by);
                
                AI_Sprites *bturret = [AI_Sprites blueTurretOnLayer:self];
                bturret.position = [self positionForTileCoord:tilePos1];
                
                bturret.visible = YES;
                [blueTurrets addObject:bturret];
                [_batchNode addChild:bturret];
                [self.actBlueMobs addObject:bturret];
                
                //_blueTroopCounter++;
                
                int rx = [[turPosRed valueForKey:@"x"] intValue];
                int ry = [[turPosRed valueForKey:@"y"] intValue];
                CGPoint tilePos2 = ccp(rx, ry);
                
                AI_Sprites *rturret = [AI_Sprites redTurretOnLayer:self];
                rturret.position = [self positionForTileCoord:tilePos2];; 
                
                rturret.visible = YES;
                [redTurrets addObject:rturret];
                [_batchNode addChild:rturret];
                [self.actRedMobs addObject:rturret];
                
                NSLog(@"bx:%d, by:%d, rx:%d, ry:%d",bx,by,rx,ry);
                
                
            }//
            
            [_blueMobs setObject:blueTurrets forKey:keyBlue];
            [_redMobs setObject:redTurrets forKey:keyRed];
            
            
        }//*/
        
        [turPosDict release];
        
        
        
        /*for (int i = 0; i < INFANTRY_MAX; i++) {
            AI_Sprites *soldier = [AI_Sprites blueInfantryOnLayer:self];
            [_batchNode addChild:soldier];
        }//*/
        
        
        [self schedule:@selector(startWave) interval:5];
        [self schedule:@selector(checkProximity) interval:1/20];
        
        
        /*for (int i = 0; i < NUM_ENEMY_TANKS; ++i) {
            
            
            RandomTank * enemy = [[RandomTank alloc] initWithLayer:self type:2 hp:2];
            enemy.RPM = 60;
            CGPoint randSpot;
            BOOL inWall = YES;
            
            while (inWall) {            
                randSpot.x = CCRANDOM_0_1() * [self tileMapWidth];
                randSpot.y = CCRANDOM_0_1() * [self tileMapHeight];
                inWall = [self isWallAtPosition:randSpot];                
            }
            
            enemy.position = randSpot;
            [_batchNode addChild:enemy];
            [_enemyTanks addObject:enemy];
            
        }//*/
        
        _explosion = [CCParticleSystemQuad particleWithFile:@"explosion.plist"];
        [_explosion stopSystem];
        [_tileMap addChild:_explosion z:1];
        
        _explosion2 = [CCParticleSystemQuad particleWithFile:@"explosion2.plist"];
        [_explosion2 stopSystem];
        [_tileMap addChild:_explosion2 z:1];
        
        /*
        _exit = [CCSprite spriteWithSpriteFrameName:@"exit.png"];
        CGPoint exitTileCoord = ccp(98, 98);
        CGPoint exitTilePos = [self positionForTileCoord:exitTileCoord];
        _exit.position = exitTilePos;
        [_batchNode addChild:_exit];//*/
        
        
        
        
        
        CCLabelTTF *backLabel = [CCLabelTTF labelWithString:@"reset" fontName:@"Arial" fontSize:HD_PIXELS(24)];
        
        CCMenuItemLabel *goBack = [CCMenuItemLabel itemWithLabel:backLabel target:self selector:@selector(onBack:)];
		
		CCMenu *menu = [CCMenu menuWithItems:goBack, nil];
		menu.position = ccp(winSize.width*0.9, winSize.height*0.9);
		[menu alignItemsVerticallyWithPadding: 20.0f];
		[self addChild:menu];
        
        
        
        //[self performSelectorInBackground:@selector(checkBluePositions) withObject:nil];
        //[self performSelectorInBackground:@selector(checkRedPositions) withObject:nil];
        
        
        
        
        
        
    }
    return self;
}



- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (_gameOver) return;
    /*
    CGSize winSize = [CCDirector sharedDirector].winSize;
    ZJoystick *_tempJoystick = (ZJoystick *)[self getChildByTag:50];
    for ( UITouch* touch in touches ) {
        CGPoint location = [self convertTouchToNodeSpace: touch];
        
        if (location.y < _tempJoystick.contentSize.height) {
            if (location.x < _tempJoystick.contentSize.width) {
                self.tank.moving = YES;
            } else if (location.x > winSize.width - _tempJoystick.contentSize.width) {
                self.tank.shooting = YES;
                [self updateTankShot];
            }
            
        }
        //code
        //NSLog(@"mx:%f my:%f",location.x,location.y);
    }//*/
    
    
    
    
    //self.tank.moving = YES;
    //[self.tank moveToward:mapLocation];
    
    
    //*/self.tank.shooting = YES;
    
    
    
    
    
    
    
}

- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (_gameOver) return;
    /*
    CGSize winSize = [CCDirector sharedDirector].winSize;
    ZJoystick *_tempJoystick = (ZJoystick *)[self getChildByTag:50];
    for ( UITouch* touch in touches ) {
        CGPoint location = [self convertTouchToNodeSpace: touch];
        
        if (location.y < _tempJoystick.contentSize.height) {
            if (location.x < _tempJoystick.contentSize.width) {
                self.tank.moving = YES;
            } else if (location.x > winSize.width - _tempJoystick.contentSize.width) {
                self.tank.shooting = YES;
                [self updateTankShot];
            }
            
        }
        //code
        //NSLog(@"mx:%f my:%f",location.x,location.y);
    }//*/
    
    /*
    UITouch * touch = [touches anyObject];
    CGPoint mapLocation = [_tileMap convertTouchToNodeSpace:touch];
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    //self.tank.moving = YES;
    //[self.tank moveToward:mapLocation];
    
    //self.tank.shooting = YES;
    //[self.tank shootToward:mapLocation];
    
    ZJoystick *_tempJoystick = (ZJoystick *)[self getChildByTag:50];
    CGPoint location = [self convertTouchToNodeSpace: touch];
    
    if (location.y < _tempJoystick.contentSize.height) {
        if (location.x < _tempJoystick.contentSize.width) {
            self.tank.moving = YES;
        } else if (location.x > winSize.width - _tempJoystick.contentSize.width) {
            self.tank.shooting = YES;
        }
        
     }//*///self.tank.shooting = YES;
    
    //NSLog(@"mx:%f my:%f",mapLocation.x,mapLocation.y);
    
   
    
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    //self.tank.shooting = NO;
    
}


- (void)restartTapped:(id)sender {
    [[CCDirector sharedDirector] replaceScene:[CCTransitionZoomFlipX transitionWithDuration:0.5 scene:[HelloWorldLayer scene]]];   
}

- (void)endScene:(EndReason)endReason {
    
    //if (_gameOver) return;
    //_gameOver = true;
    
    
    /*
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    NSString *message;
    if (endReason == kEndReasonWin) {
        message = @"You win!";
    } else if (endReason == kEndReasonLose) {
        message = @"You lose!";
    }
    
    CCLabelBMFont *label;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        label = [CCLabelBMFont labelWithString:message fntFile:@"TanksFont.fnt"];
    } else {
        label = [CCLabelBMFont labelWithString:message fntFile:@"TanksFont.fnt"];
    }
    label.scale = 0.1;
    label.position = ccp(winSize.width/2, winSize.height * 0.7);
    [self addChild:label];
    
    CCLabelBMFont *restartLabel;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        restartLabel = [CCLabelBMFont labelWithString:@"Restart" fntFile:@"TanksFont.fnt"];    
    } else {
        restartLabel = [CCLabelBMFont labelWithString:@"Restart" fntFile:@"TanksFont.fnt"];    
    }
    
    CCMenuItemLabel *restartItem = [CCMenuItemLabel itemWithLabel:restartLabel target:self selector:@selector(restartTapped:)];
    restartItem.scale = 0.1;
    restartItem.position = ccp(winSize.width/2, winSize.height * 0.3);
    
    CCMenu *menu = [CCMenu menuWithItems:restartItem, nil];
    menu.position = CGPointZero;
    [self addChild:menu];
    
    [restartItem runAction:[CCScaleTo actionWithDuration:0.5 scale:4.0]];
    [label runAction:[CCScaleTo actionWithDuration:0.5 scale:4.0]];//*/
    
}

/*
-(void)FollowPath:(id)sender {
    
	AI_Sprites *creep = (AI_Sprites *)sender;
	
	WayPoint * waypoint = [creep getNextWaypoint];
    
    
	id actionMove = [CCMoveTo actionWithDuration:moveDuration position:waypoint.position];
	id actionMoveDone = [CCCallFuncN actionWithTarget:self selector:@selector(FollowPath:)];
	[creep stopAllActions];
	[creep runAction:[CCSequence actions:actionMove, actionMoveDone, nil]];
}//*/


/*
- (void)checkBluePositions {
    
    //NSLog(@"blue pos start");
    
    NSMutableArray *mobArray = [[NSMutableArray alloc] init];
    NSMutableArray *enemyMobArray = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < 3; i++) {
        
        NSString *keyTur;
        NSString *keyMob;
        NSString *keyEnemyTur;
        
        switch (i) {
            case 0:
                keyTur = @"blue_top";
                keyMob = @"TopMob";
                keyEnemyTur = @"red_top";
                break;
            case 1:
                keyTur = @"blue_mid";
                keyMob = @"MidMob";
                keyEnemyTur = @"red_mid";
                break;
            case 2:
                keyTur = @"blue_bot";
                keyMob = @"BotMob";
                keyEnemyTur = @"red_bot";
                break;
        }
        
        [mobArray addObjectsFromArray:[_blueMobs objectForKey:keyMob]];
        [mobArray addObjectsFromArray:[_blueMobs objectForKey:keyTur]];
        [enemyMobArray addObjectsFromArray:[_redMobs objectForKey:keyMob]];
        [enemyMobArray addObjectsFromArray:[_redMobs objectForKey:keyEnemyTur]];
        
        for (Tanks *mob in mobArray) {
            
            if (!mob.visible) {
                return;
            } else {
                for (int z = 0; z < enemyMobArray.count; z++) {
                    
                    Tanks *enemy = [enemyMobArray objectAtIndex:z];
                    
                    if (!enemy.visible) {
                        return;
                    } else {
                        float _tarDist = ccpDistance(mob.position, enemy.position);
                        if (_tarDist < mob.range) {
                            [mob addTargetToArray:enemy];
                        }
                    }
                    
                }
                
            }
            
        }
        
    }
    
    [mobArray release];
    [enemyMobArray release];
    
    //[self performSelectorInBackground:@selector(checkBluePositions) withObject:nil];
    
}//*/


/*
- (void)checkRedPositions {
    
    //NSLog(@"red pos start");
    
    NSMutableArray *mobArray = [[NSMutableArray alloc] init];
    NSMutableArray *enemyMobArray = [[NSMutableArray alloc] init];
    NSArray *curTargets = [NSArray array];
    
    for (int i = 0; i < 3; i++) {
        
        NSString *keyTur;
        NSString *keyMob;
        NSString *keyEnemyTur;
        
        switch (i) {
            case 0:
                keyTur = @"red_top";
                keyMob = @"TopMob";
                keyEnemyTur = @"blue_top";
                break;
            case 1:
                keyTur = @"red_mid";
                keyMob = @"MidMob";
                keyEnemyTur = @"blue_mid";
                break;
            case 2:
                keyTur = @"red_bot";
                keyMob = @"BotMob";
                keyEnemyTur = @"blue_bot";
                break;
        }
        
        [mobArray addObjectsFromArray:[_redMobs objectForKey:keyMob]];
        [mobArray addObjectsFromArray:[_redMobs objectForKey:keyTur]];
        [enemyMobArray addObjectsFromArray:[_blueMobs objectForKey:keyMob]];
        [enemyMobArray addObjectsFromArray:[_blueMobs objectForKey:keyEnemyTur]];
        
        [enemyMobArray addObject:self.tank];
        
        for (Tanks *mob in mobArray) {
            
            if (!mob.visible) {
                return;
            } else {
                curTargets = mob.targetsInRange;
                
                for (int z = 0; z < enemyMobArray.count; z++) {
                    
                    Tanks *enemy = [enemyMobArray objectAtIndex:z];
                    
                    if (!enemy.visible) {
                        return;
                    } else if ([curTargets containsObject:enemy]) {
                        return;
                    } else {
                        float _tarDist = ccpDistance(mob.position, enemy.position);
                        if (_tarDist < mob.range) {
                            [mob addTargetToArray:enemy];
                        }
                    }
                    
                }
                
            }
            
        }
        
    }
    
    [mobArray release];
    [enemyMobArray release];
    
    //[self performSelectorInBackground:@selector(checkRedPositions) withObject:nil];
    
    
    
}//*/


- (void)checkPositions {
    
    _parsing = YES;
    
    
    for (int z = 0; z < self.actBlueMobs.count; z++) {
        Tanks *bluemob = [self.actBlueMobs objectAtIndex:2];
        if (!bluemob.visible) {
            return;
        } else {
            for (int i = 0; i < self.actRedMobs.count; i++) {
                Tanks *redmob = [self.actRedMobs objectAtIndex:3];
                if (!redmob.visible) {
                    return;
                } else {
                    float _tarDist = ccpDistance(bluemob.position, redmob.position);
                    if (_tarDist < bluemob.range) {
                        NSLog(@"added to bluemob");
                        [bluemob addTargetToArray:redmob];
                    }
                    if (_tarDist < redmob.range) {
                        NSLog(@"added to redmob");
                        [redmob addTargetToArray:bluemob];
                    }
                }
            }
        }
    }
    
    _parsing = NO;
    
    
    /*
    for (int z = 0; z < self.actBlueMobs.count; z++) {
        Tanks *bluemob = [self.actBlueMobs objectAtIndex:z];
        if (!bluemob.visible) {
            return;
        } else {
            for (int i = 0; i < self.actRedMobs.count; i++) {
                Tanks *redmob = [self.actRedMobs objectAtIndex:i];
                if (!redmob.visible) {
                    return;
                } else {
                    float _tarDist = ccpDistance(bluemob.position, redmob.position);
                    if (_tarDist < bluemob.range) {
                        NSLog(@"added to bluemob");
                        [bluemob addTargetToArray:redmob];
                    }
                    if (_tarDist < redmob.range) {
                        NSLog(@"added to redmob");
                        [redmob addTargetToArray:bluemob];
                    }
                }
            }
        }
    }//*/
    
    
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
        tank.visible = NO;
        tank.curWaypoint = 0;
        tank.position = ccp(0,0);
    }
    
}



- (void)checkProximity {
    [self.proxManager update];
    //NSMutableArray *test = [self.proxManager getExactRange:self.tank.position.x y:self.tank.position.y range:200];
	//NSLog(@"%@",test);
    
    CCArray *bBullets = [self.bullets objectForKey:@"blue_bullets"];
    CCArray *rBullets = [self.bullets objectForKey:@"red_bullets"];
    for (Bullet *bullet in rBullets) {
        if (bullet.visible) {
            CCArray *hits = [self.proxManager getRoughRange:bullet.position.x y:bullet.position.y range:bullet.radius];
            [hits removeObjectsInArray:self.actRedMobs];
            for (Tanks *bTanks in hits) {
                if ([self intersectBetweenCircle1:bTanks.position rad1:bTanks.contentSize.width/2 Circle2:bullet.position rad2:bullet.radius]) {
                    bullet.visible = NO;
                    _explosion2.position = bTanks.position;
                    [_explosion2 resetSystem];
                    
                    if (bTanks.type == 1) {
                        [self mobDidGetHit:bTanks Damage:100];
                    }
                    
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
                    
                    if (rTanks.type == 1) {
                        [self mobDidGetHit:rTanks Damage:100];
                    }
                    
                    [[SimpleAudioEngine sharedEngine] playEffect:@"explode1.wav"];
                    break;
                }
            }
        }
    }//*/
    
    for (Tanks *bluemob in self.actBlueMobs) {
        if (bluemob.visible && !bluemob.curTarget && bluemob.type < 4) {
            CCArray *test = [self.proxManager getExactRange:bluemob.position.x y:bluemob.position.y range:(int)bluemob.range];
            [test removeObjectsInArray:self.actBlueMobs];
            [test removeObjectsInArray:bluemob.targetsInRange];
            [bluemob addTargetArrayToArray:test];
            
            
        }
        
        
        
    }
    
    for (Tanks *redmob in self.actRedMobs) {
        if (redmob.visible && !redmob.curTarget && redmob.type < 4) {
            CCArray *test = [self.proxManager getExactRange:redmob.position.x y:redmob.position.y range:(int)redmob.range];
            [test removeObjectsInArray:self.actRedMobs];
            [test removeObjectsInArray:redmob.targetsInRange];
            [redmob addTargetArrayToArray:test];
        }
        
    }//*/
    
    
    
    
    
    /*for (Tanks *redmob in self.actBlueMobs) {
        NSMutableArray *test = [self.proxManager getExactRange:redmob.position.x y:redmob.position.y range:(int)redmob.range];
        for (Tanks *bluemob in test) {
            if (bluemob.team != redmob.team) {
                [redmob addTargetToArray:bluemob];
            }
        }
        
    }//*/
    
}

- (Bullet *)getBullet:(BulletType)type {
    
    Bullet *b;
    NSString *key;
    int counter;
    switch (type) {
        case kBlue:
            key = @"blue_bullets";
            counter = _bBulletCount;
            break;
        case kRed:
            key = @"red_bullets";
            counter = _rBulletCount;
            break;
        case kHero:
            key = @"blue_bullets";
            counter = _bBulletCount;
            break;
    }
    CCArray *bulArray = [self.bullets objectForKey:key];
    b = [bulArray objectAtIndex:counter];
    counter++;
    if (counter >= BULLET_MAX) {
        counter = 0;
    }
    
    switch (type) {
        case kBlue:
            _bBulletCount = counter;
            break;
        case kRed:
            _rBulletCount = counter;
            break;
        case kHero:
            _bBulletCount = counter;
            break;
    }
    
    return b;
    
}


- (void)update:(ccTime)dt {
    
    //test for adding targets to range array
    //id topTurret = [[_redMobs objectForKey:@"red_top"] objectAtIndex:1];
    //if (topTurret) NSLog(@"posx:%f posy:%f",topTurret.position.x,topTurret.position.y);
    //[topTurret addTargetToArray:self.tank];
    
    //[self checkBluePositions];
    //[self checkRedPositions];
    
    //if (!_parsing) {
    //    [self checkPositions];
    //}
    
    if (!_isReady) {
        return;
    }
    
    _syncTimer += dt;
    if (_syncTimer >= 5) {
        [self syncCurTank];
        _syncTimer = 0;
    }
    
    
    // 1
    //if (_gameOver) return;
    
    // 2
    if (CGRectIntersectsRect(_exit.boundingBox, _tank.boundingBox)) {
        [self endScene:kEndReasonWin];
    }
    
    // 3
    CCArray * childrenToRemove = [CCArray array];
    // 4
    
    /*
    for (CCSprite * sprite in self.batchNode.children) {
        // 5
        if (sprite.tag != 0) { // bullet     
            // 6       
            if ([self isWallAtPosition:sprite.position]) {
                //[childrenToRemove addObject:sprite];
                continue;
            }
            // 7
            if (sprite.tag == 1) { // hero bullet
                for (int j = _blueMobs.count - 1; j >= 0; j--) {
                    Tanks *enemy = [_blueMobs objectAtIndex:j];
                    if (CGRectIntersectsRect(sprite.boundingBox, enemy.boundingBox)) {
                        
                        //[childrenToRemove addObject:sprite];
                        enemy.hp--;
                        if (enemy.hp <= 0) {
                            [[SimpleAudioEngine sharedEngine] playEffect:@"explode3.wav"];
                            _explosion.position = enemy.position;
                            [_explosion resetSystem];
                            [_blueMobs removeObject:enemy];
                            //[childrenToRemove addObject:enemy];
                        } else {
                            _explosion2.position = enemy.position;
                            [_explosion2 resetSystem];
                            [[SimpleAudioEngine sharedEngine] playEffect:@"explode2.wav"];
                        }
                    }
                }
            }
            // 8
            if (sprite.tag == 2 && sprite.visible) { // enemy bullet                
                if (CGRectIntersectsRect(sprite.boundingBox, self.tank.boundingBox)) {                    
                    //[childrenToRemove addObject:sprite];
                    //self.tank.hp--;  //delete to remove invinciblity
                    sprite.visible = NO;
                    
                    if (self.tank.hp <= 0) {
                        [[SimpleAudioEngine sharedEngine] playEffect:@"explode2.wav"];                        
                        _explosion.position = self.tank.position;
                        [_explosion resetSystem];
                        [self endScene:kEndReasonLose];
                    } else {
                        _explosion2.position = self.tank.position;
                        [_explosion2 resetSystem];
                        [[SimpleAudioEngine sharedEngine] playEffect:@"explode1.wav"];                        
                    }
                }
            }
        }
    }
    for (CCSprite * child in childrenToRemove) {
        [child removeFromParentAndCleanup:YES];
    }//*/
    
    switch (_currentPlayerValue) {
        case 1:
            [self setViewpointCenter:self.tank.position];
            break;
        case 2:
            [self setViewpointCenter:self.tank2.position];
            break;
    }
    
    
    
    /*
    for (Tanks *bluemob in self.actBlueMobs) {
        if (bluemob.visible) {
            for (Tanks *redmob in self.actRedMobs) {
                if (redmob.visible) {
                    float _tarDist = ccpDistance(bluemob.position, redmob.position);
                    if (_tarDist < bluemob.range) {
                        //NSLog(@"added to bluemob");
                        [bluemob addTargetToArray:redmob];
                    }
                    if (_tarDist < redmob.range) {
                        //NSLog(@"added to redmob");
                        [redmob addTargetToArray:bluemob];
                    }
                } 
            }
        } 
    }//*/
    
    
    
    
    
    /*
    if (self.tank.moving) {
        [self updateTankOffset];
    }
    if (self.tank.shooting) {
        [self updateTankShot];
    }//*/
    
    
    
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
    
    
}


- (void)setShot:(CGPoint)shotOff {
    
    _shotOffset = shotOff;
    [self.tank shootToward:_shotOffset];
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

    
    /*
    for (int i = 0; i < 3; i++) {
        switch (i) {
            case 0:
                objects = [_tileMap objectGroupNamed:@"WaypointsTop"];
                spawnPointBlue = [objects objectNamed:[NSString stringWithFormat:@"Waypoint0"]];
                spawnPointRed = [objects objectNamed:[NSString stringWithFormat:@"Waypoint8"]];
                blueArray = [_blueMobs objectForKey:@"TopMob"];
                redArray = [_redMobs objectForKey:@"TopMob"];
                break;
            case 1: 
                objects = [_tileMap objectGroupNamed:@"WaypointsMid"];
                spawnPointBlue = [objects objectNamed:[NSString stringWithFormat:@"Waypoint0"]];
                spawnPointRed = [objects objectNamed:[NSString stringWithFormat:@"Waypoint4"]];
                blueArray = [_blueMobs objectForKey:@"MidMob"];
                redArray = [_redMobs objectForKey:@"MidMob"];
                break;
            case 2:
                objects = [_tileMap objectGroupNamed:@"WaypointsBot"];
                spawnPointBlue = [objects objectNamed:[NSString stringWithFormat:@"Waypoint0"]];
                spawnPointRed = [objects objectNamed:[NSString stringWithFormat:@"Waypoint8"]];
                blueArray = [_blueMobs objectForKey:@"BotMob"];
                redArray = [_redMobs objectForKey:@"BotMob"];
                break;
        }
        int x = [[spawnPointBlue valueForKey:@"x"] intValue];
		int y = [[spawnPointBlue valueForKey:@"y"] intValue];
        AI_Sprites *soldier = [blueArray objectAtIndex:_blueTroopCounter];
        soldier.position = ccp(x, y);
        soldier.visible = YES;
        //_blueTroopCounter++;
        int rx = [[spawnPointRed valueForKey:@"x"] intValue];
		int ry = [[spawnPointRed valueForKey:@"y"] intValue];
        AI_Sprites *rsoldier = [redArray objectAtIndex:0];
        rsoldier.position = ccp(rx, ry);
        rsoldier.visible = YES;
    }//*/
    
    /*CCTMXObjectGroup *objects = [_tileMap objectGroupNamed:@"WaypointsTop"];
    NSMutableDictionary *spawnPoint = [objects objectNamed:[NSString stringWithFormat:@"Waypoint0"]];
		int x = [[spawnPoint valueForKey:@"x"] intValue];
		int y = [[spawnPoint valueForKey:@"y"] intValue];
    
    AI_Sprites *soldier = (AI_Sprites*)[_batchNode getChildByTag:100];
    soldier.position = ccp(x, y);//*/
    //[soldier moveToNextWaypoint];
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
    } else if (gameState == kGameStateWaitingForStart) {
        NSLog(@"Waiting for start");
    } else if (gameState == kGameStateActive) {
        NSLog(@"Active");
    } else if (gameState == kGameStateDone) {
        NSLog(@"Done");
    } 
    
}

#pragma mark GCHelperDelegate

- (void)matchStarted {    
    CCLOG(@"Match started");        
    if (receivedRandom) {
        [self setGameState:kGameStateWaitingForStart];
    } else {
        [self setGameState:kGameStateWaitingForRandomNumber];
    }
    [self sendRandomNumber];
    [self tryStartGame];
}

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
            [self tryStartGame];        
        }
        
    } else if (message->messageType == kMessageTypeGameBegin) {        
        
        [self setGameState:kGameStateActive];
        _isReady = YES;
        [self schedule:@selector(startWave) interval:5];
        [self schedule:@selector(checkProximity) interval:1/20];
        
    } else if (message->messageType == kMessageTypeMove) {     
        
        CCLOG(@"Received move");
        
        if (isPlayer1) {
            //[player2 moveForward];
        } else {
            //[player1 moveForward];
        }        
    } else if (message->messageType == kMessageTypeGameOver) {        
        
        MessageGameOver * messageGameOver = (MessageGameOver *) [data bytes];
        CCLOG(@"Received game over with player 1 won: %d", messageGameOver->player1Won);
        
        if (messageGameOver->player1Won) {
            [self endScene:kEndReasonLose];    
        } else {
            [self endScene:kEndReasonWin];    
        }
        
    } else if (message->messageType == kMessageTypeP1Move) {
        
        MessagePlayerMove *messagePlayerMove = (MessagePlayerMove *)[data bytes];
        self.tank.moving = YES;
        [self.tank moveToward:ccp(messagePlayerMove->playerMove.x*ADJUST_COORD(1),messagePlayerMove->playerMove.y*ADJUST_COORD(1))];
        //CCLOG(@"recieved p1 move");
        NSLog(@"1: %f, %f", messagePlayerMove->playerMove.x, messagePlayerMove->playerMove.y);
        
    } else if (message->messageType == kMessageTypeP2Move) {
        
        MessagePlayerMove *messagePlayerMove = (MessagePlayerMove *)[data bytes];
        self.tank2.moving = YES;
        [self.tank2 moveToward:ccp(messagePlayerMove->playerMove.x*ADJUST_COORD(1),messagePlayerMove->playerMove.y*ADJUST_COORD(1))];
        //CCLOG(@"recieved p2 move");
        NSLog(@"2: %f, %f", messagePlayerMove->playerMove.x, messagePlayerMove->playerMove.y);
        
    } else if (message->messageType == kMessageTypeP1Sync) {
        
        MessagePlayerSync *messagePlayerMove = (MessagePlayerSync *)[data bytes];
        self.tank.position = ccp(messagePlayerMove->playerPos.x*ADJUST_COORD(1),messagePlayerMove->playerPos.y*ADJUST_COORD(1));
        NSLog(@"1: %f, %f", messagePlayerMove->playerPos.x, messagePlayerMove->playerPos.y);
        
    } else if (message->messageType == kMessageTypeP2Sync) {
        
        MessagePlayerSync *messagePlayerMove = (MessagePlayerSync *)[data bytes];
        self.tank2.position = ccp(messagePlayerMove->playerPos.x*ADJUST_COORD(1),messagePlayerMove->playerPos.y*ADJUST_COORD(1));
        NSLog(@"2: %f, %f", messagePlayerMove->playerPos.x, messagePlayerMove->playerPos.y);
        
    }
}

- (void)inviteReceived {
    [self restartTapped:nil];    
}


@end

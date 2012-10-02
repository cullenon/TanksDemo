//
//  LevelSelectLayer.m
//  tanks
//
//  Created by Cullen O'Neill on 3/4/12.
//  Copyright 2012 Lot18. All rights reserved.
//

#import "LevelSelectLayer.h"
#import "AppDelegate.h"
#import "CCMenuAdvanced.h"
#import "DeviceSettings.h"
#import "SceneManager.h"


@implementation LevelSelectLayer

@synthesize currentPlayerValue = _currentPlayerValue;
@synthesize levelSprites = _levelSprites;
@synthesize levelStrings = _levelStrings;
@synthesize levelImg = _levelImg;
@synthesize levelSelectDict = _levelSelectDict;


- (void)setGameState:(GameState)state {
    
    gameState = state;
    if (gameState == kGameStateWaitingForMatch) {
        NSLog(@"Waiting for match");
    } else if (gameState == kGameStateWaitingForRandomNumber) {
        NSLog(@"Waiting for rand #");
    } else if (gameState == kGameStateWaitingForStart) {
        NSLog(@"Waiting for start");
    } else if (gameState == kGameStateWaitingForMap) {
        NSLog(@"Waiting for map");
    } else if (gameState == kGameStateActive) {
        NSLog(@"Active");
    } else if (gameState == kGameStateDone) {
        NSLog(@"Done");
    } 
    
}

+ (id)singlePlayerSelect {
    LevelSelectLayer *layer = [[[LevelSelectLayer alloc] initWithNum:1 curPID:0] autorelease];
    return layer;
}

+ (id)multiPlayerSelect:(int)players {
    LevelSelectLayer *layer = [[[LevelSelectLayer alloc] initWithNum:players curPID:0] autorelease];
    return layer;
}

- (NSString *)returnMapString:(NSString *)string {
    
    NSString *newString = [string stringByReplacingOccurrencesOfString:@".png" withString:@".tmx"];
    return newString;
}

- (void)onBack {
    [SceneManager goMenu];
}

- (id)initWithNum:(int)players curPID:(int)playID {
    
    if ((self = [super init])) {
        
        CGSize winSize = [CCDirector sharedDirector].winSize;
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:SD_OR_HD_PLIST(@"maps.plist")];
        
        CCLabelTTF *backLabel = [CCLabelTTF labelWithString:@"Back" fontName:@"Arial" fontSize:HD_PIXELS(20)];
        CCMenuItemLabel *back = [CCMenuItemLabel itemWithLabel:backLabel target:self selector:@selector(onBack)];
        CCMenu *backmenu = [CCMenu menuWithItems:back, nil];
        backmenu.position = ccp(winSize.width*0.2,winSize.height*0.8);
        [self addChild:backmenu];
        
        if (players > 1) {
            AppDelegate * delegate = (AppDelegate *) [UIApplication sharedApplication].delegate;                
            [[GCHelper sharedInstance] findMatchWithMinPlayers:2 maxPlayers:2 viewController:delegate.viewController delegate:self];
            
            ourRandom = arc4random();
            [self setGameState:kGameStateWaitingForMatch];
            _isReady = NO;
            _numPlayers = players;
            
            CCSprite *rightNormal = [CCSprite spriteWithSpriteFrameName:@"arrow_right.png"];
            CCSprite *rightSelect = [CCSprite spriteWithSpriteFrameName:@"arrow_right.png"];
            CCSprite *rightDisabled = [CCSprite spriteWithSpriteFrameName:@"arrow_right.png"];
            [rightNormal setColor:ccRED];
            [rightSelect setColor:ccGRAY];
            [rightDisabled setColor:ccGRAY];
            
            CCMenuItemSprite *nextLevel = [CCMenuItemSprite itemFromNormalSprite:rightNormal selectedSprite:rightSelect disabledSprite:rightDisabled target:self selector:@selector(runMap)];
            CCMenu *menuNext = [CCMenu menuWithItems:nextLevel, nil];
            menuNext.position = ccp(winSize.width*0.85, winSize.height*0.75);
            [self addChild:menuNext z:1 tag:100];
            CCArray *kids = [menuNext children];
            for (CCMenuItem *item in kids) {
                //item.isEnabled = NO;
            }
            
            
            
        } else {
            _numPlayers = 1;
            _isReady = YES;
            isPlayer1 = YES;
            _currentPlayerValue = 1;
            
        }
        
        
        
        
        
        
        CCSprite *leftNormal = [CCSprite spriteWithSpriteFrameName:@"arrow_left.png"];
        CCSprite *leftSelect = [CCSprite spriteWithSpriteFrameName:@"arrow_left.png"];
        CCSprite *leftDisabled = [CCSprite spriteWithSpriteFrameName:@"arrow_left.png"];
        CCSprite *rightNormal = [CCSprite spriteWithSpriteFrameName:@"arrow_right.png"];
        CCSprite *rightSelect = [CCSprite spriteWithSpriteFrameName:@"arrow_right.png"];
        CCSprite *rightDisabled = [CCSprite spriteWithSpriteFrameName:@"arrow_right.png"];
        [leftSelect setColor:ccGRAY];
        [leftDisabled setColor:ccGRAY];
        [rightSelect setColor:ccGRAY];
        [rightDisabled setColor:ccGRAY];
        
        CCMenuItemSprite *nextLevel = [CCMenuItemSprite itemFromNormalSprite:rightNormal selectedSprite:rightSelect disabledSprite:rightDisabled target:self selector:@selector(goNextLevel)];
        CCMenuItemSprite *backLevel = [CCMenuItemSprite itemFromNormalSprite:leftNormal selectedSprite:leftSelect disabledSprite:leftDisabled target:self selector:@selector(goBackLevel)];
        
        
        CCMenu *menu1 = [CCMenu menuWithItems:backLevel, nil];
        menu1.position = ccp(winSize.width*0.2, winSize.height*0.5);
        [self addChild:menu1];
        CCMenu *menu2 = [CCMenu menuWithItems:nextLevel, nil];
        menu2.position = ccp(winSize.width*0.8, winSize.height*0.5);
        [self addChild:menu2];
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:SD_OR_HD_PLIST(@"sprites.plist")];
        
        CCSprite *shadow1 = [CCSprite spriteWithSpriteFrameName:@"shadow_base.png"];
        CCSprite *flash1 = [CCSprite spriteWithSpriteFrameName:@"flash_base.png"];
        CCSprite *blaze1 = [CCSprite spriteWithSpriteFrameName:@"blaze_base.png"];
        CCSprite *iceberg1 = [CCSprite spriteWithSpriteFrameName:@"iceberg_base.png"];
        CCSprite *shadow2 = [CCSprite spriteWithSpriteFrameName:@"shadow_base.png"];
        CCSprite *flash2 = [CCSprite spriteWithSpriteFrameName:@"flash_base.png"];
        CCSprite *blaze2 = [CCSprite spriteWithSpriteFrameName:@"blaze_base.png"];
        CCSprite *iceberg2 = [CCSprite spriteWithSpriteFrameName:@"iceberg_base.png"];
        [shadow2 setColor:ccGRAY];
        [flash2 setColor:ccGRAY];
        [blaze2 setColor:ccGRAY];
        [iceberg2 setColor:ccGRAY];
        
        
        CCMenuItemSprite *tank1 = [CCMenuItemSprite itemFromNormalSprite:shadow1 selectedSprite:shadow2 target:self selector:@selector(tank1)];
        CCMenuItemSprite *tank2 = [CCMenuItemSprite itemFromNormalSprite:flash1 selectedSprite:flash2 target:self selector:@selector(tank2)];
        CCMenuItemSprite *tank3 = [CCMenuItemSprite itemFromNormalSprite:blaze1 selectedSprite:blaze2 target:self selector:@selector(tank3)];
        CCMenuItemSprite *tank4 = [CCMenuItemSprite itemFromNormalSprite:iceberg1 selectedSprite:iceberg2 target:self selector:@selector(tank4)];
        
        CCMenuAdvanced *menu = [CCMenuAdvanced menuWithItems:tank1,tank2,tank3,tank4, nil];
        
        
        [menu alignItemsHorizontallyWithPadding:ADJUST_COORD(16) leftToRight: YES]; //< also sets contentSize and keyBindings on Mac
        menu.isRelativeAnchorPoint = YES;	
        
        
        //widget
        menu.anchorPoint = ccp(0.5f, 1);
        //menu.position = ccp(winSize.width / 4, winSize.height*0.5);
        
        menu.scale = MIN ((winSize.width / 2.0f) / menu.contentSize.width, 2.00f );
        
        menu.boundaryRect = CGRectMake(MAX(0, winSize.width / 4.0f - [menu boundingBox].size.width / 2.0f),
                                       winSize.height*0.05,
                                       winSize.width,
                                       [menu boundingBox].size.height);
        
        [menu fixPosition];
        
        [self addChild:menu];//*/
        
        
        //self.levelStrings = [[CCArray alloc] init];
        _levelSelectDict = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"levels" ofType:@"plist"]];
        //_levelStrings = [[CCArray alloc] initWithArray:[_levelSelectDict objectForKey:@"all_maps"]];
        
        self.levelSprites = [[CCArray alloc] initWithCapacity:2];
        _levelIndex = 0;
        
        _levelImg = [CCSprite spriteWithSpriteFrameName:[[_levelSelectDict objectForKey:@"all_maps"] objectAtIndex:_levelIndex]];
        _levelImg.position = ccp(winSize.width/2,winSize.height/2);
        _levelImg.scale = 0.5;
        [self addChild:_levelImg];
        
        [self schedule:@selector(lobbyRefresh) interval:1];
        
        
    }
    
    return self;

    
    
}

/*
- (id)initWithMulti:(BOOL)YesMulti {
    
    if ((self = [super init])) {
        
        if (YesMulti) {
            AppDelegate * delegate = (AppDelegate *) [UIApplication sharedApplication].delegate;                
            [[GCHelper sharedInstance] findMatchWithMinPlayers:2 maxPlayers:2 viewController:delegate.viewController delegate:self];
            
            ourRandom = arc4random();
            [self setGameState:kGameStateWaitingForMatch];
            _isReady = NO;
            
            
            
            
        } else {
            
            _numPlayers = 1;
            isPlayer1 = YES;
            _isReady = YES;
            CGSize winSize = [CCDirector sharedDirector].winSize;
            //_batchNode = [CCSpriteBatchNode batchNodeWithFile:SD_OR_HD_PVR(@"maps.pvr.ccz")];
            //[self addChild:_batchNode];
            [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:SD_OR_HD_PLIST(@"maps.plist")];
            
            CCSprite *leftNormal = [CCSprite spriteWithSpriteFrameName:@"arrow_left.png"];
            CCSprite *leftSelect = [CCSprite spriteWithSpriteFrameName:@"arrow_left.png"];
            CCSprite *leftDisabled = [CCSprite spriteWithSpriteFrameName:@"arrow_left.png"];
            CCSprite *rightNormal = [CCSprite spriteWithSpriteFrameName:@"arrow_right.png"];
            CCSprite *rightSelect = [CCSprite spriteWithSpriteFrameName:@"arrow_right.png"];
            CCSprite *rightDisabled = [CCSprite spriteWithSpriteFrameName:@"arrow_right.png"];
            [leftSelect setColor:ccGRAY];
            [leftDisabled setColor:ccGRAY];
            [rightSelect setColor:ccGRAY];
            [rightDisabled setColor:ccGRAY];
            
            CCMenuItemSprite *nextLevel = [CCMenuItemSprite itemFromNormalSprite:rightNormal selectedSprite:rightSelect disabledSprite:rightDisabled target:self selector:@selector(goNextLevel)];
            CCMenuItemSprite *backLevel = [CCMenuItemSprite itemFromNormalSprite:leftNormal selectedSprite:leftSelect disabledSprite:leftDisabled target:self selector:@selector(goBackLevel)];
            
            //nextLevel.position = ccp(winSize.width*0.8, winSize.height*0.5);
            //backLevel.position = ccp(winSize.width*0.2, winSize.height*0.5);
            
            CCMenu *menu1 = [CCMenu menuWithItems:backLevel, nil];
            menu1.position = ccp(winSize.width*0.2, winSize.height*0.5);
            [self addChild:menu1];
            CCMenu *menu2 = [CCMenu menuWithItems:nextLevel, nil];
            menu2.position = ccp(winSize.width*0.8, winSize.height*0.5);
            [self addChild:menu2];
            
            [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:SD_OR_HD_PLIST(@"sprites.plist")];
            
            CCSprite *shadow1 = [CCSprite spriteWithSpriteFrameName:@"shadow_base.png"];
            CCSprite *flash1 = [CCSprite spriteWithSpriteFrameName:@"flash_base.png"];
            CCSprite *shadow2 = [CCSprite spriteWithSpriteFrameName:@"shadow_base.png"];
            CCSprite *flash2 = [CCSprite spriteWithSpriteFrameName:@"flash_base.png"];
            CCSprite *shadow12 = [CCSprite spriteWithSpriteFrameName:@"shadow_base.png"];
            CCSprite *flash12 = [CCSprite spriteWithSpriteFrameName:@"flash_base.png"];
            CCSprite *shadow22 = [CCSprite spriteWithSpriteFrameName:@"shadow_base.png"];
            CCSprite *flash22 = [CCSprite spriteWithSpriteFrameName:@"flash_base.png"];
            [shadow12 setColor:ccGRAY];
            [flash12 setColor:ccGRAY];
            [shadow22 setColor:ccGRAY];
            [flash22 setColor:ccGRAY];
            
            
            CCMenuItemSprite *tank1 = [CCMenuItemSprite itemFromNormalSprite:shadow1 selectedSprite:shadow12 target:self selector:@selector(tank1)];
            CCMenuItemSprite *tank2 = [CCMenuItemSprite itemFromNormalSprite:flash1 selectedSprite:flash12 target:self selector:@selector(tank2)];
            CCMenuItemSprite *tank3 = [CCMenuItemSprite itemFromNormalSprite:shadow2 selectedSprite:shadow22 target:self selector:@selector(tank3)];
            CCMenuItemSprite *tank4 = [CCMenuItemSprite itemFromNormalSprite:flash2 selectedSprite:flash22 target:self selector:@selector(tank4)];
            
            CCMenuAdvanced *menu = [CCMenuAdvanced menuWithItems:tank1,tank2,tank3,tank4, nil];
            
            
            [menu alignItemsHorizontallyWithPadding:ADJUST_COORD(16) leftToRight: YES]; //< also sets contentSize and keyBindings on Mac
            menu.isRelativeAnchorPoint = YES;	
            
            
            //widget
            menu.anchorPoint = ccp(0.5f, 1);
            //menu.position = ccp(winSize.width / 4, winSize.height*0.5);
            
            menu.scale = MIN ((winSize.width / 2.0f) / menu.contentSize.width, 2.00f );
            
            menu.boundaryRect = CGRectMake(MAX(0, winSize.width / 4.0f - [menu boundingBox].size.width / 2.0f),
                                           winSize.height*0.05,
                                           winSize.width,
                                           [menu boundingBox].size.height);
            
            [menu fixPosition];
            
            [self addChild:menu];//*/
            
            
            
            
            /*CCSprite *level1Normal = [CCSprite spriteWithSpriteFrameName:@"long_map.png"];
            CCSprite *level2Normal = [CCSprite spriteWithSpriteFrameName:@"square_map.png"];
            CCSprite *level3Normal = [CCSprite spriteWithSpriteFrameName:@"long_map.png"];
            CCSprite *level4Normal = [CCSprite spriteWithSpriteFrameName:@"square_map.png"];
            CCSprite *level1Select = [CCSprite spriteWithSpriteFrameName:@"long_map.png"];
            CCSprite *level2Select = [CCSprite spriteWithSpriteFrameName:@"square_map.png"];
            CCSprite *level3Select = [CCSprite spriteWithSpriteFrameName:@"long_map.png"];
            CCSprite *level4Select = [CCSprite spriteWithSpriteFrameName:@"square_map.png"];
            [level1Select setColor:ccGRAY];
            [level2Select setColor:ccGRAY];
            [level3Select setColor:ccGRAY];
            [level4Select setColor:ccGRAY];
            
            
            CCMenuItemSprite *level1 = [CCMenuItemSprite itemFromNormalSprite:level1Normal selectedSprite:level1Select target:self selector:@selector(level1)];
            CCMenuItemSprite *level2 = [CCMenuItemSprite itemFromNormalSprite:level2Normal selectedSprite:level2Select target:self selector:@selector(level2)];
            CCMenuItemSprite *level3 = [CCMenuItemSprite itemFromNormalSprite:level3Normal selectedSprite:level3Select target:self selector:@selector(level3)];
            CCMenuItemSprite *level4 = [CCMenuItemSprite itemFromNormalSprite:level4Normal selectedSprite:level4Select target:self selector:@selector(level4)];
            
            CCMenuAdvanced *menu = [CCMenuAdvanced menuWithItems:level1,level2,level3,level4, nil];
            
            //[menu alignItemsHorizontallyWithPadding:200 leftToRight:YES];
            //menu.anchorPoint = ccp(0.5f,0.5f);
            //menu.position = ccp(winSize.width/2,winSize.height/2);
            //menu.isRelativeAnchorPoint = YES;
            
            
            [menu alignItemsHorizontallyWithPadding:ADJUST_COORD(32) leftToRight: YES]; //< also sets contentSize and keyBindings on Mac
            menu.isRelativeAnchorPoint = YES;	
            
            
            //widget
            menu.anchorPoint = ccp(0.5f, 1);
            menu.position = ccp(winSize.width / 4, winSize.height/2);
            
            //menu.scale = MIN ((winSize.width / 1.0f) / menu.contentSize.width, 2.00f );
            
            
            menu.boundaryRect = CGRectMake(MAX(0, winSize.width / 4.0f - [menu boundingBox].size.width / 2.0f),
                                           100.0f,
                                           winSize.width,
                                           [menu boundingBox].size.height );
            
            [menu fixPosition];
            
            [self addChild:menu];
            self.levelStrings = [[CCArray alloc] init];
            NSDictionary *levelSelectDict = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"levels" ofType:@"plist"]];
            _levelStrings = [levelSelectDict objectForKey:@"all_maps"];
            
            self.levelSprites = [[CCArray alloc] initWithCapacity:2];
            _levelIndex = 0;
            
            _levelImg = [CCSprite spriteWithSpriteFrameName:[_levelStrings objectAtIndex:_levelIndex]];
            _levelImg.position = ccp(winSize.width/2,winSize.height/2);
            _levelImg.scale = 0.5;
            [self addChild:_levelImg];
            
            
            
            
            
        }
        
        
        
        
        
        
        
    }
    
    return self;
    
}//*/

- (void)level1 {
    
}

- (void)level2 {
    
}

- (void)level3 {
    
}

- (void)level4 {
    
}

- (void)goBackLevel {
    
    
    if (isPlayer1) {
        _levelIndex--;
        if (_levelIndex < 0) {
            _levelIndex = [[_levelSelectDict objectForKey:@"all_maps"] count] - 1;
        }
        
        [_levelImg setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[[_levelSelectDict objectForKey:@"all_maps"] objectAtIndex:_levelIndex]]];
    }
    
    
    
}

- (void)goNextLevel {
    
    
    if (isPlayer1) {
        _levelIndex++;
        if (_levelIndex >= [[_levelSelectDict objectForKey:@"all_maps"] count]) {
            _levelIndex = 0;
        }
        
        [_levelImg setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[[_levelSelectDict objectForKey:@"all_maps"] objectAtIndex:_levelIndex]]];
    }
    
    
    
}




- (void)dealloc {
    
    [_levelSprites release]; _levelSprites = nil;
    [_levelStrings release]; _levelStrings = nil;
    [_levelSelectDict release]; _levelSelectDict = nil;
    
    [super dealloc];
}




- (void)sendData:(NSData *)data {
    Message *message = (Message *) [data bytes];
    NSLog(@"message:%d",message->messageType);
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
    
    /*
    MessageGameBegin message;
    message.message.messageType = kMessageTypeGameBegin;
    NSData *data = [NSData dataWithBytes:&message length:sizeof(MessageGameBegin)];    
    [self sendData:data];//*/
    
}

- (void)sendLoadMap:(int)map {
    MessageLoadMap message;
    message.message.messageType = kMessageTypeLoadMap;
    message.map = map;
    message.p1 = _oneTank;
    message.p2 = _twoTank;
    message.p3 = _threeTank;
    message.p4 = _fourTank;
    NSData *data = [NSData dataWithBytes:&message length:sizeof(MessageLoadMap)];    
    [self sendData:data];
}

static BOOL _sendReadySched;

- (void)sendReadySelect {
    if (self.currentPlayerValue == 0) {
        if (!_sendReadySched) {
            [self schedule:@selector(sendReadySelect) interval:0.25];
            _sendReadySched = YES;
        }
        
    } else {
        MessageReadySelect message;
        switch (self.currentPlayerValue) {
            case 1:
                message.message.messageType = kMessageTypeP1ReadySelect;
                message.selectedTank = _oneTank;
                break;
            case 2:
                message.message.messageType = kMessageTypeP2ReadySelect;
                message.selectedTank = _twoTank;
                break;
                
        }
        NSData *data = [NSData dataWithBytes:&message length:sizeof(MessageReadySelect)];    
        [self sendData:data];
        [self unschedule:@selector(sendReadySelect)];
        _sendReadySched = NO;
    }
    
    
}

- (void)sendCancelSelect {
    MessageCancelSelect message;
    switch (self.currentPlayerValue) {
        case 1:
            message.message.messageType = kMessageTypeP1CancelSelect;
            break;
        case 2:
            message.message.messageType = kMessageTypeP2CancelSelect;
            break;
            
    }
    NSData *data = [NSData dataWithBytes:&message length:sizeof(MessageCancelSelect)];    
    [self sendData:data];
}

- (void)tryStartGame {
    
    if (gameState == kGameStateWaitingForStart) {
        [self setGameState:kGameStateActive];
        //[self sendGameBegin];
        if (isPlayer1) {
            _isReady = YES;
        }
    }
    
}

- (void)endScene:(EndReason)endReason {
    
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
        
    } else if (message->messageType == kMessageTypeLoadMap) {        
        
        //[self setGameState:kGameStateActive];
        _isReady = YES;
        MessageLoadMap *messageLoadMap = (MessageLoadMap *)[data bytes];
        _levelIndex = messageLoadMap->map;
        _oneTank = messageLoadMap->p1;
        _twoTank = messageLoadMap->p2;
        _threeTank = messageLoadMap->p3;
        _fourTank = messageLoadMap->p4;
        [self runMap];
        
        
    } else if (message->messageType == kMessageTypeP1ReadySelect) {        
        
        MessageReadySelect * messageReady = (MessageReadySelect *) [data bytes];
        CCLOG(@"player 1 ready select:%d",messageReady->selectedTank);
        _playerOneReady = YES;
        _oneTank = messageReady->selectedTank;
        
    } else if (message->messageType == kMessageTypeP2ReadySelect) {        
        
        MessageReadySelect * messageReady = (MessageReadySelect *) [data bytes];
        CCLOG(@"player 2 ready select:%d",messageReady->selectedTank);
        _playerTwoReady = YES;
        _twoTank = messageReady->selectedTank;
    } else if (message->messageType == kMessageTypeP1CancelSelect) {        
        
        //MessageCancelSelect * messageReady = (MessageCancelSelect *) [data bytes];
        CCLOG(@"player 1 cancelled select");
        _playerOneReady = NO;
        _oneTank = -1;
        
    } else if (message->messageType == kMessageTypeP2CancelSelect) {        
        
        //MessageCancelSelect * messageReady = (MessageCancelSelect *) [data bytes];
        CCLOG(@"player 2 cancelled select");
        _playerTwoReady = NO;
        _twoTank = -1;
    } 
}

- (void)inviteReceived {
    //[self restartTapped:nil];    
}

- (void)lobbyRefresh {
    
    if (_numPlayers == 1) {
        [self unschedule:@selector(lobbyRefresh)];
        return;
    }
    
    CCMenu *menuNext = (CCMenu *)[self getChildByTag:100];
    CCArray *kids = [menuNext children];
    for (CCMenuItem *item in kids) {
        switch (_numPlayers) {
            case 1:
                break;
            case 2:
                if (isPlayer1 && _playerOneReady && _playerTwoReady) {
                    item.isEnabled = YES;
                }
                break;
        }
        
        
    }
    
    
    
}

- (void)tank1 {
    
    if (_numPlayers == 1) {
        _oneTank = kShadow;
        [self runMap];
    } else {
        switch (_currentPlayerValue) {
            case 1:
                _oneTank = kShadow;
                break;    
            case 2:
                _twoTank = kShadow;
                break;
            case 3:
                _threeTank = kShadow;
                break;
            case 4:
                _fourTank = kShadow;
                break;
        }
        [self sendReadySelect];
    }
    
    
}
                 
- (void)tank2 {
    if (_numPlayers == 1) {
        _oneTank = kFlash;
        [self runMap];
    } else {
        switch (_currentPlayerValue) {
            case 1:
                _oneTank = kFlash;
            case 2:
                _twoTank = kFlash;
                break;
            case 3:
                _threeTank = kFlash;
                break;
            case 4:
                _fourTank = kFlash;
                break;
        }
        [self sendReadySelect];
    }
    
    
}

- (void)tank3 {
    if (_numPlayers == 1) {
        _oneTank = kBlaze;
        [self runMap];
    } else {
        switch (_currentPlayerValue) {
            case 1:
                _oneTank = kBlaze;
            case 2:
                _twoTank = kBlaze;
                break;
            case 3:
                _threeTank = kBlaze;
                break;
            case 4:
                _fourTank = kBlaze;
                break;
        }
        [self sendReadySelect];
    }
}

- (void)tank4 {
    if (_numPlayers == 1) {
        _oneTank = kIceberg;
        [self runMap];
    } else {
        switch (_currentPlayerValue) {
            case 1:
                _oneTank = kIceberg;
            case 2:
                _twoTank = kIceberg;
                break;
            case 3:
                _threeTank = kIceberg;
                break;
            case 4:
                _fourTank = kIceberg;
                break;
        }
        [self sendReadySelect];
    }
}

- (void)runMap {
    
    if (!_isReady) return;
    
    
    if (isPlayer1) {
        [self sendLoadMap:_levelIndex];
        NSLog(@"sent load map");
    } 

    NSLog(@"numplayers:%d, one:%d two:%d",_numPlayers,_oneTank,_twoTank);
    
    NSDictionary *data;
    switch (_numPlayers) {
        case 1:
            data = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:_numPlayers],@"numPlayers",[NSNumber numberWithInt:_oneTank],@"p1",nil];
            //NSLog(@"runmap");
            [SceneManager playMap:[self returnMapString:[[_levelSelectDict objectForKey:@"all_maps"] objectAtIndex:_levelIndex]] Data:data CurPlayer:_currentPlayerValue];
            break;
        case 2:
            data = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:_numPlayers],@"numPlayers",[NSNumber numberWithInt:_oneTank],@"p1",[NSNumber numberWithInt:_twoTank],@"p2",nil];
            [SceneManager playMap:[self returnMapString:[[_levelSelectDict objectForKey:@"all_maps"] objectAtIndex:_levelIndex]] Data:data CurPlayer:_currentPlayerValue];
            break;
        case 3:
            
            break;
        case 4:
            
            break;
            
            
    }
    
    
}


@end

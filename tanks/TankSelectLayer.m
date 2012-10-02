//
//  TankSelectLayer.m
//  tanks
//
//  Created by Cullen O'Neill on 2/18/12.
//  Copyright 2012 Lot18. All rights reserved.
//

#import "TankSelectLayer.h"
#import "CCMenuAdvanced.h"
#import "DeviceSettings.h"
#import "SceneManager.h"
#import "PublicEnums.h"


@implementation TankSelectLayer

- (id)initWithNum:(int)players curPID:(int)playID{
    if ((self = [super init])) {
        
        _numPlayers = players;
        _curPlayerValue = playID;
        
        CGSize winSize = [CCDirector sharedDirector].winSize;
        _batchNode = [CCSpriteBatchNode batchNodeWithFile:SD_OR_HD_PVR(@"sprites.pvr.ccz")];
        [self addChild:_batchNode];
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
        menu.position = ccp(winSize.width / 4, winSize.height/2);
        
        menu.scale = MIN ((winSize.width / 2.0f) / menu.contentSize.width, 2.00f );
        
        menu.boundaryRect = CGRectMake(MAX(0, winSize.width / 4.0f - [menu boundingBox].size.width / 2.0f),
                                       100.0f,
                                       [menu boundingBox].size.width,
                                       100.0f );
        
        [menu fixPosition];
        
        [self addChild:menu];
    }
    return self;
}

-(id) init
{
	
	if ((self = [super init])) {
        
        CGSize winSize = [CCDirector sharedDirector].winSize;
        _batchNode = [CCSpriteBatchNode batchNodeWithFile:SD_OR_HD_PVR(@"sprites.pvr.ccz")];
        [self addChild:_batchNode];
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
        
        //[menu alignItemsHorizontallyWithPadding:200 leftToRight:YES];
        //menu.anchorPoint = ccp(0.5f,0.5f);
        //menu.position = ccp(winSize.width/2,winSize.height/2);
        //menu.isRelativeAnchorPoint = YES;
        
        
        [menu alignItemsHorizontallyWithPadding:ADJUST_COORD(16) leftToRight: YES]; //< also sets contentSize and keyBindings on Mac
        menu.isRelativeAnchorPoint = YES;	
        
        
        //widget
        menu.anchorPoint = ccp(0.5f, 1);
        menu.position = ccp(winSize.width / 4, winSize.height/2);
        
        menu.scale = MIN ((winSize.width / 2.0f) / menu.contentSize.width, 2.00f );
        
        menu.boundaryRect = CGRectMake(MAX(0, winSize.width / 4.0f - [menu boundingBox].size.width / 2.0f),
                                       100.0f,
                                       [menu boundingBox].size.width,
                                       100.0f );
        
        [menu fixPosition];
        
        
        
        
        [self addChild:menu];
    }
    return self;
    
}

- (void)tank1 {
    NSDictionary *data;
    if (_numPlayers == 1) {
        data = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:1],@"numPlayers",[NSNumber numberWithInt:kShadow],@"p1",nil];
        [SceneManager playLongMapWithData:data];
    } else {
        switch (_curPlayerValue) {
            case 2:
                data = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:_numPlayers],@"numPlayers",[NSNumber numberWithInt:kShadow],@"p2",nil];
                [SceneManager playLongMapWithData:data];
                break;
            case 3:
                data = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:_numPlayers],@"numPlayers",[NSNumber numberWithInt:kShadow],@"p3",nil];
                [SceneManager playLongMapWithData:data];
                break;
            case 4:
                data = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:_numPlayers],@"numPlayers",[NSNumber numberWithInt:kShadow],@"p4",nil];
                [SceneManager playLongMapWithData:data];
                break;
                
            
        }
    }
}

- (void)tank2 {
    NSDictionary *data;
    if (_numPlayers == 1) {
        data = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:1],@"numPlayers",[NSNumber numberWithInt:kFlash],@"p1",nil];
        [SceneManager playLongMapWithData:data];
    } else {
        switch (_curPlayerValue) {
            case 2:
                data = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:_numPlayers],@"numPlayers",[NSNumber numberWithInt:kFlash],@"p2",nil];
                [SceneManager playLongMapWithData:data];
                break;
            case 3:
                data = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:_numPlayers],@"numPlayers",[NSNumber numberWithInt:kFlash],@"p3",nil];
                [SceneManager playLongMapWithData:data];
                break;
            case 4:
                data = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:_numPlayers],@"numPlayers",[NSNumber numberWithInt:kFlash],@"p4",nil];
                [SceneManager playLongMapWithData:data];
                break;
                
                
        }
    }
}

- (void)tank3 {
    
}

- (void)tank4 {
    
}


@end

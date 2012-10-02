//
//  GameScene.m
//  Aiden's Adventures
//
//  Created by Cullen O'Neill on 9/29/11.
//  Copyright 2011 Lot18. All rights reserved.
//

#import "GameScene.h"
#import "AppDelegate.h"
//#import "HelloWorldLayer.h"
#import "TileMapLayer.h"
#import "HUDLayer.h"
#import "Tanks.h"
#import "HeroTank.h"


@implementation GameScene

- (TileMapLayer *)getMainLayer {
    return mainLayer;
}

- (id)initWithKey:(NSString *)key playerData:(NSDictionary *)data {
    
    if((self=[super init])) {
        
        //mainLayer = [HelloWorldLayer node];
        mainLayer = [TileMapLayer gameLayerWithKey:key playerData:data];
        hudLayer = [HUDLayer node];
        [self addChild:mainLayer z:0 tag:1];
        [self addChild:hudLayer z:1 tag:2];
        
        [self scheduleUpdate];
    }
    return self;
    
}


- (id)initWithKey:(NSString *)key numPlayers:(int)num
{
    if((self=[super init])) {
        
        //mainLayer = [HelloWorldLayer node];
        mainLayer = [TileMapLayer gameLayerWithKey:key numPlayers:num];
        hudLayer = [HUDLayer node];
        [self addChild:mainLayer z:0 tag:1];
        [self addChild:hudLayer z:1 tag:2];
        
        [self scheduleUpdate];
    }
    return self;
}

- (void)update:(ccTime)dt {
    
    switch (mainLayer.currentPlayerValue) {
        case 1:
            hudLayer.hp = mainLayer.tank.hp;
            break;
        case 2:
            hudLayer.hp = mainLayer.tank2.hp;
            break;
    }
    
    
    
    if (hudLayer.controlShoot) {
        switch (mainLayer.currentPlayerValue) {
            case 1:
                mainLayer.tank.shooting = YES;
                [mainLayer setShot:hudLayer.shotOffset];
                break;
            case 2:
                mainLayer.tank2.shooting = YES;
                [mainLayer setShot:hudLayer.shotOffset];
                break;
        }
        
        
        //mainLayer.tank.shooting = YES;
        //[mainLayer setShot:hudLayer.shotOffset];
    } else {
        switch (mainLayer.currentPlayerValue) {
            case 1:
                mainLayer.tank.shooting = NO;
                break;
            case 2:
                mainLayer.tank2.shooting = NO;
                break;
        }
    }
    if (hudLayer.controlMove) {
        CGPoint _offset;
        switch (mainLayer.currentPlayerValue) {
            case 1:
                mainLayer.tank.moving = YES;
                _offset = ccpSub(mainLayer.tank.position, hudLayer.moveOffset);
                [mainLayer setMove:_offset];
                break;
            case 2:
                mainLayer.tank2.moving = YES;
                _offset = ccpSub(mainLayer.tank2.position, hudLayer.moveOffset);
                [mainLayer setMove:_offset];
                break;
        }
        
        //mainLayer.tank.moving = YES;
        //CGPoint _offset = ccpSub(mainLayer.tank.position, hudLayer.moveOffset);
        //[mainLayer setMove:_offset];
    }
    
}

- (void)pauseMenu {
    /*if (!mainLayer.gameSuspended) {
        [mainLayer runPauseMenu];
    } else {
        return;
    }//*/
    
}

@end

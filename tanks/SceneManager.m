//
//  SceneManager.m
//  SpaceGame
//
//  Created by Cullen O'Neill on 9/2/11.
//  Copyright 2011 Lot18. All rights reserved.
//

#import "SceneManager.h"

#import "HelloWorldLayer.h"
//#import "Highscores.h"
#import "MenuLayer.h"
//#import "CreditsLayer.h"
#import "GameScene.h"
//#import "HowToPlayLayer.h"
#import "GameSelectLayer.h"
#import "TankSelectLayer.h"
#import "LevelSelectLayer.h"
#import "GCHelper.h"
#import "TileMapLayer.h"
#import "TurnLayer.h"
#import "MPTurnLayer.h"


@implementation SceneManager

+ (void)goTurnDemo {
    
    CCLayer *layer = [TurnLayer node];
    [SceneManager go:layer];
    
}

+ (void)goMPTurnDemo {
    CCLayer *layer = [MPTurnLayer node];
    [SceneManager go:layer];
}

+ (void)goGameType:(int)type {
    GameSelectLayer *layer = [GameSelectLayer node];
    layer.gametype = type;
    [SceneManager go:layer]; 
}

+ (void)goMenu 
{
	CCLayer *layer = [MenuLayer node];
	[SceneManager go:layer];
}//*/

+ (void)goGameSelect {
    CCLayer *layer = [GameSelectLayer node];
    [SceneManager go:layer];
}

+ (void)goTankSelect {
    CCLayer *layer = [TankSelectLayer node];
    [SceneManager go:layer];
}

+ (void)goTankSelectWith:(int)players playID:(int)playID {
    CCLayer *layer = [[[TankSelectLayer alloc] initWithNum:players curPID:playID] autorelease];
    [SceneManager go:layer];
}



+ (void)goLevelSelect:(int)numPlayers {
    CCLayer *layer;
    if (numPlayers == 1) {
        layer = [LevelSelectLayer singlePlayerSelect];
    } else {
        
        layer = [LevelSelectLayer multiPlayerSelect:numPlayers];
    }
    [SceneManager go:layer];
}


+ (void)playMap:(NSString *)key Data:(NSDictionary *)data CurPlayer:(int)player{
    GameScene *newScene = [[[GameScene alloc] initWithKey:key playerData:data] autorelease];
    CCDirector *director = [CCDirector sharedDirector];
    
    [newScene getMainLayer].currentPlayerValue = player;
    int pVal; 
    switch (player) {
        case 1:
            pVal = [[data objectForKey:@"p1"] intValue];
            break;
        case 2:
            pVal = [[data objectForKey:@"p2"] intValue];
            break;
        case 3:
            pVal = [[data objectForKey:@"p3"] intValue];
            break;
        case 4:
            pVal = [[data objectForKey:@"p4"] intValue];
            break;
    }
    [[newScene getMainLayer] createAbilityMenu:pVal];
    [[newScene getMainLayer] createGameLogic];

    
    if ([director runningScene]) {
        [director replaceScene:[CCTransitionZoomFlipX transitionWithDuration:0.5 scene:newScene]];
	}
	else {
		[director runWithScene:newScene];		
	}
}

+ (void)playLongMapWithData:(NSDictionary *)data {
    CCScene *newScene = [[[GameScene alloc] initWithKey:@"long_map.tmx" playerData:data] autorelease];
    CCDirector *director = [CCDirector sharedDirector];
    if ([director runningScene]) {
        [director replaceScene:[CCTransitionZoomFlipX transitionWithDuration:0.5 scene:newScene]];
	}
	else {
		[director runWithScene:newScene];		
	}
}

+ (void)playShortMapWithData:(NSDictionary *)data {
    CCScene *newScene = [[[GameScene alloc] initWithKey:@"long_map.tmx" playerData:data] autorelease];
    CCDirector *director = [CCDirector sharedDirector];
    if ([director runningScene]) {
        [director replaceScene:[CCTransitionZoomFlipX transitionWithDuration:0.5 scene:newScene]];
	}
	else {
		[director runWithScene:newScene];		
	}
}

+ (void)playFatMapWithData:(NSDictionary *)data {
    CCScene *newScene = [[[GameScene alloc] initWithKey:@"long_map.tmx" playerData:data] autorelease];
    CCDirector *director = [CCDirector sharedDirector];
    if ([director runningScene]) {
        [director replaceScene:[CCTransitionZoomFlipX transitionWithDuration:0.5 scene:newScene]];
	}
	else {
		[director runWithScene:newScene];		
	}
}

+ (void)playSkinnyMapWithData:(NSDictionary *)data {
    CCScene *newScene = [[[GameScene alloc] initWithKey:@"long_map.tmx" playerData:data] autorelease];
    CCDirector *director = [CCDirector sharedDirector];
    if ([director runningScene]) {
        [director replaceScene:[CCTransitionZoomFlipX transitionWithDuration:0.5 scene:newScene]];
	}
	else {
		[director runWithScene:newScene];		
	}
}



+ (void)playLongMap:(int)players {
    CCScene *newScene = [[[GameScene alloc] initWithKey:@"long_map.tmx" numPlayers:players] autorelease];
    CCDirector *director = [CCDirector sharedDirector];
    if ([director runningScene]) {
        [director replaceScene:[CCTransitionZoomFlipX transitionWithDuration:0.5 scene:newScene]];
	}
	else {
		[director runWithScene:newScene];		
	}
}

+ (void)playShortMap:(int)players {
    CCScene *newScene = [[[GameScene alloc] initWithKey:@"long_map.tmx" numPlayers:players] autorelease];
    CCDirector *director = [CCDirector sharedDirector];
    if ([director runningScene]) {
        [director replaceScene:[CCTransitionZoomFlipX transitionWithDuration:0.5 scene:newScene]];
	}
	else {
		[director runWithScene:newScene];		
	}
}

+ (void)playFatMap:(int)players {
    CCScene *newScene = [[[GameScene alloc] initWithKey:@"long_map.tmx" numPlayers:players] autorelease];
    CCDirector *director = [CCDirector sharedDirector];
    if ([director runningScene]) {
        [director replaceScene:[CCTransitionZoomFlipX transitionWithDuration:0.5 scene:newScene]];
	}
	else {
		[director runWithScene:newScene];		
	}
}

+ (void)playSkinnyMap:(int)players {
    CCScene *newScene = [[[GameScene alloc] initWithKey:@"long_map.tmx" numPlayers:players] autorelease];
    CCDirector *director = [CCDirector sharedDirector];
    if ([director runningScene]) {
        [director replaceScene:[CCTransitionZoomFlipX transitionWithDuration:0.5 scene:newScene]];
	}
	else {
		[director runWithScene:newScene];		
	}
}

+ (void)goPlay 
{
    
    //[[CCDirector sharedDirector] setProjection:CCDirectorProjection3D];
    
    CCScene *newScene = [GameScene node];
    CCDirector *director = [CCDirector sharedDirector];
    if ([director runningScene]) {
        [director replaceScene:[CCTransitionZoomFlipX transitionWithDuration:0.5 scene:newScene]];
	}
	else {
		[director runWithScene:newScene];		
	}
    
    //[[CCDirector sharedDirector] setProjection:CCDirectorProjection2D];
    
    /*
    CCLayer *layer = [HelloWorldLayer node];
    [SceneManager go:layer];//*/

}





/*
+ (void)goHighscore {
    
    Highscores *layer = [[[Highscores alloc] initWithScore:0] autorelease];
    [SceneManager go:layer];
    
}//*/
/*
+ (void)goHowToPlay 
{
    
    CCLayer *layer = [HowToPlayLayer node];
    [SceneManager go:layer];
    
}

+ (void)goCredits 
{
    
    CCLayer *layer = [CreditsLayer node];
    [SceneManager go:layer];
    
}//*/

+ (void)go:(CCLayer *)layer 
{
	CCDirector *director = [CCDirector sharedDirector];
	CCScene *newScene = [SceneManager wrap:layer];
	
	if ([director runningScene]) {
		[director replaceScene:[CCTransitionZoomFlipX transitionWithDuration:0.5 scene:newScene]];
	}
	else {
		[director runWithScene:newScene];		
	}
}

+ (CCScene *)wrap:(CCLayer *)layer 
{
	CCScene *newScene = [CCScene node];
	[newScene addChild: layer];
	return newScene;
}



@end

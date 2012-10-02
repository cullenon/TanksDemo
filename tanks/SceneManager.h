//
//  SceneManager.h
//  SpaceGame
//
//  Created by Cullen O'Neill on 9/2/11.
//  Copyright 2011 Lot18. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"


@interface SceneManager : NSObject {
    
}

+ (void)goPlay;
+ (void)goMenu;
//+ (void)goHighscore;
+ (void)goHowToPlay;
+ (void)goCredits;
+ (void)go:(CCLayer *)layer;
+ (CCScene *)wrap:(CCLayer *)layer;


+ (void)goTurnDemo;
+ (void)goMPTurnDemo;

+ (void)goGameType:(int)type;
+ (void)goGameSelect;
+ (void)goTankSelect;
+ (void)goTankSelectWith:(int)players playID:(int)playID;
+ (void)goLevelSelect:(int)numPlayers;
+ (void)playMap:(NSString*)key Data:(NSDictionary*)data CurPlayer:(int)player;
+ (void)playLongMap:(int)players;
+ (void)playShortMap:(int)players;
+ (void)playFatMap:(int)players;
+ (void)playSkinnyMap:(int)players;
+ (void)playLongMapWithData:(NSDictionary *)data;
+ (void)playShortMapWithData:(NSDictionary *)data;
+ (void)playFatMapWithData:(NSDictionary *)data;
+ (void)playSkinnyMapWithData:(NSDictionary *)data;

@end

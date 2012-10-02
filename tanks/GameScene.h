//
//  GameScene.h
//  Aiden's Adventures
//
//  Created by Cullen O'Neill on 9/29/11.
//  Copyright 2011 Lot18. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
//#import "GCHelper.h"

//@class HelloWorldLayer;
@class HUDLayer;
@class TileMapLayer;


@interface GameScene : CCScene {
    
    TileMapLayer *mainLayer;
    HUDLayer *hudLayer;
    
}


- (id)initWithKey:(NSString *)key playerData:(NSDictionary *)data;
- (id)initWithKey:(NSString *)key numPlayers:(int)num;
- (void)pauseMenu;

- (TileMapLayer *) getMainLayer;

@end

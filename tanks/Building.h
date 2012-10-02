//
//  Building.h
//  tanks
//
//  Created by Cullen O'Neill on 5/12/12.
//  Copyright 2012 Lot18. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@class TurnLayer;

@interface Building : CCNode {
    TurnLayer *theGame;
    CCSprite *mySprite;
    int owner;
}

@property (nonatomic,assign)CCSprite *mySprite;
@property (nonatomic,readwrite) int owner;

-(void)createSprite:(NSMutableDictionary *)tileDict;

@end

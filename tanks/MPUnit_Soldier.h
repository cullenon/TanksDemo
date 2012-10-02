//
//  Unit_Soldier.h
//  tanks
//
//  Created by Cullen O'Neill on 5/11/12.
//  Copyright 2012 Lot18. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "MPUnit.h"

@class TileData;
@class TurnLayer;

@interface MPUnit_Soldier : MPUnit {
    
}

-(id)initWithTheGame:(TurnLayer *)_game tileDict:(NSMutableDictionary *)tileDict owner:(int)_owner;
-(BOOL)canWalkOverTile:(TileData *)td;

@end

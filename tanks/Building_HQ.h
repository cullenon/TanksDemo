//
//  Building_HQ.h
//  tanks
//
//  Created by Cullen O'Neill on 5/12/12.
//  Copyright 2012 Lot18. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Building.h"

@interface Building_HQ : Building {
    
}

+(id)nodeWithTheGame:(TurnLayer *)_game tileDict:(NSMutableDictionary *)tileDict owner:(int)_owner;
-(id)initWithTheGame:(TurnLayer *)_game tileDict:(NSMutableDictionary *)tileDict owner:(int)_owner;

@end

//
//  Building.m
//  tanks
//
//  Created by Cullen O'Neill on 5/12/12.
//  Copyright 2012 Lot18. All rights reserved.
//

#import "Building.h"
#import "TurnLayer.h"


@implementation Building

@synthesize mySprite,owner;

-(id)init {
    if ((self=[super init])) {
        
    }
    return self;
}

-(void)createSprite:(NSMutableDictionary *)tileDict {
    // Get the sprite position and dimension from tile data
    int x = [[tileDict valueForKey:@"x"] intValue]/[theGame spriteScale];
    int y = [[tileDict valueForKey:@"y"] intValue]/[theGame spriteScale];
    int width = [[tileDict valueForKey:@"width"] intValue]/[theGame spriteScale];
    int height = [[tileDict valueForKey:@"height"] intValue];
    // Get the height of the building in tiles
    int heightInTiles = height/[theGame getTileHeightForRetina];
    // Calculate x and y values
    x += width/2;
    y += (heightInTiles * [theGame getTileHeightForRetina]/(2*[theGame spriteScale]));
    // Create building sprite and position it
    mySprite = [CCSprite spriteWithFile:[NSString stringWithFormat:@"%@_P%d.png",[tileDict valueForKey:@"Type"],owner]];
    [self addChild:mySprite];
    mySprite.userData = self;
    mySprite.position = ccp(x,y);
}

@end

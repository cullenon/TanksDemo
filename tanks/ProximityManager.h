/* cocos2d for iPhone
 *
 * http://www.cocos2d-iphone.org
 *
 * Copyright (C) 2009 Jason Booth
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the 'cocos2d for iPhone' license.
 *
 * You will find a copy of this license within the cocos2d for iPhone
 * distribution inside the "LICENSE" file.
 *
 */

/*
  This is a fast spacial grid based proximity manager, useful when you have
 to determine likely collisions between hundreds of objects. It's based on
 Grant Skinners AS3 class, which you can see a demo of and read more about
 the technique here:
 
 http://www.gskinner.com/blog/archives/2008/01/proximitymanage.html
 
 However, this version has a few extra features. First, you querry it
 baesd on range, not based on grid neighbors. This allows you to pass
 in a range value larger than a single cell and it will automatically
 traverse into neighboring cells. You can also use the exact range querry,
 which performs a distance check on objects once they are found to be
 within cell range.
 
*/

#import "cocos2d.h"

@interface ProximityManager : CCNode 
{
  uint gridSize;
  CCArray* objects;
  NSMutableDictionary* positions;
  NSMutableDictionary* cachedPositions;
    NSMutableDictionary *staticPositions;
}

+(id)create:(int)gs;
-(id)initProxWithSize:(int)gs;

-(void)addObject:(CCNode*)object;
-(void)removeObject:(CCNode*)object;
-(void)addStaticObject:(CCNode*)object;
-(void)update;
-(CCArray*)getExactRange:(float)x y:(float)y range:(int)range;
-(CCArray*)getRoughRange:(float)x y:(float)y range:(int)range;

@end

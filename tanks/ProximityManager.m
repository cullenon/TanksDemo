//
//  ProximityManager.m
//  Warfare
//
//  Created by Jason Booth on 1/23/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ProximityManager.h"

@implementation ProximityManager

/*
+(id)create:(int)gs
{
  self = [[[ProximityManager alloc] initWithSize:gs] autorelease];
  return self;
}//*/

-(id)initProxWithSize:(int)gs
{
  self = [super init];
  if (self)
  {
    gridSize = gs;
    objects = [[CCArray alloc] init];
    positions = [[NSMutableDictionary alloc] initWithCapacity:100];
    cachedPositions = [[NSMutableDictionary alloc] initWithCapacity:100];
      staticPositions = [[NSMutableDictionary alloc] initWithCapacity:100];
  }
  return self;
}

-(void)dealloc
{
  [objects removeAllObjects];
  [positions removeAllObjects];
  [cachedPositions removeAllObjects];
    [staticPositions removeAllObjects];
  [objects release];
  [positions release];
  [cachedPositions release];
    [staticPositions release];
  [super dealloc];
}

-(void)addObject:(CCNode*)object
{
  [objects addObject:object];
}

-(void)removeObject:(CCNode*)object
{
  [objects removeObject:object];
}

-(void)addStaticObject:(CCNode*)object
{
	//[staticobjects addObject:object];
    
	uint off = gridSize*1024;
    uint index = (int)((object.position.x + off) / gridSize) << 11 | (int)((object.position.y + off) / gridSize); // max of +/- 2^10 rows and columns
    NSNumber* num = [NSNumber numberWithInt:index];
    CCArray* ar = [staticPositions objectForKey:num];
    if (ar == nil)
    {
        ar = [[[CCArray alloc] init] autorelease];
        [staticPositions setObject:ar forKey:num];
    }
    [ar addObject:object];
    
}

-(void)update
{
  [positions removeAllObjects];
  [cachedPositions removeAllObjects];
  uint off = gridSize*1024;
  for (CCNode* o in objects)
  {
    uint index = (int)((o.position.x + off) / gridSize) << 11 | (int)((o.position.y + off) / gridSize); // max of +/- 2^10 rows and columns
    NSNumber* num = [NSNumber numberWithInt:index];
    CCArray* ar = [positions objectForKey:num];
    if (ar == nil)
    {
      ar = [[[CCArray alloc] init] autorelease];
      [positions setObject:ar forKey:num];
    }
    [ar addObject:o];
  }
    [positions addEntriesFromDictionary:staticPositions];
}

-(CCArray*)getExactRange:(float)x y:(float)y range:(int)range
{
  CCArray* g = [self getRoughRange:x y:y range:range];
  CCArray* r = [[[CCArray alloc] init] autorelease];
  for (CCNode* u in g)
  {
      
      
    if ((pow([u position].x - x, 2) + pow([u position].y - y, 2)) < range*range)
    {
      [r addObject:u];
    }
  }
  return r;
}

-(CCArray*)getRoughRange:(float)x y:(float)y range:(int)range
{
  uint off = gridSize * 1024;
  uint index = (int)((x + off) / gridSize) << 11 | (int)((y + off) / gridSize); // max of +/- 2^10 rows and columns
  uint cells = 1 + (range / gridSize);
  
  // check cache
  NSString* tmp = [NSString stringWithFormat:@"%i_%i", index, cells];
  CCArray* r = [cachedPositions objectForKey:tmp];
  if (r)
    return r;
  
  // ok, no luck with the cache, do a search
  r = [[[CCArray alloc] init] autorelease];
  for (int xi = (index-cells); xi <= (index+cells); ++xi)
  {
    for (int yi = 0; yi <= (2 * cells); ++yi)
    {
      NSNumber* num = [NSNumber numberWithInt:((yi - cells)*2048)+xi];
      if ([positions objectForKey:num]) 
      {
        [r addObjectsFromArray:[positions objectForKey:num]];
      }
    }
  }
  [cachedPositions setObject:r forKey:tmp];
  return r;
}


@end

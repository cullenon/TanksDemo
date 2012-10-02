//
//  Bullet.m
//  tanks
//
//  Created by Cullen O'Neill on 1/26/12.
//  Copyright 2012 Lot18. All rights reserved.
//

#import "Bullet.h"


@implementation Bullet

@synthesize radius = _radius;
@synthesize type = _type;
@synthesize damage = _damage;
@synthesize source = _source;

+ (id)bulletWithKey:(NSString *)key {
    Bullet *bullet = [[[Bullet alloc] initWithKey:key] autorelease];
    return bullet;
}

- (id)initWithKey:(NSString *)key {
    
    if ((self = [super initWithSpriteFrameName:key])) {
        
        int spriteR = MIN(self.contentSize.width, self.contentSize.height);
        _radius = spriteR;
        
        
    }
    return self;
}


- (void)dealloc {
    
    
    
    [super dealloc];
}

@end

//
//  Bullet.h
//  tanks
//
//  Created by Cullen O'Neill on 1/26/12.
//  Copyright 2012 Lot18. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "PublicEnums.h"

@interface Bullet : CCSprite {
    
}

@property (assign) int radius;
@property (assign) int damage;
@property (assign) int source;
@property (assign) BulletType type;

+ (id)bulletWithKey:(NSString *)key;
- (id)initWithKey:(NSString *)key;

@end

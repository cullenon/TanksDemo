//
//  HeroTank.h
//  tanks
//
//  Created by Cullen O'Neill on 2/23/12.
//  Copyright 2012 Lot18. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Tanks.h"

@class TileMapLayer;

@interface HeroTank : Tanks {
    
    CGPoint _newTarPosition;
    int _abil1Level;
    int _abil2Level;
    int _abil3Level;
    
}

@property (assign) int energy;
@property (assign) int exp;
@property (assign) int level;
@property (assign) TankType tankType;

- (void)setAbilitiesWithKey:(NSString *)key;

- (void)abilityOneForType:(TankType)type;
- (void)abilityTwoForType:(TankType)type;
- (void)abilityThreeForType:(TankType)type;
- (void)useAbilityOne:(CGPoint)touch;
- (void)useAbilityTwo:(CGPoint)touch;
- (void)useAbilityThree:(CGPoint)touch;



- (void)shadowBulletTouched;
- (void)shadowHandGrabTouched;
- (void)shadowVoidZoneTouched;
- (void)flashBulletTouched;
- (void)flashBlinkTouched;
- (void)flashFlashTouched;
- (void)blazeBulletTouched;
- (void)icebergBulletTouched;

- (void)shadowBullet:(CGPoint)offset;
- (void)shadowHandGrab:(CGPoint)offset;
- (void)shadowVoidZone;
- (void)flashBullet:(CGPoint)offset;
- (void)flashBlink:(CGPoint)offset;
- (void)flashFlash:(CGPoint)offset;
- (void)blazeBullet:(CGPoint)offset;
- (void)blazeFireBlast:(CGPoint)offset;
- (void)blazeImmolation;
- (void)icebergBullet:(CGPoint)offset;
- (void)icebergIceCrag:(CGPoint)offset;
- (void)icebergIceAge;



- (void)resetBaseSprite;




+ (id)heroTankWithLayer:(TileMapLayer *)layer team:(int)team hero:(TankType)hero;
+ (id)shadowTankWithLayer:(TileMapLayer *)layer team:(int)team;
+ (id)flashTankWithLayer:(TileMapLayer *)layer team:(int)team;
+ (id)blazeTankWithLayer:(TileMapLayer *)layer team:(int)team;
+ (id)icebergTankWithLayer:(TileMapLayer *)layer team:(int)team;

- (void)resetHeroPosition;

- (void)increaseAbilityLevel:(int)abilNum;



@end

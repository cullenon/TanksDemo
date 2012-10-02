//
//  HeroTank.m
//  tanks
//
//  Created by Cullen O'Neill on 2/23/12.
//  Copyright 2012 Lot18. All rights reserved.
//

#import "HeroTank.h"
#import "Tanks.h"
#import "PublicEnums.h"
#import "SpriteDictionary.h"
#import "DeviceSettings.h"
#import "SimpleAudioEngine.h"
#import "TileMapLayer.h"
#import "Bullet.h"

@implementation HeroTank

@synthesize energy = _energy;
@synthesize exp = _exp;
@synthesize level = _level;
@synthesize tankType = _tankType;


+ (id)heroTankWithLayer:(TileMapLayer *)layer team:(int)team hero:(TankType)hero {
    HeroTank *tankHero;
    switch (hero) {
        case kShadow:
            tankHero = [HeroTank shadowTankWithLayer:layer team:team];
            break;
        case kFlash:
            tankHero = [HeroTank flashTankWithLayer:layer team:team];
            break;
        case kBlaze:
            tankHero = [HeroTank blazeTankWithLayer:layer team:team];
            break;
        case kIceberg:
            tankHero = [HeroTank icebergTankWithLayer:layer team:team];
            break;
            
    }
    tankHero.tankType = hero;
    
    return tankHero;
}

+ (id)shadowTankWithLayer:(TileMapLayer *)layer team:(int)team {
    HeroTank *hero = [[[HeroTank alloc] initWithKey:@"shadow" layer:layer] autorelease];
    hero.team = team;
    //hero.tankType = kShadow;
    return hero;
}


+ (id)flashTankWithLayer:(TileMapLayer *)layer team:(int)team {
    HeroTank *hero = [[[HeroTank alloc] initWithKey:@"flash" layer:layer] autorelease];
    hero.team = team;
    //hero.tankType = kFlash;
    return hero;
}

+ (id)blazeTankWithLayer:(TileMapLayer *)layer team:(int)team {
    HeroTank *hero = [[[HeroTank alloc] initWithKey:@"blaze" layer:layer] autorelease];
    hero.team = team;
    return hero;
}

+ (id)icebergTankWithLayer:(TileMapLayer *)layer team:(int)team {
    HeroTank *hero = [[[HeroTank alloc] initWithKey:@"iceberg" layer:layer] autorelease];
    hero.team = team;
    return hero;
}

- (id)initWithKey:(NSString *)key layer:(TileMapLayer *)layer {
    
    if ((self = [super initWithKey:key layer:layer])) {
        
        _abil1Level = 1;
        _abil2Level = 1;
        _abil3Level = 1;
        
    }
    
    return self;
    
}

- (void)setAbilitiesWithKey:(NSString *)key {
    
    
    
    
}

- (void)abilityOneForType:(TankType)type {
    /*switch (type) {
        case kFlash:
            [self flashBulletTouched];
            break;
        case kShadow:
            [self shadowBulletTouched];
            break;
    }//*/
    [self setLayerAbilityFlag:kAbilityOne];
}

- (void)abilityTwoForType:(TankType)type {
    /*switch (type) {
        case kFlash:
            [self flashBlinkTouched];
            break;
        case kShadow:
            [self shadowHandGrabTouched];
            break;
    }//*/
    [self setLayerAbilityFlag:kAbilityTwo];
}

- (void)abilityThreeForType:(TankType)type {
    switch (type) {
        case kFlash:
            //[self flashFlashTouched];
            [self setLayerAbilityFlag:kAbilityThree];
            break;
        case kShadow:
            //[self shadowVoidZoneTouched];
            [self shadowVoidZone];
            [_layer sendAbility:ccp(0,0) Num:kAbilityThree];
            break;
        case kBlaze:
            break;
        case kIceberg:
            [self icebergIceAge];
            [_layer sendAbility:ccp(0,0) Num:kAbilityThree];
    }//*/
    //[self setLayerAbilityFlag:kAbilityThree];
}

- (void)useAbilityOne:(CGPoint)touch {
    switch (self.tankType) {
        case kFlash:
            [self flashBullet:touch];
            break;
        case kShadow:
            [self shadowBullet:touch];
            break;
        case kBlaze:
            [self blazeBullet:touch];
            break;
        case kIceberg:
            [self icebergBullet:touch];
            break;
    }
}

- (void)useAbilityTwo:(CGPoint)touch {
    switch (self.tankType) {
        case kFlash:
            [self flashBlink:touch];
            break;
        case kShadow:
            [self shadowHandGrab:touch];
            break;
        case kBlaze:
            [self blazeFireBlast:touch];
            break;
        case kIceberg:
            [self icebergIceCrag:touch];
            break;
    }
}

- (void)useAbilityThree:(CGPoint)touch {
    switch (self.tankType) {
        case kFlash:
            [self flashFlash:touch];
            break;
        case kShadow:
            [self shadowVoidZone];
            break;
        case kBlaze:
            [self blazeImmolation];
            break;
        case kIceberg:
            [self icebergIceAge];
            break;
    }
}

- (void)increaseAbilityLevel:(int)abilNum {
    
    switch (abilNum) {
        case 1:
            _abil1Level++;
            break;
        case 2:
            _abil2Level++;
            break;
        case 3:
            _abil3Level++;
            break;
    }
    
}

- (void)shadowBulletTouched {
    [self setLayerAbilityFlag:kShadowBullet];
}

- (void)shadowHandGrabTouched {
    [self setLayerAbilityFlag:kShadowHandGrab];
}

- (void)shadowVoidZoneTouched {
    [self setLayerAbilityFlag:kShadowVoidZone];
}

- (void)flashBulletTouched {
    [self setLayerAbilityFlag:kFlashBullet];
}

- (void)flashBlinkTouched {
    [self setLayerAbilityFlag:kFlashBlink];
}

- (void)flashFlashTouched {
    [self setLayerAbilityFlag:kFlashFlash];
}

- (void)shadowBullet:(CGPoint)offset {
    NSString * shootSound = [NSString stringWithFormat:@"tank1Shoot.wav"];
    [[SimpleAudioEngine sharedEngine] playEffect:shootSound];
    
    CGPoint shotvect = ccpSub(offset, self.position);
    _shootVector = ccpNormalize(shotvect);
    
    CGPoint actualVector = ccpMult(_shootVector, self.range);  
    
    // 3
    float POINTS_PER_SECOND = ADJUST_COORD(self.projSpeed);
    float duration = self.range / POINTS_PER_SECOND;
    
    
    //CCSprite *bullet = [CCSprite spriteWithSpriteFrameName:@"dark_shot1.png"];
    Bullet *bullet = [_layer getBullet:kHero];
    [bullet setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"dark_shot1.png"]];
    bullet.position = self.position;
    CGFloat angle = ccpToAngle(_shootVector);
    bullet.rotation = (int)(-1 * CC_RADIANS_TO_DEGREES(angle)) + 90;
    //[_layer.tileMap addChild:bullet z:2];
    CCMoveBy * move = [CCMoveBy actionWithDuration:duration position:actualVector];
    CCCallBlockN * call = [CCCallFuncN actionWithTarget:self selector:@selector(setInvisible:)];
    bullet.visible = YES;
    //bullet.source = _layer.currentPlayerValue;
    bullet.damage = 30;
    
    id animate = [CCAnimate actionWithAnimation:[[SpriteDictionary sharedDictionary].data objectForKey:@"shadowDarkShot"]];
    id repeat = [CCRepeatForever actionWithAction:animate];
    
    [bullet runAction:repeat];
    [bullet runAction:[CCSequence actions:move, call, nil]];
    [self rotateTurretAngle];
    
}

- (void)shadowHandGrab:(CGPoint)offset {
    //_isCasting = YES;
    NSString * shootSound = [NSString stringWithFormat:@"tank1Shoot.wav"];
    [[SimpleAudioEngine sharedEngine] playEffect:shootSound];
    
    CGPoint shotvect = ccpSub(offset, self.position);
    _shootVector = ccpNormalize(shotvect);
    
    CGPoint actualVector = ccpMult(_shootVector, self.range);  
    
    // 3
    float POINTS_PER_SECOND = ADJUST_COORD(200);
    float duration = self.range / POINTS_PER_SECOND;
    
    
    //CCSprite *bullet = [CCSprite spriteWithSpriteFrameName:@"shadow_grab_hand.png"];
    Bullet *bullet = [_layer getBullet:kHero];
    [bullet setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"shadow_grab_hand.png"]];
    bullet.position = self.position;
    CGFloat angle = ccpToAngle(_shootVector);
    bullet.rotation = (int)(-1 * CC_RADIANS_TO_DEGREES(angle)) + 90;
    //[_layer.tileMap addChild:bullet z:2];
    CCMoveBy * move = [CCMoveBy actionWithDuration:duration position:actualVector];
    CCMoveTo * move2 = [CCMoveTo actionWithDuration:duration position:self.position];
    CCCallBlockN * call = [CCCallFuncN actionWithTarget:self selector:@selector(setInvisible:)];
    bullet.visible = YES;
    //bullet.source = _layer.currentPlayerValue;
    bullet.damage = 30;
    
    [bullet runAction:[CCSequence actions:move, move2, call, nil]];
    [self rotateTurretAngle];
    [self setLayerAbilityFlag:kAbilityNone];
}

- (void)shadowVoidZone {
    _isCasting = YES;
    id animate = [CCAnimate actionWithAnimation:[[SpriteDictionary sharedDictionary].data objectForKey:@"shadowVoidZone"]];
    id reset = [CCCallFunc actionWithTarget:self selector:@selector(resetBaseSprite)];
    id sequence = [CCSequence actions:animate,reset, nil];
    
    
    [self.base runAction:sequence];
    [self setLayerAbilityFlag:kAbilityNone];
}

- (void)flashBullet:(CGPoint)offset {
    NSString * shootSound = [NSString stringWithFormat:@"tank1Shoot.wav"];
    [[SimpleAudioEngine sharedEngine] playEffect:shootSound];
    
    CGPoint shotvect = ccpSub(offset, self.position);
    _shootVector = ccpNormalize(shotvect);
    
    CGPoint actualVector = ccpMult(_shootVector, self.range);  
    
     
    
    // 3
    float POINTS_PER_SECOND = ADJUST_COORD(self.projSpeed);
    float duration = self.range / POINTS_PER_SECOND;
    
    
    //CCSprite *bullet = [CCSprite spriteWithSpriteFrameName:@"lightning_shot1.png"];
    Bullet *bullet = [_layer getBullet:kHero];
    [bullet setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"lightning_shot1.png"]];
    bullet.position = self.position;
    CGFloat angle = ccpToAngle(_shootVector);
    bullet.rotation = (int)(-1 * CC_RADIANS_TO_DEGREES(angle)) + 90;
    //[_layer.tileMap addChild:bullet z:2];
    CCMoveBy * move = [CCMoveBy actionWithDuration:duration position:actualVector];
    CCCallBlockN * call = [CCCallFuncN actionWithTarget:self selector:@selector(setInvisible:)];
    bullet.visible = YES;
    //bullet.source = _layer.currentPlayerValue;
    bullet.damage = 30;
    //NSLog(@"posx:%f posy:%f",bullet.position.x,bullet.position.y);
    
    
    id animate = [CCAnimate actionWithAnimation:[[SpriteDictionary sharedDictionary].data objectForKey:@"flashLightningShot"]];
    id repeat = [CCRepeatForever actionWithAction:animate];
    
    [bullet runAction:repeat];
    [bullet runAction:[CCSequence actions:move, call, nil]];
    [self rotateTurretAngle];
}

- (void)flashBlink:(CGPoint)offset {
    _isCasting = YES;
    
    /*CCSpriteFrame *f1 = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"flash_blink_anim1.png"];
    CCSpriteFrame *f2 = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"flash_blink_anim2.png"];
    CCSpriteFrame *f3 = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"flash_blink_anim3.png"];
    
    NSArray *frames = [NSArray arrayWithObjects:f1,f2,f3, nil];
    
    CCAnimation *flashAnim = [CCAnimation animationWithFrames:frames delay:0.1];//*/
    
    //id animate = [CCAnimate actionWithAnimation:flashAnim];
    
    int maxBlink;
    
    switch (_abil2Level) {
        case 0:
            return;
            break;
        case 1:
            maxBlink = ADJUST_COORD(90);
            break;
        case 2:
            maxBlink = ADJUST_COORD(140);
            break;
    }
    
    CGPoint adjOffset;
    if ((pow(offset.x-self.position.x, 2)+pow(offset.y-self.position.y, 2)) > maxBlink*maxBlink) {
        adjOffset = ccpNormalize(ccpSub(offset,self.position));
        adjOffset = ccpAdd(self.position,ccpMult(adjOffset, maxBlink));
    } else {
        adjOffset = offset;
    }
    
    float duration = (pow(adjOffset.x-self.position.x, 2)+pow(adjOffset.y-self.position.y, 2))/ADJUST_COORD(50000);
    
    Bullet *bullet = [_layer getBullet:kHero];
    [bullet setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"flash_base.png"]];
    bullet.position = self.position;
    bullet.opacity = 128;
    bullet.rotation = self.rotation;
    CCMoveBy * move = [CCMoveTo actionWithDuration:duration position:adjOffset];
    CCCallBlockN * call = [CCCallFuncN actionWithTarget:self selector:@selector(setInvisible:)];
    bullet.visible = YES;
    //bullet.source = _layer.currentPlayerValue;
    bullet.damage = 30;
    [bullet runAction:[CCSequence actions:move, call, nil]];
    
    
    
    id animate = [CCAnimate actionWithAnimation:[[SpriteDictionary sharedDictionary].data objectForKey:@"flashBlink"]];
    id reset = [CCCallFunc actionWithTarget:self selector:@selector(resetBaseSprite)];
    id sequence = [CCSequence actions:animate,reset, nil];
    
    self.position = adjOffset;
    [self.base runAction:sequence];
    [self setLayerAbilityFlag:kAbilityNone];
    _newTarPosition = adjOffset;
    [self schedule:@selector(resetHeroPosition) interval:0.05];
    
    
    
    
    
    
}

static int _flashCount;

- (void)flashFlash:(CGPoint)offset {
    
    if (_flashCount == 0) {
        _flashCount = 4;
    } 
    
    _isCasting = YES;
    
    /*CCSpriteFrame *f1 = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"flash_blink_anim1.png"];
     CCSpriteFrame *f2 = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"flash_blink_anim2.png"];
     CCSpriteFrame *f3 = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"flash_blink_anim3.png"];
     
     NSArray *frames = [NSArray arrayWithObjects:f1,f2,f3, nil];
     
     CCAnimation *flashAnim = [CCAnimation animationWithFrames:frames delay:0.1];//*/
    
    //id animate = [CCAnimate actionWithAnimation:flashAnim];
    
    int maxBlink;
    
    switch (_abil2Level) {
        case 0:
            return;
            break;
        case 1:
            maxBlink = ADJUST_COORD(90);
            break;
        case 2:
            maxBlink = ADJUST_COORD(140);
            break;
    }
    
    CGPoint adjOffset;
    if ((pow(offset.x-self.position.x, 2)+pow(offset.y-self.position.y, 2)) > maxBlink*maxBlink) {
        adjOffset = ccpNormalize(ccpSub(offset,self.position));
        adjOffset = ccpAdd(self.position,ccpMult(adjOffset, maxBlink));
    } else {
        adjOffset = offset;
    }
    
    float duration = (pow(adjOffset.x-self.position.x, 2)+pow(adjOffset.y-self.position.y, 2))/ADJUST_COORD(50000);
    
    Bullet *bullet = [_layer getBullet:kHero];
    [bullet setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"flash_base.png"]];
    bullet.position = self.position;
    bullet.opacity = 128;
    //bullet.rotation = self.rotation;
    CCMoveBy * move = [CCMoveTo actionWithDuration:duration position:adjOffset];
    CCCallBlockN * call = [CCCallFuncN actionWithTarget:self selector:@selector(setInvisible:)];
    bullet.visible = YES;
    bullet.damage = 30;
    [bullet runAction:[CCSequence actions:move, call, nil]];
    
    id animate = [CCAnimate actionWithAnimation:[[SpriteDictionary sharedDictionary].data objectForKey:@"flashBlink"]];
    id reset = [CCCallFunc actionWithTarget:self selector:@selector(resetBaseSprite)];
    id sequence = [CCSequence actions:animate,reset, nil];
    
    self.position = adjOffset;
    [self.base runAction:sequence];
    _flashCount--;
    if (_flashCount > 0) {
        [self setLayerAbilityFlag:kAbilityThree];
    } else {
        [self setLayerAbilityFlag:kAbilityNone];
    }
    _newTarPosition = adjOffset;
    [self schedule:@selector(resetHeroPosition) interval:0.05];
    
    
    
    /*
    _isCasting = YES;
    id animate = [CCAnimate actionWithAnimation:[[SpriteDictionary sharedDictionary].data objectForKey:@"flashBlink"]];
    id reset = [CCCallFunc actionWithTarget:self selector:@selector(resetBaseSprite)];
    id sequence = [CCSequence actions:animate,reset, nil];
    
    self.position = offset;
    [self.base runAction:sequence];
    [self setLayerAbilityFlag:kAbilityNone];
    _newTarPosition = offset;
    [self schedule:@selector(resetHeroPosition) interval:0.05];//*/
}

- (void)blazeBullet:(CGPoint)offset {
    NSString * shootSound = [NSString stringWithFormat:@"tank1Shoot.wav"];
    [[SimpleAudioEngine sharedEngine] playEffect:shootSound];
    
    CGPoint shotvect = ccpSub(offset, self.position);
    _shootVector = ccpNormalize(shotvect);
    
    CGPoint actualVector = ccpMult(_shootVector, self.range);  
    
    // 3
    float POINTS_PER_SECOND = ADJUST_COORD(self.projSpeed);
    float duration = self.range / POINTS_PER_SECOND;
    
    
    Bullet *bullet = [_layer getBullet:kHero];
    [bullet setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"fire_shot1.png"]];
    bullet.position = self.position;
    CGFloat angle = ccpToAngle(_shootVector);
    bullet.rotation = (int)(-1 * CC_RADIANS_TO_DEGREES(angle)) + 90;
    //[_layer.tileMap addChild:bullet z:2];
    CCMoveBy * move = [CCMoveBy actionWithDuration:duration position:actualVector];
    CCCallBlockN * call = [CCCallFuncN actionWithTarget:self selector:@selector(setInvisible:)];
    bullet.visible = YES;
    bullet.damage = 30;
    
    id animate = [CCAnimate actionWithAnimation:[[SpriteDictionary sharedDictionary].data objectForKey:@"blazeFireShot"]];
    id repeat = [CCRepeatForever actionWithAction:animate];
    
    [bullet runAction:repeat];
    [bullet runAction:[CCSequence actions:move, call, nil]];
    [self rotateTurretAngle];
}

- (void)blazeFireBlast:(CGPoint)offset {
    
    NSString * shootSound = [NSString stringWithFormat:@"tank1Shoot.wav"];
    [[SimpleAudioEngine sharedEngine] playEffect:shootSound];
    
    CGPoint shotvect = ccpSub(offset, self.position);
    _shootVector = ccpNormalize(shotvect);
    
    CGPoint actualVector = ccpMult(_shootVector, self.range);  
    
    // 3
    float POINTS_PER_SECOND = ADJUST_COORD(self.projSpeed);
    float duration = self.range / POINTS_PER_SECOND;
    
    
    //CCSprite *bullet = [CCSprite spriteWithSpriteFrameName:@"fire_shot1.png"];
    Bullet *bullet = [_layer getBullet:kHero];
    [bullet setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"fire_shot1.png"]];
    bullet.scale = 3;
    bullet.position = self.position;
    CGFloat angle = ccpToAngle(_shootVector);
    bullet.rotation = (int)(-1 * CC_RADIANS_TO_DEGREES(angle)) + 90;
    //[_layer.tileMap addChild:bullet z:2];
    CCMoveBy * move = [CCMoveBy actionWithDuration:duration position:actualVector];
    CCCallBlockN * call = [CCCallFuncN actionWithTarget:self selector:@selector(setInvisible:)];
    bullet.visible = YES;
    bullet.damage = 30;
    
    id animate = [CCAnimate actionWithAnimation:[[SpriteDictionary sharedDictionary].data objectForKey:@"blazeFireShot"]];
    id repeat = [CCRepeatForever actionWithAction:animate];
    
    [bullet runAction:repeat];
    [bullet runAction:[CCSequence actions:move, call, nil]];
    [self rotateTurretAngle];
    [self setLayerAbilityFlag:kAbilityNone];
    
}

- (void)blazeImmolation {
    
    
    
}

- (void)icebergBullet:(CGPoint)offset {
    NSString * shootSound = [NSString stringWithFormat:@"tank1Shoot.wav"];
    [[SimpleAudioEngine sharedEngine] playEffect:shootSound];
    
    CGPoint shotvect = ccpSub(offset, self.position);
    _shootVector = ccpNormalize(shotvect);
    
    CGPoint actualVector = ccpMult(_shootVector, self.range);  
    
    // 3
    float POINTS_PER_SECOND = ADJUST_COORD(self.projSpeed);
    float duration = self.range / POINTS_PER_SECOND;
    
    
    //CCSprite *bullet = [CCSprite spriteWithSpriteFrameName:@"ice_shot1.png"];
    Bullet *bullet = [_layer getBullet:kHero];
    [bullet setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"ice_shot1.png"]];
    bullet.position = self.position;
    CGFloat angle = ccpToAngle(_shootVector);
    bullet.rotation = (int)(-1 * CC_RADIANS_TO_DEGREES(angle)) + 90;
    //[_layer.tileMap addChild:bullet z:2];
    CCMoveBy * move = [CCMoveBy actionWithDuration:duration position:actualVector];
    CCCallBlockN * call = [CCCallFuncN actionWithTarget:self selector:@selector(setInvisible:)];
    bullet.visible = YES;
    bullet.damage = 30;
    
    id animate = [CCAnimate actionWithAnimation:[[SpriteDictionary sharedDictionary].data objectForKey:@"icebergIceShot"]];
    id repeat = [CCRepeatForever actionWithAction:animate];
    
    [bullet runAction:repeat];
    [bullet runAction:[CCSequence actions:move, call, nil]];
    [self rotateTurretAngle];
}

- (void)icebergIceCrag:(CGPoint)offset {
    
    NSString * shootSound = [NSString stringWithFormat:@"tank1Shoot.wav"];
    [[SimpleAudioEngine sharedEngine] playEffect:shootSound];
    
    CGPoint shotvect = ccpSub(offset, self.position);
    _shootVector = ccpNormalize(shotvect);
    
    CGPoint actualVector = ccpMult(_shootVector, self.range);  
    
    // 3
    float POINTS_PER_SECOND = ADJUST_COORD(self.projSpeed);
    float duration = self.range / POINTS_PER_SECOND;
    
    
    //CCSprite *bullet = [CCSprite spriteWithSpriteFrameName:@"voidzone1.png"];
    Bullet *bullet = [_layer getBullet:kHero];
    [bullet setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"voidzone1.png"]];
    bullet.position = offset;
    //CGFloat angle = ccpToAngle(_shootVector);
    //bullet.rotation = (-1 * CC_RADIANS_TO_DEGREES(angle)) + 90;
    [_layer.tileMap addChild:bullet z:2];
    //CCMoveBy * move = [CCMoveBy actionWithDuration:duration position:actualVector];
    CCCallBlockN * call = [CCCallFuncN actionWithTarget:self selector:@selector(setInvisible:)];
    bullet.visible = YES;
    bullet.damage = 30;
    
    id animate = [CCAnimate actionWithAnimation:[[SpriteDictionary sharedDictionary].data objectForKey:@"icebergIceCrag"]];
    //id repeat = [CCRepeatForever actionWithAction:animate];
    
    //[bullet runAction:repeat];
    [bullet runAction:[CCSequence actions:animate, call, nil]];
    [self rotateTurretAngle];
    [self setLayerAbilityFlag:kAbilityNone];
    
}

- (void)icebergIceAge {
    _isCasting = YES;
    id animate = [CCAnimate actionWithAnimation:[[SpriteDictionary sharedDictionary].data objectForKey:@"icebergIceAge"]];
    id reset = [CCCallFunc actionWithTarget:self selector:@selector(resetBaseSprite)];
    id sequence = [CCSequence actions:animate,reset, nil];
    
    
    [self.base runAction:sequence];
    [self setLayerAbilityFlag:kAbilityNone];
}


- (void)resetHeroPosition {
    _isCasting = NO;
    [self unschedule:@selector(resetHeroPosition)];
    [self setTargetPosition:_newTarPosition];
}

- (void)resetBaseSprite {
    //CCTexture2D *texture;
    switch (self.tankType) {
        case kFlash:
            //texture = [[CCTextureCache sharedTextureCache] addImage:@"flash_base.png"];
            [self.base setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"flash_base.png"]];
            //[self setTexture:texture];
            break;
        case kShadow:
            //texture = [[CCTextureCache sharedTextureCache] addImage:@"shadow_base.png"];
            //[self setTexture:texture];
            [self.base setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"shadow_base.png"]];
    }
    _isCasting = NO;
}

- (void)rotateTurretAngle {
    
    CGFloat angle = ccpToAngle(_shootVector);
    self.turret.rotation = (int)(-1 * CC_RADIANS_TO_DEGREES(angle)) + 90 - self.rotation;
        
}


- (void)dealloc {
    
    
    [super dealloc];
}


@end

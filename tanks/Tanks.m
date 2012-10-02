//
//  Tanks.m
//  tanks
//
//  Created by Cullen O'Neill on 1/3/12.
//  Copyright 2012 Lot18. All rights reserved.
//

#import "Tanks.h"
#import "SimpleAudioEngine.h"
#import "HelloWorldLayer.h"
#import "DeviceSettings.h"
#import "Bullet.h"
#import "TileMapLayer.h"
#import "HeroTank.h"


@implementation Tanks
@synthesize moving = _moving;
@synthesize hp = _hp;
@synthesize shooting = _shooting;
@synthesize RPM = _RPM;
@synthesize range = _range;
@synthesize projSpeed = _projSpeed;
@synthesize curWaypoint = _curWaypoint;
@synthesize mobLane = _mobLane;
@synthesize targetsInRange = _targetsInRange;
@synthesize targetsToRemove = _targetsToRemove;
@synthesize team = _team;
@synthesize curTarget = _curTarget;
@synthesize type = _type;
@synthesize speed = _speed;
@synthesize radius = _radius;
@synthesize damage = _damage;
@synthesize bulletType = _bulletType;
@synthesize targetPosition = _targetPosition;
@synthesize base = _base;
@synthesize turret = _turret;
@synthesize baseStrings = _baseStrings;
@synthesize bulletStr = _bulletStr;
@synthesize isActive = _isActive;

+ (id)enemyMobWithLayer:(TileMapLayer *)layer key:(NSString *)key team:(int)team {
    Tanks *enemy = [[[Tanks alloc] initWithKey:key layer:layer] autorelease];
    enemy.team = team;
    return enemy;
}


+ (id)heroTankWithLayer:(TileMapLayer *)layer team:(int)team hero:(int)hero {
    Tanks *tankHero;
    switch (hero) {
        case 0:
            tankHero = [Tanks shadowTankWithLayer:layer team:team];
            break;
        case 1:
            tankHero = [Tanks flashTankWithLayer:layer team:team];
            break;
    
    }
    
    return tankHero;
}

+ (id)shadowTankWithLayer:(TileMapLayer *)layer team:(int)team {
    Tanks *hero = [[[Tanks alloc] initWithKey:@"shadow" layer:layer] autorelease];
    hero.team = team;
    return hero;
}


+ (id)flashTankWithLayer:(TileMapLayer *)layer team:(int)team {
    Tanks *hero = [[[Tanks alloc] initWithKey:@"flash" layer:layer] autorelease];
    hero.team = team;
    return hero;
}

+ (id)blueTankWithLayer:(TileMapLayer *)layer team:(int)team {
    Tanks *hero = [[[Tanks alloc] initWithKey:@"blue_tank1" layer:layer] autorelease];
    hero.team = team;
    return hero;
}

+ (id)redTankWithLayer:(TileMapLayer *)layer team:(int)team {
    Tanks *hero = [[[Tanks alloc] initWithKey:@"red_tank1" layer:layer] autorelease];
    hero.team = team;
    return hero;
}

+ (id)blueTurretWithLayer:(TileMapLayer *)layer team:(int)team {
    Tanks *hero = [[[Tanks alloc] initWithKey:@"blue_turret1" layer:layer] autorelease];
    hero.team = team;
    return hero;
}

+ (id)redTurretWithLayer:(TileMapLayer *)layer team:(int)team {
    Tanks *hero = [[[Tanks alloc] initWithKey:@"red_turret1" layer:layer] autorelease];
    hero.team = team;
    return hero;
}




- (id)initWithKey:(NSString *)key layer:(TileMapLayer *)layer {
    
    NSString *pListPath = [[NSBundle mainBundle] pathForResource:@"mob_type.plist" ofType:nil];
    NSDictionary *rootDict = [NSDictionary dictionaryWithContentsOfFile:pListPath];
    _data = [NSDictionary dictionaryWithDictionary:[rootDict objectForKey:key]];
    //NSString *spritePath = [_data objectForKey:@"base"];
    
    
    if ((self = [super init])) {
        
        NSLog(@"loading %@",key);
        
        _type = [[_data objectForKey:@"type"] intValue];
        _hp = [[_data objectForKey:@"baseHP"] intValue];
        _range = [[_data objectForKey:@"baseRange"] intValue];
        _RPM = [[_data objectForKey:@"baseRPM"] intValue];
        _radius = [[_data objectForKey:@"radius"] intValue];
        _damage = [[_data objectForKey:@"baseDMG"] intValue];
        _projSpeed = [[_data objectForKey:@"projSpeed"] intValue];
        _baseStrings = [[CCArray alloc] init];
        CCArray *array = [_data objectForKey:@"base_strings"];
        for (int i = 0; i < array.count; i++) {
            NSString *basestr = [array objectAtIndex:i];
            [_baseStrings addObject:basestr];
        }
        
        _bulletStr = [NSString stringWithString:[_data objectForKey:@"bullet"]];
        
        NSLog(@"loading %@",_bulletStr);
        
        //_baseStrings = [_data objectForKey:@"base_strings"];
        //CCArray *base_strings = [_data objectForKey:@"base_strings"];
        _base = [CCSprite spriteWithSpriteFrameName:[_baseStrings objectAtIndex:0]];
        [self addChild:_base z:kTankBase];
        _turret = [CCSprite spriteWithSpriteFrameName:[_data objectForKey:@"turret"]];
        //_turret.position = ccp(_base.contentSize.width/2, _base.contentSize.height/2);
        _moveCounter = 0;
        
        
        
        if (_type != 0) {
            _speed = [[_data objectForKey:@"baseSpeed"] intValue];
            //_tankbase = [CCSprite spriteWithSpriteFrameName:[_data objectForKey:@"base"]];
            //[self addChild:_tankbase z:0 tag:0];
            
            if (_type == 5) {
                //_turret.anchorPoint = ccp(0.5, 0.25);
            } else if (_type == 6) {
                
            } else {
                _turret.anchorPoint = ccp(0.5, 0.25);
            }
            
            
            
            if (_type == 1) {
                self.curWaypoint = 0;
            } else if (_type == 100) {
                [self schedule:@selector(scheduleLogicForType) interval:1.5];
            }
        }
        
        _layer = layer;
        [self addChild:_turret z:kTankTurret tag:0];
        
        [self scheduleUpdateWithPriority:-1];
        _targetsToRemove = [[CCArray alloc] init];
        _targetsInRange = [[CCArray alloc] init];
        
    }
    
    return self;
    
}



- (id)initWithLayer:(TileMapLayer *)layer type:(int)type team:(int)team {
    
    self.curWaypoint = 0;
    _ready = NO;
    
    _team = team;
    
    NSString *tankTeam;
    if (_team == 1) {
        tankTeam = @"blue";
    } else if (_team == 2) {
        tankTeam = @"red";
    }
    
    NSString *tankBase;
    NSString *tankTurret;
    switch (type) {
        /*case 1:
            tankBase = @"soldier_armcannon_";
            tankTurret = @"soldier_armcannon_";
            _range = ADJUST_COORD(100);
            break;//*/
        case 2:
            tankBase = @"_tank_base";
            tankTurret = @"_tank_gun";
            _range = ADJUST_COORD(100);
            _speed = 50;
            break;
        case 3:
            tankBase = @"_turret1";
            tankTurret = @"_turret1";
            _range = ADJUST_COORD(200);
            break;
        case 4:
            tankBase = @"shadow_base";
            tankTurret = @"shadow_gun";
            tankTeam = @"";
            _range = ADJUST_COORD(100);
            _speed = 150;
            break;
    }
    
    NSString *spriteBase = [NSString stringWithFormat:@"%@%@.png",tankTeam,tankBase];
    
    
    
    
    //NSString *spriteFrameName = [NSString stringWithFormat:@"tank%d_base.png", type];    
    
    
    
    
    
    if ((self = [super init])) {
        
        _base = [CCSprite spriteWithSpriteFrameName:spriteBase];
        [self addChild:_base];
        _layer = layer;
        _type = type;
        self.hp = 5;     
        [self scheduleUpdateWithPriority:-1];
        
        self.RPM = 120;
        //self.range = 100;
        self.projSpeed = 100;
        
        //NSString *turretName = [NSString stringWithFormat:@"tank%d_turret.png", type];
        NSString *spriteTurret;
        if (type != 1) {
            spriteTurret = [NSString stringWithFormat:@"%@%@.png",tankTeam,tankTurret];
        }
        
        if (type != 1) {
            _turret = [CCSprite spriteWithSpriteFrameName:spriteTurret];
            if (type != 3) _turret.anchorPoint = ccp(0.5, 0.25);
            //_turret.position = ccp(_base.contentSize.width/2, _base.contentSize.height/2);
            [self addChild:_turret];
        }
        
        //[self schedule:@selector(updateShoot) interval:1/30];
        
        //double timeDiff = 60/self.RPM;
        
        //int bulletMin = 2*((_range/_projSpeed)/timeDiff) + 1;
        
        
        //_bullets = [[CCArray alloc] initWithCapacity:bulletMin];
        
        _targetsToRemove = [[CCArray alloc] init];
        
        _targetsInRange = [[CCArray alloc] init];
        
        
        /*NSString *bulletName = [NSString stringWithFormat:@"bullet_%@.png", tankTeam];
        for (int i = 0; i < bulletMin; i++) {
            
            CCSprite * bullet = [CCSprite spriteWithSpriteFrameName:bulletName];
            bullet.tag = _type;
            bullet.position = ccp(0,0);
            [_layer.batchNode addChild:bullet];
            [_bullets addObject:bullet];
            
            
        }//*/
        
        
        [self schedule:@selector(scheduleReady) interval:1];
        
        
        /*
        _flighttime = self.range/self.projSpeed;
        _bullets = 1 + _flighttime*60/self.RPM + 1;
         
         //*/
        
    }
    return self;
}

- (NSString *)defaultBulletForTank {
    NSString *bullet = [_data objectForKey:@"bullet"];
    return bullet;
}



- (void)scheduleReady {
    [self unschedule:@selector(scheduleReady)];
    _ready = YES;
}

- (void)moveToward:(CGPoint)targetPosition {    
    _targetPosition = targetPosition;     
    
    //_targetPosition = ccpAdd(self.position, targetPosition);
    
    
    
}

- (void)shootToward:(CGPoint)targetPosition {
    
    CGPoint offset = ccpSub(targetPosition, self.position);
    float MIN_OFFSET = 2;
    //if (ccpLength(offset) < MIN_OFFSET) return;
    
    if (ccpLength(targetPosition) < MIN_OFFSET) return;
    
    
    _shootVector = ccpNormalize(targetPosition);
    
    //CGFloat angle = ccpToAngle(_shootVector);
    //_turret.rotation = (-1 * CC_RADIANS_TO_DEGREES(angle)) + 90 - self.rotation;
    
    
}

- (void)shootTowardPosition:(CGPoint)targetPosition {
    
    CGPoint offset = ccpSub(targetPosition, self.position);
    float MIN_OFFSET = 2;
    if (ccpLength(offset) < MIN_OFFSET) return;
    
    _shootVector = ccpNormalize(offset);
    
    //CGFloat angle = ccpToAngle(_shootVector);
    //_turret.rotation = (-1 * CC_RADIANS_TO_DEGREES(angle)) + 90 - self.rotation;
    
    
}

- (void)scheduleLogicForType {
    [self unschedule:@selector(scheduleLogicForType)];
    
    switch (_type) {
        case 100:
            [self schedule:@selector(adjustMoveVectorEnemy) interval:1];
            _timeInactive = 0;
            break;
    }
    
    
    
}

- (void)calcNextMove {
    
    
    
    
    
}

- (void)adjustMoveVectorEnemy {
    
    _timeInactive += 0.2;
    
    if (_type == 100) {
        
        int _nearTargetDist;
        CGPoint _tarDist = ccpSub(self.position, _layer.tank.position);
        float _adjDist = (_tarDist.x*_tarDist.x + _tarDist.y*_tarDist.y);
        CGPoint _tarDist2 = ccpSub(self.position, _layer.tank.position);
        float _adjDist2 = (_tarDist2.x*_tarDist2.x + _tarDist2.y*_tarDist2.y);
        if (_adjDist < _adjDist2) {
            _adjDist = _adjDist2;
            _nearTarget = _layer.tank2.position;
        } else {
            _nearTarget = _layer.tank.position;
        }
        if (_adjDist < self.range*self.range*2) {
            self.moving = YES;
            [self moveToward:_nearTarget];
            _timeInactive = 0;
        } else {
            self.moving = NO;
        }
        
    }
    
    
    /*if (self.targetsToRemove.count > 0) {
        [self.targetsInRange removeObjectsInArray:_targetsToRemove];
        [self.targetsToRemove removeAllObjects];
        if (self.targetsInRange.count == 0 && _type == 100) { 
            self.moving = NO;
        }
    }
    
    if (_type == 100 && self.targetsInRange.count > 0) {
        
        int _nearTargetDist = self.range*self.range*2 + 1;
        for (Tanks *target in self.targetsInRange) {
            if (target.visible) {
                CGPoint _tarDist = ccpSub(self.position, target.position);
                float _adjDist = (_tarDist.x*_tarDist.x + _tarDist.y*_tarDist.y);
                if (_adjDist < self.range*self.range*2) {
                    if (_adjDist < _nearTargetDist) {
                        _nearTargetDist = _adjDist;
                        _nearTarget = target.position;
                    }
                } else if (_adjDist > self.range*self.range*2) {
                    [_targetsToRemove addObject:target];
                }
            } else {
                [_targetsToRemove addObject:target];
            }
            
            
        }
        
        if (_nearTargetDist <= self.range*self.range*2) {
            
            self.moving = YES;
            //CGPoint _offset = ccpSub(_nearTarget, self.position);
            [self moveToward:_nearTarget];
            _timeInactive = 0;
            
        }
        
        if (_targetsToRemove.count > 0) NSLog(@"target removed");
        
        
    }//*/
    
    if (_timeInactive >= 3) {
        self.isActive = NO;
        self.visible = NO;
    }
    
}

- (void)setShootVector:(CGPoint)vector {
    
    _shootVector = vector;
    //CGFloat angle = ccpToAngle(vector);
    //_turret.rotation = (-1 * CC_RADIANS_TO_DEGREES(angle)) + 90 - self.rotation;
    
}

- (void)updateMove:(ccTime)dt {
    
    // 1
    if (!self.moving) return;
    
    if (_isCasting) {
        return;
    }
    
    // 2
    CGPoint offset = ccpSub(_targetPosition, self.position);
    
    _moveVector = ccpNormalize(offset);
    
    //CGFloat angle = ccpToAngle(_moveVector);
    //self.rotation = (-1 * CC_RADIANS_TO_DEGREES(angle)) + 90;
    
    
    // 3
    float MIN_OFFSET = 3;
    if (ccpLength(offset) < MIN_OFFSET) return;
    
    // 4
    CGPoint targetVector = ccpNormalize(offset);    
    
    if (targetVector.x < 0) {
        _xMove -= targetVector.x;
    } else {
        _xMove += targetVector.x;
    }
    if (targetVector.y < 0) {
        _yMove -= targetVector.y;
    } else {
        _yMove += targetVector.y;
    }
    
    //NSLog(@"move x:%f y:%f",_xMove,_yMove);
    
    // 5
    float POINTS_PER_SECOND = ADJUST_COORD(_speed);
    CGPoint targetPerSecond = ccpMult(targetVector, POINTS_PER_SECOND);
    // 6
    CGPoint actualTarget = ccpAdd(self.position, ccpMult(targetPerSecond, dt));
    
    
    // 7
    /*int newX = (int)actualTarget.x;
    int newY = (int)actualTarget.y;
    actualTarget = ccp(newX,newY);//*/
    
    CGPoint oldPosition = self.position;
    self.position = actualTarget; 
    
    if ([_layer isWallAtRect:[self boundingBox]]) {
        self.position = oldPosition;
        
        
        /*CGPoint newPos = ccp(actualTarget.x,self.position.y);
        self.position = newPos;
        
        if ([_layer isWallAtRect:[self boundingBox]]) {
            self.position = oldPosition;
            newPos = ccp(self.position.x,actualTarget.y);
            self.position = newPos;
            
            if ([_layer isWallAtRect:[self boundingBox]]) {
                self.position = oldPosition;
            }
        }//*/
        
        
        
        
        //[self calcNextMove];
    }
    
}

- (void)shootNow {
    // 1
    //CGFloat angle = ccpToAngle(_shootVector);
    //_turret.rotation = (-1 * CC_RADIANS_TO_DEGREES(angle)) + 90;
    
    // 2
    //float mapMax = MAX([_layer tileMapWidth], [_layer tileMapHeight]);
    CGPoint actualVector = ccpMult(_shootVector, self.range);  
    
    // 3
    float POINTS_PER_SECOND = ADJUST_COORD(self.projSpeed);
    float duration = self.range / POINTS_PER_SECOND;
    
    
    NSString *tankTeam;
    BulletType bulType;
    /*if (_team == 1) {
        tankTeam = @"blue";
        bulType = kBlue;
    } else if (_team == 2) {
        tankTeam = @"red";
        bulType = kRed;
    }//*/
    
    
    // 4
    NSString * shootSound = [NSString stringWithFormat:@"tank2Shoot.wav"];
    [[SimpleAudioEngine sharedEngine] playEffect:shootSound];
    
    
    //CCSprite * bullet = [_bullets objectAtIndex:_bulletCounter];
    Bullet *bullet = [_layer getBullet:self.bulletType];
    bullet.position = self.position;//ccpAdd(self.position, ccpMult(_shootVector, _turret.contentSize.height));        
    CCMoveBy * move = [CCMoveBy actionWithDuration:duration position:actualVector];
    CCCallBlockN * call = [CCCallFuncN actionWithTarget:self selector:@selector(setInvisible:)];
    bullet.visible = YES;
    bullet.damage = _damage;
    [bullet runAction:[CCSequence actions:move, call, nil]];
    
    /*_bulletCounter++;
    if (_bulletCounter >= _bullets.count) {
        _bulletCounter = 0;
    }//*/
    
    
    
    // 5
    /*NSString *bulletName = [NSString stringWithFormat:@"bullet_%@.png", tankTeam];
    CCSprite * bullet = [CCSprite spriteWithSpriteFrameName:bulletName];
    bullet.tag = _type;
    bullet.position = ccpAdd(self.position, ccpMult(_shootVector, _turret.contentSize.height));        
    CCMoveBy * move = [CCMoveBy actionWithDuration:duration position:actualVector];
    CCCallBlockN * call = [CCCallBlockN actionWithBlock:^(CCNode *node) {
        [node removeFromParentAndCleanup:YES];
    }];
    [bullet runAction:[CCSequence actions:move, call, nil]];
    [_layer.batchNode addChild:bullet];//*/
}

- (void)setInvisible:(CCSprite *)sprite {
    sprite.visible = NO;
    sprite.opacity = 255;
    [sprite stopAllActions];
    
}





- (BOOL)shouldShoot {
    
    /*if (_type < 4 ) {
        if (!self.curTarget) {
            return NO;
        } else if (self.curTarget.visible) {
            _curTarget = nil;
            return NO;
        } else {
            CGPoint _tarDist = ccpSub(self.position, _curTarget.position);
            float _adjDist = (_tarDist.x*_tarDist.x + _tarDist.y*_tarDist.y);
            if (_adjDist < self.range*self.range) {
                //_nearTarget = _curTarget.position;
                self.shooting = YES;
                CGPoint _offset = ccpSub(_curTarget.position, self.position);
                [self shootToward:_offset];
                
                double SECS_BETWEEN_SHOTS = 60/self.RPM;
                if (_timeSinceLastShot > SECS_BETWEEN_SHOTS) {        
                    _timeSinceLastShot = 0;
                    return YES;        
                } else {
                    
                    return NO;
                }
            } else if (_adjDist > 1.25*self.range*self.range) {
                _curTarget = nil;
                return NO;
            }
        }
    } else {
        
        if (!self.shooting) return NO;    
        
        double SECS_BETWEEN_SHOTS = 60/self.RPM;
        if (_timeSinceLastShot > SECS_BETWEEN_SHOTS) {        
            _timeSinceLastShot = 0;
            return YES;        
        } else {
            return NO;
        }
        
    }//*/
    

    /*
    [self.targetsInRange removeObjectsInArray:_targetsToRemove];
    [self.targetsToRemove removeAllObjects];
    if (self.targetsInRange.count == 0 && (_type < 4 || _type == 100)) { 
        self.shooting = NO;
        //[self moveToNextWaypoint];
    }
    
    int mobVar = 1;
    
    if (_type == 100) {
        mobVar = 2;
    }//*/
    
    if (_type == 100) {
        
        int _nearTargetDist;
        CGPoint _tarDist = ccpSub(self.position, _layer.tank.position);
        float _adjDist = (_tarDist.x*_tarDist.x + _tarDist.y*_tarDist.y);
        CGPoint _tarDist2 = ccpSub(self.position, _layer.tank.position);
        float _adjDist2 = (_tarDist2.x*_tarDist2.x + _tarDist2.y*_tarDist2.y);
        if (_adjDist < _adjDist2) {
            _adjDist = _adjDist2;
            _nearTarget = _layer.tank2.position;
        } else {
            _nearTarget = _layer.tank.position;
        }
        if (_adjDist < self.range*self.range) {
            self.shooting = YES;
            CGPoint _offset = ccpSub(_nearTarget, self.position);
            [self shootToward:_offset];
            
            double SECS_BETWEEN_SHOTS = 60/self.RPM;
            if (_timeSinceLastShot > SECS_BETWEEN_SHOTS) {        
                _timeSinceLastShot = 0;
                //CGPoint _offset = ccpSub(_layer.tank.position, self.position);
                //[self shootToward:_offset];
                
                //NSLog(@"x:%f y:%f",_offset.x,_offset.y);
                return YES;        
            } else {
                return NO;
            }
        } else {
            return NO;
        }
        
    } else {
        
        if (!self.shooting) return NO;    
        
        double SECS_BETWEEN_SHOTS = 60/self.RPM;
        if (_timeSinceLastShot > SECS_BETWEEN_SHOTS) {        
            _timeSinceLastShot = 0;
            return YES;        
        } else {
            return NO;
        }
        
    }
    
    
    
    /*
    if ((_type < 4 || _type == 100) && self.targetsInRange.count > 0) {
        //NSLog(@"count:%d",[self.targetsInRange count]);
        
        int _nearTargetDist = self.range*self.range + 1;
        for (Tanks *target in self.targetsInRange) {
            //CCSprite *target = [self.targetsInRange objectAtIndex:0];
            if (target.visible) {
                CGPoint _tarDist = ccpSub(self.position, target.position);
                float _adjDist = (_tarDist.x*_tarDist.x + _tarDist.y*_tarDist.y);
                //NSLog(@"sx:%f sy:%f tx:%f ty:%f",self.position.x, self.position.y, target.position.x, target.position.y);
                if (_adjDist < self.range*self.range) {
                    if (_adjDist < _nearTargetDist) {
                        _nearTargetDist = _adjDist;
                        _nearTarget = target.position;
                        //NSLog(@"nearest target:%d",_nearTargetDist);
                    }
                } else if (_adjDist > self.range*self.range*mobVar) {
                    [_targetsToRemove addObject:target];
                    //NSLog(@"removed target");
                }
            } else {
                [_targetsToRemove addObject:target];
            }
            
            
        }
        
        if (_nearTargetDist >= self.range*self.range + 1) {
            return NO;
        } else {
            
            self.shooting = YES;
            CGPoint _offset = ccpSub(_nearTarget, self.position);
            [self shootToward:_offset];
            
            double SECS_BETWEEN_SHOTS = 60/self.RPM;
            if (_timeSinceLastShot > SECS_BETWEEN_SHOTS) {        
                _timeSinceLastShot = 0;
                //CGPoint _offset = ccpSub(_layer.tank.position, self.position);
                //[self shootToward:_offset];
                
                //NSLog(@"x:%f y:%f",_offset.x,_offset.y);
                return YES;        
            } else {
                
                return NO;
            }
            
            //NSLog(@"x:%f y:%f",_offset.x,_offset.y);
            
        }
        
        if (_targetsToRemove.count > 0) NSLog(@"target removed");
        
        [self.targetsInRange removeObjectsInArray:_targetsToRemove];
        [self.targetsToRemove removeAllObjects];
        if (self.targetsInRange.count == 0) { 
            self.shooting = NO;
            [self moveToNextWaypoint];
        }//
    } else {
    
        if (!self.shooting) return NO;    
        
        double SECS_BETWEEN_SHOTS = 60/self.RPM;
        if (_timeSinceLastShot > SECS_BETWEEN_SHOTS) {        
            _timeSinceLastShot = 0;
            return YES;        
        } else {
            return NO;
        }
    
    }//*/
}


- (void)updateShoot:(ccTime)dt {
    
    if (_isCasting) {
        return;
    }
    
    _timeSinceLastShot += dt;
    if ([self shouldShoot]) {       
        [self shootNow];        
    }
    
}//*/

- (void)updateShoot {
    if ([self shouldShoot]) {
        [self shootNow];
    }
}

- (void)update:(ccTime)dt {    
    
    
    /*if (!_ready) {
        return;
    }//*/
    
    if ((_xMove >= 5 || _yMove >= 5) && !_isCasting) {
        _moveCounter++;
        //CCArray *base_strings = [_data objectForKey:@"base_strings"];
        
        if (_moveCounter >= [self.baseStrings count]) {
            _moveCounter = 0;
        }
        [_base setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[self.baseStrings objectAtIndex:_moveCounter]]];
        _xMove = 0;
        _yMove = 0;
    }
    
    
    
    [self updateMove:dt]; 
    [self updateShoot:dt];
    
    CGFloat angle2 = ccpToAngle(_moveVector);
    if (self.moving) {
        self.rotation = (int)(-1 * CC_RADIANS_TO_DEGREES(angle2)) + 90;
    }
    
    CGFloat angle = ccpToAngle(_shootVector);
    if (self.shooting) {
        if (_type == 0) {
            self.rotation = (int)(-1 * CC_RADIANS_TO_DEGREES(angle)) + 90;
        } else {
            _turret.rotation = (int)(-1 * CC_RADIANS_TO_DEGREES(angle)) + 90 - self.rotation;
        }
    }
    
    //if (_team == 2 && _mobLane == 0) NSLog(@"count:%d team:%d lane:%d type:%d",_targetsInRange.count, _team, _mobLane, _type);
    
    if (_type == 1) {
        if (_targetsInRange.count == 0) {
            self.moving = YES;
            if (!_didReachWP) {
                
                CCTMXObjectGroup *objects;
                NSMutableDictionary *spawnPoint;
                if (_team == 1) {
                    switch (_mobLane) {
                        case 1:
                            objects = [_layer.tileMap objectGroupNamed:@"WaypointsTop"];
                            spawnPoint = [objects objectNamed:[NSString stringWithFormat:@"wp%d",self.curWaypoint]];
                            break;
                        case 3:
                            objects = [_layer.tileMap objectGroupNamed:@"WaypointsBot"];
                            spawnPoint = [objects objectNamed:[NSString stringWithFormat:@"wp%d",self.curWaypoint]];
                            break;
                    }
                } else if (_team == 2) {
                    int adjWP;
                    switch (_mobLane) {
                        case 1:
                            objects = [_layer.tileMap objectGroupNamed:@"WaypointsTop"];
                            adjWP = 12 - self.curWaypoint;
                            spawnPoint = [objects objectNamed:[NSString stringWithFormat:@"wp%d",adjWP]];
                            break;
                        case 3:
                            objects = [_layer.tileMap objectGroupNamed:@"WaypointsBot"];
                            adjWP = 12 - self.curWaypoint;
                            spawnPoint = [objects objectNamed:[NSString stringWithFormat:@"wp%d",adjWP]];
                            break;
                    }
                }
                
                
                int x = [[spawnPoint valueForKey:@"x"] intValue];
                int y = [[spawnPoint valueForKey:@"y"] intValue];
                CGPoint targetPos = ccp(x/CC_CONTENT_SCALE_FACTOR(), y/CC_CONTENT_SCALE_FACTOR());
                CGPoint offset = ccpSub(self.position, targetPos);
                
                float _length = ccpLength(offset);
                
                //NSLog(@"x:%d,y:%d",x,y);
                //NSLog(@"s.x:%f,s.y:%f",self.position.x,self.position.y);
                
                
                //NSLog(@"o.l:%f",_length);
                
                if (_length < 5) {
                    _didReachWP = YES;
                }
            } else {
                [self moveToNextWaypoint];
            }
        } else {
            self.moving = NO;
        }
    }
    
    
    /*
    if (_type < 4) {
        if (!self.shooting) {
            if (!_didReachWP) {
                CCTMXObjectGroup *objects;
                NSMutableDictionary *spawnPoint;
                if (_team == 1) {
                    switch (_mobLane) {
                        case 1:
                            objects = [_layer.tileMap objectGroupNamed:@"WaypointsTop"];
                            spawnPoint = [objects objectNamed:[NSString stringWithFormat:@"Waypoint%d",self.curWaypoint]];
                            break;
                        case 2: 
                            objects = [_layer.tileMap objectGroupNamed:@"WaypointsMid"];
                            spawnPoint = [objects objectNamed:[NSString stringWithFormat:@"Waypoint%d",self.curWaypoint]];
                            break;
                        case 3:
                            objects = [_layer.tileMap objectGroupNamed:@"WaypointsBot"];
                            spawnPoint = [objects objectNamed:[NSString stringWithFormat:@"Waypoint%d",self.curWaypoint]];
                            break;
                    }
                } else if (_team == 2) {
                    int adjWP;
                    switch (_mobLane) {
                        case 1:
                            objects = [_layer.tileMap objectGroupNamed:@"WaypointsTop"];
                            adjWP = 8 - self.curWaypoint;
                            spawnPoint = [objects objectNamed:[NSString stringWithFormat:@"Waypoint%d",adjWP]];
                            break;
                        case 2: 
                            objects = [_layer.tileMap objectGroupNamed:@"WaypointsMid"];
                            adjWP = 4 - self.curWaypoint;
                            spawnPoint = [objects objectNamed:[NSString stringWithFormat:@"Waypoint%d",adjWP]];
                            break;
                        case 3:
                            objects = [_layer.tileMap objectGroupNamed:@"WaypointsBot"];
                            adjWP = 8 - self.curWaypoint;
                            spawnPoint = [objects objectNamed:[NSString stringWithFormat:@"Waypoint%d",adjWP]];
                            break;
                    }
                }
                
                
                int x = [[spawnPoint valueForKey:@"x"] intValue];
                int y = [[spawnPoint valueForKey:@"y"] intValue];
                CGPoint targetPos = ccp(x, y);
                CGPoint offset = ccpSub(self.position, targetPos);
                
                float _length = ccpLength(offset);
                
                //NSLog(@"x:%d,y:%d",x,y);
                //NSLog(@"s.x:%f,s.y:%f",self.position.x,self.position.y);
                
                
                //NSLog(@"o.l:%f",_length);
                
                if (_length < 5) {
                    _didReachWP = YES;
                }
            } else {
                [self moveToNextWaypoint];
            }
        }
    }//*/
    
    /*
    if (_type < 4) {
        if (!self.visible) {
            return;
        } else {
            
            NSArray *enemyMobs;
            
            switch (_team) {
                case 1:
                    enemyMobs = _layer.actRedMobs;
                    break;
                case 2:
                    enemyMobs = _layer.actBlueMobs;
                    break;
            }
            
            for (Tanks *enemymob in enemyMobs) {
                if (!enemymob.visible) {
                    return;
                } else {
                    float _tarDist = ccpDistance(self.position, enemymob.position);
                    BOOL inArray = ([self.targetsInRange containsObject:enemymob]);
                    if (_tarDist < self.range ) {
                        [self addTargetToArray:enemymob];
                    } 
                }
            }
            
        }
    }//*/
    
    
}

- (void)moveToNextWaypoint {
    //[self unschedule:@selector(moveToNextWaypoint)];
    
    //NSLog(@"move to next waypoint");
    int waypointLimit = 0;
    switch (_mobLane) {
        case 1:
            waypointLimit = 12;
            break;
        case 2:
            waypointLimit = 4;
            break;
        case 3:
            waypointLimit = 12;
            break;
            
    }
    
    if (self.curWaypoint < waypointLimit) {
        if (_didReachWP) {
            self.curWaypoint++;
            self.moving = YES;
            _didReachWP = NO;
        }
    } else {
        return;
    }
    
    CCTMXObjectGroup *objects;
    NSMutableDictionary *spawnPoint;
    
    if (_team == 1) {
        switch (_mobLane) {
            case 1:
                objects = [_layer.tileMap objectGroupNamed:@"WaypointsTop"];
                spawnPoint = [objects objectNamed:[NSString stringWithFormat:@"wp%d",self.curWaypoint]];
                break;
            case 2: 
                objects = [_layer.tileMap objectGroupNamed:@"WaypointsMid"];
                spawnPoint = [objects objectNamed:[NSString stringWithFormat:@"wp%d",self.curWaypoint]];
                break;
            case 3:
                objects = [_layer.tileMap objectGroupNamed:@"WaypointsBot"];
                spawnPoint = [objects objectNamed:[NSString stringWithFormat:@"wp%d",self.curWaypoint]];
                break;
        }
    } else if (_team == 2) {
        int adjWP;
        switch (_mobLane) {
            case 1:
                objects = [_layer.tileMap objectGroupNamed:@"WaypointsTop"];
                adjWP = 12 - self.curWaypoint;
                spawnPoint = [objects objectNamed:[NSString stringWithFormat:@"wp%d",adjWP]];
                break;
            case 2: 
                objects = [_layer.tileMap objectGroupNamed:@"WaypointsMid"];
                adjWP = 4 - self.curWaypoint;
                spawnPoint = [objects objectNamed:[NSString stringWithFormat:@"wp%d",adjWP]];
                break;
            case 3:
                objects = [_layer.tileMap objectGroupNamed:@"WaypointsBot"];
                adjWP = 12 - self.curWaypoint;
                spawnPoint = [objects objectNamed:[NSString stringWithFormat:@"wp%d",adjWP]];
                break;
        }
    }

    
    int x = [[spawnPoint valueForKey:@"x"] intValue];
    int y = [[spawnPoint valueForKey:@"y"] intValue];
    CGPoint targetPos = ccp(x/CC_CONTENT_SCALE_FACTOR(), y/CC_CONTENT_SCALE_FACTOR());
    
    //NSLog(@"t.x:%f,t.y:%f",targetPos.x,targetPos.y);
    [self moveToward:targetPos];    
    
    
    
}

- (void)addTargetToArray:(Tanks *)target {
    
    //NSLog(@"count:%d",self.targetsInRange.count);
    
    if (!target) {
        return;
    }
    /*if (self.targetsInRange.count == 8) {
        return;
    } else*/ if ([self.targetsInRange containsObject:target]) {
        return;
    } else {
        BOOL arrayExists = NO;
        if (_targetsInRange) arrayExists = YES;
        NSLog(@"exists:%i",arrayExists);
        [self.targetsInRange addObject:target];
        
        NSLog(@"target added");
        
    }
    
    //NSLog(@"count:%d",self.targetsInRange.count);
}

- (void)addTargetArrayToArray:(CCArray *)targetArray {
    
    if (!targetArray) {
        return;
    }
    
    for (Tanks *target in targetArray) {
        if (target.visible && target.team != self.team) {
            [self.targetsInRange addObject:target];
            //NSLog(@"target added");
        }
    }
    
}

- (void)changeCurrentTarget:(Tanks *)target {
    self.curTarget = target;
}

- (void)checkPositions {
    
    
    if (!self.visible) {
        return;
    } else {
    
    NSArray *enemyMobs;
    
    switch (_team) {
        case 1:
            enemyMobs = _layer.actRedMobs;
            break;
        case 2:
            enemyMobs = _layer.actBlueMobs;
            break;
    }
    
    for (Tanks *enemymob in enemyMobs) {
        if (!enemymob.visible) {
            return;
        } else {
            float _tarDist = ccpDistance(self.position, enemymob.position);
            BOOL inArray = ([self.targetsInRange containsObject:enemymob]);
            if (_tarDist < self.range ) {
                [self addTargetToArray:enemymob];
            } 
        }
    }
    
    }
    
    
    /*
    
    for (int i = 0; i < enemyMobs.count; i++) {
        Tanks *enemymob = [enemyMobs objectAtIndex:i];
        if (!enemymob.visible) {
            return;
        } else {
            float _tarDist = ccpDistance(self.position, enemymob.position);
            if (_tarDist < self.range) {
                [self addTargetToArray:enemymob];
            } 
        }
    }//*/
            
    
    
    
    
    
    
    /*
    //NSLog(@"red pos start");
    
    //NSMutableArray *mobArray = [[NSMutableArray alloc] init];
    NSMutableArray *enemyMobArray = [[NSMutableArray alloc] init];
    NSArray *curTargets = [NSArray array];
    NSString *teamColor;
    NSString *enemyColor;
    
    switch (_team) {
        case 1:
            teamColor = @"blue";
            enemyColor = @"red";
            break;
        case 2:
            teamColor = @"red";
            enemyColor = @"blue";
            break;
    }
    
    
    for (int i = 0; i < 3; i++) {
        
        NSString *keyTur;
        NSString *keyMob;
        NSString *keyEnemyTur;
        
        switch (i) {
            case 0:
                keyMob = @"TopMob";
                keyTur = [NSString stringWithFormat:@"%@_top",teamColor];
                keyEnemyTur = [NSString stringWithFormat:@"%@_top",enemyColor];
                break;
            case 1:
                keyMob = @"MidMob";
                keyTur = [NSString stringWithFormat:@"%@_mid",teamColor];
                keyEnemyTur = [NSString stringWithFormat:@"%@_mid",enemyColor];
                break;
            case 2:
                keyMob = @"BotMob";
                keyTur = [NSString stringWithFormat:@"%@_bot",teamColor];
                keyEnemyTur = [NSString stringWithFormat:@"%@_bot",enemyColor];
                break;
        }
        
        switch (_team) {
            case 1:
                [enemyMobArray addObjectsFromArray:[_layer.redMobs objectForKey:keyMob]];
                [enemyMobArray addObjectsFromArray:[_layer.redMobs objectForKey:keyEnemyTur]];
                break;
            case 2:
                [enemyMobArray addObjectsFromArray:[_layer.blueMobs objectForKey:keyMob]];
                [enemyMobArray addObjectsFromArray:[_layer.blueMobs objectForKey:keyEnemyTur]];
                break;
        }
        
        
        
        if (_team == 2) [enemyMobArray addObject:_layer.tank];
        
        if (!self.visible) {
            return;
        } else {
            curTargets = self.targetsInRange;
            
            for (int z = 0; z < enemyMobArray.count; z++) {
                
                Tanks *enemy = [enemyMobArray objectAtIndex:z];
                
                if (!enemy.visible) {
                    return;
                } else if ([curTargets containsObject:enemy]) {
                    return;
                } else {
                    float _tarDist = ccpDistance(self.position, enemy.position);
                    NSLog(@"dist:%f range:%f",_tarDist,self.range);
                    if (_tarDist < self.range) {
                        [self addTargetToArray:enemy];
                    }
                }
                
            }
            
        }
            
            
            
        
        
    }//*/
    
    //[mobArray release];
    //[enemyMobArray release];
    
    //[self performSelectorInBackground:@selector(checkRedPositions) withObject:nil];
    
    
    
}

- (void)setLayerAbilityFlag:(AbilityNumber)flag {
    
    _layer.abilityFlagTouch = flag;
    
}

- (void)setTargetPosition:(CGPoint)position {
    _targetPosition = position;
}


- (void)dealloc {
    
    [_targetsInRange release]; _targetsInRange = nil;
    [_targetsToRemove release]; _targetsToRemove = nil;
    [_bullets release]; _bullets = nil;
    [_baseStrings release]; _baseStrings = nil;
    
    [super dealloc];
}


@end
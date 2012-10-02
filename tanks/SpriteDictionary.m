//
//  SpriteDictionary.m
//  tanks
//
//  Created by Cullen O'Neill on 2/29/12.
//  Copyright (c) 2012 Lot18. All rights reserved.
//

#import "SpriteDictionary.h"
#import "DeviceSettings.h"

@implementation SpriteDictionary

@synthesize data = _data;


static SpriteDictionary *activeDictionary = nil;

+ (void)activateDictionary {
    if (!activeDictionary) {
        activeDictionary = [[SpriteDictionary alloc] init];
    }
}

+ (SpriteDictionary *)sharedDictionary {
    if (!activeDictionary) {
        activeDictionary = [[SpriteDictionary alloc] init];
    }
    return activeDictionary;
}

- (id)init {
    
    if ((self = [super init])) {
        
        self.data = [[NSMutableDictionary alloc] init];
        
        //_batchNode = [CCSpriteBatchNode batchNodeWithFile:SD_OR_HD_PVR(@"sprite_animations.pvr.ccz")];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:SD_OR_HD_PLIST(@"sprite_animations.plist")];
        
        //[self loadFlashAnimations];
        
    }
    
    return self;
    
}

- (void)loadFlashAnimations {
    
    CCSpriteFrame *f1 = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"flash_blink_anim1.png"];
    CCSpriteFrame *f2 = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"flash_blink_anim2.png"];
    CCSpriteFrame *f3 = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"flash_blink_anim3.png"];
    
    
    NSArray *frames = [NSArray arrayWithObjects:f1,f2,f3, nil];
    
    CCAnimation *flashAnim = [CCAnimation animationWithFrames:frames delay:0.1];
    
    [_data setObject:flashAnim forKey:@"flashBlink"];
    
    
    CCSpriteFrame *f10 = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"lightning_shot1.png"];
    CCSpriteFrame *f11 = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"lightning_shot2.png"];
    CCSpriteFrame *f12 = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"lightning_shot3.png"];
    CCSpriteFrame *f13 = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"lightning_shot4.png"];
    CCSpriteFrame *f14 = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"lightning_shot5.png"];
    NSArray *frames2 = [NSArray arrayWithObjects:f10,f11,f12,f13,f14, nil];
    CCAnimation *blinkAnim2 = [CCAnimation animationWithFrames:frames2 delay:0.1];
    [_data setObject:blinkAnim2 forKey:@"flashLightningShot"];
    
    
}

- (void)loadShadowAnimations {
    
    NSLog(@"shadow anim loaded");
    
    CCSpriteFrame *f1 = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"voidzone1.png"];
    CCSpriteFrame *f2 = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"voidzone2.png"];
    CCSpriteFrame *f3 = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"voidzone3.png"];
    CCSpriteFrame *f4 = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"voidzone4.png"];
    CCSpriteFrame *f5 = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"voidzone5.png"];
    CCSpriteFrame *f6 = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"voidzone6.png"];
    CCSpriteFrame *f7 = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"voidzone7.png"];
    CCSpriteFrame *f8 = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"voidzone8.png"];
    
    NSArray *frames1 = [NSArray arrayWithObjects:f1,f2,f3,f4,f5,f6,f7,f8, nil];
    
    CCAnimation *shadowAnim1 = [CCAnimation animationWithFrames:frames1 delay:0.1];
    
    [_data setObject:shadowAnim1 forKey:@"shadowVoidZone"];
    
    
    CCSpriteFrame *f10 = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"dark_shot1.png"];
    CCSpriteFrame *f11 = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"dark_shot2.png"];
    CCSpriteFrame *f12 = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"dark_shot3.png"];
    CCSpriteFrame *f13 = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"dark_shot4.png"];
    CCSpriteFrame *f14 = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"dark_shot5.png"];
    NSArray *frames2 = [NSArray arrayWithObjects:f10,f11,f12,f13,f14, nil];
    CCAnimation *shadowAnim2 = [CCAnimation animationWithFrames:frames2 delay:0.1];
    [_data setObject:shadowAnim2 forKey:@"shadowDarkShot"];
    
    CCSprite *shadowHand = [CCSprite spriteWithSpriteFrameName:@"shadow_grab_hand.png"];
    [_data setObject:shadowHand forKey:@"shadowHand"];
    
    
    
    
}

- (void)loadIcebergAnimations {
    
    NSLog(@"shadow anim loaded");
    
    CCSpriteFrame *f1 = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"iceage1.png"];
    CCSpriteFrame *f2 = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"iceage2.png"];
    CCSpriteFrame *f3 = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"iceage3.png"];
    CCSpriteFrame *f4 = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"iceage4.png"];
    CCSpriteFrame *f5 = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"iceage5.png"];
    CCSpriteFrame *f6 = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"iceage6.png"];
    CCSpriteFrame *f7 = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"iceage7.png"];
    CCSpriteFrame *f8 = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"iceage8.png"];
    CCSpriteFrame *f9 = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"iceage9.png"];
    
    NSArray *frames1 = [NSArray arrayWithObjects:f1,f2,f3,f4,f5,f6,f7,f8,f9, nil];
    
    CCAnimation *iceAnim1 = [CCAnimation animationWithFrames:frames1 delay:0.1];
    
    [_data setObject:iceAnim1 forKey:@"icebergIceAge"];
    
    
    CCSpriteFrame *f10 = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"ice_shot1.png"];
    CCSpriteFrame *f11 = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"ice_shot2.png"];
    CCSpriteFrame *f12 = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"ice_shot3.png"];
    CCSpriteFrame *f13 = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"ice_shot4.png"];
    CCSpriteFrame *f14 = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"ice_shot5.png"];
    NSArray *frames2 = [NSArray arrayWithObjects:f10,f11,f12,f13,f14, nil];
    CCAnimation *iceAnim2 = [CCAnimation animationWithFrames:frames2 delay:0.1];
    [_data setObject:iceAnim2 forKey:@"icebergIceShot"];
    
    CCSpriteFrame *f15 = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"fire_shot1.png"];
    CCSpriteFrame *f16 = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"fire_shot2.png"];
    CCSpriteFrame *f17 = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"fire_shot3.png"];
    CCSpriteFrame *f18 = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"fire_shot4.png"];
    CCSpriteFrame *f19 = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"fire_shot5.png"];
    NSArray *frames3 = [NSArray arrayWithObjects:f15,f16,f17,f18,f19, nil];
    CCAnimation *fireAnim2 = [CCAnimation animationWithFrames:frames3 delay:0.1];
    [_data setObject:fireAnim2 forKey:@"blazeFireShot"];
    
    CCSpriteFrame *a1 = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"voidzone1.png"];
    CCSpriteFrame *a2 = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"voidzone2.png"];
    CCSpriteFrame *a3 = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"voidzone3.png"];
    NSArray *frames4 = [NSArray arrayWithObjects:a1,a2,a3, nil];
    CCAnimation *iceAnim3 = [CCAnimation animationWithFrames:frames4 delay:0.2];
    [_data setObject:iceAnim3 forKey:@"icebergIceCrag"];
    
    
}


- (void)dealloc {
    
    //[_data release]; _data = nil;
    [super dealloc];
}



@end

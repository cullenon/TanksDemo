//
//  GameSelectLayer.m
//  tanks
//
//  Created by Cullen O'Neill on 2/15/12.
//  Copyright (c) 2012 Lot18. All rights reserved.
//

#import "GameSelectLayer.h"
#import "SceneManager.h"
#import "DeviceSettings.h"
#import "PublicEnums.h"
#import "GCTurnHelper.h"
#import "AppDelegate.h"

@implementation GameSelectLayer

@synthesize gametype = _gametype;

-(id) init
{
	
	if ((self = [super init])) {
        
        CGSize winSize = [CCDirector sharedDirector].winSize;
        
        CCLabelTTF *singleLabel = [CCLabelTTF labelWithString:@"Single Player" fontName:@"Arial" fontSize:HD_PIXELS(20)];
        CCLabelTTF *multiLabel = [CCLabelTTF labelWithString:@"Multiplayer" fontName:@"Arial" fontSize:HD_PIXELS(20)];
        CCLabelTTF *backLabel = [CCLabelTTF labelWithString:@"Back" fontName:@"Arial" fontSize:HD_PIXELS(20)];
        CCMenuItemLabel *single = [CCMenuItemLabel itemWithLabel:singleLabel target:self selector:@selector(onSingle)];
        CCMenuItemLabel *multi = [CCMenuItemLabel itemWithLabel:multiLabel target:self selector:@selector(onMulti)];
        CCMenuItemLabel *back = [CCMenuItemLabel itemWithLabel:backLabel target:self selector:@selector(onBack)];

        CCMenu *menu = [CCMenu menuWithItems:single, multi, back, nil];
		menu.position = ccp(winSize.width/2, winSize.height/2);
		[menu alignItemsVerticallyWithPadding: 15.0f];
        
        
        
        [self addChild:menu];
    }
    return self;
    
}

- (void)onSingle {
    
    switch (self.gametype) {
        case 1:
            [SceneManager goLevelSelect:1];
            break;
        case 2:
            [SceneManager goTurnDemo];
            break;
    }
    
    
    //[SceneManager goLevelSelect];
    //[SceneManager goTankSelectWith:1 playID:1];
    //[SceneManager goTankSelect];
    //[SceneManager playLongMap:1];
}

- (void)onMulti {
    
    if (_gametype == 1) {
        [SceneManager goLevelSelect:2];
    } else if (_gametype == 2) {
        AppDelegate * delegate = (AppDelegate *) [UIApplication sharedApplication].delegate;                
        [[GCTurnHelper sharedInstance] findMatchWithMinPlayers:2 maxPlayers:2 viewController:delegate.viewController];
        [SceneManager goMPTurnDemo];
    }
    
    
    
    //[SceneManager goLevelSelect:2];
    //NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:2],@"numPlayers",[NSNumber numberWithInt:kFlash],@"p1",[NSNumber numberWithInt:kShadow],@"p2",nil];
    //[SceneManager playLongMapWithData:data];
    
    
    
    
    //[SceneManager goPlay];
    //[SceneManager playLongMap:2];
}

- (void)onBack {
    [SceneManager goMenu];
}



@end

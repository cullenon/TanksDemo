//
//  HUDLayer.m
//  tanks
//
//  Created by Cullen O'Neill on 1/14/12.
//  Copyright 2012 Lot18. All rights reserved.
//

#import "HUDLayer.h"
#import "DeviceSettings.h"



@implementation HUDLayer

@synthesize controlMove = _controlMove;
@synthesize controlShoot = _controlShoot;
@synthesize moveOffset = _moveOffset;
@synthesize shotOffset = _shotOffset;
@synthesize hp = _hp;


-(id) init
{
    if( (self=[super init])) {
        
        CGSize winSize = [CCDirector sharedDirector].winSize;
        
        
        CCLabelTTF *hpLabel = [CCLabelTTF labelWithString:@"0" fontName:@"Arial" fontSize:HD_PIXELS(24)];
        hpLabel.color = ccBLACK;
        hpLabel.position = ccp(winSize.width*0.3, winSize.height*0.3);
        [self addChild:hpLabel z:1 tag:100];
        
        //Joystick 
        ZJoystick *_joystick	= [ZJoystick joystickNormalSpriteFile:SD_OR_HD_PNG(@"JoystickContainer_norm.png") selectedSpriteFile:SD_OR_HD_PNG(@"JoystickContainer_trans.png") controllerSpriteFile:SD_OR_HD_PNG(@"Joystick_norm.png")];
        _joystick.position	= ccp(_joystick.contentSize.width/2, _joystick.contentSize.height/2);
        _joystick.delegate	= self;				//Joystick Delegate
        //_joystick.controlledObject  = self.tank;     //we set our controlled object which the blue circle
        _joystick.speedRatio         = 3.0f;                //we set speed ratio, movement speed of blue circle once controlled to any direction
        _joystick.joystickRadius     = 50.0f;               //Added in v1.2
        [self addChild:_joystick z:50 tag:50];//*/
        
        //----------------------------------------------------END----------------------------------------------------
        
        ZJoystick *_joystick2	= [ZJoystick joystickNormalSpriteFile:SD_OR_HD_PNG(@"JoystickContainer_norm.png") selectedSpriteFile:SD_OR_HD_PNG(@"JoystickContainer_trans.png") controllerSpriteFile:SD_OR_HD_PNG(@"Joystick_norm.png")];
        _joystick2.position	= ccp(winSize.width - _joystick.contentSize.width/2, _joystick.contentSize.height/2);
        _joystick2.delegate	= self;				//Joystick Delegate
        //_joystick.controlledObject  = self.tank;     //we set our controlled object which the blue circle
        _joystick2.speedRatio         = 3.0f;                //we set speed ratio, movement speed of blue circle once controlled to any direction
        _joystick2.joystickRadius     = 50.0f;               //Added in v1.2
        [self addChild:_joystick2 z:50 tag:51];
        
        self.isTouchEnabled = YES;
        [self scheduleUpdate];
        
        
        
        
    }
    return self;
}

- (void)update:(ccTime)dt {
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    ZJoystick *_tempJoystick1 = (ZJoystick *)[self getChildByTag:50];
    ZJoystick *_tempJoystick2 = (ZJoystick *)[self getChildByTag:51];
    
    if (_tempJoystick1.isControlling) {
        _controlMove = YES;
        CGPoint _contrPos = _tempJoystick1.controller.position;
        CGPoint _centPos = _tempJoystick1.position;
        /*float adjX = _centPos.x - winSize.width + _tempJoystick1.contentSize.width/2;
        float adjX2 = _contrPos.x - _tempJoystick1.contentSize.width/2;
        _contrPos = ccp(adjX2, _contrPos.y);
        _centPos = ccp(adjX, _centPos.y);*/
        
        _moveOffset = ccpSub(_centPos, _contrPos);
    } else {
        _controlMove = NO;
        _moveOffset = ccp(0,0);
    }
    
    if (_tempJoystick2.isControlling) {
        _controlShoot = YES;
        CGPoint _contrPos = _tempJoystick2.controller.position;
        CGPoint _centPos = _tempJoystick2.position;
        float adjX = _centPos.x - winSize.width + _tempJoystick2.contentSize.width/2;
        float adjX2 = _contrPos.x - _tempJoystick2.contentSize.width/2;
        _contrPos = ccp(adjX2, _contrPos.y);
        _centPos = ccp(adjX, _centPos.y);
        
        _shotOffset = ccpSub(_contrPos, _centPos);
    } else {
        _controlShoot = NO;
        _shotOffset = ccp(0,0);
    }
    
    CCLabelTTF *label = (CCLabelTTF *)[self getChildByTag:100];
[label setString:[NSString stringWithFormat:@"%d",_hp]];

    
    
}




@end


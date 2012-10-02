//
//  HUDLayer.h
//  Aiden's Adventures
//
//  Created by Cullen O'Neill on 9/29/11.
//  Copyright 2011 Lot18. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "ZJoystick.h"

@interface HUDLayer : CCLayer <ZJoystickDelegate> {
    
    
    
}

@property (assign) BOOL controlMove;
@property (assign) BOOL controlShoot;
@property (assign) CGPoint moveOffset;
@property (assign) CGPoint shotOffset;
@property (assign) int hp;

@end

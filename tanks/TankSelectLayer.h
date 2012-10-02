//
//  TankSelectLayer.h
//  tanks
//
//  Created by Cullen O'Neill on 2/18/12.
//  Copyright 2012 Lot18. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface TankSelectLayer : CCLayer {
    CCSpriteBatchNode *_batchNode;
    int _numPlayers;
    int _curPlayerValue;
}

- (id)initWithNum:(int)players curPID:(int)playID;

- (void)tank1;
- (void)tank2;
- (void)tank3;
- (void)tank4;

@end

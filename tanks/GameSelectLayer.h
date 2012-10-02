//
//  GameSelectLayer.h
//  tanks
//
//  Created by Cullen O'Neill on 2/15/12.
//  Copyright (c) 2012 Lot18. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface GameSelectLayer : CCLayer {

}

@property (assign) int gametype;

- (void)onSingle;
- (void)onMulti;
- (void)onBack;

@end

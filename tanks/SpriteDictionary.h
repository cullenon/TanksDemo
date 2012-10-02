//
//  SpriteDictionary.h
//  tanks
//
//  Created by Cullen O'Neill on 2/29/12.
//  Copyright (c) 2012 Lot18. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface SpriteDictionary : NSObject {
    CCSpriteBatchNode *_batchNode;
}

@property (retain) NSMutableDictionary *data;

+ (void)activateDictionary;
+ (SpriteDictionary *)sharedDictionary;
- (void)loadFlashAnimations;
- (void)loadShadowAnimations;
- (void)loadBlazeAnimations;
- (void)loadIcebergAnimations;

@end

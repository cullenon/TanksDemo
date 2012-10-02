//
//  MenuLayer.h
//  SpaceGame
//
//  Created by Cullen O'Neill on 9/2/11.
//  Copyright 2011 Lot18. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface MenuLayer : CCLayer  {
    
    //CCNode *_batchNodeDictionary;
    //CCSprite *_ship;
    CCLabelBMFont *currentPlayerLabel;
    CCNode *_menuNode;
    
    /*
    AdWhirlView *adView;
    //This is a trick, AdMob uses a viewController to display its Ads, trust me, you'll need this
    RootViewController *viewController_;//*/
    
}

//And last, we set the property
//@property (retain) AdWhirlView *adView;


- (id)init;
- (void)onNewGame:(id)sender;
- (void)onScores:(id)sender;
- (void)onCredits:(id)sender;
- (void)onOptions;

@end

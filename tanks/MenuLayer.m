//
//  MenuLayer.m
//  SpaceGame
//
//  Created by Cullen O'Neill on 9/2/11.
//  Copyright 2011 Lot18. All rights reserved.
//

#import "MenuLayer.h"
#import "SimpleAudioEngine.h"
#import "DeviceSettings.h"
#import "SceneManager.h"
/*
#import "AdWhirlView.h"
#import "AppDelegate.h"
#import "LeaderboardViewController.h"
#import "AchievementsViewController.h"//*/
@interface MenuLayer ()

@end

@implementation MenuLayer
{
    
}
//@synthesize adView;

-(id) init
{
	
	if ((self = [super init])) {
		CGSize winSize = [[CCDirector sharedDirector] winSize];
		
        [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
        
        
        
        //NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        //int theme = [[defaults objectForKey:@"COCacheDefault"] intValue];
        
        
        _menuNode = [CCNode node];
        [self addChild:_menuNode];
        
        
        /*
        CCLabelBMFont *newLabel = [CCLabelBMFont labelWithString:@"New Game" fntFile:SD_OR_HD_FNT(@"visitor32.fnt")];
        CCLabelBMFont *scoresLabel = [CCLabelBMFont labelWithString:@"High Scores" fntFile:SD_OR_HD_FNT(@"visitor32.fnt")];
        CCLabelBMFont *achieveLabel = [CCLabelBMFont labelWithString:@"Achievements" fntFile:SD_OR_HD_FNT(@"visitor32.fnt")];
        CCLabelBMFont *optionsLabel = [CCLabelBMFont labelWithString:@"Options" fntFile:SD_OR_HD_FNT(@"visitor32.fnt")];
        CCLabelBMFont *creditsLabel = [CCLabelBMFont labelWithString:@"Credits" fntFile:SD_OR_HD_FNT(@"visitor32.fnt")];
        CCLabelBMFont *howToLabel = [CCLabelBMFont labelWithString:@"How To Play" fntFile:SD_OR_HD_FNT(@"visitor32.fnt")];//*/
        
        
        
        CCLabelTTF *newLabel = [CCLabelTTF labelWithString:@"New Game" fontName:@"Arial" fontSize:HD_PIXELS(20)];
        CCLabelTTF *optionsLabel = [CCLabelTTF labelWithString:@"Options" fontName:@"Arial" fontSize:HD_PIXELS(20)];
        CCLabelTTF *creditsLabel = [CCLabelTTF labelWithString:@"Credits" fontName:@"Arial" fontSize:HD_PIXELS(20)];
        CCLabelTTF *howToLabel = [CCLabelTTF labelWithString:@"How To Play" fontName:@"Arial" fontSize:HD_PIXELS(20)];//*/
        
        //NSString *currentPlayer = [NSString stringWithFormat:@"%@'s Adventure", [GCCache activeCache].profileName];
        currentPlayerLabel = [CCLabelTTF labelWithString:@"Tank SMASH" fontName:@"Arial" fontSize:HD_PIXELS(36)];
        
		
		CCMenuItemLabel *startNew = [CCMenuItemLabel itemWithLabel:newLabel target:self selector:@selector(onNewGame:)];
        CCMenuItemLabel *options = [CCMenuItemLabel itemWithLabel:optionsLabel target:self selector:@selector(onOptions)];
        CCMenuItemLabel *credits = [CCMenuItemLabel itemWithLabel:creditsLabel target:self selector:@selector(onCredits:)];
        CCMenuItemLabel *howToPlay = [CCMenuItemLabel itemWithLabel:howToLabel target:self selector:@selector(onHowToPlay:)];
        
        CCMenu *menu = [CCMenu menuWithItems:startNew, options, howToPlay, credits, nil];
		menu.position = ccp(winSize.width/2, winSize.height/2);
		[menu alignItemsVerticallyWithPadding: 15.0f];
        
        currentPlayerLabel.position = ccp(winSize.width/2, winSize.height*0.8);
        //currentPlayerLabel.scale = 0.75;
        
		[_menuNode addChild:menu];
        [_menuNode addChild:currentPlayerLabel];
	}
	
	return self;
}


- (void)onNewGame:(id)sender
{
	//[MusicHandler playButtonClick];
	//[self restartGame];
    //[SceneManager goPlay];
    //[SceneManager goGameSelect];
    [SceneManager goGameType:1];
}

- (void)onScores:(id)sender
{
	//[MusicHandler playButtonClick];
	//[SceneManager goHighscore];
    [self showHighScores];
}

- (void)onCredits:(id)sender
{
    //[SceneManager goCredits];
}

- (void)onHowToPlay:(id)sender {
    //[SceneManager goHowToPlay];
}

- (void)onOptions {
    //[SceneManager goTurnDemo];
    [SceneManager goGameType:2];
    
    /*CGSize winSize = [CCDirector sharedDirector].winSize;
    id action = [CCSequence actions:[CCMoveBy actionWithDuration:0.1 position:ccp(winSize.width*0.05,0)], [CCMoveBy actionWithDuration:0.8 position:ccp(-winSize.width*1.1,0)], [CCMoveBy actionWithDuration:0.1 position:ccp(winSize.width*0.05,0)], nil];
    [_menuNode runAction:action];//*/
}

- (void)backPressed {
    /*CGSize winSize = [CCDirector sharedDirector].winSize;
    id action = [CCSequence actions:[CCMoveBy actionWithDuration:0.1 position:ccp(-winSize.width*0.05,0)], [CCMoveBy actionWithDuration:0.8 position:ccp(winSize.width*1.1,0)], [CCMoveBy actionWithDuration:0.1 position:ccp(-winSize.width*0.05,0)], nil];
    [_menuNode runAction:action];
    [currentPlayerLabel setString:[NSString stringWithFormat:@"%@'s Adventure", [GCCache activeCache].profileName]];//*/
}

- (void)dealloc {
    
    //Remove the adView controller
    //self.adView.delegate = nil;
    //self.adView = nil;
    //_ship = nil;
    _menuNode = nil;
    [super dealloc];
}





@end

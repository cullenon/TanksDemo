//
//  MPTurnLayer.m
//  tanks
//
//  Created by Cullen O'Neill on 5/12/12.
//  Copyright 2012 Lot18. All rights reserved.
//

#import "MPTurnLayer.h"
#import "SimpleAudioEngine.h"
#import "HKTMXTiledMap.h"
#import "HKTMXLayer.h"
#import "TileData.h"
#import "DeviceSettings.h"
#import "SceneManager.h"
#import "PublicEnums.h"
#import "MPUnit.h"
#import "MPUnit_Soldier.h"
#import "Building.h"


@implementation MPTurnLayer

@synthesize tileDataArray;
@synthesize p1Units;
@synthesize p2Units;
@synthesize playerTurn;
@synthesize selectedUnit;
@synthesize actionsMenu;
@synthesize mapData = _mapData;

+ (id)mpTurnLayerWithKey:(NSString *)key Data:(NSDictionary *)data {
    MPTurnLayer *mpLayer = [[[MPTurnLayer alloc] initWithData:data key:key new:NO] autorelease];
    return mpLayer;
}

+ (id)mpTurnLayerNewMap:(NSString *)key {
    MPTurnLayer *mpLayer = [[[MPTurnLayer alloc] initWithData:nil key:key new:YES] autorelease];
    return mpLayer;
}

- (id)initWithData:(NSDictionary *)data key:(NSString *)key new:(BOOL)gameIsNew {
    
    if ((self=[super init])) {
        self.isTouchEnabled = YES;
        //[self createTileMapWithKey:key];
        
        CGSize winSize = [CCDirector sharedDirector].winSize;
        CCLabelTTF *backLabel = [CCLabelTTF labelWithString:@"back" fontName:@"Arial" fontSize:HD_PIXELS(24)];
        CCMenuItemLabel *goBack = [CCMenuItemLabel itemWithLabel:backLabel target:self selector:@selector(onBack:)];
        
        //_mapData = [[NSMutableDictionary alloc] initWithDictionary:mapData];
		
		CCMenu *menu = [CCMenu menuWithItems:goBack, nil];
		menu.position = ccp(winSize.width*0.9, winSize.height*0.9);
		[menu alignItemsVerticallyWithPadding: 20.0f];
		[self addChild:menu z:50];
        
        
        
        p1Units = [[NSMutableArray alloc] initWithCapacity:10];
        p2Units = [[NSMutableArray alloc] initWithCapacity:10];
        //[self loadUnits:1];
        //[self loadUnits:2];
        
        // Set up turns
        playerTurn = 1;
        [self addMenu];
        
        // Create building arrays
        p1Buildings = [[NSMutableArray alloc] initWithCapacity:10];
        p2Buildings = [[NSMutableArray alloc] initWithCapacity:10];
        // Load buildings
        //[self loadBuildings:1];
        //[self loadBuildings:2];
        
        // Play background music
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"Five Armies.mp3" loop:YES];
        
        [GCTurnHelper sharedInstance].delegate = self;
        
        if (gameIsNew) {
            //load all of the regular data from the map
            [self createTileMapWithKey:key];
            [self loadUnits:1];
            [self loadUnits:2];
            [self loadBuildings:1];
            [self loadBuildings:2];
        } else {
            _mapData = [[NSMutableDictionary alloc] initWithDictionary:data];
            [self loadUnits:1 mapData:_mapData];
            [self loadUnits:2 mapData:_mapData];
            [self loadBuildings:1];
            [self loadBuildings:2];
        }
        
        
        
    }
    return self;
    
    
    
}

- (id)init {
    if ((self=[super init])) {
        self.isTouchEnabled = YES;
        [self createTileMap];
        _moveCounter = 0;
        
        CGSize winSize = [CCDirector sharedDirector].winSize;
        CCLabelTTF *backLabel = [CCLabelTTF labelWithString:@"back" fontName:@"Arial" fontSize:HD_PIXELS(24)];
        CCMenuItemLabel *goBack = [CCMenuItemLabel itemWithLabel:backLabel target:self selector:@selector(onBack:)];
        
        _mapData = [[NSMutableDictionary alloc] init];
        NSMutableArray *army1 = [NSMutableArray array];
        NSMutableArray *army2 = [NSMutableArray array];
        NSMutableArray *moves = [NSMutableArray array];
        [_mapData setObject:army1 forKey:@"army1"];
        [_mapData setObject:army1 forKey:@"army2"];
        [_mapData setObject:moves forKey:@"move_queue"];
		
		CCMenu *menu = [CCMenu menuWithItems:goBack, nil];
		menu.position = ccp(winSize.width*0.9, winSize.height*0.9);
		[menu alignItemsVerticallyWithPadding: 20.0f];
		[self addChild:menu];
        
        p1Units = [[NSMutableArray alloc] initWithCapacity:10];
        p2Units = [[NSMutableArray alloc] initWithCapacity:10];
        [self loadUnits:1];
        [self loadUnits:2];
        
        // Set up turns
        playerTurn = 1;
        [self addMenu];
        
        // Create building arrays
        p1Buildings = [[NSMutableArray alloc] initWithCapacity:10];
        p2Buildings = [[NSMutableArray alloc] initWithCapacity:10];
        // Load buildings
        [self loadBuildings:1];
        [self loadBuildings:2];
        
        // Play background music
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"Five Armies.mp3" loop:YES];
        
        [GCTurnHelper sharedInstance].delegate = self;
    }
    return self;
}


- (void)dealloc
{
	[tileDataArray release];
    [p1Units release];
    [p2Units release];
    [p1Buildings release];
    [p2Buildings release];
    
    [_mapData release]; _mapData = nil;
	[super dealloc];
}

- (void)onBack:(id)sender
{
	[SceneManager goMenu];
}

- (void)createTileMapWithKey:(NSString *)key {
    // 1 - Create the map
    tileMap = [CCTMXTiledMap tiledMapWithTMXFile:SD_OR_HD_TMX(key)];        
    [self addChild:tileMap];
    // 2 - Get the background layer
    bgLayer = [tileMap layerNamed:@"Background"];
    // 3 - Get information for each tile in background layer
    tileDataArray = [[NSMutableArray alloc] initWithCapacity:5];
    for(int i = 0; i< tileMap.mapSize.height;i++) {
        for(int j = 0; j< tileMap.mapSize.width;j++) {
            int movementCost = 1;
            NSString * tileType = nil;
            int tileGid=[bgLayer tileGIDAt:ccp(j,i)];
            if (tileGid) {
                NSDictionary *properties = [tileMap propertiesForGID:tileGid];
                if (properties) {
                    movementCost = [[properties valueForKey:@"MovementCost"] intValue];
                    tileType = [properties valueForKey:@"TileType"];
                }
            }
            TileData * tData = [TileData nodeWithTheGame:self movementCost:movementCost position:ccp(j,i) tileType:tileType];
            [tileDataArray addObject:tData];
        } 
    }
}



- (void)createTileMap {
    // 1 - Create the map
    tileMap = [CCTMXTiledMap tiledMapWithTMXFile:SD_OR_HD_TMX(@"StageMap.tmx")];        
    [self addChild:tileMap];
    // 2 - Get the background layer
    bgLayer = [tileMap layerNamed:@"Background"];
    // 3 - Get information for each tile in background layer
    tileDataArray = [[NSMutableArray alloc] initWithCapacity:5];
    for(int i = 0; i< tileMap.mapSize.height;i++) {
        for(int j = 0; j< tileMap.mapSize.width;j++) {
            int movementCost = 1;
            NSString * tileType = nil;
            int tileGid=[bgLayer tileGIDAt:ccp(j,i)];
            if (tileGid) {
                NSDictionary *properties = [tileMap propertiesForGID:tileGid];
                if (properties) {
                    movementCost = [[properties valueForKey:@"MovementCost"] intValue];
                    tileType = [properties valueForKey:@"TileType"];
                }
            }
            TileData * tData = [TileData nodeWithTheGame:self movementCost:movementCost position:ccp(j,i) tileType:tileType];
            [tileDataArray addObject:tData];
        } 
    }
}

// Get the scale for a sprite - 1 for normal display, 2 for retina
- (int)spriteScale {
    if (IS_HD)
        return 2;
    else
        return 1;
}

// Get the height for a tile based on the display type (retina or SD)
- (int)getTileHeightForRetina {
    if (IS_HD)
        return TILE_HEIGHT_HD;
    else
        return TILE_HEIGHT;
}

// Return tile coordinates (in rows and columns) for a given position
- (CGPoint)tileCoordForPosition:(CGPoint)position {
    CGSize tileSize = CGSizeMake(tileMap.tileSize.width,tileMap.tileSize.height);
    if (IS_HD) {
        tileSize = CGSizeMake(tileMap.tileSize.width/2,tileMap.tileSize.height/2);
    }
    int x = position.x / tileSize.width;
    int y = ((tileMap.mapSize.height * tileSize.height) - position.y) / tileSize.height;
    return ccp(x, y);
}

// Return the position for a tile based on its row and column
- (CGPoint)positionForTileCoord:(CGPoint)position {
    CGSize tileSize = CGSizeMake(tileMap.tileSize.width,tileMap.tileSize.height);
    if (IS_HD) {
        tileSize = CGSizeMake(tileMap.tileSize.width/2,tileMap.tileSize.height/2);
    }
    int x = position.x * tileSize.width + tileSize.width/2;
    int y = (tileMap.mapSize.height - position.y) * tileSize.height - tileSize.height/2;
    return ccp(x, y);
}

// Get the surrounding tiles (above, below, to the left, and right) of a given tile based on its row and column
- (NSMutableArray *)getTilesNextToTile:(CGPoint)tileCoord {
    NSMutableArray * tiles = [NSMutableArray arrayWithCapacity:4]; 
    if (tileCoord.y+1<tileMap.mapSize.height)
        [tiles addObject:[NSValue valueWithCGPoint:ccp(tileCoord.x,tileCoord.y+1)]];
    if (tileCoord.x+1<tileMap.mapSize.width)
        [tiles addObject:[NSValue valueWithCGPoint:ccp(tileCoord.x+1,tileCoord.y)]];
    if (tileCoord.y-1>=0)
        [tiles addObject:[NSValue valueWithCGPoint:ccp(tileCoord.x,tileCoord.y-1)]];
    if (tileCoord.x-1>=0)
        [tiles addObject:[NSValue valueWithCGPoint:ccp(tileCoord.x-1,tileCoord.y)]];
    return tiles;
}

// Get the TileData for a tile at a given position
- (TileData *)getTileData:(CGPoint)tileCoord {
    for (TileData * td in tileDataArray) {
        if (CGPointEqualToPoint(td.position, tileCoord)) {
            return td;
        }
    }
    return nil;
}

- (void)loadUnits:(int)player mapData:(NSDictionary *)mapData {
    
    // 1 - Retrieve the layer based on the player number
    //CCTMXObjectGroup * unitsObjectGroup = [tileMap objectGroupNamed:[NSString stringWithFormat:@"Units_P%d",player]];
    // 2 - Set the player array
    NSMutableArray * units = nil;
    if (player ==1)
        units = p1Units;
    if (player ==2)
        units = p2Units;
    
    
    
    // 3 - Load units into player array based on the objects on the layer
    for (int i = 0; i < [units count]; i++) {
        NSMutableDictionary * d = [_mapData objectForKey:[NSString stringWithFormat:@"army%d",player]];
        NSString * unitType = [d objectForKey:@"Type"];
        NSLog(@"%@",[d objectForKey:@"Type"]);
        NSString *classNameStr = [NSString stringWithFormat:@"Unit_%@",unitType];
        //Class theClass = NSClassFromString(classNameStr);
        MPUnit * unit = [MPUnit_Soldier nodeWithTheGame:self tileDict:d owner:player];
        [units addObject:unit];
        
    } 
    
    
}

- (void)loadUnits:(int)player {
    // 1 - Retrieve the layer based on the player number
    CCTMXObjectGroup * unitsObjectGroup = [tileMap objectGroupNamed:[NSString stringWithFormat:@"Units_P%d",player]];
    // 2 - Set the player array
    NSMutableArray * units = nil;
    if (player ==1)
        units = p1Units;
    if (player ==2)
        units = p2Units;
   
    
    // 3 - Load units into player array based on the objects on the layer
    for (NSMutableDictionary * unitDict in [unitsObjectGroup objects]) {
        NSMutableDictionary * d = [NSMutableDictionary dictionaryWithDictionary:unitDict];
        NSString * unitType = [d objectForKey:@"Type"];
        NSLog(@"%@",[d objectForKey:@"Type"]);
        NSString *classNameStr = [NSString stringWithFormat:@"Unit_%@",unitType];
        //Class theClass = NSClassFromString(classNameStr);
        MPUnit * unit = [MPUnit_Soldier nodeWithTheGame:self tileDict:d owner:player];
        [units addObject:unit];
        
    } 
    
}

// Check specified tile to see if there's any other unit (from either player) in it already
-(MPUnit *)otherUnitInTile:(TileData *)tile {
    for (MPUnit *u in p1Units) {
        if (CGPointEqualToPoint([self tileCoordForPosition:u.mySprite.position], tile.position))
            return u;
    }
    for (MPUnit *u in p2Units) {
        if (CGPointEqualToPoint([self tileCoordForPosition:u.mySprite.position], tile.position))
            return u;
    }
    return nil;
}

// Check specified tile to see if there's an enemy unit in it already
-(MPUnit *)otherEnemyUnitInTile:(TileData *)tile unitOwner:(int)owner {
    if (owner == 1) {
        for (MPUnit *u in p2Units) {
            if (CGPointEqualToPoint([self tileCoordForPosition:u.mySprite.position], tile.position))
                return u;
        }
    } else if (owner == 2) {
        for (MPUnit *u in p1Units) {
            if (CGPointEqualToPoint([self tileCoordForPosition:u.mySprite.position], tile.position))
                return u;
        }
    }
    return nil;
}

// Mark the specified tile for movement, if it hasn't been marked already
-(BOOL)paintMovementTile:(TileData *)tData {
    CCSprite *tile = [bgLayer tileAt:tData.position];
    if (!tData.selectedForMovement) {
        [tile setColor:ccBLUE];
        tData.selectedForMovement = YES;
        return NO;
    }
    return YES;
}

// Set the color of a tile back to the default color
-(void)unPaintMovementTile:(TileData *)tileData {
    CCSprite * tile = [bgLayer tileAt:tileData.position];
    [tile setColor:ccWHITE];
}

// Select specified unit
-(void)selectUnit:(MPUnit *)unit {
    selectedUnit = nil;
    selectedUnit = unit;
}

// Deselect the currently selected unit
-(void)unselectUnit {
    if (selectedUnit) {
        [selectedUnit unselectUnit];
    }
    selectedUnit = nil;
}

-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	for (UITouch *touch in touches) {
		// Get the location of the touch
		CGPoint location = [touch locationInView: [touch view]];
		// Convert the touch location to OpenGL coordinates
		location = [[CCDirector sharedDirector] convertToGL: location];
		// Get the tile data for the tile at touched position
		TileData * td = [self getTileData:[self tileCoordForPosition:location]];
		// Move to the tile if we can move there
        if ((td.selectedForMovement && ![self otherUnitInTile:td]) || ([self otherUnitInTile:td] == selectedUnit)) {
            [selectedUnit doMarkedMovement:td];
            CGPoint p1 = [self positionForTileCoord:[self tileCoordForPosition:location]];
            NSLog(@"x:%f y:%f",p1.x,p1.y);
            
        } else if(td.selectedForAttack) {
            // Attack the specified tile
            [selectedUnit doMarkedAttack:td];
            // Deselect the unit
            [self unselectUnit];
        } else {
            // Tapped a non-marked tile. What do we do?
            if (selectedUnit.selectingAttack) {
                // Was in the process of attacking - cancel attack and show menu
                selectedUnit.selectingAttack = NO;
                [self unPaintAttackTiles];
                [self showActionsMenu:selectedUnit canAttack:YES];
            } else if (selectedUnit.selectingMovement) {
                // Was in the process of moving - just remove marked tiles and await further action
                selectedUnit.selectingMovement = NO;
                [selectedUnit unMarkPossibleMovement];
                [self unselectUnit];
            }
        }
	}
}

-(void)showActionsMenu:(MPUnit *)unit canAttack:(BOOL)canAttack {
    // 1 - Get the window size
    CGSize wins = [[CCDirector sharedDirector] winSize];
    // 2 - Create the menu background
    contextMenuBck = [CCSprite spriteWithFile:@"popup_bg.png"];
    [self addChild:contextMenuBck z:19];
    // 3 - Create the menu option labels
    CCLabelBMFont * stayLbl = [CCLabelBMFont labelWithString:@"Stay" fntFile:@"Font_dark_size15.fnt"];
    CCMenuItemLabel * stayBtn = [CCMenuItemLabel itemWithLabel:stayLbl target:unit selector:@selector(doStay)];
    CCLabelBMFont * attackLbl = [CCLabelBMFont labelWithString:@"Attack" fntFile:@"Font_dark_size15.fnt"];
    CCMenuItemLabel * attackBtn = [CCMenuItemLabel itemWithLabel:attackLbl target:unit selector:@selector(doAttack)];
    CCLabelBMFont * cancelLbl = [CCLabelBMFont labelWithString:@"Cancel" fntFile:@"Font_dark_size15.fnt"];
    CCMenuItemLabel * cancelBtn = [CCMenuItemLabel itemWithLabel:cancelLbl target:unit selector:@selector(doCancel)];
    // 4 - Create the menu
    actionsMenu = [CCMenu menuWithItems:nil];
    // 5 - Add Stay button
    [actionsMenu addChild:stayBtn];
    // 6 - Add the Attack button only if the current unit can attack
    if (canAttack) {
        [actionsMenu addChild:attackBtn];
    }
    // 7 - Add the Cancel button
    [actionsMenu addChild:cancelBtn];
    // 8 - Add the menu to the layer
    [self addChild:actionsMenu z:19];
    // 9 - Position menu
    [actionsMenu alignItemsVerticallyWithPadding:5];
    if (unit.mySprite.position.x > wins.width/2) {
        [contextMenuBck setPosition:ccp(100,wins.height/2)];
        [actionsMenu setPosition:ccp(100,wins.height/2)];
    } else {
        [contextMenuBck setPosition:ccp(wins.width-100,wins.height/2)];
        [actionsMenu setPosition:ccp(wins.width-100,wins.height/2)];
    }
}

-(void)removeActionsMenu {
    // Remove the menu from the layer and clean up
    [contextMenuBck.parent removeChild:contextMenuBck cleanup:YES];
    contextMenuBck = nil;
    [actionsMenu.parent removeChild:actionsMenu cleanup:YES];
    actionsMenu = nil;
}

// Add the user turn menu
-(void)addMenu {
    // Get window size
    CGSize wins = [[CCDirector sharedDirector] winSize];
    // Set up the menu background and position
    CCSprite * hud = [CCSprite spriteWithFile:@"uiBar.png"];
    [self addChild:hud];
    [hud setPosition:ccp(wins.width/2,wins.height-[hud boundingBox].size.height/2)];
    // Set up the label showing the turn 
    turnLabel = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"Player %d's turn",playerTurn] fntFile:@"Font_dark_size15.fnt"];
    [self addChild:turnLabel];
    [turnLabel setPosition:ccp([turnLabel boundingBox].size.width/2 + 5,wins.height-[hud boundingBox].size.height/2)];
    // Set the turn label to display the current turn
    [self setPlayerTurnLabel];
    // Create End Turn button
    endTurnBtn = [CCMenuItemImage itemFromNormalImage:@"uiBar_button.png" selectedImage:@"uiBar_button.png" target:self selector:@selector(doEndTurn)];
    CCMenu * menu = [CCMenu menuWithItems:endTurnBtn, nil];
    [self addChild:menu];
    [menu setPosition:ccp(0,0)];
    [endTurnBtn setPosition:ccp(wins.width - 3 - [endTurnBtn boundingBox].size.width/2, wins.height - [endTurnBtn boundingBox].size.height/2 - 3)];
}

// End the turn, passing control to the other player
-(void)doEndTurn {
    // Do not do anything if a unit is selected
    if (selectedUnit)
        return;
    // Play sound
    [[SimpleAudioEngine sharedEngine] playEffect:@"btn.wav"];
    // Switch players depending on who's currently selected
    if (playerTurn ==1) {
        playerTurn = 2;
    } else if (playerTurn ==2) {
        playerTurn = 1;
    }
    // Do a transition to signify the end of turn
    [self showEndTurnTransition];
    // Set the turn label to display the current turn
    [self setPlayerTurnLabel];
}

// Set the turn label to display the current turn
-(void)setPlayerTurnLabel {
    // Set the label value for the current player
    [turnLabel setString:[NSString stringWithFormat:@"Player %d's turn",playerTurn]];
    // Change the label colour based on the player
    if (playerTurn ==1) {
        [turnLabel setColor:ccRED];
    } else if (playerTurn == 2) {
        [turnLabel setColor:ccBLUE];
    }
}

// Fancy transition to show turn switch/end
-(void)showEndTurnTransition {
    // Create a black layer
    ccColor4B c = {0,0,0,0};
    CCLayerColor *layer = [CCLayerColor layerWithColor:c];
    [self addChild:layer z:20];
    // Add a label showing the player turn to the black layer
    CCLabelBMFont * turnLbl = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"Player %d's turn",playerTurn] fntFile:@"Font_silver_size17.fnt"];
    [layer addChild:turnLbl];
    [turnLbl setPosition:ccp([CCDirector sharedDirector].winSize.width/2,[CCDirector sharedDirector].winSize.height/2)];
    // Run an action which fades in the black layer, calls the beginTurn method, fades out the black layer, and finally removes it
    [layer runAction:[CCSequence actions:[CCFadeTo actionWithDuration:1 opacity:150],[CCCallFunc actionWithTarget:self selector:@selector(beginTurn)],[CCFadeTo actionWithDuration:1 opacity:0],[CCCallFuncN actionWithTarget:self selector:@selector(removeLayer:)], nil]];
}

// Begin the next turn
-(void)beginTurn {
    // Activate the units for the active player
    if (playerTurn ==1) {
        [self activateUnits:p2Units];
    } else if (playerTurn ==2) {
        [self activateUnits:p1Units];
    }
}

// Remove the black layer added for the turn change transition
-(void)removeLayer:(CCNode *)n {
    [n.parent removeChild:n cleanup:YES];
}

// Activate all the units in the specified array (called from beginTurn passing the units for the active player)
-(void)activateUnits:(NSMutableArray *)units {
    for (MPUnit *unit in units) {
        [unit startTurn];
    }
}

// Check the specified tile to see if it can be attacked
-(BOOL)checkAttackTile:(TileData *)tData unitOwner:(int)owner {
    // Is this tile already marked for attack, if so, we don't need to do anything further
    // If not, does the tile contain an enemy unit? If yes, we can attack this tile
    if (!tData.selectedForAttack && [self otherEnemyUnitInTile:tData unitOwner:owner]!= nil) {
        tData.selectedForAttack = YES;
        return NO;
    }
    return YES;
}

// Paint the given tile as one that can be attacked
-(BOOL)paintAttackTile:(TileData *)tData {
    CCSprite * tile = [bgLayer tileAt:tData.position];
    [tile setColor:ccRED];
    return YES;
}

// Remove the attack marking from all tiles
-(void)unPaintAttackTiles {
    for (TileData * td in tileDataArray) {
        [self unPaintAttackTile:td];
    }
}

// Remove the attack marking from a specific tile
-(void)unPaintAttackTile:(TileData *)tileData {
    CCSprite * tile = [bgLayer tileAt:tileData.position];
    [tile setColor:ccWHITE];
}

// Calculate the damage inflicted when one unit attacks another based on the unit type
-(int)calculateDamageFrom:(MPUnit *)attacker onDefender:(MPUnit *)defender {
    if ([attacker isKindOfClass:[MPUnit_Soldier class]]) {
        if ([defender isKindOfClass:[MPUnit_Soldier class]]) {
            return 5;
        } 
    }
    
    /*
     if ([attacker isKindOfClass:[Unit_Soldier class]]) {
     if ([defender isKindOfClass:[Unit_Soldier class]]) {
     return 5;
     } else if ([defender isKindOfClass:[Unit_Helicopter class]]) {
     return 1;
     } else if ([defender isKindOfClass:[Unit_Tank class]]) {
     return 2;
     } else if ([defender isKindOfClass:[Unit_Cannon class]]) {
     return 4;
     }
     } else if ([attacker isKindOfClass:[Unit_Tank class]]) {
     if ([defender isKindOfClass:[Unit_Soldier class]]) {
     return 6;
     } else if ([defender isKindOfClass:[Unit_Helicopter class]]) {
     return 3;
     } else if ([defender isKindOfClass:[Unit_Tank class]]) {
     return 5;
     } else if ([defender isKindOfClass:[Unit_Cannon class]]) {
     return 8;
     }
     } else if ([attacker isKindOfClass:[Unit_Helicopter class]]) {
     if ([defender isKindOfClass:[Unit_Soldier class]]) {
     return 7;
     } else if ([defender isKindOfClass:[Unit_Helicopter class]]) {
     return 4;
     } else if ([defender isKindOfClass:[Unit_Tank class]]) {
     return 7;
     } else if ([defender isKindOfClass:[Unit_Cannon class]]) {
     return 3;
     }
     } else if ([attacker isKindOfClass:[Unit_Cannon class]]) {
     if ([defender isKindOfClass:[Unit_Soldier class]]) {
     return 6;
     } else if ([defender isKindOfClass:[Unit_Helicopter class]]) {
     return 0;
     } else if ([defender isKindOfClass:[Unit_Tank class]]) {
     return 8;
     } else if ([defender isKindOfClass:[Unit_Cannon class]]) {
     return 8;
     }
     }//*/
    
    return 0;
}

// Check if each player has run out of units
-(void)checkForMoreUnits {
    if ([p1Units count]== 0) {
        [self showEndGameMessageWithWinner:2];
    } else if([p2Units count]== 0) {
        [self showEndGameMessageWithWinner:1];
    }
}

// Show winning message for specified player
-(void)showEndGameMessageWithWinner:(int)winningPlayer {
    // Create black layer
    ccColor4B c = {0,0,0,0};
    CCLayerColor * layer = [CCLayerColor layerWithColor:c];
    [self addChild:layer z:20];
    // Add background image to new layer
    CCSprite * bck = [CCSprite spriteWithFile:@"victory_bck.png"];
    [layer addChild:bck];
    [bck setPosition:ccp([CCDirector sharedDirector].winSize.width/2,[CCDirector sharedDirector].winSize.height/2)];
    // Create winning message
    CCLabelBMFont * turnLbl = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"Player %d wins!",winningPlayer]  fntFile:@"Font_dark_size15.fnt"];
    [layer addChild:turnLbl];
    [turnLbl setPosition:ccp([CCDirector sharedDirector].winSize.width/2,[CCDirector sharedDirector].winSize.height/2-30)];
    // Fade in new layer, show it for 2 seconds, call method to remove layer, and finally, restart game
    [layer runAction:[CCSequence actions:[CCFadeTo actionWithDuration:1 opacity:150],[CCDelayTime actionWithDuration:2],[CCCallFuncN actionWithTarget:self selector:@selector(removeLayer:)],[CCCallFunc actionWithTarget:self selector:@selector(restartGame)], nil]];
}

// Restart game
-(void)restartGame {
    [[CCDirector sharedDirector] replaceScene:[CCTransitionJumpZoom transitionWithDuration:1 scene:[MPTurnLayer scene]]];
}

// Load buildings for layer
-(void)loadBuildings:(int)player {
    // Get building object group from tilemap
    CCTMXObjectGroup *buildingsObjectGroup = [tileMap objectGroupNamed:[NSString stringWithFormat:@"Buildings_P%d",player]];
    // Get the correct building array based on the current player
    NSMutableArray *buildings = nil;
    if (player == 1)
        buildings = p1Buildings;
    if (player == 2)
        buildings = p2Buildings;
    // Iterate over the buildings in the array, adding them to the game
    for (NSMutableDictionary *buildingDict in [buildingsObjectGroup objects]) {
        // Get the building type
        NSMutableDictionary *d = [NSMutableDictionary dictionaryWithDictionary:buildingDict];
        NSString *buildingType = [d objectForKey:@"Type"];
        // Get the right building class based on type
        NSString *classNameStr = [NSString stringWithFormat:@"Building_%@",buildingType];
        Class theClass = NSClassFromString(classNameStr);
        // Create the building
        Building *building = [theClass nodeWithTheGame:self tileDict:d owner:player];
        [buildings addObject:building];
    }
}

// Return the first matching building (if any) on the given tile
-(Building *)buildingInTile:(TileData *)tile {
    // Check player 1's buildings
    for (Building *u in p1Buildings) {
        if (CGPointEqualToPoint([self tileCoordForPosition:u.mySprite.position], tile.position))
            return u;
    }
    // Check player 2's buildings
    for (Building *u in p2Buildings) {
        if (CGPointEqualToPoint([self tileCoordForPosition:u.mySprite.position], tile.position))
            return u;
    }
    return nil;
}

#pragma mark - GCTurnBasedMatchHelperDelegate

-(void)enterNewGame:(GKTurnBasedMatch *)match {
    NSLog(@"Entering new game...");
    
    
    //mainTextController.text = @"Once upon a time";
}

-(void)takeTurn:(GKTurnBasedMatch *)match {
    NSLog(@"Taking turn for existing game...");
    int playerNum = [match.participants 
                     indexOfObject:match.currentParticipant] + 1;
    NSString *statusString = [NSString stringWithFormat:
                              @"Player %d's Turn (that's you)", playerNum];
    //statusLabel.text = statusString;
    //textInputField.enabled = YES;
    if ([match.matchData bytes]) {
        NSString *storySoFar = [NSString stringWithUTF8String:
                                [match.matchData bytes]];
        //mainTextController.text = storySoFar;
    }
    
    [self checkForEnding:match.matchData];
}

-(void)layoutMatch:(GKTurnBasedMatch *)match {
    NSLog(@"Viewing match where it's not our turn...");
    NSString *statusString;
    
    if (match.status == GKTurnBasedMatchStatusEnded) {
        statusString = @"Match Ended";
    } else {
        int playerNum = [match.participants 
                         indexOfObject:match.currentParticipant] + 1;
        statusString = [NSString stringWithFormat:
                        @"Player %d's Turn", playerNum];
    }
    //statusLabel.text = statusString;
    //textInputField.enabled = NO;
    NSString *storySoFar = [NSString stringWithUTF8String:
                            [match.matchData bytes]];
    //mainTextController.text = storySoFar;
    [self checkForEnding:match.matchData];
}

-(void)checkForEnding:(NSData *)matchData {
    if ([matchData length] > 3000) {
        /*statusLabel.text = [NSString stringWithFormat:
                            @"%@, only about %d letter left", statusLabel.text, 
                            4000 - [matchData length]];*/
    }
}

-(void)recieveEndGame:(GKTurnBasedMatch *)match {
    [self layoutMatch:match];
}

@end

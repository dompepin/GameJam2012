//
//  MenuScene.m
//  Snake
//
//  Created by Clawoo on 4/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MenuScene.h"
#import "GameConfig.h"
#import "BoardLayer.h"


@implementation MenuScene

+(id) scene {
	CCScene *scene = [CCScene node];
	MenuScene *layer = [MenuScene node];
	[scene addChild:layer];
	return scene;
}

- (id)init {
    if ((self = [super init])) {
        CCLayerColor *backgroundLayer = [CCLayerColor layerWithColor:kGameBackgroundColor];
        [self addChild:backgroundLayer];
        
        CCMenuItem *playButton = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithFile:@"play.png" rect:CGRectMake(0, 0, 127, 140)]
                                                         selectedSprite:[CCSprite spriteWithFile:@"play.png" rect:CGRectMake(0, 0, 127, 140)]
                                                                 target:self 
                                                               selector:@selector(playBtnTapped:)];
        
        CCMenu *menu = [CCMenu menuWithItems:playButton, nil];
        [menu alignItemsVertically];
        [self addChild:menu];
    }
    return self;
}

- (void)playBtnTapped:(CCMenuItem *)sender {
	[[CCDirector sharedDirector] replaceScene:[CCTransitionTurnOffTiles transitionWithDuration:.5 
																					 scene:[BoardLayer scene]]];
}

- (void)highscoresBtnTapped:(CCMenuItem *)sender {
    
}

- (void)aboutBtnTapped:(CCMenuItem *)sender {
    
}

@end

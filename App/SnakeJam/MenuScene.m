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
        CCSprite* background = [CCSprite spriteWithFile:@"Background_level2_1024x768.png" rect:CGRectMake(0, 0, 1024, 768)];
        background.position = ccp(1024/2,768/2);
        [self addChild:background z:-1];
        background = [CCSprite spriteWithFile:@"menu-final.png" rect:CGRectMake(0, 0, 1024, 768)];
        background.position = ccp(1024/2,768/2);
        [self addChild:background z:0];
        
        CCMenuItem *playButton = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithFile:@"Menu_button.png" rect:CGRectMake(20, 0, 376, 200)]
                                                         selectedSprite:[CCSprite spriteWithFile:@"Menu_button.png" rect:CGRectMake(0, 0, 376, 200)]
                                                                 target:self 
                                                               selector:@selector(playBtnTapped:)];

        playButton.position = CGPointMake(200, 200);//CGPointMake(playButton.position.x - 200, playButton.position.y);
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

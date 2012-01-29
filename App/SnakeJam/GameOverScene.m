//
//  GameOverScene.m
//  Cocos2DSimpleApp
//
//  Created by Dominic Pepin on 12-01-22.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GameOverScene.h"
#import "BoardLayer.h"
#import "MenuScene.h"
#import "SimpleAudioEngine.h"

@implementation GameOverScene
@synthesize layer = _layer;

- (id)init {
    
    if ((self = [super init])) {
        self.layer = [GameOverLayer node];
        [self addChild:_layer];
    }
    return self;
}

- (void)dealloc {
    [_layer release];
    _layer = nil;
    [super dealloc];
}

@end

@implementation GameOverLayer
@synthesize label = _label;

-(id) init
{
    if( (self=[super initWithColor:ccc4(255,0,0,0)] )) {
        CGSize winSize = [[CCDirector sharedDirector] winSize];

        CCSprite* background = [CCSprite spriteWithFile:@"Background_level1_1024x768.png" rect:CGRectMake(0, 0, 1024, 768)];
        background.position = ccp(1024/2,768/2);
        [self addChild:background z:-1];

        background = [CCSprite spriteWithFile:@"gameOverMenu.png" rect:CGRectMake(0, 0, 1024, 768)];
        background.position = ccp(1024/2,768/2);
        [self addChild:background z:0];

        [self runAction:[CCSequence actions:
                         [CCDelayTime actionWithDuration:3],
                         [CCCallFunc actionWithTarget:self selector:@selector(gameOverDone)],
                         nil]];

        [[SimpleAudioEngine sharedEngine] playEffect:@"Death.mp3"];
        
    }	
    return self;
}

- (void)gameOverDone {
    
    [[CCDirector sharedDirector] replaceScene:[MenuScene scene]];
}

- (void)dealloc {
    [_label release];
    _label = nil;
    [super dealloc];
}

@end
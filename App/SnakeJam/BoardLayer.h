//
//  BoardLayer.h
//  SnakeJam
//
//  Created by Dominic Pepin on 12-01-27.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"

// HelloWorldLayer
@interface BoardLayer : CCLayerColor
{
@private
    CCSprite *_snakeHead;
    NSMutableArray *_snakeBody;
    NSMutableArray *_touchArray;
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

@end

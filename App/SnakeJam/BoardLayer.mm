//
//  HelloWorldLayer.m
//  Cocos2DSimpleApp
//
//  Created by Dominic Pepin on 12-01-21.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//


// Import the interfaces
#import "BoardLayer.h"
#import "CCActionInterval.h"
#import "SimpleAudioEngine.h"
#import "GameOverScene.h"
#import "CCActionInterval.h"

// HelloWorldLayer implementation
@interface BoardLayer ()

@property(retain, nonatomic) NSMutableArray* snakeBody;
@property(retain, nonatomic) CCSprite *snakeHead;

- (void)addSnakeBody;

- (void)addSnakeHead:(CGSize)windowsSize;

- (float)findDistanceBetween:(CGPoint)point1 andPoint:(CGPoint)point2;


@end

@implementation BoardLayer

float _snakeSpeed;
CGPoint _previousSnakeHeadPosition;
CGPoint _snakeHeading;
const short pixelBetweenNodes = 2;


@synthesize snakeHead = _snakeHead;
@synthesize snakeBody = _snakeBody;

+ (CCScene *)scene {
    _snakeSpeed = 200 / 1; //X pixel/seconds

    // 'scene' is an autorelease object.
    CCScene *scene = [CCScene node];

    // 'layer' is an autorelease object.
    BoardLayer *layer = [BoardLayer node];

    // add layer as a child to scene
    [scene addChild:layer];

    // return the scene
    return scene;
}


- (void)addTarget {

//    CCSprite *target = [CCSprite spriteWithFile:@"Target.png"
//                                           rect:CGRectMake(0, 0, 27, 40)];
//
//    target.tag = 1;
//    [_snakeBody addObject:target];
//
//    // Determine where to spawn the target along the Y axis
//    CGSize winSize = [[CCDirector sharedDirector] winSize];
//    int minY = target.contentSize.height/2;
//    int maxY = winSize.height - target.contentSize.height/2;
//    int rangeY = maxY - minY;
//    int actualY = (arc4random() % rangeY) + minY;
//
//    // Create the target slightly off-screen along the right edge,
//    // and along a random position along the Y axis as calculated above
//    target.position = ccp(winSize.width + (target.contentSize.width/2), actualY);
//    [self addChild:target];
//
//    // Determine speed of the target
//    int minDuration = 2.0;
//    int maxDuration = 4.0;
//    int rangeDuration = maxDuration - minDuration;
//    int actualDuration = (arc4random() % rangeDuration) + minDuration;
//
//    // Create the actions
//    id actionMove = [CCMoveTo actionWithDuration:actualDuration
//                                        position:ccp(-target.contentSize.width/2, actualY)];
//    id actionMoveDone = [CCCallFuncN actionWithTarget:self
//                                             selector:@selector(spriteMoveFinished:)];
//    [target runAction:[CCSequence actions:actionMove, actionMoveDone, nil]];
//
}

- (void)gameLogic:(ccTime)dt {
    [self addTarget];
}

// on "init" you need to initialize your instance
- (id)init {
    if ((self = [super initWithColor:ccc4(145, 255, 255, 255)])) {
        CGSize winSize = [[CCDirector sharedDirector] winSize];

        [self addSnakeHead:winSize];

        self.snakeBody = [[NSMutableArray alloc] init];
        [self addSnakeBody];
        [self addSnakeBody];
        [self addSnakeBody];
        [self addSnakeBody];

        [self schedule:@selector(gameLogic:) interval:1.0];
        [self schedule:@selector(update:)];

        self.isTouchEnabled = YES;

        // TODO: Play background music
        //[[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"background-music-aac.caf"];
    }
    return self;
}

// on "dealloc" you need to release all your retained objects
- (void)dealloc {
    // in case you have something to dealloc, do it in this method
    // in this particular example nothing needs to be released.
    // cocos2d will automatically release all the children (Label)

    [_snakeHead release], _snakeHead = nil;
    [_snakeBody release], _snakeBody = nil;

    [super dealloc];
}

#pragma mark - CCStandardTouchDelegate Members

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {

// Choose one of the touches to work with
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInView:[touch view]];
    touchLocation = [[CCDirector sharedDirector] convertToGL:touchLocation];


    _snakeHeading = touchLocation;
    float distance = [self findDistanceBetween:_snakeHead.position andPoint:touchLocation];
    float duration = distance / _snakeSpeed;
//    [_snakeHead runAction:[CCSequence actions:[CCMoveTo actionWithDuration:duration position:touchLocation],
//                  [CCCallFuncN actionWithTarget:self selector:@selector(snakeHeadMoveFinished:)],
//                  nil]];

    // rotate the sprite
    CGPoint vector = ccpSub(touchLocation, _snakeHead.position);
    CGFloat rotateAngle = -ccpToAngle(vector);
    float angle = CC_RADIANS_TO_DEGREES(rotateAngle);
    _snakeHead.rotation = angle;



//    // What is the initial touchLocation of the snake?
//    CGSize winSize = [[CCDirector sharedDirector] winSize];
//
//    // Determine offset of touchLocation to projectile
//    int offX = touchLocation.x - _snakeHead.position.x;
//    int offY = touchLocation.y - _snakeHead.position.y;
//
//    // Bail out if we are shooting down or backwards
//
//    // Determine where we wish to shoot the projectile to
//    int realX = winSize.width + (_snakeHead.contentSize.width / 2);
//    float ratio = (float) offY / (float) offX;
//    int realY = (realX * ratio) + _snakeHead.position.y;
//    CGPoint realDest = ccp(realX, realY);
//
//    // Determine the length of how far we're shooting
//    int offRealX = realX - _snakeHead.position.x;
//    int offRealY = realY - _snakeHead.position.y;
//    float length = sqrtf((offRealX * offRealX) + (offRealY * offRealY));
//    float realMoveDuration = 50;//length / _speed;
//
//    // Move projectile to actual endpoint
//    [_snakeHead runAction:[CCSequence actions:[CCMoveTo actionWithDuration:realMoveDuration position:realDest],
//              [CCCallFuncN actionWithTarget:self selector:@selector(spriteMoveFinished:)],
//              nil]];

    // Make some sound
    //[[SimpleAudioEngine sharedEngine] playEffect:@"pew-pew-lei.caf"];

}


#pragma mark - Private Methods


- (void)addSnakeBody {
    CCSprite *snakeNode = [CCSprite spriteWithFile:@"SnakeBody_16x16.png" rect:CGRectMake(0, 0, 16, 16)];
    if ([_snakeBody count] == 0)        {
        snakeNode.position = CGPointMake(_snakeHead.position.x - pixelBetweenNodes, _snakeHead.position.y);
    }
    else{
        CCSprite *bodyNode = [_snakeBody objectAtIndex:([_snakeBody count]-1)];
        snakeNode.position = CGPointMake(bodyNode.position.x - pixelBetweenNodes, bodyNode.position.y);
    }
    [self.snakeBody addObject:snakeNode];
    [self addChild:snakeNode];
}

- (void)addSnakeHead:(CGSize)windowsSize {
    self.snakeHead = [CCSprite spriteWithFile:@"SnakeHead_27x40.png" rect:CGRectMake(0, 0, 27, 40)];
    _snakeHead.position = ccp(_snakeHead.contentSize.width / 2, windowsSize.height / 2);
    _previousSnakeHeadPosition = _snakeHead.position;
    [self addChild:_snakeHead];
}

- (float)findDistanceBetween:(CGPoint)point1 andPoint:(CGPoint)point2 {
     return sqrt(powf(point1.x - point2.x, 2.f) + powf(point1.y - point2.y, 2.f));
 }

// Occurs when the snake body finished moving
- (void)snakeBodyMoveFinished:(id)sender {

}

// Occurs when the snake head finished moving
- (void)snakeHeadMoveFinished:(id)sender {

}


- (void)update:(ccTime)time {

    if (_snakeHead.position.x == _snakeHeading.x &&
            _snakeHead.position.y == _snakeHeading.y)
        return;

    CGPoint prevPoint = _snakeHead.position;

    float distance = [self findDistanceBetween:_snakeHead.position andPoint:_snakeHeading];
    float duration = distance / _snakeSpeed;
    [_snakeHead runAction:[CCSequence actions:[CCMoveTo actionWithDuration:duration position:_snakeHeading],
    [CCCallFuncN actionWithTarget:self selector:@selector(snakeHeadMoveFinished:)],
    nil]];

    for (int i = 0; i < [_snakeBody count]; i++) {

        CCSprite *bodyNode = ((CCSprite *)[_snakeBody objectAtIndex:i]);
        [bodyNode runAction:[CCSequence actions:[CCMoveTo actionWithDuration:duration position:prevPoint],
                                  [CCCallFuncN actionWithTarget:self selector:@selector(snakeBodyMoveFinished:)],
                                   nil]];
        prevPoint = bodyNode.position;
    }
    
//    if (_previousSnakeHeadPosition.x == _snakeHead.position.x &&
//            _previousSnakeHeadPosition.y == _snakeHead.position.y)
//        return;
//
//    
//    _previousSnakeHeadPosition = _snakeHead.position;
//    CGPoint previousPosition;
//    for (int i = 0; i < [_snakeBody count]; i++) {
//        if (i == 0)
//        {
//            previousPosition = ((CCSprite *)[_snakeBody objectAtIndex:i]).position;
//            ((CCSprite *)[_snakeBody objectAtIndex:i]).position = _snakeHead.position;
//            continue;
//        }
//
//        CGPoint tmpPoint =  ((CCSprite *)[_snakeBody objectAtIndex:i]).position;
//        ((CCSprite *)[_snakeBody objectAtIndex:i]).position = previousPosition;
//        previousPosition =  tmpPoint;
//    }
}

@end

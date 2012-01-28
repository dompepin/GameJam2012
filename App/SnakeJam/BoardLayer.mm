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
@property(retain, nonatomic) NSMutableArray* touchArray;

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
@synthesize touchArray = _touchArray;

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


- (void)addPlanet {

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
    [self addPlanet];
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

        self.touchArray =[[NSMutableArray alloc ] init];

        [self schedule:@selector(gameLogic:) interval:1.0];
        [self schedule:@selector(update:)];

        self.isTouchEnabled = YES;

        // TODO: Play background music
        //[[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"background-music-aac.caf"];
    }
    return self;
}

-(void) ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event  {
    UITouch *touch = [ touches anyObject];
    CGPoint new_location = [touch locationInView: [touch view]];
    new_location = [[CCDirector sharedDirector] convertToGL:new_location];

    CGPoint oldTouchLocation = [touch previousLocationInView:touch.view];
    oldTouchLocation = [[CCDirector sharedDirector] convertToGL:oldTouchLocation];
    oldTouchLocation = [self convertToNodeSpace:oldTouchLocation];

    [self.touchArray addObject:NSStringFromCGPoint(new_location)];
    [self.touchArray addObject:NSStringFromCGPoint(oldTouchLocation)];
}

-(void)draw
{
    [super draw];
    glEnable(GL_LINE_SMOOTH);

    for(int i = 0; i < [_touchArray count]; i+=2)
    {
        CGPoint start = CGPointFromString([_touchArray objectAtIndex:i]);
        CGPoint end = CGPointFromString([_touchArray objectAtIndex:i+1]);

        ccDrawLine(start, end);
    }
}

// on "dealloc" you need to release all your retained objects
- (void)dealloc {
    // in case you have something to dealloc, do it in this method
    // in this particular example nothing needs to be released.
    // cocos2d will automatically release all the children (Label)

    [_snakeHead release], _snakeHead = nil;
    [_snakeBody release], _snakeBody = nil;
    [_touchArray release], _touchArray= nil;
    [super dealloc];
}

#pragma mark - CCStandardTouchDelegate Members

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    BoardLayer *line = [BoardLayer node];
    [self addChild: line];
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
// Choose one of the touches to work with
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInView:[touch view]];
    touchLocation = [[CCDirector sharedDirector] convertToGL:touchLocation];


    _snakeHeading = touchLocation;
//    float distance = [self findDistanceBetween:_snakeHead.position andPoint:touchLocation];
//    float duration = distance / _snakeSpeed;
//    [_snakeHead runAction:[CCSequence actions:[CCMoveTo actionWithDuration:duration position:touchLocation],
//                  [CCCallFuncN actionWithTarget:self selector:@selector(snakeHeadMoveFinished:)],
//                  nil]];

    // rotate the sprite
    CGPoint vector = ccpSub(touchLocation, _snakeHead.position);
    CGFloat rotateAngle = -ccpToAngle(vector);
    float angle = CC_RADIANS_TO_DEGREES(rotateAngle);
    _snakeHead.rotation = angle;

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
}

@end

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

@property(retain, nonatomic) NSMutableArray* deleteArray;
@property(retain, nonatomic) NSMutableArray* snakeBody;
@property(retain, nonatomic) CCSprite *snakeHead;
@property(retain, nonatomic) NSMutableArray* touchArray;
@property(retain, nonatomic) NSMutableArray* testArray;
@property(retain, nonatomic) NSMutableArray* planetArray;

- (void)gameLogic:(ccTime)dt;

- (void)addBackground;

- (void)addPlanet:(CCSprite *)planet;

- (void)addSnakeBody;

- (void)createSnakeHead:(CGSize)windowsSize;

- (float)findDistanceBetween:(CGPoint)point1 andPoint:(CGPoint)point2;

- (CCSprite *)getPlanet:(int)planetID;

- (void)planetMoveFinished:(id)sender;

@end

@implementation BoardLayer

float _snakeSpeed;
CGPoint _previousSnakeHeadPosition;
CGPoint _snakeHeading;
NSUInteger _nextHeadingIndex;
int _planetNum;

const short kPixelBetweenHeadAndBody = 129 / 2;
const short kPixelBetweenSnakeNodes = 61 / 2;

const short kTagForPlanetSprite = 1;

@synthesize snakeHead = _snakeHead;
@synthesize snakeBody = _snakeBody;
@synthesize touchArray = _touchArray;
@synthesize deleteArray = _deleteArray;
@synthesize planetArray = _planetArray;
@synthesize testArray = _testArray;


// on "dealloc" you need to release all your retained objects
- (void)dealloc {
    // in case you have something to dealloc, do it in this method
    // in this particular example nothing needs to be released.
    // cocos2d will automatically release all the children (Label)

    [_snakeHead release], _snakeHead = nil;
    [_snakeBody release], _snakeBody = nil;
    [_touchArray release], _touchArray= nil;
    [_deleteArray release], _deleteArray=nil;
    [_planetArray release];
    [_testArray release];
    [super dealloc];
}

// on "init" you need to initialize your instance
- (id)init {
    if (self = [super init]) { // initWithColor:ccc4(145, 255, 255, 255)])) {
        CGSize winSize = [[CCDirector sharedDirector] winSize];

        [self addBackground];

        [self createSnakeHead:winSize];
        
//        self.snakeBody = [[NSMutableArray alloc] init];
//        [self addSnakeBody];
//        [self addSnakeBody];
//        [self addSnakeBody];
//        [self addSnakeBody];

        // adding the snake head after the body so that it renders on top
        [self addChild:_snakeHead];
        [self reorderChild:_snakeHead z:2];

        self.touchArray =[[NSMutableArray alloc ] init];
        [_touchArray addObject:NSStringFromCGPoint(_snakeHead.position)];
        [_touchArray addObject:NSStringFromCGPoint(CGPointMake(winSize.width, winSize.height/2))];
        self.deleteArray =[[NSMutableArray alloc ] init];

        self.planetArray = [[NSMutableArray alloc ] init];

        [self schedule:@selector(gameLogic:) interval:10];
        [self schedule:@selector(update:)];

        self.isTouchEnabled = YES;
        _nextHeadingIndex = 0;
        _planetNum = 0;

        // TODO: Play background music
        //[[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"background-music-aac.caf"];
    }
    return self;
}

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

#pragma mark - CCNode Overrides

-(void)draw
{
    [super draw];
    glEnable(GL_LINE_SMOOTH);
    glColor4ub(0, 0, 0, 255);

    //TODO: _nextHeadingIndex
    for(int i = 0; i < [_touchArray count] -1; i++)
    {
        CGPoint start = CGPointFromString([_touchArray objectAtIndex:i]);
        CGPoint end = CGPointFromString([_touchArray objectAtIndex:i+1]);

        ccDrawLine(start, end);
    }
        
    for (CCSprite *planet in _planetArray) {        
        if (!planet.visible) continue;
       
        if (CGRectIntersectsRect(_snakeHead.boundingBox, planet.boundingBox)) {  
            [_snakeHead runAction:[CCSequence actions:
                                   [CCBlink actionWithDuration:1.0 blinks:20],
                                   [CCCallFuncN actionWithTarget:self selector:@selector(snakeHeadBlinkFinished:)],
                                   nil]];  
            planet.visible = NO;
            //[self addSnakeBody];             
        }
        
        // set this to yes for debug purposes
        BOOL drawBoundingBoxes=NO;
        if (drawBoundingBoxes) {
            CGRect rect = _snakeHead.boundingBox;
            CGPoint vertices[4]={
                ccp(rect.origin.x,rect.origin.y),
                ccp(rect.origin.x+rect.size.width,rect.origin.y),
                ccp(rect.origin.x+rect.size.width,rect.origin.y+rect.size.height),
                ccp(rect.origin.x,rect.origin.y+rect.size.height),
            };
            ccDrawPoly(vertices, 4, YES);
            rect = planet.boundingBox;
            CGPoint vertices1[4]={
                ccp(rect.origin.x,rect.origin.y),
                ccp(rect.origin.x+rect.size.width,rect.origin.y),
                ccp(rect.origin.x+rect.size.width,rect.origin.y+rect.size.height),
                ccp(rect.origin.x,rect.origin.y+rect.size.height),
            };
            ccDrawPoly(vertices1, 4, YES);
        }
    }
}

#pragma mark - CCStandardTouchDelegate Members

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

    [_touchArray removeAllObjects];
    _nextHeadingIndex = 0;


// Choose one of the touches to work with
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInView:[touch view]];
    touchLocation = [[CCDirector sharedDirector] convertToGL:touchLocation];


    _snakeHeading = touchLocation;
    self.touchArray = [[NSMutableArray alloc] initWithCapacity:2];
    [_touchArray addObject:NSStringFromCGPoint(_snakeHead.position)];
    [_touchArray addObject:NSStringFromCGPoint(touchLocation)];

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

//
-(void) ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event  {
    UITouch *touch = [ touches anyObject];
    CGPoint new_location = [touch locationInView: [touch view]];
    new_location = [[CCDirector sharedDirector] convertToGL:new_location];

    CGPoint oldTouchLocation = [touch previousLocationInView:touch.view];
    oldTouchLocation = [[CCDirector sharedDirector] convertToGL:oldTouchLocation];
    oldTouchLocation = [self convertToNodeSpace:oldTouchLocation];

    [self.touchArray addObject:NSStringFromCGPoint(new_location)];
    //[self.touchArray addObject:NSStringFromCGPoint(oldTouchLocation)];
}

//
- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {

}

//
#pragma mark - update methods

- (void)gameLogic:(ccTime)dt {
    CCSprite *target = [self getPlanet:(_planetNum%3)];
    [self addPlanet:target];
    _planetNum++;
}

#pragma mark - Private Methods
//
- (void)addBackground {
    CCSprite* background = [CCSprite spriteWithFile:@"Star_bg1_1024x768.png" rect:CGRectMake(0, 0, 1024, 768)];
    background.position = ccp(1024/2,768/2);
    [self addChild:background z:-1];
}

//
- (void)addPlanet:(CCSprite *)planet; {

    planet.tag = kTagForPlanetSprite;
    [_planetArray addObject:planet];

    // Determine where to spawn the target along the Y axis
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    int minY = planet.contentSize.height/2;
    int maxY = winSize.height - planet.contentSize.height/2;
    int rangeY = maxY - minY;
    int actualY = (arc4random() % rangeY) + minY;

    // Create the target slightly off-screen along the right edge,
    // and along a random position along the Y axis as calculated above
    planet.position = ccp(winSize.width + (planet.contentSize.width/2), actualY);
    [self addChild:planet];
    [self reorderChild:planet z:0];

    // Determine speed of the target
    int minDuration = 10.0;
    int maxDuration = 30.0;
    int rangeDuration = maxDuration - minDuration;
    int actualDuration = (arc4random() % rangeDuration) + minDuration;

    // Create the actions
    id actionMove = [CCMoveTo actionWithDuration:actualDuration
                                        position:ccp(-planet.contentSize.width/2, actualY)];
    id actionMoveDone = [CCCallFuncN actionWithTarget:self
                                             selector:@selector(planetMoveFinished:)];

    actualDuration = (arc4random() % rangeDuration) + minDuration;
    id rotate = [CCRotateBy actionWithDuration:actualDuration angle:720];
    id actions = [CCSpawn actions:actionMove, rotate, nil];
    id sequence = [CCSequence actions:actions, actionMoveDone, nil];
    
    [planet runAction:sequence];
}

//
- (void)addSnakeBody {
    CCSprite *snakeNode = [CCSprite spriteWithFile:@"Body blocks_61x53.png" rect:CGRectMake(0, 0, 61, 53)];
    if ([_snakeBody count] == 0)        {
        snakeNode.position = CGPointMake(_snakeHead.position.x + kPixelBetweenSnakeNodes, _snakeHead.position.y + 100);
    }
    else{
        CCSprite *bodyNode = [_snakeBody objectAtIndex:([_snakeBody count]-1)];
        snakeNode.position = CGPointMake(bodyNode.position.x - kPixelBetweenSnakeNodes, bodyNode.position.y);
    }
    [self.snakeBody addObject:snakeNode];
    [self addChild:snakeNode];
    [self reorderChild:snakeNode z:1];
}

//
- (void)createSnakeHead:(CGSize)windowsSize  {
    self.snakeHead = [CCSprite spriteWithFile:@"Head2_129x82.png" rect:CGRectMake(0, 0, 129, 82)];
    _snakeHead.position = ccp(_snakeHead.contentSize.width / 2, windowsSize.height / 2);
    _previousSnakeHeadPosition = _snakeHead.position;
}

- (float)findDistanceBetween:(CGPoint)point1 andPoint:(CGPoint)point2 {
     return sqrt(powf(point1.x - point2.x, 2.f) + powf(point1.y - point2.y, 2.f));
 }

//
- (CCSprite*)getPlanet:(int)planetID {
    switch (planetID) {
        case 0:
            return [CCSprite spriteWithFile:@"GasPlanet_82x84.png" rect:CGRectMake(0, 0, 82, 84)];
            break;
        case 1:
            return [CCSprite spriteWithFile:@"WaterPlanet_81x81.png" rect:CGRectMake(0, 0, 81, 81)];
            break;
        case 2:
            return [CCSprite spriteWithFile:@"RockyPlanet_84x85.png" rect:CGRectMake(0, 0, 84, 85)];
            break;
        default:
            return [CCSprite spriteWithFile:@"GasPlanet_82x84.png" rect:CGRectMake(0, 0, 82, 84)];
            break;
    }
}


// Occurs when the snake body finished moving
- (void)planetMoveFinished:(id)sender {
    CCSprite *sprite = (CCSprite *)sender;
    [self removeChild:sprite cleanup:YES];
     [_planetArray removeObject:sprite];
}

// Occurs when the snake body finished moving
- (void)snakeBodyMoveFinished:(id)sender {

}

// Occurs when the snake head finished moving
- (void)snakeHeadMoveFinished:(id)sender {


}

-(void)snakeHeadBlinkFinished:(id)sender {
    _snakeHead.visible = true;
}


- (void)repositionHeadAlongTouchPath:(ccTime)time {
   ccTime timeLeft = time;

    NSArray *path = [[NSArray alloc] initWithArray:_touchArray];
    float distanceToTravel = time * _snakeSpeed;
    if ([path count] == 0)
        return;
    
    CGPoint prevPoint = CGPointMake(CGPointFromString([path objectAtIndex:0]).x, CGPointFromString([path objectAtIndex:0]).y);
    int i = 1;
    for (i = 1; i < [path count]; i++) {
        
        CGPoint tmpPoint = CGPointMake(CGPointFromString([path objectAtIndex:i]).x, CGPointFromString([path objectAtIndex:i]).y);
        float distanceTraveled = [self findDistanceBetween:prevPoint andPoint:tmpPoint];
        if (distanceToTravel > distanceTraveled)
        {
            timeLeft -= timeLeft * distanceTraveled/distanceToTravel;
            distanceToTravel -= distanceTraveled;
            prevPoint = tmpPoint;

            // rotate the head
            CGPoint vector = ccpSub(tmpPoint, prevPoint);
            CGFloat rotateAngle = -ccpToAngle(vector);
            float angle = CC_RADIANS_TO_DEGREES(rotateAngle);
            _snakeHead.rotation = angle;

            continue;
        }
        else
        {
            CGPoint offset = ccpSub(tmpPoint, prevPoint);
            CGPoint targetVector = ccpNormalize(offset);
            CGPoint targetPerSecond = ccpMult(targetVector, _snakeSpeed);

            CGPoint actualTarget = ccpAdd(prevPoint, ccpMult(targetPerSecond, timeLeft));

            _snakeHead.position = actualTarget;

            // rotate the head
            CGFloat rotateAngle = -ccpToAngle(offset);
            float angle = CC_RADIANS_TO_DEGREES(rotateAngle);
            _snakeHead.rotation = angle;
            break;
        }
    }

    //_nextHeadingIndex = i;
    NSMutableArray *newArray = [[NSMutableArray alloc] init];
    [newArray addObject:NSStringFromCGPoint(_snakeHead.position)];
    for (int j = i; j < [path count]; j++) {

        [newArray addObject:[path objectAtIndex:j]];
    }
    
    self.touchArray = newArray;
    
}

- (void)update:(ccTime)time {

    if (_snakeHead.position.x == _snakeHeading.x &&
            _snakeHead.position.y == _snakeHeading.y)
        return;

    [self repositionHeadAlongTouchPath:(ccTime)time];

}

//- (void)update:(ccTime)time {
//
//    if (_snakeHead.position.x == _snakeHeading.x &&
//            _snakeHead.position.y == _snakeHeading.y) {
//
//        // if head arrives at the start of the path, follow path
//        if (_nextHeadingIndex < [_touchArray count]) {
//            _nextHeadingIndex += 2;
//            if (_nextHeadingIndex >= [_touchArray count]) {
//                [_touchArray removeAllObjects];
//                return;
//            }
//
//            _snakeHeading = CGPointMake(CGPointFromString([_touchArray objectAtIndex:_nextHeadingIndex]).x, CGPointFromString([_touchArray objectAtIndex:_nextHeadingIndex]).y);
//            CGPoint vector = ccpSub(_snakeHeading, _snakeHead.position);
//            CGFloat rotateAngle = -ccpToAngle(vector);
//            float angle = CC_RADIANS_TO_DEGREES(rotateAngle);
//            _snakeHead.rotation = angle;
//        }
//        else
//        {
//            return;
//        }
//    }
//
//    CGPoint nextBodyPartCurrentPoint = _snakeHead.position;
//
//    float distance = [self findDistanceBetween:_snakeHead.position andPoint:_snakeHeading];
//    float duration = distance / _snakeSpeed;
//    [_snakeHead runAction:[CCSequence actions:[CCMoveTo actionWithDuration:duration position:_snakeHeading],
//    [CCCallFuncN actionWithTarget:self selector:@selector(snakeHeadMoveFinished:)],
//    nil]];
//
//    for (int i = 0; i < [_snakeBody count]; i++) {
//
//
//        CCSprite *bodyNode = ((CCSprite *)[_snakeBody objectAtIndex:i]);
//        CGPoint tmpPoint = bodyNode.position;
//        CGPoint vector = ccpSub(bodyNode.position, nextBodyPartCurrentPoint);
//        CGFloat rotateAngle = -ccpToAngle(vector);
//        float angle = CC_RADIANS_TO_DEGREES(rotateAngle);
//        bodyNode.rotation = angle;
//
//        [bodyNode runAction:[CCSequence actions:[CCMoveTo actionWithDuration:duration position:nextBodyPartCurrentPoint],
//                                  [CCCallFuncN actionWithTarget:self selector:@selector(snakeBodyMoveFinished:)],
//                                   nil]];
//
//        nextBodyPartCurrentPoint = tmpPoint;
//    }
//}

@end

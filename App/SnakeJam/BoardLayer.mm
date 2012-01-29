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

@property(retain, nonatomic) NSMutableArray *snakeBody;
@property(retain, nonatomic) CCSprite *snakeHead;
@property(retain, nonatomic) NSMutableArray *touchArray;
@property(retain, nonatomic) NSMutableArray *newBodyToInsert;
@property(retain, nonatomic) NSMutableArray *planetArray;
@property(nonatomic, retain) CCLabelTTF *planetLeftLabel;
@property(nonatomic, retain) CCLabelTTF *levelLabel;
@property(nonatomic, retain) CCLabelTTF *livesLabel;

- (void)gameLogic:(ccTime)dt;

- (void)addBackground;

- (void)addYPlanet:(CCSprite *)planet;


- (void)addXPlanet:(CCSprite *)planet;

- (void)addSnakeBody;

- (void)createSnakeHead:(CGSize)windowsSize;

- (float)findDistanceBetween:(CGPoint)point1 andPoint:(CGPoint)point2;

- (CCSprite *)getPlanet:(int)planetID;

- (void)planetMoveFinished:(id)sender;

- (CGPoint)lerpWithCurrentVector:(CGPoint)currentVector andDestVector:(CGPoint)destVector andConst:(float)konst;


@end

@implementation BoardLayer
    
CCSprite *background;
float _snakeSpeed;
CGPoint _previousSnakeHeadPosition;
CGPoint _snakeHeading;
NSUInteger _nextHeadingIndex;
int _planetNum;
int _level = 1;
int _planetLeft = 5;
int _livesLeft = 5;
BOOL _updating = FALSE;
float _cTime = 0.0;
float minYDuration = 10;
float maxYDuration = 30;
float minXDuration;
float maxXDuration;

const short kPixelBetweenSnakeNodes = 45;

const short kTagForPlanetSprite = 1;
const short kLerpConst = 0.6;

const short kPlanetsPerLevel = 10;

@synthesize snakeHead = _snakeHead;
@synthesize snakeBody = _snakeBody;
@synthesize touchArray = _touchArray;
@synthesize planetArray = _planetArray;
@synthesize newBodyToInsert = _newBodyToInsert;
@synthesize planetLeftLabel = _planetLeftLabel;
@synthesize levelLabel = _levelLabel;
@synthesize livesLabel = _livesLabel;


// on "dealloc" you need to release all your retained objects
- (void)dealloc {
    // in case you have something to dealloc, do it in this method
    // in this particular example nothing needs to be released.
    // cocos2d will automatically release all the children (Label)

    [_snakeHead release], _snakeHead = nil;
    [_snakeBody release], _snakeBody = nil;
    [_touchArray release], _touchArray = nil;
    [_planetArray release];
    [_newBodyToInsert release];
    [_planetLeftLabel release];
    [_levelLabel release];
    [_livesLabel release];
    [super dealloc];
}

// on "init" you need to initialize your instance
- (id)init {
    if (self = [super init]) { // initWithColor:ccc4(145, 255, 255, 255)])) {

        maxXDuration = maxYDuration * 768 / 1024;
        minXDuration = minYDuration * 768 / 1024;

        CGSize winSize = [[CCDirector sharedDirector] winSize];

        [self createSnakeHead:winSize];

        self.touchArray = [[NSMutableArray alloc] init];
        self.newBodyToInsert = [[NSMutableArray alloc] init];
        self.snakeBody = [[NSMutableArray alloc] init];
        self.planetArray = [[NSMutableArray alloc] init];

        [self addChild:_snakeHead];
        [self reorderChild:_snakeHead z:2];

        // add startup path
        [_touchArray addObject:NSStringFromCGPoint(_snakeHead.position)];
        [_touchArray addObject:NSStringFromCGPoint(CGPointMake(winSize.width, winSize.height / 2))];

        [self schedule:@selector(gameLogic:) interval:1];
        [self schedule:@selector(update:)];

        self.isTouchEnabled = YES;
        _nextHeadingIndex = 0;
        _planetNum = 0;
        _planetLeft = kPlanetsPerLevel;
        _livesLeft = 5;
        _level = 1;

        // Play background music
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"dragon.mp3.caf"];

        [UIFont fontWithName:@"Nevis.ttf" size:24];
        self.planetLeftLabel = [CCLabelTTF labelWithString:nil fontName:@"Nevis" fontSize:24];

        _planetLeftLabel.color = ccc3(255, 255, 255);
        _planetLeftLabel.position = ccp(winSize.width - 120, winSize.height - 44);

        self.livesLabel = [CCLabelTTF labelWithString:nil fontName:@"Nevis" fontSize:24];
        _livesLabel.color = ccc3(255, 255, 255);
        _livesLabel.position = ccp(winSize.width - 120, winSize.height - 88);

        self.levelLabel = [CCLabelTTF labelWithString:nil fontName:@"Nevis" fontSize:24];
        _levelLabel.color = ccc3(255, 255, 255);
        _levelLabel.position = ccp(winSize.width - 120, winSize.height - 132);

        background = [CCSprite spriteWithFile:@"Background_level1_1024x768.png" rect:CGRectMake(0, 0, 1024, 768)];
        background.position = ccp(1024 / 2, 768 / 2);
        [self addChild:background z:-1];
        [self addChild:_planetLeftLabel z:+3];
        [self addChild:_livesLabel z:+3];
        [self addChild:_levelLabel z:+3];
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

- (void)resetParameters {
    CGSize winSize = [[CCDirector sharedDirector] winSize];

    for (int i=0; i<[_snakeBody count]; i++) {
        CCSprite *snakeNodeSprite = (CCSprite *) [_snakeBody objectAtIndex:i];
        [self removeChild:snakeNodeSprite cleanup:YES];
    } 
    [self.snakeBody removeAllObjects];
    [self.touchArray removeAllObjects];
    [self.newBodyToInsert removeAllObjects];
    
    // add startup path
    [_touchArray addObject:NSStringFromCGPoint(_snakeHead.position)];

    _nextHeadingIndex = 0;
}

- (void)levelUp {
    // reset arrays
    [self resetParameters];
//    
//    int level = (_level%3)+1;
//    switch (level) {
//        case 1:
//            background = [CCSprite spriteWithFile:@"Background_level1_1024x768.png" rect:CGRectMake(0, 0, 1024, 768)];
//            background.position = ccp(1024 / 2, 768 / 2);
//            [self addChild:background z:-1];
//            break;            
//        case 2:
//            background = [CCSprite spriteWithFile:@"Background_level2_1024x768.png" rect:CGRectMake(0, 0, 1024, 768)];
//            background.position = ccp(1024 / 2, 768 / 2);
//            [self addChild:background z:-1];
//            break;
//        case 3:
//            background = [CCSprite spriteWithFile:@"Background_level3_1024x768.png" rect:CGRectMake(0, 0, 1024, 768)];
//            background.position = ccp(1024 / 2, 768 / 2);
//            [self addChild:background z:-1];
//            break;
//        default:
//            // you win!
//            break;
//    }

    _level++;
    _planetLeft = kPlanetsPerLevel;
    minYDuration = minYDuration * 0.75;
    maxYDuration = maxYDuration * 0.75;
    _snakeSpeed = _snakeSpeed * 1.25;
}

#pragma mark - CCNode Overrides


- (void)playEatingPlanetSound:(CCSprite *)sprite {

    int planetID = (arc4random() % 4) + 0;
    switch (planetID) {
            case 0:
            [[SimpleAudioEngine sharedEngine] playEffect:@"GasPlanet.mp3"];
                break;
            case 1:
            [[SimpleAudioEngine sharedEngine] playEffect:@"OmNom3.mp3"];
                break;
            case 2:
            [[SimpleAudioEngine sharedEngine] playEffect:@"RockPlanet.mp3"];
                break;
            default:
            [[SimpleAudioEngine sharedEngine] playEffect:@"WaterPlanet.mp3"];
                break;
        }
}

- (void)draw {
    [_planetLeftLabel setString:[NSString stringWithFormat:@"PLANETS LEFT : %d", _planetLeft]];
    [_livesLabel setString:[NSString stringWithFormat:@"LIVES                : %d", _livesLeft]];
    [_levelLabel setString:[NSString stringWithFormat:@"LEVEL                : %d", _level]];

    if (_updating)
        return;

    _updating = true;

    [super draw];
    glEnable(GL_LINE_SMOOTH);
    glColor4ub(0, 0, 0, 255);

    //TODO: _nextHeadingIndex
    NSArray *tmpArray = [NSArray arrayWithArray:_touchArray];
    for (int i = 0; i < [tmpArray count] - 1; i++) {
        CGPoint start = CGPointFromString([tmpArray objectAtIndex:i]);
        CGPoint end = CGPointFromString([tmpArray objectAtIndex:i + 1]);

        ccDrawLine(start, end);
    }

    NSMutableArray *planetsToDelete = [[NSMutableArray alloc] init];
    for (CCSprite *planet in _planetArray) {
        if (!planet.visible) continue;
        CGRect planetBounds = CGRectMake(planet.position.x - (planet.contentSize.width / 2), planet.position.y - (planet.contentSize.height / 2), planet.contentSize.width, planet.contentSize.height);
        if (CGRectIntersectsRect(_snakeHead.boundingBox, planet.boundingBox)) {
            planet.visible = NO;
            [planetsToDelete addObject:planet];
            [self playEatingPlanetSound:planet];
            [self addSnakeBody];
            --_planetLeft;
        }

//        for (int i = 0; i < [planetsToDelete count]; i++) {
//
//            CCSprite* sprite = (CCSprite *)[planetsToDelete objectAtIndex:i];
//            @synchronized (_planetArray) {
//                [_planetArray removeObject:sprite];
//            }
//        }

        // set this to yes for debug purposes
        BOOL drawBoundingBoxes = NO;
        if (drawBoundingBoxes) {
            CGRect rect = _snakeHead.boundingBox;
            CGPoint vertices[4] = {
                    ccp(rect.origin.x, rect.origin.y),
                    ccp(rect.origin.x + rect.size.width, rect.origin.y),
                    ccp(rect.origin.x + rect.size.width, rect.origin.y + rect.size.height),
                    ccp(rect.origin.x, rect.origin.y + rect.size.height),
            };
            ccDrawPoly(vertices, 4, YES);
            //rect = planet.boundingBox;
            rect = planetBounds;
            CGPoint vertices1[4] = {
                    ccp(rect.origin.x, rect.origin.y),
                    ccp(rect.origin.x + rect.size.width, rect.origin.y),
                    ccp(rect.origin.x + rect.size.width, rect.origin.y + rect.size.height),
                    ccp(rect.origin.x, rect.origin.y + rect.size.height),
            };
            ccDrawPoly(vertices1, 4, YES);
        }
    }
    
    if (_planetLeft <= 0) {
        [self levelUp];
    }
    _updating = false;
}

#pragma mark - CCStandardTouchDelegate Members

- (void)ccTouchesBegan:(NSSet *)touches
             withEvent:(UIEvent *)event {

    _nextHeadingIndex = 0;

    // Choose one of the touches to work with
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInView:[touch view]];
    touchLocation = [[CCDirector sharedDirector] convertToGL:touchLocation];
    _snakeHeading = touchLocation;

    NSMutableArray *tmpArray = [[NSMutableArray alloc] init];
    for (int k = 0; k < [_snakeBody count]; k++) {
        [tmpArray addObject:NSStringFromCGPoint(((CCSprite *) [_snakeBody objectAtIndex:k]).position)];
    }
    [tmpArray addObject:NSStringFromCGPoint(_snakeHead.position)];
    [tmpArray addObject:NSStringFromCGPoint(touchLocation)];

    self.touchArray = tmpArray;

    // rotate the sprite
    CGPoint vector = ccpSub(touchLocation, _snakeHead.position);
    CGFloat rotateAngle = -ccpToAngle(vector);
    float angle = CC_RADIANS_TO_DEGREES(rotateAngle);
    _snakeHead.rotation = angle;
}

//
- (void)ccTouchesMoved:(NSSet *)touches
             withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint new_location = [touch locationInView:[touch view]];
    new_location = [[CCDirector sharedDirector] convertToGL:new_location];

    CGPoint oldTouchLocation = [touch previousLocationInView:touch.view];
    oldTouchLocation = [[CCDirector sharedDirector] convertToGL:oldTouchLocation];
    oldTouchLocation = [self convertToNodeSpace:oldTouchLocation];

    [self.touchArray addObject:NSStringFromCGPoint(new_location)];
}

//
#pragma mark - update methods

- (void)gameLogic:(ccTime)dt {
    CCSprite *target = [self getPlanet:(_planetNum % 3)];

    int random = (arc4random() % 2) + 0;
    if (random == 1) {
        [self addXPlanet:target];
    }
    else {
        [self addYPlanet:target];
    }
    _planetNum++;
}

#pragma mark - Private Methods
//
- (void)addYPlanet:(CCSprite *)planet; {

    planet.tag = kTagForPlanetSprite;
    @synchronized (_planetArray) {
        [_planetArray addObject:planet];
    }

    // Determine where to spawn the target along the Y axis
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    int minY = planet.contentSize.height / 2;
    int maxY = winSize.height - planet.contentSize.height / 2;
    int rangeY = maxY - minY;
    int actualY = (arc4random() % rangeY) + minY;

    // Create the target slightly off-screen along the right edge,
    // and along a random position along the Y axis as calculated above
    planet.position = ccp(winSize.width + (planet.contentSize.width / 2), actualY);
    [self addChild:planet];
    [self reorderChild:planet z:0];

    // Determine speed of the target
    int rangeDuration = maxYDuration - minYDuration;
    int actualDuration = (arc4random() % rangeDuration) + minYDuration;

    // Create the actions
    id actionMove = [CCMoveTo actionWithDuration:actualDuration
                                        position:ccp(-planet.contentSize.width / 2, actualY)];
    id actionMoveDone = [CCCallFuncN actionWithTarget:self
                                             selector:@selector(planetMoveFinished:)];

    actualDuration = (arc4random() % rangeDuration) + minYDuration;
    id rotate = [CCRotateBy actionWithDuration:actualDuration angle:3000];
    id actions = [CCSpawn actions:actionMove, rotate, nil];
    id sequence = [CCSequence actions:actions, actionMoveDone, nil];

    [planet runAction:sequence];
}

//
- (void)addXPlanet:(CCSprite *)planet; {

    planet.tag = kTagForPlanetSprite;
    @synchronized (_planetArray) {
        [_planetArray addObject:planet];
    }

    // Determine where to spawn the target along the Y axis
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    int minX = planet.contentSize.width / 2;
    int maxX = winSize.width - planet.contentSize.width / 2;
    int rangeX = maxX - minX;
    int actualX = (arc4random() % rangeX) + minX;

    // Create the target slightly off-screen along the right edge,
    // and along a random position along the Y axis as calculated above
    planet.position = ccp(actualX, winSize.width + (planet.contentSize.width / 2));
    [self addChild:planet];
    [self reorderChild:planet z:0];

    // Determine speed of the target
    int rangeDuration = maxXDuration - minXDuration;
    int actualDuration = (arc4random() % rangeDuration) + minYDuration;

    // Create the actions
    id actionMove = [CCMoveTo actionWithDuration:actualDuration
                                        position:ccp(actualX, -planet.contentSize.width / 2)];
    id actionMoveDone = [CCCallFuncN actionWithTarget:self
                                             selector:@selector(planetMoveFinished:)];

    actualDuration = (arc4random() % rangeDuration) + minXDuration;
    id rotate = [CCRotateBy actionWithDuration:actualDuration angle:3000];
    id actions = [CCSpawn actions:actionMove, rotate, nil];
    id sequence = [CCSequence actions:actions, actionMoveDone, nil];

    [planet runAction:sequence];
}

//
- (void)addSnakeBody {
    CCSprite *snakeNode = [CCSprite spriteWithFile:@"Body_block_round_61x53.png" rect:CGRectMake(0, 0, 61, 53)];

    if ([_snakeBody count] > 0) {
        snakeNode.position = ((CCSprite *) [_snakeBody objectAtIndex:0]).position;
    }
    else {
        snakeNode.position = _snakeHead.position;
    }

    [_newBodyToInsert addObject:snakeNode];
}

//
- (void)createSnakeHead:(CGSize)windowsSize {
    self.snakeHead = [CCSprite spriteWithFile:@"Head_Short_129x82.png" rect:CGRectMake(0, 0, 129, 82)];
    _snakeHead.position = ccp(_snakeHead.contentSize.width / 2, windowsSize.height / 2);
    _previousSnakeHeadPosition = _snakeHead.position;
}

- (float)findDistanceBetween:(CGPoint)point1
                    andPoint:(CGPoint)point2 {
    return sqrt(powf(point1.x - point2.x, 2.f) + powf(point1.y - point2.y, 2.f));
}

//
- (CCSprite *)getPlanet:(int)planetID {
    switch (planetID) {
        case 0:
            return [CCSprite spriteWithFile:@"Planet_Gas_82x84.png" rect:CGRectMake(0, 0, 82, 84)];
            break;
        case 1:
            return [CCSprite spriteWithFile:@"Planet_Water_81x81.png" rect:CGRectMake(0, 0, 81, 81)];
            break;
        case 2:
            return [CCSprite spriteWithFile:@"Planet_Rocky_84x85.png" rect:CGRectMake(0, 0, 84, 85)];
            break;
        default:
            return [CCSprite spriteWithFile:@"Planet_Gas_82x84.png" rect:CGRectMake(0, 0, 82, 84)];
            break;
    }
}

// Occurs when the snake body finished moving
- (void)planetMoveFinished:(id)sender {
    CCSprite *sprite = (CCSprite *) sender;
    [self removeChild:sprite cleanup:YES];
    @synchronized (_planetArray) {
        [_planetArray removeObject:sprite];
    }

    if (sprite.visible)
        _livesLeft--;

    if (_livesLeft <= 0)
    {
        GameOverScene *gameOverScene = [GameOverScene node];
        [gameOverScene.layer.label setString:@"You Lose :["];
        [[CCDirector sharedDirector] replaceScene:gameOverScene];
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:nil];
    }
}

// Occurs when the snake body finished moving
- (void)snakeBodyMoveFinished:(id)sender {
}

// Occurs when the snake head finished moving
- (void)snakeHeadMoveFinished:(id)sender {
}

- (void)snakeHeadBlinkFinished:(id)sender {
}


-(void) repositionHeadAlongTouchPath:(ccTime) time
{
    ccTime timeLeft = time;
    
    CGPoint prevHeadPosition = _snakeHead.position;
    NSArray *path = [[NSArray alloc] initWithArray:_touchArray];
    float distanceToTravel = time * _snakeSpeed;
    if ([path count] < 2)
        return;
    
    int i = [_snakeBody count]; // skip the body, it will be calculated later
    
    CGPoint prevPoint = CGPointMake(CGPointFromString([path objectAtIndex:i]).x, CGPointFromString([path objectAtIndex:i]).y);
    for (++i; i < [path count]; i++) {
        
        CGPoint tmpPoint = CGPointMake(CGPointFromString([path objectAtIndex:i]).x, CGPointFromString([path objectAtIndex:i]).y);
        float distanceTraveled = [self findDistanceBetween:prevPoint andPoint:tmpPoint];
        if (distanceToTravel > distanceTraveled) {
            timeLeft -= timeLeft * distanceTraveled / distanceToTravel;
            distanceToTravel -= distanceTraveled;
            
            // rotate the head
            CGPoint vector = ccpSub(tmpPoint, prevPoint);
            
            prevPoint = tmpPoint;
            
            // destination vector
            if (i + 1 < [path count]) {
                CGPoint dest2ndPoint = CGPointMake(CGPointFromString([path objectAtIndex:i + 1]).x, CGPointFromString([path objectAtIndex:i + 1]).y);
                CGPoint destVector = ccpSub(dest2ndPoint, tmpPoint);
                
                CGPoint lerpVector = [self lerpWithCurrentVector:vector andDestVector:destVector
                                                        andConst:kLerpConst];
                float rotateAngle = -ccpToAngle(lerpVector);
                float angle = CC_RADIANS_TO_DEGREES(rotateAngle);
                
                _snakeHead.rotation = angle;
            }
            
            continue;
        }
        else {
            CGPoint offset = ccpSub(tmpPoint, prevPoint);
            CGPoint targetVector = ccpNormalize(offset);
            CGPoint targetPerSecond = ccpMult(targetVector, _snakeSpeed);
            CGPoint actualTarget = ccpAdd(prevPoint, ccpMult(targetPerSecond, timeLeft));
            _snakeHead.position = actualTarget;
            
            // destination vector
            if (i + 1 < [path count]) {
                CGPoint dest2ndPoint = CGPointMake(CGPointFromString([path objectAtIndex:i + 1]).x, CGPointFromString([path objectAtIndex:i + 1]).y);
                CGPoint destVector = ccpSub(dest2ndPoint, tmpPoint);
                
                CGPoint lerpVector = [self lerpWithCurrentVector:offset andDestVector:destVector
                                                        andConst:kLerpConst];
                float rotateAngle = -ccpToAngle(lerpVector);
                float angle = CC_RADIANS_TO_DEGREES(rotateAngle);
                
                _snakeHead.rotation = angle;
            }
            break;
        }
    }
    
    // recreate the touch array
    NSMutableArray *newArray = [[NSMutableArray alloc] init];
    for (int k = 0; k < [_snakeBody count]; k++) {
        [newArray addObject:NSStringFromCGPoint(((CCSprite *) [_snakeBody objectAtIndex:k]).position)];
    }
    //[newArray addObject:NSStringFromCGPoint(prevHeadPosition)];
    [newArray addObject:NSStringFromCGPoint(_snakeHead.position)];
    
    for (int j = i; j < [path count]; j++) {
        
        [newArray addObject:[path objectAtIndex:j]];
    }
    
    self.touchArray = newArray;
}

-(void) repositionBodyAlongTouchPath:(ccTime) time
{
    // if the head stop moving
    NSArray *path = [[NSArray alloc] initWithArray:_touchArray];
    
    if ([path count] <= [_snakeBody count] + 1)
        return;
    
    int i = [_snakeBody count] - 1; // skip the body, it will be calculated later
    CGPoint prevPoint = CGPointMake(CGPointFromString([path objectAtIndex:[_snakeBody count]]).x, CGPointFromString([path objectAtIndex:[_snakeBody count]]).y);
    
    CGPoint lastVector = CGPointMake(12, 12);
    for (int l = [_snakeBody count] - 1; l >= 0; l--) {
        float distanceToTravel = kPixelBetweenSnakeNodes;
        //CGPoint snakeBodyPos = CGPointFromString([_snakeBody objectAtIndex:l]);
        
        BOOL abort = false;
        for (i; i >= 0; i--) {
            
            CGPoint tmpPoint = CGPointMake(CGPointFromString([path objectAtIndex:i]).x, CGPointFromString([path objectAtIndex:i]).y);
            float distanceBetweenPoint = [self findDistanceBetween:prevPoint andPoint:tmpPoint];
            
            if (distanceToTravel > distanceBetweenPoint) {
                distanceToTravel -= distanceBetweenPoint;
                CGPoint test = prevPoint;
                
                //                // rotate the head
                lastVector = ccpSub(tmpPoint, prevPoint);
                
                prevPoint = tmpPoint;
                //                CGFloat rotateAngle = -ccpToAngle(lastVector);
                //                float angle = CC_RADIANS_TO_DEGREES(rotateAngle);
                //                ((CCSprite *) [_snakeBody objectAtIndex:l]).rotation = angle;
                
                continue;
            }
            else {
                lastVector = ccpSub(tmpPoint, prevPoint);
                CGPoint targetVector = ccpNormalize(lastVector);
                CGPoint targetPerSecond = ccpMult(targetVector, distanceToTravel);
                CGPoint actualTarget = ccpAdd(prevPoint, targetPerSecond);
                
                ((CCSprite *) [_snakeBody objectAtIndex:l]).position = actualTarget;
                prevPoint = actualTarget;
                
                // rotate the head
                CGFloat rotateAngle = -ccpToAngle(lastVector);
                float angle = CC_RADIANS_TO_DEGREES(rotateAngle);
                ((CCSprite *) [_snakeBody objectAtIndex:l]).rotation = angle;
                abort = true;
                
                break;
            }
        }
    }
}

-(void) update:(ccTime) time
{
    if (_updating) {
        _cTime += time;
        return;
    }

    _updating = true;

    if ([_newBodyToInsert count] > 0) {
        for (int i = 0; i < [_newBodyToInsert count]; i++) {
            CCSprite *snakeNode = (CCSprite *) [_newBodyToInsert objectAtIndex:i];
            [_snakeBody insertObject:snakeNode atIndex:0];
            [self addChild:snakeNode];
            [self reorderChild:snakeNode z:1];

            [_touchArray insertObject:NSStringFromCGPoint(snakeNode.position) atIndex:0];
            [_newBodyToInsert removeAllObjects];
        }
    }

    if (_snakeHead.position.x == _snakeHeading.x &&
            _snakeHead.position.y == _snakeHeading.y)
        return;

    [self repositionHeadAlongTouchPath:(ccTime) time];
    [self repositionBodyAlongTouchPath:(ccTime) time];

    _updating = false;
}

//increase the constant if I want it to be smoother
-(CGPoint) lerpWithCurrentVector:(CGPoint) currentVector andDestVector:(CGPoint) destVector andConst:(float) konst
{
    return currentVector;
//    float a = 1 - konst;
//    return ccpAdd(ccpMult(currentVector, konst),  ccpMult(destVector, a));
}

@end

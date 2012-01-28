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

// HelloWorldLayer implementation
@interface BoardLayer ()
- (void)addSnakeHead:(CGSize)windowsSize;

- (float)findDistanceBetween:(CGPoint)point1 andPoint:(CGPoint)point2;


@property(retain, nonatomic) CCSprite *snakeHead;


@end

@implementation BoardLayer

NSMutableArray *_snakeBody;
NSMutableArray *_projectiles;
float _speed;


@synthesize snakeHead = _snakeHead;

+ (CCScene *)scene {
    _speed = 200 / 1; //X pixel/seconds

    // 'scene' is an autorelease object.
    CCScene *scene = [CCScene node];

    // 'layer' is an autorelease object.
    BoardLayer *layer = [BoardLayer node];

    // add layer as a child to scene
    [scene addChild:layer];

    // return the scene
    return scene;
}


- (void)spriteMoveFinished:(id)sender {
//    CCSprite *sprite = (CCSprite *) sender;
//
//    [self removeChild:sprite cleanup:YES];
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

        [self schedule:@selector(gameLogic:) interval:1.0];
        [self schedule:@selector(update:)];

        _snakeBody = [[NSMutableArray alloc] init];
        _projectiles = [[NSMutableArray alloc] init];

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

    [_snakeBody release];
    _snakeBody = nil;
    [_projectiles release];
    _projectiles = nil;

    // don't forget to call "super dealloc"
    [_snakeHead release];
    [super dealloc];
}


- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {

// Choose one of the touches to work with
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:[touch view]];
    location = [[CCDirector sharedDirector] convertToGL:location];


    float distance = [self findDistanceBetween:_snakeHead.position andPoint:location];
    float duration = distance / _speed;
    [_snakeHead runAction:[CCSequence actions:[CCMoveTo actionWithDuration:duration position:location],
                  [CCCallFuncN actionWithTarget:self selector:@selector(spriteMoveFinished:)],
                  nil]];


//    // What is the initial location of the snake?
//    CGSize winSize = [[CCDirector sharedDirector] winSize];
//
//    // Determine offset of location to projectile
//    int offX = location.x - _snakeHead.position.x;
//    int offY = location.y - _snakeHead.position.y;
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

- (void)update:(ccTime)dt {

//    NSMutableArray *projectilesToDelete = [[NSMutableArray alloc] init];
//    for (CCSprite *projectile in _projectiles) {
//        CGRect projectileRect = CGRectMake(
//                                           projectile.position.x - (projectile.contentSize.width/2),
//                                           projectile.position.y - (projectile.contentSize.height/2),
//                                           projectile.contentSize.width,
//                                           projectile.contentSize.height);
//
//        NSMutableArray *targetsToDelete = [[NSMutableArray alloc] init];
//        for (CCSprite *target in _snakeBody) {
//            CGRect targetRect = CGRectMake(
//                                           target.position.x - (target.contentSize.width/2),
//                                           target.position.y - (target.contentSize.height/2),
//                                           target.contentSize.width,
//                                           target.contentSize.height);
//
//            if (CGRectIntersectsRect(projectileRect, targetRect)) {
//                [targetsToDelete addObject:target];
//            }
//        }
//
//        for (CCSprite *target in targetsToDelete) {
//            [_snakeBody removeObject:target];
//            [self removeChild:target cleanup:YES];
//            _projectilesDestroyed++;
//            if (_projectilesDestroyed > 30) {
//                GameOverScene *gameOverScene = [GameOverScene node];
//                _projectilesDestroyed = 0;
//                [gameOverScene.layer.label setString:@"You Win!"];
//                [[CCDirector sharedDirector] replaceScene:gameOverScene];
//            }
//        }
//
//        if (targetsToDelete.count > 0) {
//            [projectilesToDelete addObject:projectile];
//        }
//        [targetsToDelete release];
//    }
//
//    for (CCSprite *projectile in projectilesToDelete) {
//        [_projectiles removeObject:projectile];
//        [self removeChild:projectile cleanup:YES];
//    }
//    [projectilesToDelete release];
}


#pragma mark - Private Methods

- (void)addSnakeHead:(CGSize)windowsSize {
    self.snakeHead = [CCSprite spriteWithFile:@"SnakeHead_27x40.png" rect:CGRectMake(0, 0, 27, 40)];
    _snakeHead.position = ccp(_snakeHead.contentSize.width / 2, windowsSize.height / 2);
    [self addChild:_snakeHead];
}

- (float)findDistanceBetween:(CGPoint)point1 andPoint:(CGPoint)point2 {
     return sqrt(powf(point1.x - point2.x, 2.f) + powf(point1.y - point2.y, 2.f));
 }
@end

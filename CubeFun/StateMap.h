//
//  StateMap.h
//  Snake
//
//  Created by Ying Jiang on 2/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SPoint : NSObject {
@private
    int x;
    int y;
}

@property (nonatomic, assign) int x;
@property (nonatomic, assign) int y;

@end

typedef enum {
    CubeOrientationPortrait,
    CubeOrientationLandscapeLeft,
    CubeOrientationUpsideDown,
    CubeOrientationLandscapeRight
} CubeOrientation;


@protocol StateMapDelegate <NSObject>

- (void)drawCube;
- (void)gameOver;
- (void)cubeDidUpdate;
- (void)cubeDidJump;
- (void)randomCubeCreated;
- (void)cubeDidStop;
- (void)clearRows:(NSArray *)rows;

@end

@interface StateMap : NSObject {
    id<StateMapDelegate> __unsafe_unretained delegate;
}

@property (nonatomic, unsafe_unretained) id<StateMapDelegate> delegate;

+ (id)sharedInstance;
- (void)changeDirection:(int)dire;
- (NSArray *)getNextTickCubePoints;
- (int)getSideLength;
- (void)initCube;
- (NSArray *)getNextTickCubePointsMoveByX:(int)x Y:(int)y;
- (NSArray *)getNextTickCubePoints;
- (void)createRandomCube;
- (void)cubeStops;
- (void)rotateCube;

@end

//
//  StateMap.m
//  Snake
//
//  Created by Ying Jiang on 2/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "StateMap.h"


@implementation SPoint

@synthesize x, y;


- (id)initWithX:(int)xValue Y:(int)yValue
{
    if (self = [super init]) {
        self.x = xValue;
        self.y = yValue;
    }
    
    return self;
}

+ (id)pointWithPoint:(SPoint *)point
{
    SPoint *p = [[SPoint alloc] initWithX:point.x Y:point.y];
    return p;
}

+ (id)pointWithX:(int)xValue Y:(int)yValue
{
    return [[SPoint alloc] initWithX:xValue Y:yValue];
}

- (BOOL)isEqualToPoint:(SPoint *)p
{
    return (self.x == p.x && self.y == p.y);
}

- (void)convert2Point:(SPoint *)p
{
    self.x += p.x;
    self.y += p.y;
}

@end

#define MAP_WIDTH 16
#define MAP_HEIGHT 23
#define CUBE_TYPE_COUNT 7

int directionArray[2][2] = {{-1, 1},{-1, 1}};
int cube[CUBE_TYPE_COUNT][8] = {{0,0,0,0,1,1,1,1}, {1,1,1,0,1,0,0,0}, {1,1,0,0,1,1,0,0}, {1,0,0,0,1,1,1,0}, 
                                {1,1,0,0,0,1,1,0}, {0,1,1,0,1,1,0,0}, {1,1,1,0,0,1,0,0}};

@implementation StateMap {
    int currentCubeType;  //the index in cube[][]
    CubeOrientation currentCubeOrientation; //the orientation of current cube
    int map[MAP_WIDTH][MAP_HEIGHT];
    SPoint *currentCubeOriginPoint;
    NSMutableArray *cubePoints;
}

@synthesize  delegate;

static StateMap *instance = nil;

- (BOOL)isPointAvailable:(SPoint *)point
{
    if (point.x >= 0 && point.x < MAP_WIDTH && point.y >=0 && point.y < MAP_HEIGHT) {
        if (map[point.x][point.y] == 1) {
            return NO;
        }
    }

    if (point.y >= MAP_HEIGHT) {
        return NO;
    }
    
    return YES;
}

+ (StateMap *)sharedInstance
{
    if (!instance) {
        instance = [[StateMap alloc] init];
    }
    return instance;
}

- (BOOL)isCubePositionValid
{        
    int rows = 4, cols = 2;
    if (currentCubeOrientation == CubeOrientationLandscapeLeft || currentCubeOrientation == CubeOrientationLandscapeRight) {
        rows = 2, cols = 4;
    }
    
    for (int col = 0; col < cols; col ++) {
        for (int row = 0; row < rows; row ++) {
            int index = col * 4 + row;
            if (currentCubeOrientation == CubeOrientationLandscapeLeft) {
                index = col + (1 - row) * 4;
            } else if (currentCubeOrientation == CubeOrientationUpsideDown) {
                index = (1 - col) * 4 + (3 - row);
            } else if (currentCubeOrientation == CubeOrientationLandscapeRight) {
                index = (3 - col) + row * 4;
            }
            
            if (cube[currentCubeType][index] == 1) {
                SPoint *point = [SPoint pointWithX:col Y:row];
                [point convert2Point:currentCubeOriginPoint];
                
                if (point.x < 0 || point.x >= MAP_WIDTH) {
                    [currentCubeOriginPoint convert2Point:[SPoint pointWithX:1 Y:0]];
                    return NO;
                } else if (point.x >= MAP_WIDTH) {
                    [currentCubeOriginPoint convert2Point:[SPoint pointWithX:-1 Y:0]];
                    return NO;
                }
                
                if ([self isPointAvailable:point] == NO) {
                    return NO;
                }
            }
        }
    }

    
    return YES;
}


- (void)cubeJumpDown
{
    int rows = 4, cols = 2;
    if (currentCubeOrientation == CubeOrientationLandscapeLeft || currentCubeOrientation == CubeOrientationLandscapeRight) {
        rows = 2, cols = 4;
    }
    
    int jumpHeight = MAP_HEIGHT - 1;
    
    for (int col = 0; col < cols; col ++) {
        for (int row = 0; row < rows; row ++) {
            int index = col * 4 + row;
            if (currentCubeOrientation == CubeOrientationLandscapeLeft) {
                index = col + (1 - row) * 4;
            } else if (currentCubeOrientation == CubeOrientationUpsideDown) {
                index = (1 - col) * 4 + (3 - row);
            } else if (currentCubeOrientation == CubeOrientationLandscapeRight) {
                index = (3 - col) + row * 4;
            }
            
            if (cube[currentCubeType][index] == 1) {
                int mapCol = col + currentCubeOriginPoint.x;
                
                if (jumpHeight > MAP_HEIGHT - 1 - row - currentCubeOriginPoint.y) {
                    jumpHeight = MAP_HEIGHT - 1 - row - currentCubeOriginPoint.y;
                }
                
                for (int mapRow = row + currentCubeOriginPoint.y; mapRow < MAP_HEIGHT; mapRow ++) {
                    if (map[mapCol][mapRow] == 1) {
                        if (jumpHeight > mapRow - 1 - row - currentCubeOriginPoint.y) {
                            jumpHeight = mapRow - 1 - row - currentCubeOriginPoint.y;
                        }
                        break;
                    }
                }
            }
        }
    }
    
    if (jumpHeight <= 0) {
        [self.delegate gameOver];
        return;
    }
    
    [currentCubeOriginPoint convert2Point:[SPoint pointWithX:0 Y:jumpHeight - 1]];
    
    [self.delegate cubeDidJump];
}

- (void)changeDirection:(int)dire
{
    if (dire == 2) {
        
        [currentCubeOriginPoint convert2Point:[SPoint pointWithX:-1 Y:-1]];
        
        if ([self isCubePositionValid] == NO) {
            return;
        }
        
        [self.delegate cubeDidUpdate];
    } else if (dire == 3) {
        [currentCubeOriginPoint convert2Point:[SPoint pointWithX:1 Y:-1]];
        
        if ([self isCubePositionValid] == NO) {
            return;
        }
        
        [self.delegate cubeDidUpdate];
    } else if (dire == 1) {
        [self cubeJumpDown];
    }
}

- (void)rotateCube
{
    currentCubeOrientation ++;
    
    if (currentCubeOrientation >= 4) {
        currentCubeOrientation = CubeOrientationPortrait;
    }
    
    [self.delegate cubeDidUpdate];
}

- (int)getSideLength
{
    return 20;
}

- (void)createRandomCube
{
    currentCubeType = random() % CUBE_TYPE_COUNT;
//    currentCubeOrientation = random() % 4;
    currentCubeOrientation = CubeOrientationPortrait;
    currentCubeOriginPoint = [SPoint pointWithX:MAP_WIDTH / 2 - 1 Y:-4];
    
    [self.delegate randomCubeCreated];
}

- (id)init
{
    if (self = [super init]) {
    }
    return self;
}

- (void)initCube
{
    if (cubePoints) {
        [cubePoints removeAllObjects];
        cubePoints = nil;
    }
    
    cubePoints = [[NSMutableArray alloc] init];
    memset(map, 0, sizeof(map)); 
    
    [self createRandomCube];
}

- (void)clearFullRows
{
    int shiftHeight = 0;
    NSMutableArray *rows = [[NSMutableArray alloc] init];
    
    for (int row = MAP_HEIGHT - 1; row >= 0; row --) {
        int sum = 0;
        for (int col = 0; col < MAP_WIDTH; col ++) {
            sum += map[col][row];
            map[col][row + shiftHeight] = map[col][row];
        }
        if (sum == MAP_WIDTH) {
            shiftHeight ++;
            [rows addObject:[NSNumber numberWithInt:row]];
        }
    }
    
    [self.delegate clearRows:rows];
}

- (NSArray *)getNextTickCubePointsMoveByX:(int)x Y:(int)y
{
    // move the cube down for 1 pixel
    [currentCubeOriginPoint convert2Point:[SPoint pointWithX:x Y:y]];  
   
    int rows = 4, cols = 2;
    if (currentCubeOrientation == CubeOrientationLandscapeLeft || currentCubeOrientation == CubeOrientationLandscapeRight) {
        rows = 2, cols = 4;
    }
    
START:
    [cubePoints removeAllObjects];
    
    for (int col = 0; col < cols; col ++) {
        for (int row = 0; row < rows; row ++) {
            int index = col * 4 + row;
            if (currentCubeOrientation == CubeOrientationLandscapeLeft) {
                index = col + (1 - row) * 4;
            } else if (currentCubeOrientation == CubeOrientationUpsideDown) {
                index = (1 - col) * 4 + (3 - row);
            } else if (currentCubeOrientation == CubeOrientationLandscapeRight) {
                index = (3 - col) + row * 4;
            }
            
            if (cube[currentCubeType][index] == 1) {
                SPoint *point = [SPoint pointWithX:col Y:row];
                [point convert2Point:currentCubeOriginPoint];
                
                if (point.x < 0) {
                    [currentCubeOriginPoint convert2Point:[SPoint pointWithX:1 Y:0]];
                    goto START;
                } else if (point.x >= MAP_WIDTH) {
                    [currentCubeOriginPoint convert2Point:[SPoint pointWithX:-1 Y:0]];
                    goto START;
                }
                
                if ([self isPointAvailable:point] == NO) {
                    if (point.y <= 3) {
                        [self.delegate gameOver];
                        return nil;
                    }
                    
                    [currentCubeOriginPoint convert2Point:[SPoint pointWithX:0-x Y:0-y]];
                    [self cubeStops];
                    return nil;
                }
                
                [cubePoints addObject:point];
            }
        }
    }
   
    return cubePoints;
}


- (void)cubeStops
{
    [cubePoints removeAllObjects];
    
    int rows = 4, cols = 2;
    if (currentCubeOrientation == CubeOrientationLandscapeLeft || currentCubeOrientation == CubeOrientationLandscapeRight) {
        rows = 2, cols = 4;
    }
    
    for (int col = 0; col < cols; col ++) {
        for (int row = 0; row < rows; row ++) {
            int index = col * 4 + row;
            if (currentCubeOrientation == CubeOrientationLandscapeLeft) {
                index = col + (1 - row) * 4;
            } else if (currentCubeOrientation == CubeOrientationUpsideDown) {
                index = (1 - col) * 4 + (3 - row);
            } else if (currentCubeOrientation == CubeOrientationLandscapeRight) {
                index = (3 - col) + row * 4;
            }
            if (cube[currentCubeType][index] == 1) {
                SPoint *point = [SPoint pointWithX:col Y:row];
                [point convert2Point:currentCubeOriginPoint];
                [cubePoints addObject:point];
            }
        }
    }

    if (cubePoints) {
        for (SPoint *point in cubePoints) {
            if (point.y < 0) {
                continue;
            }
            map[point.x][point.y] = 1;
        }
        
        [self clearFullRows];
    }
    
    [self.delegate cubeDidStop];
}

- (NSArray *)getNextTickCubePoints
{
    NSArray *array = [self getNextTickCubePointsMoveByX:0 Y:1];

    return array;
}

@end

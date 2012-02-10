//
//  ViewController.m
//  CubeFun
//
//  Created by Charlene Jiang on 2/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import "StateMap.h"


@implementation ViewController {
    int sideLength;
    NSTimer *timer;
}

@synthesize cubePixels;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (IBAction)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer
{
    UISwipeGestureRecognizerDirection direction = recognizer.direction;
    
    if (direction == UISwipeGestureRecognizerDirectionUp) {
        [[StateMap sharedInstance] changeDirection:0];
    } else if (direction == UISwipeGestureRecognizerDirectionDown) {
        [[StateMap sharedInstance] changeDirection:1];
    } else if (direction == UISwipeGestureRecognizerDirectionLeft) {
        [[StateMap sharedInstance] changeDirection:2];
    } else if (direction == UISwipeGestureRecognizerDirectionRight) {
        [[StateMap sharedInstance] changeDirection:3];
    }
}

- (IBAction)handleDoubleTaps:(UITapGestureRecognizer *)recognizer
{    
    [[StateMap sharedInstance] rotateCube];
}

#pragma mark - 

- (void)drawCube
{
    NSArray *array = [[StateMap sharedInstance] getNextTickCubePoints];
    
    if (array) {
        for (int i = 0; i < 4; i ++) {
            UIView *v = [self.cubePixels objectAtIndex:i];
            SPoint *point = (SPoint *)[array objectAtIndex:i];
            CGRect rect = CGRectMake(point.x * sideLength + 0.5, point.y * sideLength + 0.5, sideLength - 1, sideLength - 1);
            v.frame = rect;
        }
    }
}

- (void)tick
{
    [self performSelectorOnMainThread:@selector(drawCube) withObject:nil waitUntilDone:NO];
}

- (void)initCube
{
    if (self.cubePixels) {
        [self.cubePixels removeAllObjects];
    }
    
    self.cubePixels = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < 4; i ++) {
        UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, sideLength - 1, sideLength - 1)];
        v.backgroundColor = [UIColor blackColor];
        [self.view addSubview:v];
        [self.cubePixels addObject:v];
    }
    
    [[StateMap sharedInstance] initCube];
}

- (void)start
{
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
    
    ((StateMap *)[StateMap sharedInstance]).delegate = self;
    sideLength = [[StateMap sharedInstance] getSideLength];
    
    [self initCube];

}


#pragma mark - 
- (void)gameOver
{
    NSLog(@"Game Over");
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Game Over" message:@"Start Again?" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
}

- (void)cubeDidUpdate
{
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
    
    [self performSelectorOnMainThread:@selector(drawCube) withObject:nil waitUntilDone:YES];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(tick) userInfo:nil repeats:YES];
}

- (void)cubeDidJump
{
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
    
    [UIView animateWithDuration:0.1 animations:^{
        [self performSelectorOnMainThread:@selector(drawCube) withObject:nil waitUntilDone:YES];
    }];
    
    [[StateMap sharedInstance] cubeStops];
}

- (void)randomCubeCreated
{
    [self performSelectorOnMainThread:@selector(drawCube) withObject:nil waitUntilDone:YES];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(tick) userInfo:nil repeats:YES];

}

- (void)cubeDidStop
{
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
    
    [cubePixels removeAllObjects];
    
    for (int i = 0; i < 4; i ++) {
        UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, sideLength - 1, sideLength - 1)];
        v.backgroundColor = [UIColor blackColor];
        [self.view addSubview:v];
        [self.cubePixels addObject:v];
    }
    
    [[StateMap sharedInstance] createRandomCube];
    
}

- (void)clearRows:(NSArray *)rows
{
    
//    if (timer) {
//        [timer invalidate];
//        timer = nil;
//    }
    
    int index = 0;
    for (NSNumber *value in rows) {
        int row = [value intValue] + index++;
        
        [UIView animateWithDuration:0.1 animations:^{
            for (UIView *v in [self.view subviews]) {
                CGRect rect = v.frame;
                if (rect.origin.y > row * sideLength && rect.origin.y - row * sideLength < 1) {
                    [v removeFromSuperview];
                } else if (rect.origin.y < row * sideLength) {
                    rect.origin.y = rect.origin.y + sideLength;
                    v.frame = rect;
                }
            }
        }completion:^(BOOL finished){
            
        }];
    }
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self start];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    for (UIView *v in [self.view subviews]) {
        [v removeFromSuperview];
    }
    
    [self start];
}

@end

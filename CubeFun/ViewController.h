//
//  ViewController.h
//  CubeFun
//
//  Created by Charlene Jiang on 2/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StateMap.h"

@interface ViewController : UIViewController <StateMapDelegate> {
    
}

@property (nonatomic, strong) NSMutableArray *cubePixels;

- (IBAction)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer;

@end

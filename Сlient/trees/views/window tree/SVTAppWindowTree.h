//
//  SVTAppWindowTree.h
//  lab1
//
//  Created by Тимофей Савицкий on 7/30/16.
//  Copyright © 2016 Тимофей Савицкий. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class SVTViewTreeController;
@class SVTTree;

@interface SVTAppWindowTree : NSWindowController

- (instancetype)initWithTree:(SVTTree *)tree;

@end

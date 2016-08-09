//
//  SVTViewTreesController.h
//  lab1
//
//  Created by Тимофей Савицкий on 7/30/16.
//  Copyright © 2016 Тимофей Савицкий. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class SVTTrees;

extern NSString * const kSVTViewControllerDidChangeTree;

@interface SVTViewController : NSViewController
- (instancetype)initWithModel:(SVTTrees *)model;
@property (readonly, retain) SVTTrees *trees;
@end

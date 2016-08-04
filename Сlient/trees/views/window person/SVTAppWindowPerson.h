//
//  SVTAppWindowPerson.h
//  lab1
//
//  Created by Тимофей Савицкий on 7/31/16.
//  Copyright © 2016 Тимофей Савицкий. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class SVTPerson;
@class SVTTree;

@interface SVTAppWindowPerson : NSWindowController

- (instancetype)initWithPerson:(SVTPerson *)person tree:(SVTTree *)tree;

@end

//
//  SVTViewWindowTree.h
//  lab1
//
//  Created by Тимофей Савицкий on 7/31/16.
//  Copyright © 2016 Тимофей Савицкий. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class SVTAppWindowPerson;
@class SVTTree;

@interface SVTViewTreeController : NSViewController

extern NSString *const kSVTViewTreeControllerDidChangePerson;

- (instancetype)initWithTree:(SVTTree *)tree;

@end

//
//  SVTNode.h
//  Trees
//
//  Created by Тимофей Савицкий on 8/8/16.
//  Copyright © 2016 Тимофей Савицкий. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SVTPerson;

extern NSInteger const kSVTNodeHeight;
extern CGFloat const kSVTNodeWidth;

@interface SVTNode : NSObject
- (instancetype)initWithPerson:(SVTPerson *)person;
@property (readwrite) NSInteger height;
@property (readwrite) CGFloat width;
@property (assign, readwrite) SVTPerson *mother;
@property (assign, readwrite) SVTPerson *father;
@property (assign, readwrite) SVTPerson *person;
@end
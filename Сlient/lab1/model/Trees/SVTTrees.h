//
//  SVTTrees.h
//  lab1
//
//  Created by Тимофей Савицкий on 8/3/16.
//  Copyright © 2016 Тимофей Савицкий. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SVTTree;

@interface SVTTrees : NSObject

- (instancetype)initWithTrees:(NSArray *)trees;

- (void)addTree:(SVTTree *)tree;
- (void)removeTree:(SVTTree *)tree;

@property (readonly) NSArray<SVTTree *> *trees;

@end

//
//  SVTTree.h
//  lab1
//
//  Created by Тимофей Савицкий on 7/30/16.
//  Copyright © 2016 Тимофей Савицкий. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SVTPerson;

@interface SVTTree : NSObject

- (instancetype)initWithTitle:(NSString *)title author:(NSString *)author persons:(NSArray *)persons;

- (void)addRoot:(SVTPerson *)node;
- (void)removeRoot:(SVTPerson *)node;

- (void)addPerson:(SVTPerson *)person;
- (void)removePerson:(SVTPerson *)person;

@property (readonly) NSArray<SVTPerson *> *persons;
@property (readonly) NSArray<SVTPerson *> *rootsOfForest;
@property (readwrite, copy) NSString *title;
@property (readwrite, copy) NSString *author;

@end

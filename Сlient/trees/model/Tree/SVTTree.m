//
//  SVTTree.m
//  lab1
//
//  Created by Тимофей Савицкий on 7/30/16.
//  Copyright © 2016 Тимофей Савицкий. All rights reserved.
//

#import "SVTTree.h"
#import "SVTPerson.h"

@interface SVTTree()
@property (readwrite) NSMutableArray<SVTPerson *> *mRootsOfForest;
@property (readwrite) NSMutableArray<SVTPerson *> *mPersons;
@end

@implementation SVTTree
{
@private
    NSMutableArray<SVTPerson *> *_mRootsOfForest;
}


- (instancetype)init
{
    return [self initWithTitle:@"title" author:@"author" persons:nil];
}

- (instancetype)initWithTitle:(NSString *)title author:(NSString *)author persons:(NSArray *)persons
{
    self = [super init];
    if (self)
    {
        _title = [title copy];
        _author = [author copy];
        _mPersons = persons ? [persons mutableCopy] : [[NSMutableArray alloc] init];
    }
    return self;
}



- (void)addRoot:(SVTPerson *)node
{
    [self.mRootsOfForest addObject:node];
}
- (void)removeRoot:(SVTPerson *)node
{
    [self.mRootsOfForest removeObject:node];
}

- (void)addPerson:(SVTPerson *)person
{
    [self.mPersons addObject:person];
}
- (void)removePerson:(SVTPerson *)person
{
    [self.mPersons removeObject:person];
}





#pragma mark - getters

- (NSArray<SVTPerson *> *)rootsOfForest
{
    return (NSArray *) _mRootsOfForest;
}

- (NSArray<SVTPerson *> *)persons
{
    return (NSArray *) _mPersons;
}



@end

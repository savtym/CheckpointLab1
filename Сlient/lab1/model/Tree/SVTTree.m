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
@property (readwrite, copy) NSMutableArray<SVTPerson *> *mPersons;
@end

@implementation SVTTree
{
@private
    NSString *_title;
    NSString *_author;
    NSUInteger _identifier;
    NSMutableArray<SVTPerson *> *_mPersons;
    BOOL _showTreeOnTheTable;
    NSUInteger _indexClickRowOfTable;
    NSUInteger _numberOfPersons;
}

- (instancetype)init
{
    return [self initWithTitle:@"title" author:@"author" persons:nil identifier:0 numberOfPersons:0];
}

- (instancetype)initWithTitle:(NSString *)title author:(NSString *)author persons:(NSArray *)persons identifier:(NSUInteger)identifier numberOfPersons:(NSUInteger)numberOfPersons
{
    self = [super init];
    if (self)
    {
        _title = [title copy];
        _author = [author copy];
        _identifier = identifier;
        _numberOfPersons = numberOfPersons;
        _mPersons = persons ? [persons mutableCopy] : [[NSMutableArray alloc] init];
    }
    return self;
}


#pragma mark - add/remove methods

- (void)addPerson:(SVTPerson *)person
{
    [self.mPersons addObject:person];
}
- (void)removePerson:(SVTPerson *)person
{
    [self.mPersons removeObject:person];
}


#pragma mark - dealloc

- (void)dealloc
{
    [_mPersons release];
    [_author release];
    [_title release];
    [super dealloc];
}


#pragma mark - getters

- (NSString *)author
{
    return _author;
}

- (NSString *)title
{
    return _title;
}

- (NSArray<SVTPerson *> *)persons
{
    return (NSArray *) _mPersons;
}

- (NSMutableArray<SVTPerson *> *)mPersons
{
    return _mPersons;
}

- (NSUInteger)identifier
{
    return _identifier;
}

- (BOOL)showTreeOnTheTable
{
    return _showTreeOnTheTable;
}

- (NSUInteger)indexClickRowOfTable
{
    return _indexClickRowOfTable;
}

-(NSUInteger)numberOfPersons
{
    if (_mPersons.count)
    {
        _numberOfPersons = _mPersons.count;
    }
    return _numberOfPersons;
}


#pragma mark - setters

- (void)setAuthor:(NSString *)author
{
    if (_author != author)
    {
        [_author release];
        _author = [author retain];
    }
}

- (void)setTitle:(NSString *)title
{
    if (_title != title)
    {
        [_title release];
        _title = [title retain];
    }
}

- (void)setMPersons:(NSMutableArray<SVTPerson *> *)mPersons
{
    if (_mPersons != mPersons)
    {
        [_mPersons release];
        _mPersons = [mPersons retain];
    }
}

- (void)setShowTreeOnTheTable:(BOOL)showTreeOnTheTable
{
    _showTreeOnTheTable = showTreeOnTheTable;
}

- (void)setIndexClickRowOfTable:(NSUInteger)indexClickRowOfTable
{
    _indexClickRowOfTable = indexClickRowOfTable;
}

- (void)setNumberOfPersons:(NSUInteger)numberOfPersons
{
    _numberOfPersons = numberOfPersons;
}

@end

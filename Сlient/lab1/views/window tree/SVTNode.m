//
//  SVTNode.m
//  Trees
//
//  Created by Тимофей Савицкий on 8/8/16.
//  Copyright © 2016 Тимофей Савицкий. All rights reserved.
//

#import "SVTNode.h"
#import "SVTPerson.h"

NSInteger const kSVTNodeHeight = -1;
CGFloat const kSVTNodeWidth = -1;

@implementation SVTNode
{
@private
    CGFloat _width;
    NSInteger _height;
    SVTPerson *_person;
}

- (instancetype)initWithPerson:(SVTPerson *)person
{
    self = [super init];
    if (self)
    {
        _person = person;
        _mother = person.mother;
        _father = person.father;
        _width = kSVTNodeWidth;
        _height = kSVTNodeHeight;
    }
    return self;
}


#pragma mark - getters

- (NSInteger)height
{
    return _height;
}

- (CGFloat)width
{
    return _width;
}

- (SVTPerson *)person
{
    return _person;
}


#pragma mark - setters

- (void)setHeight:(NSInteger)height
{
    _height = height;
}

- (void)setWidth:(CGFloat)width
{
    _width = width;
}

- (void)setPerson:(SVTPerson *)person
{
    _person = person;
}

@end

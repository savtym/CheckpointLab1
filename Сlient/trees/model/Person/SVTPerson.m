//
//  SVTPerson.m
//  lab1
//
//  Created by Тимофей Савицкий on 7/30/16.
//  Copyright © 2016 Тимофей Савицкий. All rights reserved.
//

#import "SVTPerson.h"

@interface SVTPerson()
@property (readwrite) NSMutableArray<SVTPerson *> *mChildren;
@end

NSInteger const kSVTPersonDepthOfVertex = -1;

@implementation SVTPerson
{
@private
    NSString *_identifier;
}

- (instancetype)initWithName:(NSString *)name surname:(NSString *)surname middleName:(NSString *)middleName genderType:(SVTPersonGenderType)genderType identifier:(NSString *)identifier
{
    self = [super init];
    if (self)
    {
        _depthOfVertex = kSVTPersonDepthOfVertex;
        _name = [name copy];
        _surname = [surname copy];
        _middleName = [middleName copy];
        _mChildren = [[NSMutableArray alloc] init];
        _identifier = identifier ? [identifier copy] : [[[NSUUID UUID] UUIDString] mutableCopy];
        _genderType = genderType;
    }
    return self;
}

- (instancetype)initWithName:(NSString *)name surname:(NSString *)surname middleName:(NSString *)middleName genderType:(SVTPersonGenderType)genderType
{
    return [self initWithName:name surname:surname middleName:middleName genderType:genderType identifier:nil];
}



- (void)addChild:(SVTPerson *)child
{
    if (self.genderType == kSVTPersonGenderTypeMale)
    {
        child.father = self;
    }
    else
    {
        child.mother = self;
    }
    [self.mChildren addObject:child];
}

- (void)removeChild:(SVTPerson *)child
{
    if (self.genderType == kSVTPersonGenderTypeMale)
    {
        child.father = nil;
    }
    else
    {
        child.mother = nil;
    }
    [self.mChildren removeObject:child];
}

- (void)removeAllChild
{
    for (SVTPerson *iChild in self.mChildren)
    {
        if (self.genderType == kSVTPersonGenderTypeMale)
        {
            iChild.father = nil;
        }
        else
        {
            iChild.mother = nil;
        }
    }
    [self.mChildren removeAllObjects];
}


#pragma mark - dealloc

- (void)dealloc
{
    [_name release];
    [_surname release];
    [_identifier release];
    [_middleName release];
    [_mChildren release];
    [super dealloc];
}


#pragma mark - getters

- (NSString *)fullName
{
    return [NSString stringWithFormat:@"%@ %@ %@", self.name, self.middleName, self.surname];
}

- (NSArray<SVTPerson *> *)children
{
    return (NSArray *) _mChildren;
}

@end

//
//  SVTPerson.m
//  lab1
//
//  Created by Тимофей Савицкий on 7/30/16.
//  Copyright © 2016 Тимофей Савицкий. All rights reserved.
//

#import "SVTPerson.h"

@interface SVTPerson()
@property (readwrite, copy) NSMutableArray<SVTPerson *> *mChildren;
@end

@implementation SVTPerson
{
@private
    NSUInteger _identifier;
    NSString *_name;
    NSString *_surname;
    NSString *_middleName;
    NSString *_fullName;
    SVTPersonGenderType _genderType;
    SVTPerson *_mother;
    SVTPerson *_father;
    NSMutableArray<SVTPerson *> *_mChildren;
}

- (instancetype)init
{
    return [self initWithName:@"name" surname:@"surname" middleName:@"middle name" genderType:0 identifier:0];
}

- (instancetype)initWithName:(NSString *)name surname:(NSString *)surname middleName:(NSString *)middleName genderType:(SVTPersonGenderType)genderType identifier:(NSUInteger)identifier
{
    self = [super init];
    if (self)
    {
        _name = [name copy];
        _surname = [surname copy];
        _middleName = [middleName copy];
        _mChildren = [[NSMutableArray alloc] init];
        _genderType = genderType;
        _identifier = identifier;
        _mother = 0;
        _father = 0;
    }
    return self;
}

- (instancetype)initWithName:(NSString *)name surname:(NSString *)surname middleName:(NSString *)middleName genderType:(SVTPersonGenderType)genderType
{
    return [self initWithName:name surname:surname middleName:middleName genderType:genderType identifier:0];
}

#pragma mark - add/remove methods

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
    [_middleName release];
    [_mChildren release];
    [super dealloc];
}


#pragma mark - getters

- (NSString *)name
{
    return _name;
}

- (NSString *)surname
{
    return _surname;
}

- (NSString *)middleName
{
    return _middleName;
}

- (NSUInteger)identifier
{
    return _identifier;
}

- (SVTPersonGenderType)genderType
{
    return _genderType;
}

- (SVTPerson *)mother
{
    return _mother;
}

- (SVTPerson *)father
{
    return _father;
}

- (NSString *)fullName
{
    return [NSString stringWithFormat:@"%@ %@ %@", self.name, self.middleName, self.surname];
}

- (NSArray<SVTPerson *> *)children
{
    return (NSArray *) _mChildren;
}

- (NSMutableArray<SVTPerson *> *)mChildren
{
    return _mChildren;
}


#pragma mark - setters

- (void)setName:(NSString *)name
{
    if (_name != name)
    {
        [_name release];
        _name = [name retain];
    }
}

- (void)setSurname:(NSString *)surname
{
    if (_surname != surname)
    {
        [_surname release];
        _surname = [surname retain];
    }
}

- (void)setMiddleName:(NSString *)middleName
{
    if (_middleName != middleName)
    {
        [_middleName release];
        _middleName = [middleName retain];
    }
}

- (void)setMother:(SVTPerson *)mother
{
    if (_mother != mother)
    {
        [_mother release];
        _mother = [mother retain];
    }
}

- (void)setFather:(SVTPerson *)father
{
    if (_father != father)
    {
        [_father release];
        _father = [father retain];
    }
}

- (void)setMChildren:(NSMutableArray<SVTPerson *> *)mChildren
{
    if (_mChildren != mChildren)
    {
        [_mChildren release];
        _mChildren = [mChildren mutableCopy];
    }
}

@end

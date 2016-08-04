//
//  SVTPerson+SVTPersonSerialization.m
//  lab1
//
//  Created by Тимофей Савицкий on 8/3/16.
//  Copyright © 2016 Тимофей Савицкий. All rights reserved.
//

#import "SVTPerson+SVTPersonSerialization.h"

static NSString *const kSVTPersonName = @"Name";
static NSString *const kSVTPersonSurname = @"Surname";
static NSString *const kSVTPersonMiddleName = @"Middle Name";
static NSString *const kSVTPersonGenderType = @"Gender Type";
static NSString *const kSVTPersonIdentifier = @"Identifier";

@implementation SVTPerson(SVTPersonSerialization)

- (instancetype)initWithDictionaryRepresentation:(NSDictionary *)aDictionary
{
    return [self initWithName:aDictionary[kSVTPersonName] surname:aDictionary[kSVTPersonSurname] middleName:aDictionary[kSVTPersonMiddleName] genderType:[aDictionary[kSVTPersonGenderType] integerValue] identifier:aDictionary[kSVTPersonIdentifier]];
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    if (self.name)
    {
        result [kSVTPersonName] = self.name;
    }
    if (self.surname)
    {
        result [kSVTPersonSurname] = self.surname;
    }
    if (self.middleName)
    {
        result [kSVTPersonMiddleName] = self.middleName;
    }
    if (self.genderType == kSVTPersonGenderTypeMale || self.genderType == kSVTPersonGenderTypeFemale)
    {
        result [kSVTPersonGenderType] = [NSNumber numberWithInteger:self.genderType];
    }
    if (self.identifier)
    {
        result [kSVTPersonIdentifier] = self.identifier;
    }
    return result;
}

@end

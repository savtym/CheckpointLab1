//
//  SVTPerson+SVTPersonSerialization.m
//  lab1
//
//  Created by Тимофей Савицкий on 8/3/16.
//  Copyright © 2016 Тимофей Савицкий. All rights reserved.
//

#import "SVTPerson+SVTPersonSerialization.h"

static NSString * const kSVTPersonName = @"name";
static NSString * const kSVTPersonSurname = @"surname";
static NSString * const kSVTPersonMiddleName = @"middle_name";
static NSString * const kSVTPersonGenderType = @"gender_type";
static NSString * const kSVTPersonIdentifier = @"id";
static NSString * const kSVTPersonMotherOfPerson = @"mother";
static NSString * const kSVTPersonFatherOfPerson = @"father";

@implementation SVTPerson(SVTPersonSerialization)

- (instancetype)initWithDictionaryRepresentation:(NSDictionary *)aDictionary
{
    return [self initWithName:aDictionary[kSVTPersonName] surname:aDictionary[kSVTPersonSurname] middleName:aDictionary[kSVTPersonMiddleName] genderType:[aDictionary[kSVTPersonGenderType] integerValue] identifier:[aDictionary[kSVTPersonIdentifier] integerValue]];
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    result[kSVTPersonName] = self.name;
    result[kSVTPersonSurname] = self.surname;
    result[kSVTPersonMiddleName] = self.middleName;
    result[kSVTPersonGenderType] = [NSNumber numberWithInteger:self.genderType];
    result[kSVTPersonIdentifier] = [NSNumber numberWithInteger:self.identifier];
    result[kSVTPersonMotherOfPerson] = self.mother ? [NSNumber numberWithInteger:self.mother.identifier] : [NSNumber numberWithInteger:0];
    result[kSVTPersonFatherOfPerson] = self.father ? [NSNumber numberWithInteger:self.father.identifier] : [NSNumber numberWithInteger:0];
    return result;
}

@end

//
//  SVTTree+SVTTreeSerialization.m
//  lab1
//
//  Created by Тимофей Савицкий on 8/3/16.
//  Copyright © 2016 Тимофей Савицкий. All rights reserved.
//

#import "SVTTree+SVTTreeSerialization.h"
#import "SVTPerson+SVTPersonSerialization.h"
#import "SVTPerson.h"

@implementation SVTTree(SVTTreeSerialization)

static NSString * const kSVTTreeTitle = @"title";
static NSString * const kSVTTreeAuthor = @"author";
static NSString * const kSVTTreeIdentifier = @"id";
static NSString * const kSVTTreeCountPerson = @"count_person";

- (instancetype)initWithDictionaryRepresentation:(NSDictionary *)aDictionary
{
    return [self initWithTitle:aDictionary[kSVTTreeTitle] author:aDictionary[kSVTTreeAuthor] persons:nil identifier:[aDictionary[kSVTTreeIdentifier] integerValue] numberOfPersons:[aDictionary[kSVTTreeCountPerson] integerValue]];
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    result[kSVTTreeTitle] = self.title;
    result[kSVTTreeAuthor] = self.author;
    result[kSVTTreeCountPerson] = [NSNumber numberWithInteger:self.persons.count];
    return result;
}

@end

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

static NSString *const kSVTTreeTitle = @"Title";
static NSString *const kSVTTreeAuthor = @"Author";
static NSString *const kSVTTreePerson = @"Person";
static NSString *const kSVTTreePersons = @"Persons";
static NSString *const kSVTTreeMotherOfPerson = @"Mother";
static NSString *const kSVTTreeFatherOfPerson = @"Father";

- (instancetype)initWithDictionaryRepresentation:(NSDictionary *)aDictionary
{
    NSMutableArray<SVTPerson *> *persons = [[[NSMutableArray alloc] init] autorelease];
    for (NSDictionary *person in aDictionary[kSVTTreePersons])
    {
        [persons addObject:[[[SVTPerson alloc] initWithDictionaryRepresentation:person[kSVTTreePerson]] autorelease]];
    }
    NSUInteger index = 0;
    for (NSDictionary *person in aDictionary[kSVTTreePersons])
    {
        if (![person[kSVTTreeFatherOfPerson] isEqualToString:@""])
        {
            for (SVTPerson *father in persons)
            {
                if ([father.identifier isEqualToString:person[kSVTTreeFatherOfPerson]])
                {
                    [father addChild:persons[index]];
                }
            }
        }
        if (![person[kSVTTreeMotherOfPerson] isEqualToString:@""])
        {
            for (SVTPerson *mother in persons)
            {
                if ([mother.identifier isEqualToString:person[kSVTTreeMotherOfPerson]])
                {
                    [mother addChild:persons[index]];
                }
            }
        }
        index = index + 1;
    }
    
    return [self initWithTitle:aDictionary[kSVTTreeTitle] author:aDictionary[kSVTTreeTitle] persons:persons];
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    if (self.title)
    {
        result [kSVTTreeTitle] = self.title;
    }
    if (self.author)
    {
        result [kSVTTreeAuthor] = self.author;
    }
    if (self.persons)
    {
        NSMutableArray *persons = [[NSMutableArray alloc] init];
        for (SVTPerson *iPerson in self.persons)
        {
            NSMutableDictionary *person = [[NSMutableDictionary alloc] init];
            person[kSVTTreePerson] = [iPerson dictionaryRepresentation];
            person[kSVTTreeMotherOfPerson] = iPerson.mother ? iPerson.mother.identifier : @"";
            person[kSVTTreeFatherOfPerson] = iPerson.father ? iPerson.father.identifier : @"";
            [persons addObject:person];
            [person release];
        }
        result [kSVTTreePersons] = persons;
        [persons release];
    }
    return result;
}

@end

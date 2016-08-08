//
//  SVTPerson+SVTPersonSerialization.h
//  lab1
//
//  Created by Тимофей Савицкий on 8/3/16.
//  Copyright © 2016 Тимофей Савицкий. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SVTPerson.h"

@interface SVTPerson(SVTPersonSerialization)

- (instancetype)initWithDictionaryRepresentation:(NSDictionary *)aDictionary;
- (NSDictionary *)dictionaryRepresentation;

@end

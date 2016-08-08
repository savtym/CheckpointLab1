//
//  SVTTree+SVTTreeSerialization.h
//  lab1
//
//  Created by Тимофей Савицкий on 8/3/16.
//  Copyright © 2016 Тимофей Савицкий. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SVTTree.h"

@interface SVTTree(SVTTreeSerialization)

- (instancetype)initWithDictionaryRepresentation:(NSDictionary *)aDictionary;
- (NSDictionary *)dictionaryRepresentation;

@end

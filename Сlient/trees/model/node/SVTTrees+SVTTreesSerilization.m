//
//  SVTTrees+SVTTreesSerilization.m
//  lab1
//
//  Created by Тимофей Савицкий on 8/3/16.
//  Copyright © 2016 Тимофей Савицкий. All rights reserved.
//

#import "SVTTrees+SVTTreesSerilization.h"
#import "SVTTree+SVTTreeSerialization.h"

static NSString *const kSVTTreesTree = @"Tree";

@implementation SVTTrees(SVTTreesSerilization)

- (instancetype)initWithDictionaryRepresentation:(NSDictionary *)aDictionary
{
    NSMutableArray *trees = [[[NSMutableArray alloc] init] autorelease];
    for (NSDictionary *tree in aDictionary[kSVTTreesTree]) {
        [trees addObject:[[[SVTTree alloc] initWithDictionaryRepresentation:tree] autorelease]];
    }
    return [self initWithTrees:trees];
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    if (self.trees)
    {
        NSMutableArray *trees = [[NSMutableArray alloc] init];
        for (SVTTree *tree in self.trees)
        {
            [trees addObject:[tree dictionaryRepresentation]];
        }
        result [kSVTTreesTree] = trees;
        [trees release];
    }
    return result;
}

@end

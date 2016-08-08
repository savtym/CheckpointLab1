//
//  SVTTrees.m
//  lab1
//
//  Created by Тимофей Савицкий on 8/3/16.
//  Copyright © 2016 Тимофей Савицкий. All rights reserved.
//

#import "SVTTrees.h"
#import "SVTTree.h"
#import "SVTTrees+SVTTreesSerilization.h"

@interface SVTTrees()
@property (readwrite, copy) NSMutableArray<SVTTree *> *mTrees;
@end

@implementation SVTTrees
{
@private
    NSMutableArray<SVTTree *> *_mTrees;
}

- (instancetype)init
{
    return [self initWithTrees:nil];
}

- (instancetype)initWithTrees:(NSArray *)trees
{
    self = [super init];
    if (self)
    {
        _mTrees = trees ? [trees mutableCopy] : [[NSMutableArray alloc] init];
    }
    return self;
}

- (instancetype)initWithFilePath:(NSString *)aPath
{
    NSError *error = nil;
    NSString *stringFromFileAtPath = [[NSString alloc] initWithContentsOfFile:aPath encoding:NSUTF8StringEncoding error:&error];
    if(!stringFromFileAtPath)
    {
        NSLog(@"initWithFilePath: error: %@", error.localizedDescription);
        stringFromFileAtPath = @"{}";
    }
    NSData *data = [stringFromFileAtPath dataUsingEncoding:NSUTF8StringEncoding];
    [stringFromFileAtPath release];
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    return [self initWithDictionaryRepresentation:dictionary];
}

- (void)writeToFilePath:(NSString *)aPath
{
    NSError *error = nil;
    NSDictionary *dict = [self dictionaryRepresentation];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    [jsonData writeToFile:aPath atomically:NO];
}


#pragma mark - add/remove tree

- (void)addTree:(SVTTree *)tree
{
    [self.mTrees addObject:tree];
}

- (void)removeTree:(SVTTree *)tree
{
    [self.mTrees removeObject:tree];
}


#pragma mark - getters

- (NSArray<SVTTree *> *)trees
{
    return (NSArray *) _mTrees;
}

- (NSMutableArray<SVTTree *> *)mTrees
{
    return _mTrees;
}


#pragma mark - setters

- (void)setMTrees:(NSMutableArray<SVTTree *> *)mTrees
{
    if (_mTrees != mTrees)
    {
        [_mTrees release];
        _mTrees = [mTrees retain];
    }
}


#pragma mark - dealloc

- (void)dealloc
{
    [_mTrees release];
    [super dealloc];
}

@end

//
//  SVTAppWindowTree.m
//  lab1
//
//  Created by Тимофей Савицкий on 7/30/16.
//  Copyright © 2016 Тимофей Савицкий. All rights reserved.
//

#import "SVTAppWindowTree.h"
#import "SVTViewTreeController.h"
#import "SVTTree.h"

@interface SVTAppWindowTree()
@end

@implementation SVTAppWindowTree
{
@private
    SVTViewTreeController *_viewTree;
}

- (instancetype)initWithTree:(SVTTree *)tree
{
    self = [super initWithWindowNibName:@"SVTAppWindowTree"];
    if (self)
    {
        _viewTree = [[SVTViewTreeController alloc] initWithTree:tree];
        [self.window.contentView addSubview:_viewTree.view];
    }
    return self;
}


#pragma mark - dealloc

- (void)dealloc
{
    [_viewTree release];
    [super dealloc];
}


#pragma mark - getters

- (SVTViewTreeController *)viewTree
{
    return _viewTree;
}


#pragma mark - setters

- (void)setViewTree:(SVTViewTreeController *)viewTree
{
    if (_viewTree != viewTree)
    {
        [_viewTree release];
        _viewTree = [viewTree retain];
    }
}

@end

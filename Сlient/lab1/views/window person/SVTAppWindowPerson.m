//
//  SVTAppWindowPerson.m
//  lab1
//
//  Created by Тимофей Савицкий on 7/31/16.
//  Copyright © 2016 Тимофей Савицкий. All rights reserved.
//

#import "SVTAppWindowPerson.h"
#import "SVTViewPersonController.h"
#import "SVTPerson.h"
#import "SVTTree.h"

@implementation SVTAppWindowPerson
{
@private
    SVTViewPersonController *_viewPerson;
}

- (instancetype)initWithPerson:(SVTPerson *)person tree:(SVTTree *)tree
{
    self = [super initWithWindowNibName:@"SVTAppWindowPerson"];
    if (self)
    {
        _viewPerson = [[SVTViewPersonController alloc] initWithPerson:person tree:tree];
        [self.window.contentView addSubview:_viewPerson.view];
    }
    return self;
}


#pragma mark - dealloc

- (void)dealloc
{
    [_viewPerson release];
    [super dealloc];
}

@end

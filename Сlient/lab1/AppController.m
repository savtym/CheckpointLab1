//
//  AppDelegate.m
//  lab1
//
//  Created by Тимофей Савицкий on 7/30/16.
//  Copyright © 2016 Тимофей Савицкий. All rights reserved.
//

#import "AppController.h"
#import "SVTViewController.h"
#import "SVTURLSessionOfServer.h"
#import "SVTTrees.h"

@interface AppController() <NSWindowDelegate>
@property (nonatomic, assign) IBOutlet NSWindow *window;
@property (retain, readwrite) SVTViewController *view;
@property (retain, readwrite) SVTTrees *model;
@end

NSString * const kSVTAppControllerPath = @"history.json";

@implementation AppController
{
@private
    NSWindow *_window;
    SVTViewController *_view;
    SVTTrees *_model;
};

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    SVTURLSessionOfServer *url = [[[SVTURLSessionOfServer alloc] init] autorelease];
    
    self.model = [url updateTreesFromServer];
    self.view = [[[SVTViewController alloc] initWithModel:self.model] autorelease];
    [self.window.contentView addSubview:self.view.view];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return YES;
}


#pragma mark - dealloc

- (void)dealloc
{
    [_view release];
    [_model release];
    [super dealloc];
}


#pragma mark - getters

- (SVTViewController *)view
{
    return _view;
}

- (SVTTrees *)model
{
    return _model;
}

- (NSWindow *)window
{
    return _window;
}


#pragma mark - setters

- (void)setView:(SVTViewController *)view
{
    if (_view != view)
    {
        [_view release];
        _view = [view retain];
    }
}

- (void)setModel:(SVTTrees *)model
{
    if (_model != model)
    {
        [_model release];
        _model = [model retain];
    }
}

@end

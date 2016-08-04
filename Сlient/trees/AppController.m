//
//  AppDelegate.m
//  lab1
//
//  Created by Тимофей Савицкий on 7/30/16.
//  Copyright © 2016 Тимофей Савицкий. All rights reserved.
//

#import "AppController.h"
#import "SVTViewController.h"
#import "SVTTrees.h"

@interface AppController() <NSWindowDelegate>
@property (nonatomic, nonatomic, assign) IBOutlet NSWindow *window;
@property (retain, readwrite) SVTViewController *view;
@property (retain, readwrite) SVTTrees *model;
@end

NSString *const kSVTAppControllerPath = @"history.json";

@implementation AppController
{
@private
    NSWindow *_window;
    SVTViewController *_view;
    SVTTrees *_model;
};

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    SVTTrees *model = [[SVTTrees alloc] initWithFilePath:kSVTAppControllerPath];
    SVTViewController *viewTrees = [[SVTViewController alloc] initWithModel:model];
    self.view = viewTrees;
    self.model = model;
    [viewTrees release];
    [model release];
    [self.window.contentView addSubview:viewTrees.view];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
    [self.model writeToFilePath:kSVTAppControllerPath];
}


- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return YES;
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


#pragma mark - dealloc

- (void)dealloc
{
    [_view release];
    [_model release];
    [super dealloc];
}

@end

//
//  SVTViewTreesController.m
//  lab1
//
//  Created by Тимофей Савицкий on 7/30/16.
//  Copyright © 2016 Тимофей Савицкий. All rights reserved.
//

#import "SVTViewController.h"
#import "SVTAppWindowTree.h"
#import "SVTTrees.h"
#import "SVTTree.h"

@interface SVTViewController() <NSWindowDelegate, NSTableViewDataSource, NSTableViewDelegate>
@property (assign) IBOutlet NSButton *buttonRemoveTree;
@property (assign) IBOutlet NSTableView *tableView;
@property (readwrite, copy) NSMutableArray *openWindowTree;
@end

static NSString *const kSVTViewControllerTableColumnTitle = @"Title";
static NSString *const kSVTViewControllerTableColumnAuthor = @"Author";
static NSString *const kSVTViewControllerTableColumnNumberOfPeople = @"NumberOfPeople";

NSString *const kSVTViewControllerDidChangeTree = @"kSVTViewControllerDidChangeTree";

@implementation SVTViewController
{
@private
	SVTTrees *_trees;
	NSButton *_buttonRemoveTree;
	NSTableView *_tableView;
	NSMutableArray *_openWindowTree;
}

- (instancetype)init
{
    return [self initWithModel:nil];
}

- (instancetype)initWithModel:(SVTTrees *)model
{
	self = [super init];
	if (self)
	{
		_trees = model ? [model retain] : [[SVTTrees alloc] init];
		_openWindowTree = [[NSMutableArray alloc] init];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewControllerDidChangeTree:) name:kSVTViewControllerDidChangeTree object:nil];
	}
	return self;
}


#pragma mark - table

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	[self.tableView setDoubleAction:@selector(doubleClickToCellVisitor:)];
	NSTableCellView *result = nil;
	NSString *columnIdentifier = tableColumn.identifier;
	if ([columnIdentifier isEqualToString:kSVTViewControllerTableColumnTitle])
	{
		result = [tableView makeViewWithIdentifier:kSVTViewControllerTableColumnTitle owner:self];
		if ([[self.trees.trees objectAtIndex:row] title])
		{
			result.textField.stringValue = [[self.trees.trees objectAtIndex:row] title];
		}
	}
	else if ([columnIdentifier isEqualToString:kSVTViewControllerTableColumnAuthor])
	{
		result = [tableView makeViewWithIdentifier:kSVTViewControllerTableColumnAuthor owner:self];
		if ([[self.trees.trees objectAtIndex:row] author])
		{
			result.textField.stringValue = [[self.trees.trees objectAtIndex:row] author];
		}
	}
	else if ([columnIdentifier isEqualToString:kSVTViewControllerTableColumnNumberOfPeople])
	{
		result = [tableView makeViewWithIdentifier:kSVTViewControllerTableColumnNumberOfPeople owner:self];
		result.textField.stringValue = [NSString stringWithFormat:@"%zd", self.trees.trees[row].persons.count];
		
	}
	return result;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
	return self.trees.trees.count;
}

- (IBAction)clickRowTable:(NSTableView *)sender
{
	self.buttonRemoveTree.enabled = (sender.selectedRow > -1);
}


- (void)doubleClickToCellVisitor:(NSTableView *)tableView
{
	NSUInteger row = tableView.selectedRow;
	SVTAppWindowTree *windowTree = [[SVTAppWindowTree alloc] initWithTree:self.trees.trees[row]];
	windowTree.window.delegate = self;
	[self.openWindowTree addObject:windowTree];
	[windowTree release];
}



#pragma mark - buttons

- (IBAction)buttonAddTree:(NSButton *)sender
{
	[self.trees addTree:[[[SVTTree alloc] init] autorelease]];
	NSTableView *tableView = self.tableView;
	[tableView beginUpdates];
	[tableView insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:self.trees.trees.count] withAnimation:NSTableViewAnimationEffectFade];
	[tableView endUpdates];
}


- (IBAction)buttonRemoveTree:(NSButton *)sender
{
    
}



#pragma mark - notification

- (void)windowWillClose:(NSNotification *)notification
{
	if ([notification.name isEqualToString:kSVTViewControllerDidChangeTree])
	{
		SVTAppWindowTree *windowTree = [notification.object windowController];
		[self.openWindowTree removeObject:windowTree];
	}
}

- (void)viewControllerDidChangeTree:(NSNotification *)notification
{
	if ([notification.name isEqualToString:kSVTViewControllerDidChangeTree])
	{
		SVTTree *tree = notification.object;
		NSUInteger index = [self.trees.trees indexOfObject:tree];
		[self.tableView reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:index] columnIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0,3)]];
	}
}







#pragma mark - dealloc

- (void)dealloc
{
	[_openWindowTree release];
	[_trees release];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}


#pragma mark - getters

- (SVTTrees *)trees
{
	return _trees;
}

- (NSButton *)buttonRemoveTree
{
	return _buttonRemoveTree;
}

- (NSTableView *)tableView
{
	return _tableView;
}

- (NSMutableArray *)openWindowTree
{
	return _openWindowTree;
}


#pragma mark - setters

- (void)setButtonRemoveTree:(NSButton *)buttonRemoveTree
{
	_buttonRemoveTree = buttonRemoveTree;
}

- (void)setTableView:(NSTableView *)tableView
{
	_tableView = tableView;
}

- (void)setOpenWindowTree:(NSMutableArray *)openWindowTree
{
	if (_openWindowTree != openWindowTree)
	{
		[_openWindowTree release];
		_openWindowTree = [openWindowTree retain];
	}
}


@end

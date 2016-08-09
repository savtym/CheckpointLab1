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
#import "SVTURLSessionOfServer.h"

@interface SVTViewController() <NSWindowDelegate, NSTableViewDataSource, NSTableViewDelegate, NSTextFieldDelegate>
@property (assign) IBOutlet NSTextField *textFieldSearch;
@property (assign) IBOutlet NSButton *buttonRemoveTree;
@property (assign) IBOutlet NSTableView *tableView;
@property (readwrite, copy) NSMutableArray *openWindowTree;
@property (readwrite, copy) NSMutableArray<NSNumber *> *openWindowTreeID;
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
	NSMutableArray<NSNumber *> *_openWindowTreeID;
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
		_openWindowTreeID = [[NSMutableArray alloc] init];
		self.view.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewControllerDidChangeTree:) name:kSVTViewControllerDidChangeTree object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowWillClose:) name:NSWindowWillCloseNotification object:self.view.window];
	}
	return self;
}


#pragma mark - table

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	[self.tableView setDoubleAction:@selector(doubleClickToCellVisitor:)];
	NSTableCellView *result = nil;
	NSString *columnIdentifier = tableColumn.identifier;
	__block NSUInteger indexArray = 0;
	[self.trees.trees enumerateObjectsUsingBlock:^(SVTTree *tree, NSUInteger index, BOOL *stop)
	{
		 if (tree.showTreeOnTheTable)
		 {
			 if (row == indexArray)
			 {
				 indexArray = index;
				 *stop = YES;
			 }
			 indexArray = indexArray + 1;
		 }
	}];
	indexArray = indexArray - 1;
	SVTTree *tree = [self.trees.trees objectAtIndex:indexArray];
	if (tree.showTreeOnTheTable)
	{
		if ([columnIdentifier isEqualToString:kSVTViewControllerTableColumnTitle])
		{
			result = [tableView makeViewWithIdentifier:kSVTViewControllerTableColumnTitle owner:self];
			if (tree.title)
			{
				result.textField.stringValue = tree.title;
			}
		}
		else if ([columnIdentifier isEqualToString:kSVTViewControllerTableColumnAuthor])
		{
			result = [tableView makeViewWithIdentifier:kSVTViewControllerTableColumnAuthor owner:self];
			if (tree.author)
			{
				result.textField.stringValue = tree.author;
			}
		}
		else if ([columnIdentifier isEqualToString:kSVTViewControllerTableColumnNumberOfPeople])
		{
			result = [tableView makeViewWithIdentifier:kSVTViewControllerTableColumnNumberOfPeople owner:self];
			result.textField.stringValue = [NSString stringWithFormat:@"%zd", tree.numberOfPersons];
			
		}
	}
	return result;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
	NSUInteger countShowOnTheTable = 0;
	for (SVTTree *tree in self.trees.trees)
	{
		if (tree.showTreeOnTheTable)
		{
			countShowOnTheTable = countShowOnTheTable + 1;
		}
	}
	return countShowOnTheTable;
}

- (IBAction)clickRowTable:(NSTableView *)sender
{
	self.buttonRemoveTree.enabled = (sender.selectedRow > -1 && self.openWindowTree.count == 0);
}

- (void)doubleClickToCellVisitor:(NSTableView *)tableView
{
	NSUInteger row = tableView.selectedRow;
	if (row != -1)
	{
		__block NSUInteger indexArray = 0;
		[self.trees.trees enumerateObjectsUsingBlock:^(SVTTree *tree, NSUInteger index, BOOL *stop)
		 {
			 if (tree.showTreeOnTheTable)
			 {
				 if (row == indexArray)
				 {
					 indexArray = index;
					 *stop = YES;
				 }
				 indexArray = indexArray + 1;
			 }
		 }];
		indexArray = indexArray - 1;
		SVTTree *tree = self.trees.trees[indexArray];
		BOOL result = YES;
		for (NSNumber *openWindowTreeID in self.openWindowTreeID)
		{
			if ([openWindowTreeID integerValue] == tree.identifier)
			{
				result = NO;
			}
		}
		if (result)
		{
			if (!tree.persons.count)
			{
				SVTURLSessionOfServer *url = [[SVTURLSessionOfServer alloc] init];
				[url updateTreeFromServerID:tree.identifier tree:tree];
				[url release];
			}
			SVTAppWindowTree *windowTree = [[SVTAppWindowTree alloc] initWithTree:tree];
			windowTree.window.delegate = self;
			[self.openWindowTree addObject:windowTree];
			[self.openWindowTreeID addObject:[NSNumber numberWithUnsignedInteger:tree.identifier]];
			[windowTree release];
		}
	}
}



#pragma mark - buttons

- (IBAction)buttonAddTree:(NSButton *)sender
{
	SVTURLSessionOfServer *url = [[SVTURLSessionOfServer alloc] init];
	[self.trees addTree:[url addTreeInServer]];
	[url release];
	NSTableView *tableView = self.tableView;
	[tableView beginUpdates];
	[tableView insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:self.trees.trees.count] withAnimation:NSTableViewAnimationEffectFade];
	[tableView endUpdates];
}

- (IBAction)buttonRemoveTree:(NSButton *)sender
{
	NSUInteger row = self.tableView.selectedRow;
	SVTTree *tree = [self.trees.trees objectAtIndex:row];
	SVTURLSessionOfServer *url = [[SVTURLSessionOfServer alloc] init];
	[url removeTreeFromServer:tree.identifier];
	[url release];
	[self.trees removeTree:tree];
	NSTableView *tableView = self.tableView;
	[tableView beginUpdates];
	[tableView removeRowsAtIndexes:[NSIndexSet indexSetWithIndex:self.trees.trees.count] withAnimation:NSTableViewAnimationSlideUp];
	[tableView endUpdates];
}


#pragma mark - textField

- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor
{
	SVTURLSessionOfServer *url = [[SVTURLSessionOfServer alloc] init];
	[url searchByTitleOfTreesInServer:control.stringValue trees:self.trees];
	[url release];
	[self.tableView reloadData];
	return YES;
}


#pragma mark - notification

- (void)windowWillClose:(NSNotification *)notification
{
	if ([notification.name isEqualToString:NSWindowWillCloseNotification])
	{
		SVTAppWindowTree *windowTree = [notification.object windowController];
		[self.openWindowTreeID removeObject:windowTree];
		[self.openWindowTree removeObject:windowTree];
	}
}

- (void)viewControllerDidChangeTree:(NSNotification *)notification
{
	if ([notification.name isEqualToString:kSVTViewControllerDidChangeTree])
	{
		SVTTree *tree = notification.object;
		SVTURLSessionOfServer *url = [[SVTURLSessionOfServer alloc] init];
		[url putIDTreeInServer:tree];
		[url release];
		[self.tableView reloadData];
	}
}


#pragma mark - dealloc

- (void)dealloc
{
	[_openWindowTree release];
	[_openWindowTreeID release];
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

- (NSMutableArray<NSNumber *> *)openWindowTreeID
{
	return _openWindowTreeID;
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
		_openWindowTree = [openWindowTree mutableCopy];
	}
}

- (void)setOpenWindowTreeID:(NSMutableArray<NSNumber *> *)openWindowTreeID
{
	if (_openWindowTreeID == openWindowTreeID)
	{
		[_openWindowTreeID release];
		_openWindowTreeID = [openWindowTreeID mutableCopy];
	}
}


@end

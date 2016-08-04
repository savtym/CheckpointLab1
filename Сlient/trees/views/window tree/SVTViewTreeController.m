//
//  SVTViewWindowTree.m
//  lab1
//
//  Created by Тимофей Савицкий on 7/31/16.
//  Copyright © 2016 Тимофей Савицкий. All rights reserved.
//

#import "SVTViewTreeController.h"
#import "SVTAppWindowPerson.h"
#import "SVTViewController.h"
#import "SVTPerson.h"
#import "SVTTree.h"

@interface SVTViewTreeController() <NSTableViewDelegate, NSTableViewDataSource, NSWindowDelegate, NSTextFieldDelegate>
@property (assign) IBOutlet NSButton *buttonRemovePeople;
@property (assign) IBOutlet NSTextField *textFieldTitle;
@property (assign) IBOutlet NSTextField *textFieldAuthor;
@property (nonatomic, assign) IBOutlet NSTableView *tableView;
@property (retain, readwrite) NSMutableArray<SVTAppWindowPerson *> *openWindowPerson;
@property (readwrite) SVTTree *tree;
@end

static NSString *const kSVTViewTreeControllerTextFieldAuthor = @"Author";
static NSString *const kSVTViewTreeControllerTextFieldTitle = @"Title";

static NSString *const kSVTViewTreeControllerTableColumnFullName = @"FullName";
static NSString *const kSVTViewTreeControllerTableColumnMother = @"Mother";
static NSString *const kSVTViewTreeControllerTableColumnFather = @"Father";
static NSString *const kSVTViewTreeControllerTableColumnChildren = @"Children";
static NSString *const kSVTViewTreeControllerTableCellOfNone = @"None";

NSString *const kSVTViewTreeControllerDidChangePerson = @"kSVTViewTreeControllerDidChangePerson";
static NSString *const kSVTViewTreeControllerClosedWindow = @"kSVTViewTreeControllerClosedWindow";


@implementation SVTViewTreeController

- (instancetype)initWithTree:(SVTTree *)tree
{
    self = [super initWithNibName:@"SVTViewTreeController" bundle:nil];
    if (self)
    {
		_tree = [tree retain];
		_openWindowPerson = [[NSMutableArray alloc] init];
		self.view.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
		[self changeTree];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewPersonControllerDidChangePerson:) name:kSVTViewTreeControllerDidChangePerson object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowWillClose:) name:kSVTViewTreeControllerClosedWindow object:self.view.window];
    }
    return self;
}


#pragma mark - table

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    [self.tableView setDoubleAction:@selector(doubleClickToCellVisitor:)];
    NSTableCellView *result = nil;
	NSString *columnIdentifier = tableColumn.identifier;
	if ([columnIdentifier isEqualToString:kSVTViewTreeControllerTableColumnFullName])
	{
		result = [tableView makeViewWithIdentifier:kSVTViewTreeControllerTableColumnFullName owner:self];
		if (self.tree.persons[row].fullName)
		{
			result.textField.stringValue = self.tree.persons[row].fullName;
		}
	}
	else if ([columnIdentifier isEqualToString:kSVTViewTreeControllerTableColumnMother])
	{
		result = [tableView makeViewWithIdentifier:kSVTViewTreeControllerTableColumnMother owner:self];
		if (self.tree.persons[row].mother.fullName)
		{
			result.textField.stringValue = self.tree.persons[row].mother.fullName;
		}
		else
		{
			result.textField.stringValue = kSVTViewTreeControllerTableCellOfNone;
		}
	}
	else if ([columnIdentifier isEqualToString:kSVTViewTreeControllerTableColumnFather])
	{
		result = [tableView makeViewWithIdentifier:kSVTViewTreeControllerTableColumnFather owner:self];
		if (self.tree.persons[row].father.fullName)
		{
			result.textField.stringValue = self.tree.persons[row].father.fullName;
		}
		else
		{
			result.textField.stringValue = kSVTViewTreeControllerTableCellOfNone;
		}
	}
	else if ([columnIdentifier isEqualToString:kSVTViewTreeControllerTableColumnChildren])
	{
		result = [tableView makeViewWithIdentifier:kSVTViewTreeControllerTableColumnChildren owner:self];
		NSArray *children = self.tree.persons[row].children;
		if (children)
		{
			NSMutableString *listOfChildren = [[NSMutableString alloc] init];
			for (SVTPerson *iChild in children)
			{
				[listOfChildren appendString:[NSString stringWithFormat:@"%@, ", iChild.fullName]];
			}
			result.textField.stringValue = listOfChildren;
			[listOfChildren release];
		}
	}
    return result;
}

- (IBAction)clickRowTable:(NSTableView *)sender
{
	self.buttonRemovePeople.enabled = (sender.selectedRow > -1 && self.openWindowPerson.count == 0);
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return self.tree.persons.count;
}

- (void)doubleClickToCellVisitor:(NSTableView *)tableView
{
	NSUInteger row = tableView.selectedRow;
	SVTAppWindowPerson *windowPerson = [[SVTAppWindowPerson alloc] initWithPerson:self.tree.persons[row] tree:self.tree];
    windowPerson.window.delegate = self;
    [self.openWindowPerson addObject:windowPerson];
    [windowPerson release];
}


#pragma mark - textFields

- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor
{
	NSString *textFieldIdentifier = control.identifier;
	if ([textFieldIdentifier isEqualToString:kSVTViewTreeControllerTextFieldAuthor])
	{
		self.tree.author = control.stringValue;
	}
	else if ([textFieldIdentifier isEqualToString:kSVTViewTreeControllerTextFieldTitle])
	{
		self.tree.title = control.stringValue;
	}
	[[NSNotificationCenter defaultCenter] postNotificationName:kSVTViewControllerDidChangeTree object:self.tree];
	return YES;
}


#pragma mark - buttons

- (IBAction)buttonAddPeople:(NSButton *)sender
{
	[self.tree addPerson:[[[SVTPerson alloc] initWithName:@"name" surname:@"surname" middleName:@"surname" genderType:kSVTPersonGenderTypeMale] autorelease]];
	NSTableView *tableView = self.tableView;
	[tableView beginUpdates];
	[tableView insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:(self.tree.persons.count - 1)] withAnimation:NSTableViewAnimationEffectFade];
	[tableView endUpdates];
	[[NSNotificationCenter defaultCenter] postNotificationName:kSVTViewControllerDidChangeTree object:self.tree];

	SVTAppWindowPerson *windowPerson = [[SVTAppWindowPerson alloc] initWithPerson:self.tree.persons.lastObject tree:self.tree];
	windowPerson.window.delegate = self;
	[self.openWindowPerson addObject:windowPerson];
	[windowPerson release];
}

- (IBAction)buttonRemovePeople:(NSButton *)sender
{
	NSUInteger index = self.tableView.selectedRow;
	SVTPerson *person = [self.tree.persons objectAtIndex:index];
	person.father = nil;
	person.mother = nil;
	for (SVTPerson *iChild in person.children)
	{
		if (person.genderType == kSVTPersonGenderTypeMale)
		{
			iChild.father = nil;
		}
		else
		{
			iChild.mother = nil;
		}
	}
	[self.tree removePerson:person];
	[self.tableView reloadData];
	[[NSNotificationCenter defaultCenter] postNotificationName:kSVTViewControllerDidChangeTree object:self.tree];
}


#pragma mark - tree

- (void)changeTree
{
	for (SVTPerson *person in self.tree.persons)
	{
		person.depthOfVertex = kSVTPersonDepthOfVertex;
	}
	for (SVTPerson *iPerson in self.tree.persons)
	{
		if ((!iPerson.father && !iPerson.mother))
		{//(iPerson.father || iPerson.mother || iPerson.children.count != 0)
			[self dfs:iPerson depthOfVertex:0];
		}
	}
	for (SVTPerson *person in self.tree.persons)
	{
		NSLog(@"depth: %zd",person.depthOfVertex);
	}
}

- (void)dfs:(SVTPerson *)vertex depthOfVertex:(NSInteger)depthOfVertex
{
	NSLog(@"1");
	if (vertex.depthOfVertex != kSVTPersonDepthOfVertex || depthOfVertex == kSVTPersonDepthOfVertex)
	{
		return;
	}
	vertex.depthOfVertex = depthOfVertex;
	if (vertex.father)
	{
		[self dfs:vertex.father depthOfVertex:(depthOfVertex - 1)];
	}
	if (vertex.mother)
	{
		[self dfs:vertex.mother depthOfVertex:(depthOfVertex - 1)];
	}
	for (SVTPerson *child in vertex.children)
	{
		[self dfs:child depthOfVertex:(depthOfVertex + 1)];
	}
}


#pragma mark - notification

- (void)windowWillClose:(NSNotification *)notification
{
	if ([notification.name isEqualToString:kSVTViewTreeControllerDidChangePerson])
	{
		SVTAppWindowPerson *windowPerson = [notification.object windowController];
		[self.openWindowPerson removeObject:windowPerson];
	}
	else if ([notification.name isEqualToString:kSVTViewTreeControllerClosedWindow])
	{
		[self.openWindowPerson removeAllObjects];
	}
}

- (void)viewPersonControllerDidChangePerson:(NSNotification *)notification
{
	if ([notification.name isEqualToString:kSVTViewTreeControllerDidChangePerson])
	{
		[self.tableView reloadData];
		SVTPerson *person = notification.object;
		NSUInteger index = [self.tree.persons indexOfObject:person];
		
		[self changeTree];
		NSLog(@"index: %zd\n\n", index);
	}
}











#pragma mark - dealloc

- (void)dealloc
{
	[_tree release];
	[_openWindowPerson release];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}



@end

//
//  SVTViewWindowTree.m
//  lab1
//
//  Created by Тимофей Савицкий on 7/31/16.
//  Copyright © 2016 Тимофей Савицкий. All rights reserved.
//

#import "SVTViewTreeController.h"
#import "SVTViewDrawTree.h"
#import "SVTAppWindowPerson.h"
#import "SVTViewController.h"
#import "SVTPerson.h"
#import "SVTTree.h"
#import "SVTURLSessionOfServer.h"

@interface SVTViewTreeController() <NSTableViewDelegate, NSTableViewDataSource, NSWindowDelegate, NSTextFieldDelegate>
@property (assign) IBOutlet NSButton *buttonRemovePeople;
@property (assign) IBOutlet NSTextField *textFieldTitle;
@property (assign) IBOutlet NSTextField *textFieldAuthor;
@property (nonatomic, assign) IBOutlet NSTableView *tableView;
@property (assign) IBOutlet SVTViewDrawTree *scrollViewDrawTree;
@property (assign) IBOutlet NSScrollView *scrollView;
@property (readwrite, copy) NSMutableArray<SVTAppWindowPerson *> *openWindowPerson;
@property (readwrite, retain) SVTTree *tree;
@end

static NSString *const kSVTViewTreeControllerTextFieldAuthor = @"Author";
static NSString *const kSVTViewTreeControllerTextFieldTitle = @"Title";

static NSString *const kSVTViewTreeControllerTableColumnFullName = @"FullName";
static NSString *const kSVTViewTreeControllerTableColumnMother = @"Mother";
static NSString *const kSVTViewTreeControllerTableColumnFather = @"Father";
static NSString *const kSVTViewTreeControllerTableColumnChildren = @"Children";
static NSString *const kSVTViewTreeControllerTableCellOfNone = @"None";

NSString *const kSVTViewTreeControllerDidChangePerson = @"kSVTViewTreeControllerDidChangePerson";


@implementation SVTViewTreeController
{
@private
	NSButton *_buttonRemovePeople;
	NSTextField *_textFieldTitle;
	NSTextField *_textFieldAuthor;
	NSTableView *_tableView;
	NSMutableArray<SVTAppWindowPerson *> *_openWindowPerson;
}

- (instancetype)initWithTree:(SVTTree *)tree
{
    self = [super initWithNibName:@"SVTViewTreeController" bundle:nil];
    if (self)
    {
		_tree = [tree retain];
		_openWindowPerson = [[NSMutableArray alloc] init];
		self.view.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewPersonControllerDidChangePerson:) name:kSVTViewTreeControllerDidChangePerson object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowWillClose:) name:NSWindowWillCloseNotification object:self.view.window];
    }
    return self;
}

- (void)awakeFromNib
{
	self.textFieldTitle.stringValue = self.tree.title;
	self.textFieldAuthor.stringValue = self.tree.author;
	self.scrollViewDrawTree.tree = self.tree;
	[self.scrollViewDrawTree displayIfNeeded];
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
	self.tree.indexClickRowOfTable = (sender.selectedRow > -1) ? self.tree.persons[sender.selectedRow].identifier : -1;
	self.scrollViewDrawTree.needsDisplay = YES;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return self.tree.persons.count;
}

- (void)doubleClickToCellVisitor:(NSTableView *)tableView
{
	NSUInteger row = tableView.selectedRow;
	if (row != -1)
	{
		SVTAppWindowPerson *windowPerson = [[SVTAppWindowPerson alloc] initWithPerson:self.tree.persons[row] tree:self.tree];
		windowPerson.window.delegate = self;
		[self.openWindowPerson addObject:windowPerson];
		[windowPerson release];
	}
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
	SVTURLSessionOfServer *url = [[SVTURLSessionOfServer alloc] init];
	[url putIDTreeInServer:self.tree];
	[url release];
	return YES;
}


#pragma mark - buttons

- (IBAction)buttonAddPeople:(NSButton *)sender
{
	SVTURLSessionOfServer *url = [[SVTURLSessionOfServer alloc] init];
	SVTTree *tree = self.tree;
	[tree addPerson:[url addPersonForTreeIDServer:tree.identifier]];
	[url putIDTreeInServer:tree];
	[url release];
	[self.scrollViewDrawTree invalidateIntrinsicContentSize];
	self.scrollViewDrawTree.needsDisplay = YES;
	[self.tableView reloadData];
	[[NSNotificationCenter defaultCenter] postNotificationName:kSVTViewControllerDidChangeTree object:tree];

	SVTAppWindowPerson *windowPerson = [[SVTAppWindowPerson alloc] initWithPerson:tree.persons.lastObject tree:tree];
	windowPerson.window.delegate = self;
	[self.openWindowPerson addObject:windowPerson];
	[windowPerson release];
}

- (IBAction)buttonRemovePeople:(NSButton *)sender
{
	NSUInteger index = self.tableView.selectedRow;
	SVTPerson *person = [self.tree.persons objectAtIndex:index];
	[person.father removeChild:person];
	[person.mother removeChild:person];
	SVTURLSessionOfServer *url = [[SVTURLSessionOfServer alloc] init];
	[url removePersonFromServer:person.identifier];
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
		[url putIDPersonInServer:iChild treeID:self.tree.identifier];
	}
	[url putIDTreeInServer:self.tree];
	[url release];
	[self.tree removePerson:person];
	[self.tableView reloadData];
	[self.scrollViewDrawTree invalidateIntrinsicContentSize];
	self.scrollViewDrawTree.needsDisplay = YES;
	[[NSNotificationCenter defaultCenter] postNotificationName:kSVTViewControllerDidChangeTree object:self.tree];
}


#pragma mark - notification

- (void)windowWillClose:(NSNotification *)notification
{
	if ([notification.name isEqualToString:NSWindowWillCloseNotification])
	{
		SVTAppWindowPerson *windowPerson = [notification.object windowController];
		[self.openWindowPerson removeObject:windowPerson];
		[self.scrollViewDrawTree invalidateIntrinsicContentSize];
		self.scrollViewDrawTree.needsDisplay = YES;
	}
}

- (void)viewPersonControllerDidChangePerson:(NSNotification *)notification
{
	if ([notification.name isEqualToString:kSVTViewTreeControllerDidChangePerson])
	{
		[self.tableView reloadData];
		NSUInteger treeID = self.tree.identifier;
		SVTURLSessionOfServer *url = [[SVTURLSessionOfServer alloc] init];
		for (SVTPerson *person in self.tree.persons)
		{
			[url putIDPersonInServer:person treeID:treeID];
		}
		[url release];
		[self.scrollViewDrawTree invalidateIntrinsicContentSize];
		self.scrollViewDrawTree.needsDisplay = YES;
	}
}


#pragma mark - getters

- (NSButton *)buttonRemovePeople
{
	return _buttonRemovePeople;
}

- (NSTextField *)textFieldTitle
{
	return _textFieldTitle;
}

- (NSTextField *)textFieldAuthor
{
	return _textFieldAuthor;
}

- (NSTableView *)tableView
{
	return _tableView;
}

- (NSMutableArray<SVTAppWindowPerson *> *)openWindowPerson
{
	return _openWindowPerson;
}


#pragma mark - setters

- (void)setButtonRemovePeople:(NSButton *)buttonRemovePeople
{
	_buttonRemovePeople = buttonRemovePeople;
}

- (void)setTextFieldTitle:(NSTextField *)textFieldTitle
{
	_textFieldTitle = textFieldTitle;
}

- (void)setTextFieldAuthor:(NSTextField *)textFieldAuthor
{
	_textFieldAuthor = textFieldAuthor;
}

- (void)setOpenWindowPerson:(NSMutableArray<SVTAppWindowPerson *> *)openWindowPerson
{
	if (_openWindowPerson != openWindowPerson)
	{
		[_openWindowPerson release];
		_openWindowPerson = [openWindowPerson mutableCopy];
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

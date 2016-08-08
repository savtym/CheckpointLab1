//
//  SVTViewPersonController.m
//  lab1
//
//  Created by Тимофей Савицкий on 7/31/16.
//  Copyright © 2016 Тимофей Савицкий. All rights reserved.
//

#import "SVTViewPersonController.h"
#import "SVTViewTreeController.h"
#import "SVTPerson.h"
#import "SVTTree.h"

@interface SVTViewPersonController() <NSTableViewDelegate, NSTableViewDataSource, NSTextFieldDelegate>
@property (assign) IBOutlet NSButton *buttonRemoveChild;
@property (assign) IBOutlet NSPopUpButton *popUpButtonSelectedChild;
@property (assign) IBOutlet NSTextField *textFieldName;
@property (assign) IBOutlet NSTextField *textFieldSurname;
@property (assign) IBOutlet NSTextField *textFieldMiddleName;
@property (assign) IBOutlet NSPopUpButton *popUpButtonGender;
@property (assign) IBOutlet NSPopUpButton *popUpButtonMother;
@property (assign) IBOutlet NSPopUpButton *popUpButtonFather;
@property (atomic, assign, readwrite) IBOutlet NSTableView *tableView;
@property (readwrite, copy) NSMutableArray<SVTPerson *> *children;
@property (readwrite, copy) NSMutableArray<SVTPerson *> *mother;
@property (readwrite, copy) NSMutableArray<SVTPerson *> *father;
@property (retain) SVTPerson *person;
@property (retain) SVTTree *tree;
@end

static NSString *const kSVTViewPersonControllerTable = @"FullName";

static NSString *const kSVTViewPersonControllerName= @"Name";
static NSString *const kSVTViewPersonControllerSurname = @"Surname";
static NSString *const kSVTViewPersonControllerMiddleName = @"MiddleName";


@implementation SVTViewPersonController
{
@private
    NSButton *_buttonRemoveChild;
    NSPopUpButton *_popUpButtonSelectedChild;
    NSTextField *_textFieldName;
    NSTextField *_textFieldSurname;
    NSTextField *_textFieldMiddleName;
    NSPopUpButton *_popUpButtonGender;
    NSPopUpButton *_popUpButtonMother;
    NSPopUpButton *_popUpButtonFather;
    NSTableView *_tableView;
    NSMutableArray<SVTPerson *> *_children;
    NSMutableArray<SVTPerson *> *_mother;
    NSMutableArray<SVTPerson *> *_father;
    SVTPerson *_person;
    SVTTree *_tree;
}

- (instancetype)initWithPerson:(SVTPerson *)person tree:(SVTTree *)tree
{
    self = [self initWithNibName:@"SVTViewPersonController" bundle:nil];
    if (self)
    {
        _tree = [tree retain];
        _person = [person retain];
        _father = [[NSMutableArray alloc] init];
        _mother = [[NSMutableArray alloc] init];
        _children = [[NSMutableArray alloc] init];
        self.view.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    }
    return self;
}

- (void)awakeFromNib
{
    self.textFieldName.delegate = self;
    self.textFieldSurname.delegate = self;
    self.textFieldMiddleName.delegate = self;
    self.textFieldName.stringValue = self.person.name;
    self.textFieldSurname.stringValue = self.person.surname;
    self.textFieldMiddleName.stringValue = self.person.middleName;
    [self.popUpButtonGender selectItemAtIndex:self.person.genderType];
    [self containsPopUpButtonsParents];
    [self containsPopUpButtonSelectedChild];
}

- (BOOL)descendantsOfChildrenResult:(BOOL)result vertex:(SVTPerson *)vertex
{
    for (SVTPerson *child in vertex.children)
    {
        result = [self descendantsOfChildrenResult:result vertex:child];
        if (!result)
        {
            break;
        }
    }
    if (result && self.person == vertex)
    {
        result = NO;
    }
    return result;
}

- (BOOL)descendantsOfParentsResult:(BOOL)result vertex:(SVTPerson *)vertex
{
    if (vertex.father)
    {
        result = [self descendantsOfParentsResult:result vertex:vertex.father];
    }
    if (vertex.mother)
    {
        result = [self descendantsOfParentsResult:result vertex:vertex.mother];
    }
    if (result && self.person == vertex)
    {
        result = NO;
    }
    return result;
}

- (void)containsPopUpButtonsParents
{
    NSUInteger indexFather = 0;
    NSUInteger bufIndex = 0;
    [self.father removeAllObjects];
    [self.mother removeAllObjects];
    for (SVTPerson *iPerson in self.tree.persons)
    {
        if (iPerson.genderType == kSVTPersonGenderTypeMale && iPerson != self.person)
        {
            BOOL childOfPerson = YES;
            childOfPerson = [self descendantsOfParentsResult:childOfPerson vertex:iPerson];
            if (childOfPerson || self.person.father == iPerson)
            {
                [self.popUpButtonFather addItemWithTitle:iPerson.fullName];
                [self.father addObject:iPerson];
                bufIndex = bufIndex + 1;
                if (iPerson == self.person.father)
                {
                    indexFather = bufIndex;
                }
            }
        }
    }
    [self.popUpButtonFather selectItemAtIndex:indexFather];
    NSUInteger indexMother = 0;
    bufIndex = 0;
    for (SVTPerson *iPerson in self.tree.persons)
    {
        if (iPerson.genderType == kSVTPersonGenderTypeFemale && iPerson != self.person)
        {
            BOOL childOfPerson = YES;
            childOfPerson = [self descendantsOfParentsResult:childOfPerson vertex:iPerson];
            if (childOfPerson || self.person.mother == iPerson)
            {
                [self.popUpButtonMother addItemWithTitle:iPerson.fullName];
                [self.mother addObject:iPerson];
                bufIndex = bufIndex + 1;
                if (iPerson == self.person.mother)
                {
                    indexMother = bufIndex;
                }
            }
        }
    }
    [self.popUpButtonMother selectItemAtIndex:indexMother];
}

- (void)containsPopUpButtonSelectedChild
{
    [self.children removeAllObjects];
    [self.popUpButtonSelectedChild removeAllItems];
    for (SVTPerson *iPerson in self.tree.persons)
    {
        if (iPerson != self.person)
        {
            BOOL childOfPerson = YES;
            //if (iPerson.depthOfVertex != kSVTPersonDepthOfVertex)
            {
                childOfPerson = [self descendantsOfChildrenResult:childOfPerson vertex:iPerson];
            }
            if (childOfPerson)
            {
                if (!iPerson.father && self.person.genderType == kSVTPersonGenderTypeMale)
                {
                    [self.children addObject:iPerson];
                }
                else if (!iPerson.mother && self.person.genderType == kSVTPersonGenderTypeFemale)
                {
                    [self.children addObject:iPerson];
                }
            }
        }
    }
    for (SVTPerson *iPerson in self.children)
    {
        [self.popUpButtonSelectedChild addItemWithTitle:iPerson.fullName];
    }
}


#pragma mark - table

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSTableCellView *result = [tableView makeViewWithIdentifier:kSVTViewPersonControllerTable owner:nil];
    result.textField.stringValue = self.person.children[row].fullName;
    return result;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return self.person.children.count;
}

- (IBAction)clickRowTable:(NSTableView *)sender
{
    self.buttonRemoveChild.enabled = (sender.selectedRow > -1);
}


#pragma mark - textFields

- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor
{
    NSString *textFieldIdentifier = control.identifier;
    if ([textFieldIdentifier isEqualToString:kSVTViewPersonControllerName])
    {
        self.person.name = control.stringValue;
    }
    else if ([textFieldIdentifier isEqualToString:kSVTViewPersonControllerSurname])
    {
        self.person.surname = control.stringValue;
    }
    else if ([textFieldIdentifier isEqualToString:kSVTViewPersonControllerMiddleName])
    {
        self.person.middleName = control.stringValue;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kSVTViewTreeControllerDidChangePerson object:self.person];
    return YES;
}


#pragma mark - buttons

- (IBAction)popUpButtonSelectedChild:(NSPopUpButton *)sender
{
    NSUInteger index = sender.indexOfSelectedItem;
    [self.person addChild:[self.children objectAtIndex:index]];
    [self.children removeObjectAtIndex:index];
    [self containsPopUpButtonSelectedChild];
    [self containsPopUpButtonsParents];
    NSTableView *tableView = self.tableView;
    [tableView beginUpdates];
    [tableView insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:(self.person.children.count - 1)] withAnimation:NSTableViewAnimationEffectFade];
    [tableView endUpdates];
    [[NSNotificationCenter defaultCenter] postNotificationName:kSVTViewTreeControllerDidChangePerson object:self.person];
}

- (IBAction)buttonRemoveChild:(NSButton *)sender
{
    NSUInteger index = self.tableView.selectedRow;
    if (index != -1)
    {
        SVTPerson *child = self.person.children[index];
        [self.children addObject:child];
        [self.person removeChild:child];
        [self containsPopUpButtonSelectedChild];
        [self containsPopUpButtonsParents];
        NSTableView *tableView = self.tableView;
        [tableView beginUpdates];
        [tableView removeRowsAtIndexes:[NSIndexSet indexSetWithIndex:self.person.children.count] withAnimation:NSTableViewAnimationSlideUp];
        [tableView endUpdates];
        [[NSNotificationCenter defaultCenter] postNotificationName:kSVTViewTreeControllerDidChangePerson object:self.person];
    }
    self.buttonRemoveChild.enabled = NO;
}

- (IBAction)popUpButtonGender:(NSPopUpButton *)sender
{
    [self.person removeAllChild];
    self.person.genderType = sender.indexOfSelectedItem;
    [self.tableView reloadData];
    [self containsPopUpButtonSelectedChild];
    [self containsPopUpButtonsParents];
    [[NSNotificationCenter defaultCenter] postNotificationName:kSVTViewTreeControllerDidChangePerson object:self.person];
}

- (IBAction)popUpButtonMother:(NSPopUpButton *)sender
{
    NSUInteger index = sender.indexOfSelectedItem;
    if (index != 0)
    {
        [self.person.mother removeChild:self.person];
        SVTPerson *mother = [self.mother objectAtIndex:(index - 1)];
        [mother addChild:self.person];
    }
    else
    {
        [self.person.mother removeChild:self.person];
        self.person.mother = nil;
    }
    [self containsPopUpButtonSelectedChild];
    [[NSNotificationCenter defaultCenter] postNotificationName:kSVTViewTreeControllerDidChangePerson object:self.person];
}

- (IBAction)popUpButtonFather:(NSPopUpButton *)sender
{
    NSUInteger index = sender.indexOfSelectedItem;
    if (index != 0)
    {
        [self.person.father removeChild:self.person];
        SVTPerson *father = [self.father objectAtIndex:(index - 1)];
        [father addChild:self.person];
    }
    else
    {
        [self.person.father removeChild:self.person];
        self.person.father = nil;
    }
    [self containsPopUpButtonSelectedChild];
    [[NSNotificationCenter defaultCenter] postNotificationName:kSVTViewTreeControllerDidChangePerson object:self.person];
}


#pragma mark - getters

- (NSButton *)buttonRemoveChild
{
    return _buttonRemoveChild;
}

- (NSPopUpButton *)popUpButtonFather
{
    return _popUpButtonFather;
}

- (NSPopUpButton *)popUpButtonMother
{
    return _popUpButtonMother;
}

- (NSPopUpButton *)popUpButtonGender
{
    return _popUpButtonGender;
}

- (NSPopUpButton *)popUpButtonSelectedChild
{
    return _popUpButtonSelectedChild;
}

- (NSTextField *)textFieldName
{
    return _textFieldName;
}

- (NSTextField *)textFieldSurname
{
    return _textFieldSurname;
}

- (NSTextField *)textFieldMiddleName
{
    return _textFieldMiddleName;
}

- (NSTableView *)tableView
{
    return _tableView;
}

- (NSMutableArray<SVTPerson *> *)children
{
    return _children;
}

-(NSMutableArray<SVTPerson *> *)mother
{
    return _mother;
}

- (NSMutableArray<SVTPerson *> *)father
{
    return _father;
}

- (SVTPerson *)person
{
    return _person;
}

- (SVTTree *)tree
{
    return _tree;
}


#pragma mark - setters

- (void)setButtonRemoveChild:(NSButton *)buttonRemoveChild
{
    _buttonRemoveChild = buttonRemoveChild;
}

- (void)setPopUpButtonFather:(NSPopUpButton *)popUpButtonFather
{
    _popUpButtonFather = popUpButtonFather;
}

- (void)setPopUpButtonMother:(NSPopUpButton *)popUpButtonMother
{
    _popUpButtonMother = popUpButtonMother;
}

- (void)setPopUpButtonGender:(NSPopUpButton *)popUpButtonGender
{
    _popUpButtonGender = popUpButtonGender;
}

- (void)setPopUpButtonSelectedChild:(NSPopUpButton *)popUpButtonSelectedChild
{
    _popUpButtonSelectedChild = popUpButtonSelectedChild;
}

- (void)setTextFieldName:(NSTextField *)textFieldName
{
    _textFieldName = textFieldName;
}

- (void)setTextFieldSurname:(NSTextField *)textFieldSurname
{
    _textFieldSurname = textFieldSurname;
}

- (void)setTextFieldMiddleName:(NSTextField *)textFieldMiddleName
{
    _textFieldMiddleName = textFieldMiddleName;
}

- (void)setTableView:(NSTableView *)tableView
{
    _tableView = tableView;
}

- (void)setChildren:(NSMutableArray<SVTPerson *> *)children
{
    if (_children != children)
    {
        [_children release];
        _children = [children mutableCopy];
    }
}

- (void)setMother:(NSMutableArray<SVTPerson *> *)mother
{
    if (_mother != mother)
    {
        [_mother release];
        _mother = [mother mutableCopy];
    }
}

- (void)setFather:(NSMutableArray<SVTPerson *> *)father
{
    if (_father != father)
    {
        [_father release];
        _father = [father mutableCopy];
    }
}

- (void)setPerson:(SVTPerson *)person
{
    if (_person != person)
    {
        [_person release];
        _person = [person retain];
    }
}

- (void)setTree:(SVTTree *)tree
{
    if (_tree != tree)
    {
        [_tree release];
        _tree = [tree retain];
    }
}


#pragma mark - dealloc

- (void)dealloc
{
    [_tree release];
    [_person release];
    [_father release];
    [_mother release];
    [_children release];
    [super dealloc];
}


@end

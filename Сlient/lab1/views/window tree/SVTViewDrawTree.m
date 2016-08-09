//
//  SVTViewDrawTree.m
//  Trees
//
//  Created by Тимофей Савицкий on 8/5/16.
//  Copyright © 2016 Тимофей Савицкий. All rights reserved.
//

#import "SVTViewDrawTree.h"
#import "SVTTree.h"
#import "SVTPerson.h"

static NSUInteger const kSVTViewDrawTreeHeightPosition = 80;
static NSUInteger const kSVTViewDrawTreeWidthPosition = 80;
static NSUInteger const kSVTViewDrawTreeFigureSize = 40;
static NSUInteger const kSVTViewDrawTreeFigureRadius = 40;
static NSUInteger const kSVTViewDrawTreePadding = 10;
static NSUInteger const kSVTViewDrawTreeFontSize = 10;
static NSUInteger const kSVTViewDrawTreeFigurePaddingHeight = 10;
static NSUInteger const kSVTViewDrawTreeFigurePaddingWidth = 20;
static NSString * const kSVTViewDrawTreeFontFamily = @"Helvetica";

static NSInteger const kSVTViewDrawTreeHeight = -1;
static CGFloat const kSVTViewDrawTreeWidth = -1;

@interface SVTViewDrawTree()
@property (readwrite) NSUInteger width;
@property (readwrite) NSUInteger height;
@property (nonatomic, readwrite) NSMutableArray<NSNumber *> *widthNode;
@property (nonatomic, readwrite) NSMutableArray<NSNumber *> *heightNode;
@property (readwrite, copy) NSMutableArray<SVTPerson *> *personOfFamily;
@property (readwrite, copy) NSMutableArray<SVTPerson *> *rootsOfForest;
@property (readwrite) BOOL treeOK;
@end

@implementation SVTViewDrawTree
{
@private
    NSUInteger _width;
    NSUInteger _height;
    NSMutableArray *_widthNode;
    NSMutableArray *_heightNode;
    NSMutableArray<SVTPerson *> *_rootsOfForest;
    NSMutableArray<SVTPerson *> *_personOfFamily;
}

#pragma mark - draw

- (void)drawRect:(NSRect)rect
{
    [super drawRect:rect];
    for (SVTPerson *person in self.tree.persons)
    {
        [self drawPerson:person];
    }
}

- (BOOL)isFlipped
{
    return YES;
}

- (NSSize)intrinsicContentSize
{
    [self.widthNode removeAllObjects];
    [self.heightNode removeAllObjects];
    for (NSUInteger index = 0; index < self.tree.persons.count; index++)
    {
        [self.widthNode addObject:[NSNumber numberWithFloat:kSVTViewDrawTreeWidth]];
        [self.heightNode addObject:[NSNumber numberWithInt:kSVTViewDrawTreeHeight]];
    }
    [self changedTree];
    return NSMakeSize((self.width + 1) * kSVTViewDrawTreeWidthPosition, (self.height + 1) * kSVTViewDrawTreeHeightPosition);
}

- (void)drawPerson:(SVTPerson *)person
{
    NSUInteger index = [self.tree.persons indexOfObject:person];
    CGFloat heightPerson = [self.heightNode[index] floatValue];
    CGFloat widthPerson = [self.widthNode[index] floatValue];
    CGFloat height = heightPerson * kSVTViewDrawTreeHeightPosition + kSVTViewDrawTreePadding;
    CGFloat width = widthPerson * kSVTViewDrawTreeWidthPosition + kSVTViewDrawTreePadding;
    CGFloat widthParent = width + (kSVTViewDrawTreeFigureSize + kSVTViewDrawTreeFigurePaddingWidth) / 2;
    CGFloat heightParent = height + kSVTViewDrawTreeFigureSize + kSVTViewDrawTreeFigurePaddingHeight - 4;
    for (SVTPerson *child in person.children)
    {
        NSUInteger indexChild = [self.tree.persons indexOfObject:child];
        CGFloat heightChild = [self.heightNode[indexChild] floatValue];
        CGFloat widthChild = [self.widthNode[indexChild] floatValue];
        CGFloat centerWidthChild = widthChild * kSVTViewDrawTreeWidthPosition + kSVTViewDrawTreePadding + (kSVTViewDrawTreeFigureSize + kSVTViewDrawTreeFigurePaddingWidth) / 2;
        CGFloat centerHeightChild = heightChild * kSVTViewDrawTreeHeightPosition + kSVTViewDrawTreePadding + 4;
        NSBezierPath *line = [NSBezierPath bezierPath];
        line.lineWidth = 4;
        [[NSColor colorWithRed:0.24 green:0.15 blue:0.14 alpha:1.0] setStroke];
        [line moveToPoint:NSMakePoint(widthParent, heightParent)];
        if ([self.heightNode[index] integerValue] == ([self.heightNode[indexChild] integerValue] - 1))
        {
            [line lineToPoint:NSMakePoint(centerWidthChild, centerHeightChild)];
        }
        else
        {
            [line curveToPoint:NSMakePoint(centerWidthChild, centerHeightChild) controlPoint1:NSMakePoint(centerWidthChild + kSVTViewDrawTreeFigurePaddingWidth * 4, centerHeightChild) controlPoint2:NSMakePoint(centerWidthChild + kSVTViewDrawTreeFigurePaddingWidth * 2, centerHeightChild)];
        }
        [line stroke];
    }
    NSRect rectBuf = NSMakeRect(width, height, kSVTViewDrawTreeFigureSize, kSVTViewDrawTreeFigureSize);
    NSUInteger indexClickRowOfTable = self.tree.indexClickRowOfTable;
    if (indexClickRowOfTable != -1 && person.identifier == indexClickRowOfTable)
    {
        [[NSColor colorWithRed:0.11 green:0.37 blue:0.13 alpha:1.0] set];
    }
    else if (person.genderType == kSVTPersonGenderTypeMale)
    {
        [[NSColor colorWithRed:0.39 green:0.71 blue:0.96 alpha:1.0] set];
    }
    else if (person.genderType == kSVTPersonGenderTypeFemale)
    {
        [[NSColor colorWithRed:0.94 green:0.38 blue:0.57 alpha:1.0] set];
    }
    
    NSRect myRect = NSMakeRect(width, height, rectBuf.size.width + kSVTViewDrawTreeFigurePaddingWidth, rectBuf.size.height + kSVTViewDrawTreeFigurePaddingHeight);
    NSBezierPath *path = [NSBezierPath bezierPath];
    [path setLineJoinStyle:NSRoundLineJoinStyle];
    [path appendBezierPathWithRoundedRect:myRect xRadius:kSVTViewDrawTreeFigureRadius yRadius:kSVTViewDrawTreeFigureRadius];
    [path fill];
    [path stroke];
    
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    style.alignment = NSCenterTextAlignment;
    NSDictionary *attributes = @{NSFontAttributeName: [NSFont fontWithName:kSVTViewDrawTreeFontFamily size:kSVTViewDrawTreeFontSize],
                                 NSParagraphStyleAttributeName:style,
                                 NSForegroundColorAttributeName:[NSColor whiteColor]};
    [person.fullName drawInRect:NSMakeRect(width + kSVTViewDrawTreeFigurePaddingWidth / 2, height + kSVTViewDrawTreeFigurePaddingHeight / 2, rectBuf.size.width, rectBuf.size.height) withAttributes:attributes];
    [style release];
}


#pragma mark - tree methods

- (void)changedTree
{
    for (SVTPerson *iPerson in self.tree.persons)
    {
        NSUInteger index = [self.tree.persons indexOfObject:iPerson];
        if (!iPerson.father && !iPerson.mother && [self.heightNode[index] integerValue] == kSVTViewDrawTreeHeight)
        {
            if (self.treeOK)
            {
                [self.widthNode removeAllObjects];
                [self.heightNode removeAllObjects];
                for (NSUInteger index = 0; index < self.tree.persons.count; index++)
                {
                    [self.widthNode addObject:[NSNumber numberWithFloat:kSVTViewDrawTreeWidth]];
                    [self.heightNode addObject:[NSNumber numberWithInt:kSVTViewDrawTreeHeight]];
                }
            }
            [self dfs:iPerson height:(kSVTViewDrawTreeHeight + 1)];
        }
    }
    NSInteger maxDepth = 0;
    [self.rootsOfForest removeAllObjects];
    for (SVTPerson *person in self.tree.persons)
    {
        NSUInteger index = [self.tree.persons indexOfObject:person];
        NSInteger height = [self.heightNode[index] integerValue];
        if (maxDepth < height)
        {
            maxDepth = height;
        }
        if (height == kSVTViewDrawTreeHeight)
        {
            self.heightNode[index] = [NSNumber numberWithUnsignedInteger:kSVTViewDrawTreeHeight + 1];
            height = kSVTViewDrawTreeHeight + 1;
        }
        if (height == kSVTViewDrawTreeHeight + 1)
        {
            [self.rootsOfForest addObject:person];
        }
    }
    self.height = maxDepth;
    NSUInteger maxWidth = 0;
    for (NSUInteger index = 0; index < (maxDepth + 1); index++)
    {
        NSUInteger width = 0;
        for (SVTPerson *person in self.tree.persons)
        {
            NSUInteger indexPerson = [self.tree.persons indexOfObject:person];
            if ([self.heightNode[indexPerson] integerValue] == index)
            {
                width = width + 1;
            }
        }
        if (maxWidth < width)
        {
            maxWidth = width;
        }
    }
    for (SVTPerson *root in self.rootsOfForest)
    {
        [self.personOfFamily removeAllObjects];
        [self containsPersonOfFamily:root];
        [self treeWidthPositionOfRoot:root];
    }
    self.width = maxWidth + self.rootsOfForest.count - 1;
    for (SVTPerson *person in self.tree.persons)
    {
        NSUInteger indexPerson = [self.tree.persons indexOfObject:person];
        NSLog(@"%@ depth: %@",person.name, self.heightNode[indexPerson]);
    }
    for (SVTPerson *person in self.tree.persons)
    {
        NSUInteger indexPerson = [self.tree.persons indexOfObject:person];
        NSLog(@"%@ width: %@", person.name, self.widthNode[indexPerson]);
    }
    NSLog(@"self width: %zd",self.width);
}

- (void)containsPersonOfFamily:(SVTPerson *)root
{
    if ([self.personOfFamily containsObject:root])
    {
        return;
    }
    [self.personOfFamily addObject:root];
    if (root.father)
    {
        [self containsPersonOfFamily:root.father];
    }
    if (root.mother)
    {
        [self containsPersonOfFamily:root.mother];
    }
    for (SVTPerson *child in root.children)
    {
        [self containsPersonOfFamily:child];
    }
}

- (void)dfs:(SVTPerson *)root height:(NSInteger)height
{
    NSUInteger indexRoot = [self.tree.persons indexOfObject:root];
    NSInteger heightRoot = [self.heightNode[indexRoot] integerValue];
    if (heightRoot != kSVTViewDrawTreeHeight || height == kSVTViewDrawTreeHeight)
    {
        if (self.treeOK)
        {
            self.treeOK = height == kSVTViewDrawTreeHeight ? NO : YES;
        }
        return;
    }
    self.heightNode[indexRoot] = [NSNumber numberWithInteger:height];
    if (root.father)
    {
        [self dfs:root.father height:(height - 1)];
    }
    if (root.mother)
    {
        [self dfs:root.mother height:(height - 1)];
    }
    for (SVTPerson *child in root.children)
    {
        [self dfs:child height:(height + 1)];
    }
}

- (void)treeWidthPositionOfRoot:(SVTPerson *)root
{
    NSUInteger indexRoot = [self.tree.persons indexOfObject:root];
    NSInteger heightRoot = [self.heightNode[indexRoot] integerValue];
    CGFloat widthRoot = [self.widthNode[indexRoot] floatValue];
    if (widthRoot != kSVTViewDrawTreeWidth)
    {
        return;
    }
    if (root.father)
    {
        [self treeWidthPositionOfRoot:root.father];
    }
    if (root.mother)
    {
        [self treeWidthPositionOfRoot:root.mother];
    }
    NSMutableArray<SVTPerson *> *treesAtTheSameDepth = [[[NSMutableArray alloc] init] autorelease];
    for (SVTPerson *person in self.tree.persons)
    {
        NSUInteger indexPerson = [self.tree.persons indexOfObject:person];
        if (heightRoot == [self.heightNode[indexPerson] integerValue])
        {
            [treesAtTheSameDepth addObject:person];
        }
    }
    if (treesAtTheSameDepth.count == 1)
    {
        if (!root.father && !root.mother)
        {
            if (root.children.count < 2)
            {
                self.widthNode[indexRoot] = [NSNumber numberWithFloat:0];
            }
            else
            {
                self.widthNode[indexRoot] = [NSNumber numberWithFloat:(root.children.count / 2)];
            }
        }
        else if (root.father && root.mother)
        {
            CGFloat fatherWidth = [self.widthNode[[self.tree.persons indexOfObject:root.father]] floatValue];
            CGFloat motherWidth = [self.widthNode[[self.tree.persons indexOfObject:root.mother]] floatValue];
            self.widthNode[indexRoot] = [NSNumber numberWithFloat:((fatherWidth + motherWidth) / 2)];
        }
        else
        {
            if (root.father && [self.heightNode[[self.tree.persons indexOfObject:root.father]] integerValue] == (heightRoot - 1))
            {
                CGFloat fatherWidth = [self.widthNode[[self.tree.persons indexOfObject:root.father]] floatValue];
                self.widthNode[indexRoot] = [NSNumber numberWithFloat:fatherWidth];
            }
            else
            {
                CGFloat motherWidth = [self.widthNode[[self.tree.persons indexOfObject:root.mother]] floatValue];
                self.widthNode[indexRoot] = [NSNumber numberWithFloat:motherWidth];
            }
        }
    }
    else
    {
        NSUInteger width = 0;
        for (SVTPerson *person in treesAtTheSameDepth)
        {
            NSUInteger indexPerson = [self.tree.persons indexOfObject:person];
            CGFloat widthPerson = [self.widthNode[indexPerson] floatValue];
            if (widthPerson != kSVTViewDrawTreeWidth)
            {
                width = width + 1;
                if (person.mother && person.father)
                {
                    width = treesAtTheSameDepth.count;
                    for (SVTPerson *personSort in treesAtTheSameDepth)
                    {
                        NSUInteger indexPersonSort = [self.tree.persons indexOfObject:personSort];
                        CGFloat widthPersonSort = [self.widthNode[indexPersonSort] floatValue];
                        if (widthPersonSort == width)
                        {
                            width = width - 1;
                        }
                    }
                    [treesAtTheSameDepth removeObject:person];
                    break;
                }
                else if (person.father || person.mother)
                {
                    NSUInteger indexParent = person.father ? [self.tree.persons indexOfObject:person.father] : [self.tree.persons indexOfObject:person.mother];
                    width = [self.widthNode[indexParent] floatValue];
                    for (SVTPerson *personSort in treesAtTheSameDepth)
                    {
                        NSUInteger indexPersonSort = [self.tree.persons indexOfObject:personSort];
                        CGFloat widthPersonSort = [self.widthNode[indexPersonSort] floatValue];
                        if (widthPersonSort == width)
                        {
                            width = width + 1;
                        }
                    }
                    [treesAtTheSameDepth removeObject:person];
                    break;
                }
            }
        }
        self.widthNode[indexRoot] = [NSNumber numberWithFloat:width];
    }
    NSInteger width = [self.widthNode[indexRoot] integerValue];
    if (self.width < width)
    {
        self.width = width;
    }
    for (SVTPerson *child in root.children)
    {
        [self treeWidthPositionOfRoot:child];
    }
}


#pragma mark - dealloc

- (void)dealloc
{
    [_rootsOfForest release];
    [_personOfFamily release];
    [_widthNode release];
    [_heightNode release];
    [super dealloc];
}


#pragma mark - getters

- (NSMutableArray<SVTPerson *> *)rootsOfForest
{
    if (!_rootsOfForest)
    {
        _rootsOfForest = [[NSMutableArray alloc] init];
    }
    return _rootsOfForest;
}

- (NSMutableArray<SVTPerson *> *)personOfFamily
{
    if (!_personOfFamily)
    {
        _personOfFamily = [[NSMutableArray alloc] init];
    }
    return _personOfFamily;
}

- (NSMutableArray<NSNumber *> *)widthNode
{
    if (!_widthNode)
    {
        _widthNode = [[NSMutableArray alloc] init];
    }
    return _widthNode;
}

- (NSMutableArray<NSNumber *> *)heightNode
{
    if (!_heightNode)
    {
        _heightNode = [[NSMutableArray alloc] init];
    }
    return _heightNode;
}

- (NSUInteger)width
{
    return _width;
}

- (NSUInteger)height
{
    return _height;
}


#pragma mark - setters

- (void)setRootsOfForest:(NSMutableArray<SVTPerson *> *)rootsOfForest
{
    if (_rootsOfForest != rootsOfForest)
    {
        [_rootsOfForest release];
        _rootsOfForest = [rootsOfForest mutableCopy];
    }
}

- (void)setPersonOfFamily:(NSMutableArray<SVTPerson *> *)personOfFamily
{
    if (_personOfFamily != personOfFamily)
    {
        [_personOfFamily release];
        _personOfFamily = [personOfFamily mutableCopy];
    }
}

- (void)setHeightNode:(NSMutableArray<NSNumber *> *)heightNode
{
    if (_heightNode != heightNode)
    {
        [_heightNode release];
        _heightNode = [heightNode retain];
    }
}

- (void)setWidhtNode:(NSMutableArray<NSNumber *> *)widhtNode
{
    if (_widthNode != widhtNode)
    {
        [_widthNode release];
        _widthNode = [widhtNode retain];
    }
}

- (void)setWidth:(NSUInteger)width
{
    _width = width;
}

- (void)setHeight:(NSUInteger)height
{
    _height = height;
}


@end

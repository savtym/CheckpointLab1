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
@property (readwrite) NSMutableArray *widhtNode;
@property (readwrite) NSMutableArray *heightNode;
@property (readwrite, copy) NSMutableArray<SVTPerson *> *personOfFamily;
@property (readwrite, copy) NSMutableArray<SVTPerson *> *rootsOfForest;
@property (readwrite) BOOL DFSTreeOK;
@end

@implementation SVTViewDrawTree
{
@private
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
    for (SVTPerson *person in self.tree.persons)
    {
        [self.widhtNode addObject:kSVTViewDrawTreeWidth];
        [self.heightNode addObject:kSVTViewDrawTreeWidth];
    }
    [self changedTree];
    return NSMakeSize((self.width + 1) * kSVTViewDrawTreeWidthPosition, (self.height + 1) * kSVTViewDrawTreeHeightPosition);
}

- (void)drawPerson:(SVTPerson *)person
{
    NSUInteger height = person.depthOfVertex * kSVTViewDrawTreeHeightPosition + kSVTViewDrawTreePadding;
    NSUInteger width = person.widthPosition * kSVTViewDrawTreeWidthPosition + kSVTViewDrawTreePadding;
    NSUInteger widthParent = width + (kSVTViewDrawTreeFigureSize + kSVTViewDrawTreeFigurePaddingWidth) / 2;
    NSUInteger heightParent = height + kSVTViewDrawTreeFigureSize + kSVTViewDrawTreeFigurePaddingHeight - 4;
    for (SVTPerson *child in person.children)
    {
        CGFloat centerWidthChild = child.widthPosition * kSVTViewDrawTreeWidthPosition + kSVTViewDrawTreePadding + (kSVTViewDrawTreeFigureSize + kSVTViewDrawTreeFigurePaddingWidth) / 2;
        CGFloat centerHeightChild = (CGFloat)child.depthOfVertex * kSVTViewDrawTreeHeightPosition + kSVTViewDrawTreePadding + 4;
        NSBezierPath *line = [NSBezierPath bezierPath];
        line.lineWidth = 4;
        [[NSColor colorWithRed:0.24 green:0.15 blue:0.14 alpha:1.0] setStroke];
        [line moveToPoint:NSMakePoint(widthParent, heightParent)];
        [line lineToPoint:NSMakePoint(centerWidthChild, centerHeightChild)];
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
}


#pragma mark - tree

- (void)changedTree
{
    self.DFSTreeOK = YES;
    BOOL nextFamily = YES;
    for (SVTPerson *iPerson in self.tree.persons)
    {
        if (!iPerson.father && !iPerson.mother && nextFamily)
        {
            [self dfs:iPerson depthOfVertex:(kSVTViewDrawTreeHeight + 1)];
            if (self.DFSTreeOK)
            {
                break;
            }
        }
    }
    for (SVTPerson *person in self.tree.persons)
    {
        NSLog(@"%@ depth: %zd",person.name, self.heightNode[person]);
    }
    NSInteger maxDepth = 0;
    [self.rootsOfForest removeAllObjects];
    for (SVTPerson *person in self.tree.persons)
    {
        if (maxDepth < [self.heightNode[person] integerValue])
        {
            maxDepth = [self.heightNode[person] integerValue];
        }
        if ([self.heightNode[person] integerValue]== kSVTViewDrawTreeHeight + 1)
        {
            BOOL result = YES;
            for (SVTPerson *descendant in self.rootsOfForest)
            {
                if (![self descendantsOfRootResult:result vertex:descendant root:person])
                {
                    result = NO;
                    break;
                }
            }
            if (result)
            {
                [self.rootsOfForest addObject:person];
            }
        }
        else if ([self.heightNode[person] integerValue] == kSVTViewDrawTreeHeight)
        {
            self.heightNode[person] = [NSNumber numberWithUnsignedInteger:(kSVTViewDrawTreeHeight + 1)];
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
            if (person.depthOfVertex == index)
            {
                width = width + 1;
            }
        }
        if (maxWidth < width)
        {
            maxWidth = width;
        }
    }
    self.width = maxWidth;
    for (SVTPerson *root in self.rootsOfForest)
    {
        [self.personOfFamily removeAllObjects];
        [self containsPersonOfFamily:root];
        
        [self treeWidthPositionOfRoot:root];
    }
    for (SVTPerson *person in self.tree.persons)
    {
        NSLog(@"%@ width: %f", person.name, person.widthPosition);
    }
    NSLog(@"self width: %zd",self.width);
}

- (BOOL)descendantsOfRootResult:(BOOL)result vertex:(SVTPerson *)vertex root:(SVTPerson *)root
{
    if (!result)
    {
        return result;
    }
    else if (result && root == vertex)
    {
        result = NO;
        return result;
    }
    if (vertex.mother)
    {
        result = [self descendantsOfRootResult:result vertex:vertex.mother root:root];
    }
    if (vertex.father)
    {
        result = [self descendantsOfRootResult:result vertex:vertex.father root:root];
    }
    for (SVTPerson *child in vertex.children)
    {
        if (![self descendantsOfRootResult:result vertex:child root:root])
        {
            result = NO;
            return result;
        }
    }
    return result;
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

- (void)dfs:(SVTPerson *)vertex depthOfVertex:(NSInteger)depthOfVertex
{
    if (vertex.depthOfVertex != kSVTPersonDepthOfVertex || depthOfVertex == kSVTPersonDepthOfVertex)
    {
        if (self.DFSTreeOK)
        {
            self.DFSTreeOK = depthOfVertex == kSVTPersonDepthOfVertex ? NO : YES;
        }
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


- (void)treeWidthPositionOfRoot:(SVTPerson *)root
{
    if (root.widthPosition != kSVTPersonWidthPosition)
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
    NSMutableArray<SVTPerson *> *treesAtTheSameDepth = [[NSMutableArray alloc] init];
    for (SVTPerson *person in self.tree.persons)
    {
        if (root.depthOfVertex == person.depthOfVertex)
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
                root.widthPosition = 0;
            }
            else
            {
                root.widthPosition = root.children.count / 2;
            }
        }
        else if (root.father && root.mother)
        {
                root.widthPosition = (root.father.widthPosition + root.mother.widthPosition) / 2;
        }
        else
        {
            if (root.father && root.father.depthOfVertex == (root.depthOfVertex - 1))
            {
                root.widthPosition = root.father.widthPosition;
            }
            else
            {
                root.widthPosition = root.mother.widthPosition;
            }
        }
    }
    else
    {
        NSUInteger width = 0;
        for (SVTPerson *person in treesAtTheSameDepth)
        {
            if (person.widthPosition != kSVTPersonWidthPosition)
            {
                width = width + 1;
                if (person.mother && person.father)
                {
                    width = treesAtTheSameDepth.count - 1;
                    for (SVTPerson *personSort in treesAtTheSameDepth)
                    {
                        if (personSort.widthPosition == width)
                        {
                            width = width - 1;
                        }
                    }
                    [treesAtTheSameDepth removeObject:person];
                    break;
                }
            }
        }
        root.widthPosition = width;
    }
    for (SVTPerson *child in root.children)
    {
        [self treeWidthPositionOfRoot:child];
    }
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

- (NSMutableDictionary *)widhtNode
{
    if (!_widhtNode)
    {
        _widhtNode = [[NSMutableDictionary alloc] init];
    }
    return _widhtNode
}

- (NSMutableDictionary *)heightNode
{
    if (!_heightNode)
    {
        _heightNode = [[NSMutableDictionary alloc] init];
    }
    return _heightNode;
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




@end

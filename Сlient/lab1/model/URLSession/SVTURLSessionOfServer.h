//
//  SVTURLSessionOfServer.h
//  Trees
//
//  Created by Тимофей Савицкий on 8/6/16.
//  Copyright © 2016 Тимофей Савицкий. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SVTTrees;
@class SVTTree;
@class SVTPerson;

@interface SVTURLSessionOfServer : NSObject

- (SVTTrees *)updateTreesFromServer;
- (void)updateTreeFromServerID:(NSUInteger)identifier tree:(SVTTree *)tree;

- (SVTTree *)addTreeInServer;
- (SVTPerson *)addPersonForTreeIDServer:(NSUInteger)treeID;

- (void)putIDTreeInServer:(SVTTree *)tree;
- (void)putIDPersonInServer:(SVTPerson *)person treeID:(NSUInteger)treeID;

- (void)removeTreeFromServer:(NSUInteger)treeID;
- (void)removePersonFromServer:(NSUInteger)personID;

- (void)searchByTitleOfTreesInServer:(NSString *)textSearch trees:(SVTTrees *)treesOfModel;

@end

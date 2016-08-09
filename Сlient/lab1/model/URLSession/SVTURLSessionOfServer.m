//
//  SVTURLSessionOfServer.m
//  Trees
//
//  Created by Тимофей Савицкий on 8/6/16.
//  Copyright © 2016 Тимофей Савицкий. All rights reserved.
//

#import "SVTURLSessionOfServer.h"
#import "SVTTrees.h"
#import "SVTTrees+SVTTreesSerilization.h"
#import "SVTTree.h"
#import "SVTTree+SVTTreeSerialization.h"
#import "SVTPerson.h"
#import "SVTPerson+SVTPersonSerialization.h"

static NSString * const kSVTURLSessionOfServerHostName = @"http://localhost:8080";
static NSString * const kSVTURLSessionOfServerTrees = @"/api/trees";
static NSString * const kSVTURLSessionOfServerPerson = @"/api/person";
static NSString * const kSVTURLSessionOfServerData = @"data";
static NSString * const kSVTURLSessionOfServerSearchOfTrees = @"/api/trees/search";

static NSString * const kSVTURLSessionOfServerPersonName = @"name";
static NSString * const kSVTURLSessionOfServerPersonSurname = @"surname";
static NSString * const kSVTURLSessionOfServerPersonMiddleName = @"middle_name";
static NSString * const kSVTURLSessionOfServerPersonGenderType = @"gender_type";
static NSString * const kSVTURLSessionOfServerPersonTreeID = @"tree_ID";
static NSString * const kSVTURLSessionOfServerMotherOfPerson = @"mother";
static NSString * const kSVTURLSessionOfServerFatherOfPerson = @"father";

static NSString * const kSVTURLSessionOfServerTitle = @"title";
static NSString * const kSVTURLSessionOfServerAuthor = @"author";

@interface SVTURLSessionOfServer()
@property (nonatomic, strong, readwrite) NSURLConnection *connection;
@end

@implementation SVTURLSessionOfServer


- (SVTTrees *)updateTreesFromServer
{
    NSURL *requestURL = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@%@", kSVTURLSessionOfServerHostName, kSVTURLSessionOfServerTrees]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:requestURL];
    [requestURL release];
    NSURLResponse *returningResponse = nil;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&returningResponse error:&error];
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    [request release];
    SVTTrees *trees = nil;
    if (data == nil)
    {
        NSLog(@"%@", error);
    }
    else
    {
        id object = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        if (object == nil)
        {
            NSLog(@"%@", error);
        }
        else
        {
            trees = [[[SVTTrees alloc] initWithDictionaryRepresentation:dictionary] autorelease];
            for (SVTTree *tree in trees.trees)
            {
                tree.showTreeOnTheTable = YES;
            }
        }
    }
    return trees;
}


- (void)updateTreeFromServerID:(NSUInteger)identifier tree:(SVTTree *)tree
{
    NSURL *requestURL = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@%@/%zd", kSVTURLSessionOfServerHostName, kSVTURLSessionOfServerTrees, identifier]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:requestURL];
    [requestURL release];
    NSURLResponse *returningResponse = nil;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&returningResponse error:&error];
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    [request release];
    if (!data)
    {
        NSLog(@"%@", error);
    }
    else
    {
        id object = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        if (!object)
        {
            NSLog(@"%@", error);
        }
        else
        {
            for (NSDictionary *person in dictionary)
            {
                [tree addPerson:[[[SVTPerson alloc] initWithDictionaryRepresentation:person] autorelease]];
            }
            NSUInteger index = 0;
            for (NSDictionary *person in dictionary)
            {
                NSUInteger fatherID = [person[kSVTURLSessionOfServerFatherOfPerson] integerValue];
                NSUInteger motherID = [person[kSVTURLSessionOfServerMotherOfPerson] integerValue];
                if (fatherID)
                {
                    for (SVTPerson *father in tree.persons)
                    {
                        if (father.identifier == fatherID)
                        {
                            [father addChild:tree.persons[index]];
                            break;
                        }
                    }
                }
                if (motherID)
                {
                    for (SVTPerson *mother in tree.persons)
                    {
                        if (mother.identifier == motherID)
                        {
                            [mother addChild:tree.persons[index]];
                            break;
                        }
                    }
                }
                index = index + 1;
            }
        }
    }
}

- (SVTTree *)addTreeInServer
{
    NSURL *requestURL = [[NSURL alloc] initWithString: [NSString stringWithFormat:@"%@%@", kSVTURLSessionOfServerHostName, kSVTURLSessionOfServerTrees]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:requestURL];
    NSURLResponse *returningResponse = nil;
    NSError *error = nil;
    request.HTTPMethod = @"POST";
    NSDictionary *dict = @{kSVTURLSessionOfServerTitle : kSVTURLSessionOfServerTitle,
                           kSVTURLSessionOfServerAuthor : kSVTURLSessionOfServerAuthor};
    NSData *jsonObject = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    request.HTTPBody = jsonObject;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&returningResponse error:&error];
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    [request release];
    [requestURL release];
    
    SVTTree *tree = nil;
    if (!data)
    {
        NSLog(@"%@", error);
    }
    else
    {
        id object = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        if (!object)
        {
            NSLog(@"%@", error);
        }
        else
        {
            tree = [[[SVTTree alloc] initWithDictionaryRepresentation:dictionary[kSVTURLSessionOfServerData]] autorelease];
        }
    }
    return tree;
}


- (SVTPerson *)addPersonForTreeIDServer:(NSUInteger)treeID
{
    NSURL *requestURL = [[NSURL alloc] initWithString: [NSString stringWithFormat:@"%@%@", kSVTURLSessionOfServerHostName, kSVTURLSessionOfServerPerson]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:requestURL];
    NSURLResponse *returningResponse = nil;
    NSError *error = nil;
    request.HTTPMethod = @"POST";
    NSDictionary *dict = @{kSVTURLSessionOfServerPersonName : kSVTURLSessionOfServerPersonName,
                           kSVTURLSessionOfServerPersonSurname : kSVTURLSessionOfServerPersonSurname,
                           kSVTURLSessionOfServerPersonMiddleName : kSVTURLSessionOfServerPersonMiddleName,
                           kSVTURLSessionOfServerPersonGenderType : [NSString stringWithFormat:@"%zd", kSVTPersonGenderTypeMale],
                           kSVTURLSessionOfServerPersonTreeID : [NSString stringWithFormat:@"%zd", treeID]};
    NSData *jsonObject = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    request.HTTPBody = jsonObject;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&returningResponse error:&error];
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    [request release];
    [requestURL release];
    
    SVTPerson *person = nil;
    if (!data)
    {
        NSLog(@"%@", error);
    }
    else
    {
        id object = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        if (!object)
        {
            NSLog(@"%@", error);
        }
        else
        {
            person = [[[SVTPerson alloc] initWithDictionaryRepresentation:dictionary[kSVTURLSessionOfServerData]] autorelease];
        }
    }
    return person;
}

- (void)putIDTreeInServer:(SVTTree *)tree
{
    NSURL *requestURL = [[NSURL alloc] initWithString: [NSString stringWithFormat:@"%@%@/%zd", kSVTURLSessionOfServerHostName, kSVTURLSessionOfServerTrees, tree.identifier]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:requestURL];
    NSURLResponse *returningResponse = nil;
    NSError *error = nil;
    request.HTTPMethod = @"PUT";
    NSData *jsonObject = [NSJSONSerialization dataWithJSONObject:[tree dictionaryRepresentation] options:NSJSONWritingPrettyPrinted error:&error];
    request.HTTPBody = jsonObject;
    [NSURLConnection sendSynchronousRequest:request returningResponse:&returningResponse error:&error];
    [request release];
    [requestURL release];
}

- (void)putIDPersonInServer:(SVTPerson *)person treeID:(NSUInteger)treeID
{
    NSURL *requestURL = [[NSURL alloc] initWithString: [NSString stringWithFormat:@"%@%@/%zd", kSVTURLSessionOfServerHostName, kSVTURLSessionOfServerPerson, person.identifier]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:requestURL];
    NSURLResponse *returningResponse = nil;
    NSError *error = nil;
    request.HTTPMethod = @"PUT";
    NSData *jsonObject = [NSJSONSerialization dataWithJSONObject:[person dictionaryRepresentation] options:NSJSONWritingPrettyPrinted error:&error];
    request.HTTPBody = jsonObject;
    [NSURLConnection sendSynchronousRequest:request returningResponse:&returningResponse error:&error];
    [request release];
    [requestURL release];
}

- (void)removeTreeFromServer:(NSUInteger)treeID
{
    NSURL *requestURL = [[NSURL alloc] initWithString: [NSString stringWithFormat:@"%@%@/%zd", kSVTURLSessionOfServerHostName, kSVTURLSessionOfServerTrees, treeID]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:requestURL];
    NSURLResponse *returningResponse = nil;
    NSError *error = nil;
    request.HTTPMethod = @"DELETE";
    [NSURLConnection sendSynchronousRequest:request returningResponse:&returningResponse error:&error];
    [request release];
    [requestURL release];
}

- (void)removePersonFromServer:(NSUInteger)personID
{
    NSURL *requestURL = [[NSURL alloc] initWithString: [NSString stringWithFormat:@"%@%@/%zd", kSVTURLSessionOfServerHostName, kSVTURLSessionOfServerPerson, personID]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:requestURL];
    NSURLResponse *returningResponse = nil;
    NSError *error = nil;
    request.HTTPMethod = @"DELETE";
    [NSURLConnection sendSynchronousRequest:request returningResponse:&returningResponse error:&error];
    [request release];
    [requestURL release];
}

- (void)searchByTitleOfTreesInServer:(NSString *)textSearch trees:(SVTTrees *)treesOfModel
{
    if (![textSearch isEqualToString:@""])
    {
        NSURL *requestURL = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@%@/%@", kSVTURLSessionOfServerHostName, kSVTURLSessionOfServerSearchOfTrees, textSearch]];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:requestURL];
        [requestURL release];
        NSURLResponse *returningResponse = nil;
        NSError *error = nil;
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&returningResponse error:&error];
        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        [request release];
        SVTTrees *trees = nil;
        if (data == nil)
        {
            NSLog(@"%@", error);
        }
        else
        {
            id object = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            if (object == nil)
            {
                NSLog(@"%@", error);
            }
            else
            {
                trees = [[SVTTrees alloc] initWithDictionaryRepresentation:dictionary];
                for (SVTTree *treeOfModel in treesOfModel.trees)
                {
                    treeOfModel.showTreeOnTheTable = NO;
                }
                for (SVTTree *tree in trees.trees)
                {
                    for (SVTTree *treeOfModel in treesOfModel.trees)
                    {
                        if (tree.identifier == treeOfModel.identifier)
                        {
                            treeOfModel.showTreeOnTheTable = YES;
                        }
                    }
                }
                [trees release];
            }
        }
    }
    else
    {
        for (SVTTree *treeOfModel in treesOfModel.trees)
        {
            treeOfModel.showTreeOnTheTable = YES;
        }
    }
}

@end

//
//  SVTPerson.h
//  lab1
//
//  Created by Тимофей Савицкий on 7/30/16.
//  Copyright © 2016 Тимофей Савицкий. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, SVTPersonGenderType)
{
    kSVTPersonGenderTypeMale = 0,
    kSVTPersonGenderTypeFemale = 1
};

extern NSInteger const kSVTPersonDepthOfVertex;

@interface SVTPerson : NSObject

- (instancetype)initWithName:(NSString *)name surname:(NSString *)surname middleName:(NSString *)middleName genderType:(SVTPersonGenderType)genderType;
- (instancetype)initWithName:(NSString *)name surname:(NSString *)surname middleName:(NSString *)middleName genderType:(SVTPersonGenderType)genderType identifier:(NSString *)identifier;

- (void)addChild:(SVTPerson *)child;
- (void)removeChild:(SVTPerson *)child;
- (void)removeAllChild;

@property (readwrite, copy) NSString *name;
@property (readwrite, copy) NSString *surname;
@property (readwrite, copy) NSString *middleName;
@property (readonly) NSString *fullName;
@property (nonatomic, readonly) NSString *identifier;
@property (readwrite, nonatomic) SVTPersonGenderType genderType;

@property (readwrite, retain) SVTPerson *mother;
@property (readwrite, retain) SVTPerson *father;
@property (readonly, retain) NSArray<SVTPerson *> *children;
@property (readwrite) NSInteger depthOfVertex;

@end

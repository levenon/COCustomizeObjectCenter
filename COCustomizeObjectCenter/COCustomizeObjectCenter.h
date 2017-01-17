//
//  COCustomizeObjectCenter.h
//  Marke Jave
//
//  Created by Marke Jave on 2016/12/1.
//  Copyright © 2016年 Marke Jave. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, COCustomizeObjectResultItemType) {
    
    COCustomizeObjectResultItemTypeOnce = 1,
    COCustomizeObjectResultItemTypeForever,
};

@class COCustomizeObjectCenter;

@protocol COCustomizeObjectCenterDelegate <NSObject>

@optional
// If you want to handle object, you can implement it.
- (void)customizeObjectCenter:(COCustomizeObjectCenter *)customizeObjectCenter handleObject:(id)object tag:(NSString *)tag;

@end

@interface COCustomizeObjectResultItem : NSObject

@property (nonatomic, copy, readonly) NSArray<NSString *> *tags;

@property (nonatomic, assign, readonly) COCustomizeObjectResultItemType type;

@property (nonatomic, strong, readonly) id object;

@end

@interface COCustomizeObjectCenterAction : NSObject

@property (nonatomic, copy, readonly) NSString *tag;

@property (nonatomic, assign, readonly) COCustomizeObjectResultItemType type;

@property (nonatomic, assign, readonly) id<COCustomizeObjectCenterDelegate> delegate;

@end

@interface COCustomizeObjectCenter : NSObject

+ (id)defaultCenter;

- (void)addObject:(id)object tags:(NSArray<NSString *> *)tags;
- (void)addObject:(id)object tags:(NSArray<NSString *> *)tags type:(COCustomizeObjectResultItemType)type;
- (void)addAllTagObject:(id)object;
- (void)addAllTagObject:(id)object type:(COCustomizeObjectResultItemType)type;

- (BOOL)addDelegate:(id<COCustomizeObjectCenterDelegate>)delegate;
- (BOOL)addDelegate:(id<COCustomizeObjectCenterDelegate>)delegate tag:(NSString *)tag;
- (BOOL)addDelegate:(id<COCustomizeObjectCenterDelegate>)delegate tag:(NSString *)tag type:(COCustomizeObjectResultItemType)type;
- (BOOL)removeDelegate:(id<COCustomizeObjectCenterDelegate>)delegate;
- (BOOL)removeDelegate:(id<COCustomizeObjectCenterDelegate>)delegate tag:(NSString *)tag;
- (BOOL)removeDelegate:(id<COCustomizeObjectCenterDelegate>)delegate tag:(NSString *)tag type:(COCustomizeObjectResultItemType)type;
- (BOOL)removeDelegatesForTag:(NSString *)tag;

- (void)removeAllObjects;
- (void)removeAllActions;
- (void)removeAllData;

#pragma mark - protected

- (BOOL)handleObjectDelegate:(id<COCustomizeObjectCenterDelegate>)delegate tag:(NSString *)tag;
- (BOOL)handleObjectResultItem:(COCustomizeObjectResultItem *)resultItem delegate:(id<COCustomizeObjectCenterDelegate>)delegate;
- (BOOL)handleObjectResultItem:(COCustomizeObjectResultItem *)resultItem delegate:(id<COCustomizeObjectCenterDelegate>)delegate tag:(NSString *)tag;

@end

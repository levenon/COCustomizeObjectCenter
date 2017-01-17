 //
//  COCustomizeObjectCenter.m
//  Marke Jave
//
//  Created by Marke Jave on 2016/12/1.
//  Copyright © 2016年 Marke Jave. All rights reserved.
//

#import "COCustomizeObjectCenter.h"
#import <objc/runtime.h>

const NSInteger COCustomizeObjectResultItemTypeIgnore = 0;

@implementation NSMutableArray (Categories)

- (void)intersectSet:(NSArray *)otherArray;{
    NSMutableSet *etSelfSet = [NSMutableSet setWithArray:[self copy]];
    NSSet *etOtherSet = [NSSet setWithArray:[otherArray copy]];
    [etSelfSet intersectSet:etOtherSet];
    [self setArray:[etSelfSet allObjects]];
}

- (void)minusSet:(NSArray *)otherArray;{
    NSMutableSet *etSelfSet = [NSMutableSet setWithArray:[self copy]];
    NSSet *etOtherSet = [NSSet setWithArray:[otherArray copy]];
    [etSelfSet minusSet:etOtherSet];
    [self setArray:[etSelfSet allObjects]];
}

- (void)unionSet:(NSArray *)otherArray;{
    NSMutableSet *etSelfSet = [NSMutableSet setWithArray:[self copy]];
    NSSet *etOtherSet = [NSSet setWithArray:[otherArray copy]];
    [etSelfSet unionSet:etOtherSet];
    [self setArray:[etSelfSet allObjects]];
}

@end

@interface COCustomizeObjectCenterActionSetter : NSObject
@property (nonatomic, assign) COCustomizeObjectCenter *container;
@property (nonatomic, assign) id delegate;
@end
@implementation COCustomizeObjectCenterActionSetter

- (void)dealloc{
    [[self container] removeDelegate:[self delegate]];
}

@end

@interface NSObject (COCustomizeObjectCenterActionSetter)
@property (nonatomic, strong, readonly) COCustomizeObjectCenterActionSetter *customizeObjectCenterActionSetter;
@end

@implementation NSObject (COCustomizeObjectCenterActionSetter)
- (COCustomizeObjectCenterActionSetter *)customizeObjectCenterActionSetter{
    COCustomizeObjectCenterActionSetter *setter = objc_getAssociatedObject(self, @selector(customizeObjectCenterActionSetter));
    if (!setter) {
        setter = [COCustomizeObjectCenterActionSetter new];
        objc_setAssociatedObject(self, @selector(customizeObjectCenterActionSetter), setter, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return setter;
}

@end

@interface COCustomizeObjectResultItem ()

@property (nonatomic, copy) NSArray<NSString *> *tags;

@property (nonatomic, assign) COCustomizeObjectResultItemType type;

@property (nonatomic, strong) id object;

@end

@implementation COCustomizeObjectResultItem

- (instancetype)initWithObject:(id)object tags:(NSArray<NSString *> *)tags type:(COCustomizeObjectResultItemType)type;{
    if (self = [super init]) {
        self.object = object;
        self.tags = tags;
        self.type = type;
    }
    return self;
}

@end

@interface COCustomizeObjectCenterAction ()

@property (nonatomic, copy) NSString *tag;

@property (nonatomic, assign) COCustomizeObjectResultItemType type;

@property (nonatomic, assign) id<COCustomizeObjectCenterDelegate> delegate;

@end

@implementation COCustomizeObjectCenterAction

- (instancetype)initWithDelegate:(id<COCustomizeObjectCenterDelegate>)delegate tag:(NSString *)tag type:(COCustomizeObjectResultItemType)type;{
    if (self = [super init]) {
        self.delegate = delegate;
        self.tag = tag;
        self.type = type;
    }
    return self;
}

@end

@interface COCustomizeObjectCenter ()

@property (nonatomic, strong) NSMutableArray<COCustomizeObjectResultItem *> *mutableObjectResultItems;

@property (nonatomic, strong) NSMutableArray<COCustomizeObjectCenterAction *> *mutableRegisteredActions;

@property (nonatomic, strong) NSMutableArray<COCustomizeObjectCenterAction *> *mutableHandledActions;

@end

@implementation COCustomizeObjectCenter

+ (id)defaultCenter;{
    static COCustomizeObjectCenter *defaultCenter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultCenter = [[[self class] alloc] init];
    });
    return defaultCenter;
}

- (instancetype)init{
    if (self = [super init]) {
        self.mutableObjectResultItems = [NSMutableArray new];
        self.mutableRegisteredActions = [NSMutableArray new];
        self.mutableHandledActions = [NSMutableArray new];
    }
    return self;
}

- (NSArray<COCustomizeObjectResultItem *> *)objectResultItemsWithTag:(NSString *)tag type:(COCustomizeObjectResultItemType)type{
    NSMutableArray<COCustomizeObjectResultItem *> *resultItems = [NSMutableArray array];
    for (COCustomizeObjectResultItem *resultItem in [[self mutableObjectResultItems] copy]) {
        BOOL condition = (type == COCustomizeObjectResultItemTypeIgnore || [resultItem type] == type) && (!tag || ![resultItem tags] || [[resultItem tags] containsObject:tag]);
        if (condition) {
            [resultItems addObject:resultItem];
        }
    }
    return resultItems;
}

- (NSArray<COCustomizeObjectCenterAction *> *)registeredActionsWithDelegate:(id<COCustomizeObjectCenterDelegate>)delegate tags:(NSArray<NSString *> *)tags type:(COCustomizeObjectResultItemType)type{
    return [self actionsInActions:[[self mutableRegisteredActions] copy] withDelegate:delegate tags:tags type:type];
}

- (NSArray<COCustomizeObjectCenterAction *> *)handledActionsWithDelegate:(id<COCustomizeObjectCenterDelegate>)delegate tags:(NSArray<NSString *> *)tags type:(COCustomizeObjectResultItemType)type{
    return [self actionsInActions:[[self mutableHandledActions] copy] withDelegate:delegate tags:tags type:type];
}

- (NSArray<COCustomizeObjectCenterAction *> *)actionsInActions:(NSArray *)actions withDelegate:(id<COCustomizeObjectCenterDelegate>)delegate tags:(NSArray<NSString *> *)tags type:(COCustomizeObjectResultItemType)type{
    NSMutableArray<COCustomizeObjectCenterAction *> *resultActions = [NSMutableArray array];
    for (COCustomizeObjectCenterAction *action in actions) {
        BOOL condition = (!delegate || [action delegate] == delegate) && (!tags || ![tags count] || [tags containsObject:[action tag]]) && (type == COCustomizeObjectResultItemTypeIgnore || type == [action type]);
        if (condition) {
            [resultActions addObject:action];
        }
    }
    return resultActions;
}

- (void)addObject:(id)object tags:(NSArray<NSString *> *)tags;{
    [self addObject:object tags:tags type:COCustomizeObjectResultItemTypeForever];
}

- (void)addObject:(id)object tags:(NSArray<NSString *> *)tags type:(COCustomizeObjectResultItemType)type;{
    NSParameterAssert(type != COCustomizeObjectResultItemTypeIgnore);
    
    COCustomizeObjectResultItem *resultItem = [[COCustomizeObjectResultItem alloc] initWithObject:object tags:tags type:type];
    [[self mutableObjectResultItems] addObject:resultItem];
    
    BOOL handled = [self handleObjectResultItem:resultItem delegate:nil];
    if (handled && [resultItem type] == COCustomizeObjectResultItemTypeOnce) {
        [[self mutableObjectResultItems] removeObject:resultItem];
    }
}

- (void)addAllTagObject:(id)object;{
    [self addAllTagObject:object type:COCustomizeObjectResultItemTypeForever];
}

- (void)addAllTagObject:(id)object type:(COCustomizeObjectResultItemType)type;{
    [self addObject:object tags:nil type:type];
}

- (BOOL)addDelegate:(id<COCustomizeObjectCenterDelegate>)delegate;{
    return [self addDelegate:delegate tag:nil];
}

- (BOOL)addDelegate:(id<COCustomizeObjectCenterDelegate>)delegate tag:(NSString *)tag;{
    return [self addDelegate:delegate tag:tag type:COCustomizeObjectResultItemTypeForever];
}

- (BOOL)addDelegate:(id<COCustomizeObjectCenterDelegate>)delegate tag:(NSString *)tag type:(COCustomizeObjectResultItemType)type;{
    if (![[self registeredActionsWithDelegate:delegate tags:(tag ? @[tag] : nil)  type:type] ?: @[] count]) {
        COCustomizeObjectCenterAction *action = [[COCustomizeObjectCenterAction alloc] initWithDelegate:delegate tag:tag type:type];
        ((NSObject *)delegate).customizeObjectCenterActionSetter.delegate = delegate;
        ((NSObject *)delegate).customizeObjectCenterActionSetter.container = self;
        [[self mutableRegisteredActions] addObject:action];
    
        [self handleObjectDelegate:delegate tag:tag];
        return YES;
    }
    return NO;
}

- (BOOL)removeDelegate:(id<COCustomizeObjectCenterDelegate>)delegate;{
    return [self removeDelegate:delegate tag:nil];
}

- (BOOL)removeDelegate:(id<COCustomizeObjectCenterDelegate>)delegate tag:(NSString *)tag;{
    return [self removeDelegate:delegate tag:tag type:COCustomizeObjectResultItemTypeIgnore];
}

- (BOOL)removeDelegate:(id<COCustomizeObjectCenterDelegate>)delegate tag:(NSString *)tag type:(COCustomizeObjectResultItemType)type;{
    NSArray *actions = [self registeredActionsWithDelegate:delegate tags:(tag ? @[tag] : nil) type:type] ?: @[];

    [[self mutableRegisteredActions] removeObjectsInArray:actions];
    
    return [actions count] != 0;
}

- (BOOL)removeDelegatesForTag:(NSString *)tag;{
    return [self removeDelegate:nil tag:tag];
}

- (void)removeAllObjects{
    [[self mutableObjectResultItems] removeAllObjects];
}

- (void)removeAllActions{
    [[self mutableHandledActions] removeAllObjects];
    [[self mutableRegisteredActions] removeAllObjects];
}

- (void)removeAllData{
    [self removeAllObjects];
    [self removeAllActions];
}

#pragma mark - private

- (void)_handledRegisteredAction:(COCustomizeObjectCenterAction *)action{
    [[self mutableRegisteredActions] removeObject:action];
    [[self mutableHandledActions] addObject:action];
}

#pragma mark - protected

- (BOOL)handleObjectDelegate:(id<COCustomizeObjectCenterDelegate>)delegate tag:(NSString *)tag{
    NSArray<COCustomizeObjectResultItem *> *resultItems = [self objectResultItemsWithTag:tag type:COCustomizeObjectResultItemTypeIgnore];
    
    BOOL result = NO;
    for (COCustomizeObjectResultItem *resultItem in resultItems) {
        BOOL handled = [self handleObjectResultItem:resultItem delegate:delegate];
        if (handled && [resultItem type] == COCustomizeObjectResultItemTypeOnce) {
            [[self mutableObjectResultItems] removeObject:resultItem];
        }
        result = result || handled;
    }
    return result;
}

- (BOOL)handleObjectResultItem:(COCustomizeObjectResultItem *)resultItem delegate:(id<COCustomizeObjectCenterDelegate>)delegate{
    NSMutableArray<COCustomizeObjectCenterAction *> *actions = [[self registeredActionsWithDelegate:delegate tags:[resultItem tags] type:COCustomizeObjectResultItemTypeIgnore] mutableCopy];
    [actions minusSet:[self mutableHandledActions]];
    
    BOOL result = NO;
    for (COCustomizeObjectCenterAction *action in [actions copy]) {
        BOOL handled = [self handleObjectResultItem:resultItem delegate:[action delegate] tag:[action tag]];
        if (handled) {
            if ([action type] == COCustomizeObjectResultItemTypeOnce) {
                [self _handledRegisteredAction:action];
            }
        }
        result = result || handled;
    }
    return result;
}

- (BOOL)handleObjectResultItem:(COCustomizeObjectResultItem *)resultItem delegate:(id<COCustomizeObjectCenterDelegate>)delegate tag:(NSString *)tag;{
    if ([delegate respondsToSelector:@selector(customizeObjectCenter:handleObject:tag:)]){
        [delegate customizeObjectCenter:self handleObject:[resultItem object] tag:tag];
        return YES;
    }
    return NO;
}

@end

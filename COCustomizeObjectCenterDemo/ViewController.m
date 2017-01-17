//
//  ViewController.m
//  COCustomizeObjectCenterDemo
//
//  Created by xulinfeng on 2017/1/17.
//  Copyright © 2017年 xulinfeng. All rights reserved.
//

#import "ViewController.h"
#import "COCustomizeObjectCenter.h"

@interface ViewController ()<COCustomizeObjectCenterDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    COCustomizeObjectCenter *center = [COCustomizeObjectCenter new];
    [center addDelegate:self tag:@"test"];
    
    [center addObject:[NSObject new] tags:@[@"test"]];
    
    [center addObject:[NSObject new] tags:@[@"other"]];
}

#pragma mark - COCustomizeObjectCenterDelegate

- (void)customizeObjectCenter:(COCustomizeObjectCenter *)customizeObjectCenter handleObject:(id)object tag:(NSString *)tag;{
    
    NSLog(@"object: %@, tag %@", object, tag);
}

@end

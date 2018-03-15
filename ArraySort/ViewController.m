//
//  ViewController.m
//  ArraySort
//
//  Created by penghe on 2018/3/14.
//  Copyright © 2018年 WondersGroup. All rights reserved.
//

#import "ViewController.h"
#import "WCServiceListModelV2.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self sortAction1];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 下面是以字符串为例子讲述三种排序方法

//数组的排序自定义排序
- (void)sortAction1
{
    NSArray *array = [NSArray arrayWithObjects:@"abc",@"456",@"123",@"789",@"ef", nil];
    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSNumber *num = [NSNumber numberWithInt:[obj characterAtIndex:0]];

        NSLog(@"%@",num);


    }];
    NSSortDescriptor *sort = [[ NSSortDescriptor alloc] initWithKey:@"self" ascending:NO];
    NSArray *sortedArray = [ array sortedArrayUsingDescriptors:@[sort] ];

//    NSArray *sortedArray = [array sortedArrayUsingSelector:@selector(compare:)];
    
    
    NSLog(@"排序后:%@",sortedArray);
}

//这里是NSString自己实现了排序方法 ，因为NSString已经有了排序方案如compare:方法已经是按照升序排列了。
- (void)sortAction2
{
    NSArray *array = [NSArray arrayWithObjects:@"abc",@"456",@"123",@"789",@"ef", nil];

    NSArray *sortedArray = [array sortedArrayUsingSelector:@selector(compare:)];
    NSLog(@"排序后:%@",sortedArray);

}

//利用block语法
- (void)sortAction3
{
    NSArray *array = [NSArray arrayWithObjects:@"abc",@"456",@"123",@"789",@"ef", nil];

    NSArray *sortedArray;
    sortedArray = [array sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSString *first = a;
        NSString *second = b;
        return [first compare:second];
    }];
    
    NSLog(@"排序后:%@",sortedArray);

}

#pragma mark - 下面是自定义对象排序
//加载自定义JSON文件
- (NSArray *)loadModel
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"CoustomObjectModel.json" ofType:@""];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    WCServiceListModelV2 *serviceListModel = [WCServiceListModelV2 yy_modelWithDictionary:json];
    return [serviceListModel.body copy];

}
//自定义对象排序第利用NSSortDescriptor
- (void)sortAction4
{
    NSArray *array = [self loadModel];
    NSSortDescriptor *serviceTypeDesc    = [NSSortDescriptor sortDescriptorWithKey:@"serviceType"
                                                                     ascending:YES];
    NSSortDescriptor *typeNameDesc    = [NSSortDescriptor sortDescriptorWithKey:@"type"
                                                                     ascending:NO];
    NSArray *sortedArray = [array sortedArrayUsingDescriptors:@[serviceTypeDesc,typeNameDesc]];

    
    NSLog(@"排序后:%@",sortedArray);

}
//自定义对象排序利用compare 升序其实还是根据字符串

- (void)sortAction5
{
    NSArray *array = [self loadModel];
    NSArray *sortedArray = [array sortedArrayUsingSelector:@selector(compare:)];
    NSLog(@"排序后:%@",sortedArray);

    
}
//自定义对象排序利用block特性效率高点

- (void)sortAction6
{
    NSArray *array = [self loadModel];

    NSArray *sortedArray = [array sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        WCServiceListModelBodyV2 *aModel = a;
        WCServiceListModelBodyV2 *bModel = b;

        //默认按serviceType排序
        NSComparisonResult result = [aModel.serviceType compare:bModel.serviceType];
        //注意:基本数据类型要进行数据转换
        //如果serviceType一样，就按照名字排序
        if (result == NSOrderedSame) {
            result = [[NSNumber numberWithInteger:aModel.type] compare:[NSNumber numberWithInteger:bModel.type]];
            if (result == NSOrderedAscending) {
                return NSOrderedDescending;
            }
        }
        return result;
      
    }];
    NSLog(@"排序后:%@",sortedArray);

}

//对于需要对比多个字段进行排序

@end

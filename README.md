# ArraySort
iOS 数组排序的几种方法
有时候后台返回的数组是没有排序的，所以需要我们自己排序。有时候数组里面是一个字符串，但是有时候数组里面是自定义的类对象。iOS其实给我们封装了一些高效的方法帮助我们进行排序。

## 数组对象是字符串排序一：
```
- (void)sortAction1
{
    NSArray *array = [NSArray arrayWithObjects:@"abc",@"456",@"123",@"789",@"ef", nil];
    NSSortDescriptor *sort = [[ NSSortDescriptor alloc] initWithKey:@"self" ascending:NO];
    NSArray *sortedArray = [ array sortedArrayUsingDescriptors:@[sort] ];

//    NSArray *sortedArray = [array sortedArrayUsingSelector:@selector(compare:)];
    
    
    NSLog(@"排序后:%@",sortedArray);
}
```

上述代码的大致介绍：
1：一个排序的容器就是数组
2：创建一个NSSortDescriptor 其实这个self 就是 里面对象 进行降序排列
3：然后调用数组排序方法参数就是上述NSSortDescriptor对象
4：返回一个新的排序后的数组

注意：字符串比较的是ASCII值 ，NSNumber *num = [NSNumber numberWithInt:[obj characterAtIndex:i]];
compare方法的比较原理为,依次比较当前字符串的第一个字母:
1:如果不同,就输出结果按照升序或者降序
2: 如果相同,依次比较当前字符串的下一个字母
3:以此类推

##数组对象是字符串排序二：

```
- (void)sortAction2
{
    NSArray *array = [NSArray arrayWithObjects:@"abc",@"456",@"123",@"789",@"ef", nil];

    NSArray *sortedArray = [array sortedArrayUsingSelector:@selector(compare:)];
    NSLog(@"排序后:%@",sortedArray);

}

```
上述代码的大致介绍：
1：一个排序的容器就是数组
2：调用字符串的compare比较并返回NSComparisonResult 默认是升序 

注意：其实就是对比比如：abc 和 456 比较并返回 NSComparisonResult。后面自定义对象可以具体看怎么实现这个方法的。

##数组对象是字符串排序三：

```
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

```
上述代码的大致介绍：
1：一个排序的容器就是数组
2：利用block语法对比里面的对象 类似上述二方法



下面介绍自定义类的数组排序：我把一个后台返回的无序的JSON加载到数组里

    NSString *path = [[NSBundle mainBundle] pathForResource:@"CoustomObjectModel.json" ofType:@""];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    WCServiceListModelV2 *serviceListModel = [WCServiceListModelV2 yy_modelWithDictionary:json];
    return [serviceListModel.body copy];

##数组对象是自定义对象排序一：
```
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
```
上述代码描述：
1：从本地文件加载JSON利用第三方框架转化为自己可以使用的数组里面的元素就是我们自己自定义的类对象。
2：自定义两个NSSortDescriptor。如果第一个属性serviceType相同，那就使用第二个NSSortDescriptor 关联的type 属性。
3：返回一个排序好的新数组。

##数组对象是自定义对象排序二：
```
- (void)sortAction5
{
    NSArray *array = [self loadModel];
    NSArray *sortedArray = [array sortedArrayUsingSelector:@selector(compare:)];
    NSLog(@"排序后:%@",sortedArray);

    
}
```
上述代码描述：
1：从本地文件加载JSON利用第三方框架转化为自己可以使用的数组里面的元素就是我们自己自定义的类对象。
2：调用数组对象也就是我们自己实现的compare：方法看下面实现：
```
- (NSComparisonResult)compare:(WCServiceListModelBodyV2 *)otherObject {
    
    NSComparisonResult result = [self.serviceType compare:otherObject.serviceType];

    if (result == NSOrderedSame) {
        result = [[NSNumber numberWithInteger:self.type] compare:[NSNumber numberWithInteger:otherObject.type]];
        if (result == NSOrderedAscending) {
            return NSOrderedDescending;
        }
    }
    return result;
}
```
 大致代码解释：
1:    默认按serviceType排序。
2：如果serviceType一样，就按照type排序。

注意：注意:基本数据类型要进行数据转换。

##数组对象是自定义对象排序三：
```
- (void)sortAction6
{
    NSArray *array = [self loadModel];

    NSArray *sortedArray = [array sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        WCServiceListModelBodyV2 *aModel = a;
        WCServiceListModelBodyV2 *bModel = b;

        NSComparisonResult result = [aModel.serviceType compare:bModel.serviceType];
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
```
 大致代码解释：
1：block里面的实现和第二种实现一样。
注意：其实a b 就是我们数组里的对象。

总结：利用block或者compare：方法要比使用NSSortDescriptor快点，由于NSSortDescriptor依赖与KVC 。好处是根据自定义类的属性进行排序比较形象，比较容易实现，试想如果有很多属性比较。

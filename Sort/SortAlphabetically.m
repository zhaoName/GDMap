//
//  SortAlphabetically.m
//  BlurrySearch
//
//  Created by zhao on 16/9/23.
//  Copyright © 2016年 zhaoName. All rights reserved.
//  将传递过来的内容排序、模糊查询

#import "SortAlphabetically.h"
#import <objc/runtime.h>

@interface SortAlphabetically ()

@property (nonatomic, strong) NSMutableDictionary *sortDictionary;

@end

@implementation SortAlphabetically

//单例
+ (SortAlphabetically *)shareSortAlphabetically
{
    static SortAlphabetically *sort = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        sort = [[SortAlphabetically alloc] init];
    });
    return sort;
}

#pragma mark -- 排序、分类
//排序
- (NSMutableDictionary *)sortAlphabeticallyWithDataArray:(NSMutableArray *)dataArray propertyName:(NSString *)propertyName
{
    //区分字符串数据 和模型数组
    NSDictionary *dict = [self distinguishDataBetweenStringDataAndModelData:dataArray propertyName:propertyName];
    
    if(dict.count <= 0) return nil;
    //按字母排序(重新赋值),分类
    [self sortWithHeadLetterFromDataArray:dict.allValues.firstObject type:dict.allKeys.firstObject];
    
    return self.sortDictionary;
}

#pragma mark -- 模糊查询

//模糊查询
- (NSMutableArray *)blurrySearchFromDataArray:(NSMutableArray *)dataArray propertyName:(NSString *)propertyName searchString:(NSString *)searchString
{
    //区分字符串数据和模型数组
    NSDictionary *dict = [self distinguishDataBetweenStringDataAndModelData:dataArray propertyName:propertyName];
    if(dict.count <= 0) return nil;
    //查询结果
    return [self handleSearchResult:dict.allValues.firstObject searchString:searchString type:dict.allKeys.firstObject];
}

//获取所有的value
- (NSMutableArray *)fetchAllValuesFromSortDict:(NSMutableDictionary *)sortDict
{
    NSMutableArray *values = [[NSMutableArray alloc] init];
    //按字母顺序 取所有的value
    NSMutableArray *keys = [self sortAllKeysFromDictKey:sortDict.allKeys];
    for(NSString *key in keys)
    {
        [values addObjectsFromArray:sortDict[key]];
    }
    return values;
}

#pragma mark -- 索引

//获取所有的key 也就是索引 此方法通用
- (NSMutableArray *)sortAllKeysFromDictKey:(NSArray *)keys
{
    NSMutableArray *keyArr = [keys mutableCopy];
    //排序
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:nil ascending:YES];
    [keyArr sortUsingDescriptors:@[descriptor]];
    
    //将@“#”放在最后
    for(NSString *string in keys)
    {
        if([string isEqualToString:@"#"])
        {
            [keyArr removeObject:@"#"];
            [keyArr addObject:@"#"];
            break;
        }
    }
    return keyArr;
}

//获取所有的索引  此方法只适合非模型数据
- (NSMutableArray *)fetchFirstLetterFromArray:(NSMutableArray *)array
{
    NSMutableSet *letterSet =[[NSMutableSet alloc] init];
    
    for (NSString *string in array)
    {
        NSString *firstLetter = [self chineseToPinYin:string];
        char letterChar = [firstLetter characterAtIndex:0];
        
        if (letterChar >= 'A' && letterChar <= 'Z') {
            [letterSet addObject:[NSString stringWithFormat:@"%c", letterChar]];
        }
        else {
            [letterSet addObject:@"#"];
        }
    }
    //返回去重、排序后所有的首字母
    NSMutableArray *arr = [NSMutableArray arrayWithArray:[[letterSet objectEnumerator].allObjects sortedArrayUsingSelector:@selector(compare:)]];
    //若包含@“#”则将其放在最后
    if([arr containsObject:@"#"])
    {
        [arr removeObject:@"#"];
        [arr addObject:@"#"];
    }
    return arr;
}

#pragma mark -- 添加数据
//添加数据
- (NSMutableDictionary *)addDataToSortDictionary:(id)data propertyName:(NSString *)propertyName
{
    //区分字符串数据 和模型数据
    NSDictionary *addDict = [self distinguishDataBetweenStringDataAndModelData:[NSMutableArray arrayWithObject:data] propertyName:propertyName];
    if(addDict.count <= 0) return nil;
    
    SortAlphabetically *sort = [addDict.allValues.firstObject firstObject];
    //添加字符串数组
    if ([addDict.allKeys.firstObject isEqualToString:@"string"])
    {
        NSString *first = [[self chineseToPinYin:sort.initialStr] substringToIndex:1];
        if ([self.sortDictionary.allKeys containsObject:first]) // 添加数据的首字母已存在
        {
            NSMutableArray *arr = [self.sortDictionary valueForKey:first];
            [arr addObject:sort.initialStr];
            // 重新排序
            NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:nil ascending:YES];
            [arr sortUsingDescriptors:@[descriptor]];
            [self.sortDictionary setObject:arr forKey:first];
        }
        else // 不存在
        {
            [self.sortDictionary setObject:@[sort.initialStr] forKey:[self isEnglishLetter:first] ? first : @"#"];
        }
        return self.sortDictionary;
    }
    else // 添加模型数数组
    {
        NSString *first = [[self chineseToPinYin:sort.initialStr] substringToIndex:1];
        if ([self.sortDictionary.allKeys containsObject:first]) // 添加数据的首字母已存在
        {
            NSMutableArray *arr = [self.sortDictionary valueForKey:first];
            [arr addObject:sort.model];
            // 重新排序
            NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"personName" ascending:YES];
            [arr sortUsingDescriptors:@[descriptor]];
            [self.sortDictionary setObject:arr forKey:first];
        }
        else // 不存在
        {
            [self.sortDictionary setObject:@[sort.model] forKey:[self isEnglishLetter:first] ? first : @"#"];
        }
        return self.sortDictionary;
    }
}

#pragma mark -- 私有方法

/**
 *  区分字符串数据和模型数组，并取出需要排序的属性值
 *
 *  @param dataArray    字符串数据或模型数组
 *  @param propertyName 需要排序的属性名
 *
 *  @return key是区分字符串数据和模型数组的标志, value是需要排序的属性值
 */
- (NSDictionary *)distinguishDataBetweenStringDataAndModelData:(NSMutableArray *)dataArray propertyName:(NSString *)propertyName
{
    if (dataArray.count <= 0) return nil;
    
    NSMutableArray *tempArr = [NSMutableArray array];
    NSString *type = nil;
    
    if ([dataArray.firstObject isKindOfClass:[NSString class]]) // 字符串
    {
        type = @"string";
        for(NSString *string in dataArray)
        {
            SortAlphabetically *sort = [[SortAlphabetically alloc] init];
            sort.initialStr = string; // 原始字符串
            sort.hanYuPinYin = [self chineseToPinYin:string]; // 汉语转拼音
            [tempArr addObject:sort];
        }
    }
    else // 模型
    {
        type = @"model";
        tempArr = [self handleModelFromDataArray:dataArray propertyName:propertyName];
    }
    return @{type : tempArr};
}

/**
 *  处理模型数据
 */
- (NSMutableArray *)handleModelFromDataArray:(NSMutableArray *)dataArray propertyName:(NSString *)propertyName
{
    NSMutableArray *tempArr = [[NSMutableArray alloc] init];
    unsigned int propertyCount;
    objc_property_t *properties = class_copyPropertyList([dataArray.firstObject class], &propertyCount);
    
    for (NSObject *object in dataArray) // 遍历模型
    {
        SortAlphabetically *sort = [[SortAlphabetically alloc] init];
        sort.model = object;
        
        for (int i=0; i<propertyCount; i++) // 遍历模型中的属性名
        {
            objc_property_t property = properties[i];
            // 获取属性名
            NSString *proName = [NSString stringWithUTF8String:property_getName(property)];
            
            if ([proName isEqualToString:propertyName])
            {
                id propertyValue = [object valueForKey:proName]; // 获取属性名对应的属性值
                sort.initialStr = propertyValue; // 原始字符串
                sort.hanYuPinYin = [self chineseToPinYin:propertyValue]; // 汉语转拼音
                [tempArr addObject:sort];
                break;
            }
            if(i == propertyCount-1)
            {
                NSLog(@"数据源model中没有你指定的属性名");
            }
        }
    }
    return tempArr;
}

/**
 *  将数据转化为拼音后(英文、符号、数字不变)，按字母排序;
 *
 *  @param dataArray 数据 若为模型则为要排序属性值
 */
- (void)sortWithHeadLetterFromDataArray:(NSMutableArray *)dataArray type:(NSString *)type
{
    // 按hanYuPinYin属性值排序
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"hanYuPinYin" ascending:YES];
    [dataArray sortUsingDescriptors:@[descriptor]];
    
    [self.sortDictionary removeAllObjects];
    for (SortAlphabetically *sort in dataArray)
    {
        NSString *capital = [self isEnglishLetter:[sort.hanYuPinYin substringToIndex:1]] ? [sort.hanYuPinYin substringToIndex:1] : @"#";
        // 若字典中已包含此首字母，则直接添加到对应的数组中
        if([self.sortDictionary.allKeys containsObject:capital])
        {
            if([type isEqualToString:@"string"])
            {
                [self.sortDictionary[capital] addObject:sort.initialStr];
            }
            else if ([type isEqualToString:@"model"])
            {
                [self.sortDictionary[capital] addObject:sort.model];
            }
        }
        else // 若字典中没有此首字母，则添加相应的字典
        {
            NSMutableArray *sortArray = [NSMutableArray array];
            if([type isEqualToString:@"string"])
            {
                [sortArray addObject:sort.initialStr];
            }
            else if ([type isEqualToString:@"model"])
            {
                [sortArray addObject:sort.model];
            }
            [self.sortDictionary setObject:sortArray forKey:capital];
        }
    }
}

/**
 *  中文转化为拼音 (英文、数字、字符不变)
 */
- (NSString *)chineseToPinYin:(NSString *)chinese
{
    NSMutableString *english = [chinese mutableCopy];
    // 转化为带声调的拼音
    CFStringTransform((__bridge CFMutableStringRef)english, NULL, kCFStringTransformMandarinLatin, NO);
    // 转化为不带声调的拼音
    CFStringTransform((__bridge CFMutableStringRef)english, NULL, kCFStringTransformStripCombiningMarks, NO);
    
    // 去除两端空格和回车
    [english stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    // 去除中间的空格
    english = (NSMutableString *)[english stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    return [english uppercaseString];
    
}

/**
 *  正则表达式判断数据中是否全为英文字符
 */
- (BOOL)isEnglishLetter:(NSString *)string
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"[A-Za-z]+"];
    return [predicate evaluateWithObject:string];
}

/**
 *  判断是否包含汉字
 */
- (BOOL)isIncludeChineseInString:(NSString*)string
{
    for (int i=0; i<string.length; i++)
    {
        unichar ch = [string characterAtIndex:i];
        if (0x4e00 < ch  && ch < 0x9fff) return true;
    }
    return false;
}

/**
 *  模糊查询 可以按拼音、中文、字符查询
 *
 *  @param array        数据源
 *  @param searchString 查询条件
 *  @param type         区分字符串数组或模型数组的标志
 *
 *  @return 符合条件的数据
 */
- (NSMutableArray *)handleSearchResult:(NSMutableArray *)array searchString:(NSString *)searchString type:(NSString *)type
{
    if(searchString.length <= 0) return nil;
    
    NSMutableArray *searchArray = [[NSMutableArray alloc] init];
    for(SortAlphabetically *sort in array)
    {
        // 输入的查找字符串中不包含中文
        if(![self isIncludeChineseInString:searchString])
        {
            // 判断转化后的拼音是否包含 搜索框中输入的字符
            NSRange range = [sort.hanYuPinYin rangeOfString:searchString options:NSCaseInsensitiveSearch];
            if(range.length > 0)
            {
                [searchArray addObject:[type isEqualToString:@"string"] ? sort.initialStr : sort.model];
            }
        }
        else // 输入的查找字符串包含中文
        {
            NSRange range = [sort.initialStr rangeOfString:searchString options:NSCaseInsensitiveSearch];
            if(range.length > 0)
            {
                [searchArray addObject:[type isEqualToString:@"string"] ? sort.initialStr : sort.model];
            }
        }
    }
    return searchArray;
}

#pragma mark -- getter

- (NSMutableDictionary *)sortDictionary
{
    if(!_sortDictionary)
    {
        _sortDictionary = [[NSMutableDictionary alloc] init];
    }
    return _sortDictionary;
}

@end

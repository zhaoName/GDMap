//
//  SortAlphabetically.h
//  BlurrySearch
//
//  Created by zhao on 16/9/23.
//  Copyright © 2016年 zhaoName. All rights reserved.
//  将传递过来的内容排序、模糊查询

#import <Foundation/Foundation.h>

@interface SortAlphabetically : NSObject

@property (nonatomic, strong) NSString *initialStr; /**< 最初的字符串*/
@property (nonatomic, strong) NSString *headLetter; /**< 每个汉字的首字母*/
@property (nonatomic, strong) NSString *hanYuPinYin; /**< 转化后的汉语拼音*/
@property (nonatomic, strong) NSString *capitalLetter; /**< 首字母*/
@property (nonatomic, strong) NSObject *model; /**< 模型数据*/


/**
 *  单例
 */
+ (SortAlphabetically *)shareSortAlphabetically;

/**
 *  把传过来的数据按字母排序 数据可以是字符串也可以是模型，返回按首字母分类、排序好的字典
 *
 *  @param dataArray    要排序的数组
 *  @param propertyName 数组中为字符串则可以为空；若为模型 则propertyName不能为空，是需要排序的属性名
 */
- (NSMutableDictionary *)sortAlphabeticallyWithDataArray:(NSMutableArray *)dataArray propertyName:(NSString *)propertyName;

/**
 *  模糊查询(可输入中文对应的拼音(不区分大小写),也可直接输入中文） 所查询的数据可以是字符串数组也可以是模型数组
 *
 *  @param dataArray    数据
 *  @param propertyName 可为nil，但数据为模型数据，此为所要查询的属性名
 *  @param searchString 搜索框中输入的字符串
 *
 *  @return 查询到的数据
 */
- (NSMutableArray *)blurrySearchFromDataArray:(NSMutableArray *)dataArray propertyName:(NSString *)propertyName searchString:(NSString *)searchString;

/**
 *  从排序号好的字典中方获取所有的key值 也就是索引值,并排序; 此方法通用
 *  因为从字典中获取的keys值可能是无序的
 */
- (NSMutableArray *)sortAllKeysFromDictKey:(NSArray *)keys;

/**
 *  从排序号好的字典中方获取所有的value值
 *
 *  @param 此方法是为了模糊查询是所用
 */
- (NSMutableArray *)fetchAllValuesFromSortDict:(NSMutableDictionary *)sortDict;

/**
 *  获取所有数据去重、排序后的首字母; 此方法只适合非模型数据
 *
 *  @param array 数据
 */
- (NSMutableArray *)fetchFirstLetterFromArray:(NSMutableArray *)array;



/**
 *  添加字符串数据或模型数据
 *
 *  @return 添加数据后重新排序的字典
 */
- (NSMutableDictionary *)addDataToSortDictionary:(id)data propertyName:(NSString *)propertyName;

@end

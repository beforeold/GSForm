//
//  GSForm.h
//  GS3PL
//
//  Created by Brook on 2017/4/28.
//  Copyright © 2017年 Brook. All rights reserved.
//  整个 tableView 的数据源对象

#import <Foundation/Foundation.h>
#import "GSSection.h"

NS_ASSUME_NONNULL_BEGIN

@interface GSForm : NSObject

@property (nonatomic, strong, readonly) NSMutableArray <GSSection *> *sectionArray;
@property (nonatomic, assign, readonly) NSUInteger count;

@property (nonatomic, assign) CGFloat rowHeight;

- (void)addSection:(GSSection *)section;
- (void)removeSection:(GSSection *)section;

- (void)reformRespRet:(id)resp;
- (id)fetchHttpParams;

- (NSDictionary *)validateRows;

/// 配置全局禁用点击事件的block
@property (nonatomic, copy) id(^disableBlock)(GSForm *);

/// 根据 indexPath 返回 row
- (GSRow *)rowAtIndexPath:(NSIndexPath *)indexPath;
/// 根据 row 返回 indexPath
- (NSIndexPath *)indexPathOfGSRow:(GSRow *)row;

@end

@interface GSForm (NSSubscript)

// 数组样式
- (GSSection *)objectAtIndexedSubscript:(NSUInteger)idx ; // 取值
- (void)setObject:(GSSection *)obj atIndexedSubscript:(NSUInteger)idx ; // 设值

@end

NS_ASSUME_NONNULL_END

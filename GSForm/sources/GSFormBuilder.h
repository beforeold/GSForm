//  整个 tableView 的数据源对象

#import <UIKit/UIKit.h>

@class GSSection;
@class GSRow;

NS_ASSUME_NONNULL_BEGIN

@interface GSFormBuilder : NSObject

@property (nonatomic, strong, readonly) NSMutableArray <GSSection *> *sectionArray;
@property (nonatomic, assign, readonly) NSUInteger count;

@property (nonatomic, assign) CGFloat rowHeight;

- (void)addSection:(GSSection *)section;
- (void)removeSection:(GSSection *)section;

- (void)reformRespRet:(id)resp;
- (id)fetchHttpParams;

- (NSDictionary *)validateRows;

/// 配置全局禁用点击事件的block
@property (nonatomic, copy) id(^disableBlock)(GSFormBuilder *);

/// 根据 indexPath 返回 row
- (GSRow *)rowAtIndexPath:(NSIndexPath *)indexPath;
/// 根据 row 返回 indexPath
- (NSIndexPath *)indexPathOfGSRow:(GSRow *)row;

@end

@interface GSFormBuilder (NSSubscript)

// 数组样式
- (GSSection *)objectAtIndexedSubscript:(NSUInteger)idx ; // 取值
- (void)setObject:(GSSection *)obj atIndexedSubscript:(NSUInteger)idx ; // 设值

@end

NS_ASSUME_NONNULL_END

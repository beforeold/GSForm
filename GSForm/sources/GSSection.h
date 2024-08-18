//  描述 section 的数据源

#import <Foundation/Foundation.h>
#import "GSRow.h"

NS_ASSUME_NONNULL_BEGIN

@interface GSSection : NSObject

@property (nonatomic, strong, readonly) NSMutableArray <GSRow *> *rowArray;
@property (nonatomic, assign, readonly) NSUInteger count;
@property (nonatomic, assign) CGFloat headerHeight;
@property (nonatomic, assign) CGFloat footerHeight;
@property (nonatomic, assign, getter=isHidden) BOOL hidden;

- (void)addRow:(GSRow *)row;
- (void)addRowArray:(NSArray <GSRow *> *)rowArray;

@end

@interface GSSection (NSSubscript)

// 数组样式
- (GSRow *)objectAtIndexedSubscript:(NSUInteger)idx ; // 取值
- (void)setObject:(GSRow *)obj atIndexedSubscript:(NSUInteger)idx ; // 设值

@end


NS_ASSUME_NONNULL_END

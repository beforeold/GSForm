#import "GSSection.h"

@interface GSSection ()

@property (nonatomic, strong, readwrite) NSMutableArray <GSRow *> *rowArray;

@end

@implementation GSSection
- (void)addRow:(GSRow *)row {
    row.section = self;
    [self.rowArray addObject:row];
}

- (void)addRowArray:(NSArray <GSRow *> *)rowArray {
    for (GSRow *row in rowArray) {
        [self addRow:row];
    }
}

- (CGFloat)footerHeight {
    if (_footerHeight != 0) return _footerHeight;
    
    return 0.01;
}

- (CGFloat)headerHeight {
    if (_headerHeight != 0) return _headerHeight;
    
    return 0.01;
}

#pragma mark - setter/getter
- (NSMutableArray *)rowArray {
    if (_rowArray) return _rowArray;
    
    _rowArray = [NSMutableArray array];
    return _rowArray;
}

- (NSUInteger)count {
    return self.rowArray.count;
}

@end

@implementation GSSection (NSSubscript)
// 数组样式
- (GSRow *)objectAtIndexedSubscript:(NSUInteger)idx {
    if (self.rowArray.count > idx) return self.rowArray[idx];
    
    return nil;
}

- (void)setObject:(GSRow *)obj atIndexedSubscript:(NSUInteger)idx {
    if (self.rowArray.count < idx) return;
    self.rowArray[idx] = obj;
}

@end

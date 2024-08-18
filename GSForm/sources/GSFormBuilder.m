#import "GSFormBuilder.h"
#import "GSSection.h"

@interface GSFormBuilder ()

@property (nonatomic, strong, readwrite) NSMutableArray <GSSection *> *sectionArray;

@end

@implementation GSFormBuilder
- (void)addSection:(GSSection *)section {
    [self.sectionArray addObject:section];
}

- (void)removeSection:(GSSection *)section {
    [self.sectionArray removeObject:section];
}

- (void)reformRespRet:(id)resp {
    for (GSSection *section in self.sectionArray) {
        for (GSRow *row in section.rowArray) {
            !row.reformRespRetBlock ?: row.reformRespRetBlock(resp, row.value);
        }
    }
}

- (id)fetchHttpParams {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    for (GSSection *secion in self.sectionArray) {
        for (GSRow *row in secion.rowArray) {
            if (!row.httpParamConfigBlock) continue;
            id http = row.httpParamConfigBlock(row.value);
            if ([http isKindOfClass:[NSDictionary class]]) {
                [dic addEntriesFromDictionary:http];
            } else if ([http isKindOfClass:[NSArray class]]) {
                for (NSDictionary *subHttp in http) {
                    [dic addEntriesFromDictionary:subHttp];
                }
            }
        }
    }
    
    return dic;
}

- (NSDictionary *)validateRows {
    for (GSSection *section in self.sectionArray) {
        for (GSRow *row in section.rowArray) {
            if (!row.isHidden && row.valueValidateBlock) {
                NSDictionary *dic = row.valueValidateBlock(row.value);
                NSNumber *ret = dic[kValidateRetKey];
                NSAssert(ret, @"必须有结果参数");
                if (!ret) continue;
                if (!ret.boolValue) return dic;
            }
        }
    }
    
    return rowOK();
}

- (NSIndexPath *)indexPathOfGSRow:(GSRow *)row {
    if (row.isHidden) return nil;
    if (!row.section || row.section.hidden) return nil;
    
    GSSection *xSection = row.section;
    NSInteger sectionCounter = -1;
    BOOL matchSection = NO;
    for (GSSection *section in self.sectionArray) {
        if(!section.isHidden) sectionCounter ++;
        if (section == xSection) {
            matchSection = YES;
            break;
        }
    }
    if(!matchSection) return nil;
    
    NSInteger rowCounter = -1;
    BOOL matchRow = NO;
    for (GSRow *rowL in xSection.rowArray) {
        if(!rowL.isHidden) rowCounter ++;
        if (rowL == row) {
            matchRow = YES;
            break;
        }
    }
    if(!matchRow) return nil;
    
    return [NSIndexPath indexPathForRow:rowCounter inSection:sectionCounter];
}

- (GSRow *)rowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger sectionCounter = -1;
    GSSection *xSection = nil;
    for (GSSection *section in self.sectionArray) {
        if (!section.isHidden) sectionCounter ++;
        if (sectionCounter == indexPath.section) {
            xSection = section;
            break;
        }
    }
    
    if (sectionCounter == -1) return nil;
    
    NSInteger rowCounter = -1;
    for (GSRow *row in xSection.rowArray) {
        if(!row.isHidden) rowCounter++;
        if(rowCounter == indexPath.row) {
            return row;
        }
    }
    
    return nil;
}

#pragma mark - setter/getter
- (NSMutableArray *)sectionArray {
    if (_sectionArray) return _sectionArray;
    
    _sectionArray = [NSMutableArray array];
    return _sectionArray;
}

- (NSUInteger)count {
    return self.sectionArray.count;
}

@end

@implementation GSFormBuilder (NSSubscript)
// 数组样式
- (GSSection *)objectAtIndexedSubscript:(NSUInteger)idx {
    if (self.sectionArray.count > idx) return self.sectionArray[idx];
    
    return nil;
}

- (void)setObject:(GSSection *)obj atIndexedSubscript:(NSUInteger)idx {
    if (self.sectionArray.count < idx) return;
    self.sectionArray[idx] = obj;
}

@end

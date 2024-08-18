#import "GSRow.h"

NSString *kGSHTTPPropertyKey = @"kGSHTTPPropertyKey";
NSString *kGSHTTPValueKey = @"kGSHTTPValueKey";

NSString *kValidateRetKey = @"kValidateRetKey";
NSString *kValidateMsgKey = @"kValidateMsgKey";

@interface GSRow ()

@end

@implementation GSRow

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super init];
    if (self) {
        _style = style;
        _reuseIdentifier = [reuseIdentifier copy];
    }
    
    return self;
}

#ifdef DEBUG
- (void)dealloc {
    NSLog(@"row dealloc %@", self);
}
#endif

@end

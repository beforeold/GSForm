#import <UIKit/UIKit.h>

@interface GSLabelFieldCell : UITableViewCell

@property (nonatomic, strong) UILabel *leftlabel;
@property (nonatomic, strong) UITextField *rightField;

@property (nonatomic, copy) void(^textChangeBlock)(NSString *text);

@end

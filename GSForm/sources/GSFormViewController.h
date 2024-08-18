//  表单控制器的基类

#import <UIKit/UIKit.h>

@class GSFormBuilder;

NS_ASSUME_NONNULL_BEGIN

@interface GSFormViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) GSFormBuilder *form;

@end

NS_ASSUME_NONNULL_END

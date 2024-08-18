#import <UIKit/UIKit.h>

@interface GenderPickerViewController : UIViewController

@property (nonatomic, copy) void(^pickBlock)(BOOL isMale);

@end

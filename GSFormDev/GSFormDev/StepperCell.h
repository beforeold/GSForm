#import <UIKit/UIKit.h>

@interface StepperCell : UITableViewCell

@property (nonatomic, copy) void(^stepperBlock)(double newValue);

- (void)updateValue:(double)value;

@end

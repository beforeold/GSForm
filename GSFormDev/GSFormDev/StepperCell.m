#import "StepperCell.h"

@interface StepperCell ()

@property (nonatomic, strong) UIStepper *stepper;

@end

@implementation StepperCell
#pragma mark - lifeCycle
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.stepper];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat centerX = self.contentView.frame.size.width - (self.stepper.bounds.size.width * 0.5 + 15);
    self.stepper.center = CGPointMake(centerX, self.contentView.frame.size.height * 0.5);
    
    self.detailTextLabel.frame = CGRectMake(0, 0, CGRectGetMinX(self.stepper.frame) - 15, self.contentView.frame.size.height);
}

- (void)updateValue:(double)value {
    self.detailTextLabel.text = [NSString stringWithFormat:@"%.0f", value];
    _stepper.value = value;
}

#pragma mark - event reponse
- (void)step:(UIStepper *)stepper {
    self.detailTextLabel.text = [NSString stringWithFormat:@"%.0f", stepper.value];
    
    !self.stepperBlock ?: self.stepperBlock(stepper.value);
}

#pragma mark - setter/getter
- (UIStepper *)stepper {
    if (_stepper) return _stepper;
    
    _stepper = [[UIStepper alloc] init];
    _stepper.minimumValue = 0;
    _stepper.maximumValue = 100;
    _stepper.stepValue = 1;
    [_stepper addTarget:self action:@selector(step:) forControlEvents:UIControlEventValueChanged];
    
    return _stepper;
}

@end

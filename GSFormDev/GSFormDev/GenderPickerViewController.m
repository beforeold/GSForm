#import "GenderPickerViewController.h"

@interface GenderPickerViewController ()

@end

@implementation GenderPickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    for (NSInteger i = 0; i < 2; ++i) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        CGFloat width = 88;
        
        [button setTitle:i ? @"Male" :@"Female" forState:UIControlStateNormal];
        button.frame = CGRectMake(50 + i * (width + 20), 100, width, 50);
        button.tag = i;
        [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:button];
    }
}

- (void)buttonClick:(UIButton *)button {
    !self.pickBlock ?: self.pickBlock(button.tag);
}

@end

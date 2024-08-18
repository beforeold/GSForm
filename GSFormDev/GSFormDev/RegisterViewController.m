#import "RegisterViewController.h"

// view
#import "GSLabelFieldCell.h"
#import "StepperCell.h"

// controller
#import "GenderPickerViewController.h"


static NSString *const kLeftKey = @"kLeftKey"; // 标记左侧内容
static NSString *const kRightKey = @"kRightKey"; // 标记右侧内容
static NSString *const kFlagKey = @"kFlagKey"; // 用于标记是否有箭头
static NSString *const kDisableKey = @"kDisableKey"; // 用于标记禁用 textField

@interface RegisterViewController ()

@end

@implementation RegisterViewController
#pragma mark - lifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];

    [self initialSetup];
    [self buildRows];
}

#pragma mark - event reponse
- (void)submit:(id)sender {
    NSDictionary *dic = [self.form validateRows];
    
    if (![dic[kValidateRetKey] boolValue]) {
        [self alertMsg:dic[kValidateMsgKey]];
    } else {
        // 获取请求参数，可以根据业务需求，自定义 fetch 方法用于发起请求
        // 比如此类中的 fetchParams 方法
        NSString *msg = [[self.form fetchHttpParams] description];
        [self alertMsg:msg title:@"Params are OK"];
    }
}

- (NSDictionary *)fetchParams {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    for (GSSection *secion in self.form.sectionArray) {
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


#pragma mark - private methods
- (void)initialSetup {
    self.title = @"Registration";
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithTitle:@"Submit"
                                                              style:UIBarButtonItemStylePlain
                                                             target:self
                                                             action:@selector(submit:)];
    self.navigationItem.rightBarButtonItem = right;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return section ? @"DETAILS" : @"ACCOUNT";
}


- (void)buildRows {
    [self.form addSection:[self sectionForAccount]];
    [self.form addSection:[self sectionForDetail]];
}

- (GSSection *)sectionForAccount {
    GSSection *section = nil;
    GSRow *row = nil;
    
    section = [[GSSection alloc] init];
    section.headerHeight = 40;
    
    
    NSDictionary *dic = @{kLeftKey:@"Email"};
    row = [self rowForFieldWithUserInfo:dic];
    [section addRow:row];
    
    dic = @{kLeftKey:@"Password"};
    GSRow *row1 = [self rowForFieldWithUserInfo:dic];
    [section addRow:row1];

    dic = @{kLeftKey:@"Repeat Password"};
    row = [self rowForFieldWithUserInfo:dic];
    
    /// 校验密码是否一致
    row.valueValidateBlock = ^NSDictionary *(id value){
        if ([row1.value[kRightKey] isEqualToString:value[kRightKey]]) return rowOK();
        return rowError(@"Two password should be the same");
    };
    
    [section addRow:row];
    
    return section;
}

- (GSSection *)sectionForDetail {
    GSSection *section = nil;
    GSRow *row = nil;
    
    section = [[GSSection alloc] init];
    section.headerHeight = 40;

    NSDictionary *dic = @{kLeftKey:@"Name"};
    row = [self rowForFieldWithUserInfo:dic];
    [section addRow:row];
    

    row = [self rowForGender];
    [section addRow:row];
    
    
    row = [self rowForBirthDay];
    [section addRow:row];
    
    
    row = [self rowForStepper];
    [section addRow:row];

    return section;
}

- (GSRow *)rowForGender {
    GSRow *row = nil;
    
    NSDictionary *dic = @{kLeftKey:@"Gender",
                          kFlagKey:@YES,
                          kDisableKey:@YES};
    row = [self rowForFieldWithUserInfo:dic];
    __weak typeof(self) weakSelf = self;
    row.didSelectCellBlock = ^(NSIndexPath *indexPath, id value, id cell){
        /// 前往二级页面
        GenderPickerViewController *vc = [[GenderPickerViewController alloc] init];
        vc.pickBlock = ^(BOOL isMale){
            [weakSelf.navigationController popToViewController:weakSelf animated:YES];
            
            value[kRightKey] = isMale ? @"Male" : @"Female";
            [weakSelf.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationMiddle];
        };
        [weakSelf.navigationController pushViewController:vc animated:YES];
    };
    
    return row;
}

- (GSRow *)rowForStepper {
    GSRow *row = nil;
    
    row = [[GSRow alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Stepper"];
    row.cellClass = [StepperCell class];
    row.rowHeight = 44.f;
    row.value = @{kLeftKey:@"Age"}.mutableCopy;
    row.rowConfigBlock = ^(StepperCell *cell, id value, NSIndexPath *indexPath){
        cell.textLabel.text = value[kLeftKey];
        [cell updateValue:[value[kRightKey] doubleValue]];
        
        cell.stepperBlock = ^(double newValue){
            value[kRightKey] = @(newValue);
        };
    };
    
    return row;
}

- (GSRow *)rowForBirthDay {
    GSRow *row = nil;
    
    NSDictionary *dic = @{kLeftKey:@"Date of Birth"};
    row = [self rowForFieldWithUserInfo:dic];
    
    /// 加入黑名单
    row.disableValidateBlock = ^NSDictionary *(id value, BOOL didClicked){
        NSString *msg = @"此行已禁用，暂不支持";
        if (didClicked) [self alertMsg:msg];
        return rowError(msg);
    };
    
    return row;
}

- (GSRow *)rowForFieldWithUserInfo:(NSDictionary *)userInfo {
    GSRow *row = nil;
    row = [[GSRow alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"lableFiled"];
    row.rowHeight = 44.f;
    row.cellClass = [GSLabelFieldCell class];
    
    row.value = userInfo.mutableCopy;
    row.rowConfigBlock = ^(GSLabelFieldCell *cell, id value, NSIndexPath *indexPath){
        cell.leftlabel.text = value[kLeftKey];
        cell.rightField.text = value[kRightKey];
        cell.rightField.enabled = ![value[kDisableKey] boolValue];
        cell.rightField.placeholder = value[kLeftKey];
        
        BOOL hasArrow =  [value[kFlagKey] boolValue];
        cell.accessoryType = hasArrow ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
        
        cell.textChangeBlock = ^(NSString *text){
            value[kRightKey] = text;
        };
    };
    
    row.httpParamConfigBlock = ^(id value) {
        NSMutableDictionary *ret = [NSMutableDictionary dictionaryWithCapacity:1];
        ret[value[kLeftKey]] = value[kRightKey];
        return ret;
    };
    
    return row;
}

- (void)alertMsg:(NSString *)msg title:(NSString *)title {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:msg
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *done = [UIAlertAction actionWithTitle:@"Done" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:done];
    [self presentViewController:alert animated:YES completion:nil];
}

/// 弹窗
- (void)alertMsg:(NSString *)msg {
    [self alertMsg:nil title:msg];
}

@end

//
//  GSLabelFieldCell.m
//  GS3PL
//
//  Created by Brook on 2017/4/22.
//  Copyright © 2017年 Brook. All rights reserved.
//

#import "GSLabelFieldCell.h"

static const CGFloat kFieldWidth = 150.f;

@implementation GSLabelFieldCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.leftlabel];
        [self.contentView addSubview:self.rightField];
        
    }
    
    return self;
}

- (void)textFieldDidChange:(UITextField *)field {
    if ([self textChangeBlock]) {
        [self textChangeBlock](field.text);
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat margin = 15;
    self.leftlabel.frame = CGRectMake(margin, 0, self.contentView.frame.size.width, self.contentView.frame.size.height);
    
    CGFloat padding = 10;
    CGFloat x = self.contentView.frame.size.width - margin - kFieldWidth;
    self.rightField.frame = CGRectMake(x, padding, kFieldWidth, self.contentView.frame.size.height - 2 * padding);
}

#pragma mark - setter/getter
- (void)setTextChangeBlock:(void (^)(NSString *))textChangeBlock {
    _textChangeBlock = [textChangeBlock copy];
    [_rightField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
}

- (UILabel *)leftlabel {
    if (_leftlabel) return _leftlabel;
    
    _leftlabel = [[UILabel alloc] init];
    _leftlabel.font = [UIFont systemFontOfSize:15];
    _leftlabel.textColor = [UIColor blackColor];

    return _leftlabel;
}

- (UITextField *)rightField {
    if (!_rightField) {
        _rightField = [[UITextField alloc] init];
        _rightField.textAlignment = NSTextAlignmentRight;
        _rightField.textColor = [UIColor darkGrayColor];
        _rightField.font = [UIFont systemFontOfSize:13];
    }
    
    return _rightField;
}

@end

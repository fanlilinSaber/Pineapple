//
//  PWDeviceCell.m
//  Pineapple
//
//  Created by Fan Li Lin on 2017/3/29.
//
//

#import "PWDeviceCell.h"
#import <Masonry/Masonry.h>

@implementation PWDeviceCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectedBackgroundView = [UIView new];
        self.selectedBackgroundView.backgroundColor = [UIColor greenColor];
        
        UILabel *nameLabel = [UILabel new];
        UILabel *addressLabel = [UILabel new];
        
        [self.contentView addSubview:nameLabel];
        [self.contentView addSubview:addressLabel];
        
        [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView.mas_top).with.offset(10);
            make.leading.equalTo(self.contentView.mas_leading).with.offset(16);
        }];
        [addressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(nameLabel.mas_bottom).with.offset(10);
            make.leading.equalTo(self.contentView.mas_leading).with.offset(16);
            make.bottom.equalTo(self.contentView.mas_bottom).with.offset(-10);
        }];
        
        self.nameLabel = nameLabel;
        self.addressLabel = addressLabel;
    }
    return self;
}

@end

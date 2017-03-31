//
//  PWDeviceCell.m
//  Pineapple
//
//  Created by Dan Jiang on 2017/3/29.
//
//

#import "PWDeviceCell.h"
@import Masonry;

@implementation PWDeviceCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        UILabel *nameLabel = [UILabel new];
        UILabel *addressLabel = [UILabel new];
        UILabel *statusLabel = [UILabel new];
        
        [self.contentView addSubview:nameLabel];
        [self.contentView addSubview:addressLabel];
        [self.contentView addSubview:statusLabel];
        
        [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView.mas_top).with.offset(10);
            make.leading.equalTo(self.contentView.mas_leading).with.offset(16);
        }];
        [addressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(nameLabel.mas_bottom).with.offset(10);
            make.leading.equalTo(self.contentView.mas_leading).with.offset(16);
            make.bottom.equalTo(self.contentView.mas_bottom).with.offset(-10);
        }];
        [statusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.contentView.mas_centerY);
            make.trailing.equalTo(self.contentView.mas_trailing).with.offset(-10);
        }];

        self.nameLabel = nameLabel;
        self.addressLabel = addressLabel;
        self.statusLabel = statusLabel;
    }
    return self;
}

@end

//
//  nrCell.m
//  NR Inject
//
//  Created by Fabian Buentello on 1/20/15.
//  Copyright (c) 2015 Fabian Buentello. All rights reserved.
//

#import "nrCell.h"

@implementation nrCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

//
//  BorrowTableViewCell.h
//  BorrowBug
//
//  Created by Chris on 11/8/15.
//  Copyright © 2015 Chris Repanich. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BorrowListing.h"
@interface BorrowTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *itemLabel;
@property (strong, nonatomic) BorrowListing* object;
@property (strong, nonatomic) IBOutlet UIButton *reminderButton;

@end

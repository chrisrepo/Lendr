//
//  SettingsTableViewController.h
//  BorrowBug
//
//  Created by Chris on 11/9/15.
//  Copyright © 2015 Chris Repanich. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsTableViewController : UITableViewController
@property (strong, nonatomic) UITextView* smsTextView;
@property (strong, nonatomic) NSString* smsTextString;
@end

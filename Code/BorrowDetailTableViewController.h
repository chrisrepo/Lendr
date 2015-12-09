//
//  BorrowDetailTableViewController.h
//  BorrowBug
//
//  Created by Chris on 11/26/15.
//  Copyright © 2015 Chris Repanich. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BorrowDetailTableViewController : UITableViewController <UITextFieldDelegate>
@property (strong, nonatomic) NSString* name;
@property (strong, nonatomic) NSString* phoneNumber;
@property (strong, nonatomic) NSString* object;
@property (strong, nonatomic) NSString* returnBy;

@property int objectIndex;

@property (strong, nonatomic) UITextField* nameField;
@property (strong, nonatomic) UITextField* phoneNumberField;
@property (strong, nonatomic) UITextField* objectBorrowedField;
@property (strong, nonatomic) UITextField* returnTimeField;
@end

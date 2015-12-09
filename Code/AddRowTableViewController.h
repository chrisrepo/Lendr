//
//  AddRowTableViewController.h
//  BorrowBug
//
//  Created by Chris on 11/15/15.
//  Copyright © 2015 Chris Repanich. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface AddRowTableViewController : UITableViewController <UITextFieldDelegate>
@property (strong, nonatomic) NSMutableArray* sectionData;
@property (strong, nonatomic) NSMutableArray* sectionCount;
@property (strong, nonatomic) NSMutableArray* rowData;
@property (strong, nonatomic) NSMutableArray* contactList;

@property (strong, nonatomic) NSString* name;
@property (strong, nonatomic) NSString* phoneNumber;
@property (strong, nonatomic) NSString* object;
@property (strong, nonatomic) NSString* returnBy;

@property (strong, nonatomic) UITextField* nameField;
@property (strong, nonatomic) UITextField* phoneNumberField;
@property (strong, nonatomic) UITextField* objectBorrowedField;
@property (strong, nonatomic) UITextField* returnTimeField;

@property (strong, nonatomic) NSMutableArray* autocompleteArray;
@property BOOL isAutocompleteNeeded;
@property BOOL isAutocompleteEnabled;
@property (strong, nonatomic) NSString* currentString;
@property (strong, nonatomic) NSArray* lastIndexPaths;
@property (strong, nonatomic) UISwitch* autocompleteSwitch;
@end

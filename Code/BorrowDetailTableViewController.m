//
//  BorrowDetailTableViewController.m
//  BorrowBug
//
//  Created by Chris on 11/26/15.
//  Copyright © 2015 Chris Repanich. All rights reserved.
//

#import "BorrowDetailTableViewController.h"
#import "BorrowListing.h"
#import "Constants.h"
#define UIColorFromHex(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface BorrowDetailTableViewController () {
    NSString* _nameLabel;
    NSString* _phoneNumberLabel;
    NSString* _objectBorrowedLabel;
    NSString* _returnTimeLabel;
    
    NSString* _doneLabel;
    NSString* _editLabel;
    
    BOOL _canEdit;
    BOOL _firstLoad;
}

@end

@implementation BorrowDetailTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //view customizations
    self.title = @"Details";
    //variable declarations and assignments
    _canEdit = NO;
    
    _nameLabel = @"Name:";
    _phoneNumberLabel = @"Phone Number:";
    _objectBorrowedLabel = @"Borrowed:";
    _returnTimeLabel = @"Will return by:";
    
    _doneLabel = @"Done";
    _editLabel = @"Edit";
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillDisappear:(BOOL)animated {
    if (self.isMovingFromParentViewController){
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Incomplete implementation, return the number of sections
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
    if (section == 0) {
        //details
        return 4;
    } else if (section == 1) {
        //edit/doneWithEdit button
        return 1;
    }
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc]init];
    
    if (indexPath.section == 0) {
        //text field section
        if (indexPath.row == 0) {
            cell.textLabel.text = _nameLabel;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            UITextField *tf = [self makeTextField:self.name placeholder:@""];
            _nameField = tf;
            _nameField.delegate = self;
            [_nameField setEnabled:NO];
            [cell addSubview:_nameField];
        } else if (indexPath.row == 1) {
            cell.textLabel.text = _phoneNumberLabel;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            UITextField *tf = [self makeTextField:self.phoneNumber placeholder:@""];
            _phoneNumberField = tf;
            _phoneNumberField.delegate = self;
            [_phoneNumberField setEnabled:NO];
            [cell addSubview:_phoneNumberField];
        } else if (indexPath.row == 2) {
            cell.textLabel.text = _objectBorrowedLabel;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            UITextField *tf = [self makeTextField:self.object placeholder:@""];
            _objectBorrowedField = tf;
            _objectBorrowedField.delegate = self;
            [_objectBorrowedField setEnabled:NO];
            [cell addSubview:_objectBorrowedField];
        } else if (indexPath.row == 3) {
            cell.textLabel.text = _returnTimeLabel;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            UITextField *tf = [self makeTextField:self.returnBy placeholder:@""];
            _returnTimeField = tf;
            _returnTimeField.delegate = self;
            [_returnTimeField setEnabled:NO];
            [cell addSubview:_returnTimeField];
        }
    } else {
        //mark returned cell
        if (_canEdit) {
            cell.textLabel.text = _doneLabel;
        } else {
            cell.textLabel.text = _editLabel;
        }
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
    }
    // Configure the cell...
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        //done/edit row
        if (_canEdit) {
            //save row before we toggle
            BorrowListing* toSave = [[BorrowListing alloc]init];
            [self setTextFieldValues];
            if (![self validateName]) {
                //name invalid
                NSLog(@"ERROR: Name Invalid");
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
                [self displayErrorMessage:@"Name Invalid" withMessage:@"Name field must not be empty" withButtonText:@"Ok"];
                return;
            }
            if (![self validatePhoneNumber]) {
                NSLog(@"ERROR: Phone Number Invalid: %@", self.phoneNumber);
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
                [self displayErrorMessage:@"Phone Number Invalid" withMessage:@"Please use the format:\n #(###)###-####" withButtonText:@"Ok"];
                //phone invalide
                return;
            }
            if (![self validateObject]) {
                NSLog(@"ERROR: Object Invalid");
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
                [self displayErrorMessage:@"Object Invalid" withMessage:@"Object field must not be empty" withButtonText:@"Ok"];
                //object invalid
                return;
            }
            if (![self validateReturn]) {
                NSLog(@"ERROR: Return Invalid");
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
                [self displayErrorMessage:@"Return Time Invalid" withMessage:@"Return time field must not be empty" withButtonText:@"Ok"];
                // return invalid
                return;
            }
            toSave.name = _nameField.text;
            toSave.phoneNumber = _phoneNumberField.text;
            toSave.objectBorrowed = _objectBorrowedField.text;
            toSave.returnBy = _returnTimeField.text;
            [self replaceCurrentObjectWith:toSave atIndex:_objectIndex forKey:BorrowBugArrayName];
        }
        [self toggleFieldEditable:!_canEdit];
    }
}

-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([indexPath row] == ((NSIndexPath*)[[tableView indexPathsForVisibleRows] lastObject]).row){
        
    }
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark helper methods 

- (void)setTextFieldValues{
    self.name = self.nameField.text;
    self.phoneNumber = self.phoneNumberField.text;
    self.object = self.objectBorrowedField.text;
    self.returnBy = self.returnTimeField.text;
}

- (BOOL) validateName {
    if (self.name.length < 1) {
        return NO;
    }
    return YES;
}

- (BOOL) validateObject {
    if (self.object.length < 1) {
        return NO;
    }
    return YES;
}

- (BOOL) validateReturn {
    if (self.returnBy.length < 1) {
        return NO;
    }
    return YES;
}

- (BOOL) validatePhoneNumber{
    //check phone number hyphens and parens
    long hyphenCount = [[self.phoneNumber componentsSeparatedByString:@"-"] count]-1;
    long leftParenCount = [[self.phoneNumber componentsSeparatedByString:@"("] count]-1;
    long rightParenCount = [[self.phoneNumber componentsSeparatedByString:@")"] count]-1;
    if (hyphenCount > 2) {
        return NO;
    }
    if (leftParenCount > 1 || rightParenCount > 1 || (rightParenCount == 1 && leftParenCount != 1) || (rightParenCount != 1 && leftParenCount == 1)) {
        //if unequal parens or too many
        return NO;
    }
    
    //check if rest is digits
    NSString* phoneTest = [self.phoneNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    phoneTest = [phoneTest stringByReplacingOccurrencesOfString:@"(" withString:@""];
    phoneTest = [phoneTest stringByReplacingOccurrencesOfString:@")" withString:@""];
    NSArray* words = [phoneTest componentsSeparatedByCharactersInSet :[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    phoneTest = [words componentsJoinedByString:@""];
    if (phoneTest.length != 10 && phoneTest.length != 11) {
        if (phoneTest.length == 7) {
            NSLog(@"DEBUG: Phone number missing area code");
            return NO;
        }
        //invalid # of digits
        return NO;
    }
    
    NSScanner *scanner = [NSScanner scannerWithString:phoneTest];
    BOOL isNumeric = [scanner scanInteger:NULL] && [scanner isAtEnd];
    if (!isNumeric) {
        //not numeric
        return NO;
    }
    return YES;
}

- (void)displayErrorMessage:(NSString *) title withMessage:(NSString*) msg withButtonText:(NSString *)bText {
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:title
                                  message:msg
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* yesButton = [UIAlertAction
                                actionWithTitle:bText
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action)
                                {
                                    //Handel your yes please button action here
                                    [alert dismissViewControllerAnimated:YES completion:nil];
                                    
                                }];
    
    [alert addAction:yesButton];
    
    [self presentViewController:alert animated:YES completion:nil];
    
}

-(UITextField*) makeTextField: (NSString*)text placeholder: (NSString*)placeholder  {
#warning hardcoded frame size. RIP layout on other devices
    UITextField *tf = [[UITextField alloc]  initWithFrame:CGRectMake(150, 13, 375, 30)];
    tf.placeholder = placeholder ;
    tf.text = text ;
    tf.autocorrectionType = UITextAutocorrectionTypeNo ;
    tf.autocapitalizationType = UITextAutocapitalizationTypeNone;
    tf.adjustsFontSizeToFitWidth = YES;
    tf.textColor = UIColorFromHex(0x000000);
    return tf ;
}

// It is important for you to hide the keyboard
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(void) toggleFieldEditable:(BOOL) val{
    _canEdit = val;
    //disable fields
    [_nameField setEnabled:val];
    [_phoneNumberField setEnabled:val];
    [_objectBorrowedField setEnabled:val];
    [_returnTimeField setEnabled:val];
    //set label of cell to edit.
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:1]] withRowAnimation:UITableViewRowAnimationNone];
}

- (NSMutableArray *)loadCustomObjectWithKey:(NSString *)key {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray* arr = [defaults objectForKey:key];
    NSMutableArray* fin = [[NSMutableArray alloc]init];
    for (NSData *borrow in arr) {
        BorrowListing *object = [NSKeyedUnarchiver unarchiveObjectWithData:borrow];
        [fin addObject:object];
    }
    return fin;
}

-(void)replaceCurrentObjectWith:(BorrowListing *)object atIndex:(int)index forKey:(NSString *) key {
    NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:object];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSMutableArray *borrows = [[NSMutableArray alloc]initWithArray:[prefs objectForKey:key]];
    [borrows replaceObjectAtIndex:index withObject:encodedObject];
    [prefs setObject:borrows forKey:key];
    [prefs synchronize];
    
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    NSLog(@"BUTTON");
}


@end

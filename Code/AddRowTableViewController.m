//
//  AddRowTableViewController.m
//  BorrowBug
//
//  Created by Chris on 11/15/15.
//  Copyright © 2015 Chris Repanich. All rights reserved.
//

#import "AddRowTableViewController.h"
#import "BorrowListing.h"
#import "Constants.h"
#import "Contact.h"
@import Contacts;
#import <MessageUI/MessageUI.h>

#define UIColorFromHex(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#warning TODO: Add a way to dismiss keyboard
/*
    ALSO TODO:
    - Fix cell dequeue problem (if cell goes above or below view/ out of view, it deques and loses it's value)
 */
@interface AddRowTableViewController () {
    NSString* _nameLabel;
    NSString* _phoneNumberLabel;
    NSString* _objectBorrowedLabel;
    NSString* _returnTimeLabel;
    
    NSString* _importContactLabel;
    NSString* _doneLabel;
    
    NSString* _namePlaceholder;
    NSString* _phoneNumberPlaceholder;
    NSString* _objectBorrowedPlaceholder;
    NSString* _returnTimePlaceholder;
    //auto completeion vars
}

@end

@implementation AddRowTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //customize nav bar
    self.title = @"Add New";
    
    //initialize member vars
    _autocompleteArray = [[NSMutableArray alloc]init];
    _isAutocompleteNeeded = NO;
    _isAutocompleteEnabled = NO;
    _sectionCount = [[NSMutableArray alloc]initWithArray:@[@1,@4,@1]];
    _currentString = @"";
    _importContactLabel = @"Use Contacts";
    _doneLabel = @"Done";
    
    _nameLabel = @"Name:";
    _phoneNumberLabel = @"Phone Number:";
    _objectBorrowedLabel = @"Borrowed:";
    _returnTimeLabel = @"Will return by:";
    
    _namePlaceholder = @"Billy Borrower";
    _phoneNumberPlaceholder = @"555-555-5555";
    _objectBorrowedPlaceholder = @"$20";
    _returnTimePlaceholder = @"Nov 15, 2016";
    
    _phoneNumberField.delegate = self;
    _objectBorrowedField.delegate = self;
    _returnTimeField.delegate = self;
    
    //create row data and add the data for each row
    _rowData = [[NSMutableArray alloc]init];
    [_rowData addObject:[[NSArray alloc]initWithObjects:@[_nameLabel, _namePlaceholder], nil]];
    [_rowData addObject:[[NSArray alloc]initWithObjects:@[_phoneNumberLabel, _phoneNumberPlaceholder], nil]];
    [_rowData addObject:[[NSArray alloc]initWithObjects:@[_objectBorrowedLabel, _objectBorrowedPlaceholder], nil]];
    [_rowData addObject:[[NSArray alloc]initWithObjects:@[_returnTimeLabel, _returnTimePlaceholder], nil]];
    
    //Contact authorization check
    _contactList = [[NSMutableArray alloc]init];
    if ([CNContactStore class]) {
        if( [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts] == CNAuthorizationStatusNotDetermined)
        {
            CNContactStore * contactStore = [[CNContactStore alloc] init];
            [contactStore requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable     error) {
                if(granted){
                    [self getAllContact];
                }
                if (error != nil) {
                    NSLog(@"ERROR: Contact store request access error");
                }
            }];
        }
        else if( [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts]== CNAuthorizationStatusAuthorized)
        {
            [self getAllContact];
        }
    }
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
   // NSLog(@"Section count: %ld", [_sectionCount count]);
    return _sectionCount.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
   // NSLog(@"Section %ld,\tRows %@", (long)section, [_sectionCount objectAtIndex:section]);
    if (section == 1) {
        if (_isAutocompleteNeeded) {
            return _rowData.count + _autocompleteArray.count;
        } else {
            return _rowData.count;
        }
    } else if (section == 0) {
        return 2;
    } else {
        return 1;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    //cell will never be nil this way. useless code
    if (cell == nil) {
        cell = [[UITableViewCell alloc] init];
    }
    
    if (indexPath.section == 1) {
        //text field section
        
        
        if (indexPath.row == 0) {
            NSArray *data = [_rowData objectAtIndex:0];
            data = [data objectAtIndex:0];
            cell.textLabel.text = [data objectAtIndex:0];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            UITextField *tf = [self makeTextField:_currentString placeholder:[data objectAtIndex:1]];
            _nameField = tf;
            _nameField.delegate = self;
            _nameField.tag = 10;
            [_nameField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
            [cell addSubview:_nameField];
        } else if (indexPath.row == (_rowData.count + _autocompleteArray.count - 3)) {
            NSArray *data = [_rowData objectAtIndex:1];
            data = [data objectAtIndex:0];
            cell.textLabel.text = [data objectAtIndex:0];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            UITextField *tf = [self makeTextField:@"" placeholder:[data objectAtIndex:1]];
            _phoneNumberField = tf;
            _phoneNumberField.delegate = self;
            [cell addSubview:_phoneNumberField];
        } else if (indexPath.row == (_rowData.count + _autocompleteArray.count - 2)) {
            NSArray *data = [_rowData objectAtIndex:2];
            data = [data objectAtIndex:0];
            cell.textLabel.text = [data objectAtIndex:0];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            UITextField *tf = [self makeTextField:@"" placeholder:[data objectAtIndex:1]];
            _objectBorrowedField = tf;
            _objectBorrowedField.delegate = self;
            [cell addSubview:_objectBorrowedField];
        } else if (indexPath.row == (_rowData.count + _autocompleteArray.count - 1)) {
            NSArray *data = [_rowData objectAtIndex:3];
            data = [data objectAtIndex:0];
            cell.textLabel.text = [data objectAtIndex:0];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            UITextField *tf = [self makeTextField:@"" placeholder:[data objectAtIndex:1]];
            _returnTimeField = tf;
            _returnTimeField.delegate = self;
            [cell addSubview:_returnTimeField];
        } else {
            //autocomplete row
            if (_isAutocompleteNeeded) {
                Contact *rowContact = [_autocompleteArray objectAtIndex:indexPath.row-1];
                cell.textLabel.text = rowContact.fullName;
                cell.backgroundColor = UIColorFromHex(0xE6E6E6);
            }
        }
        /*
        switch (indexPath.row) {
            case 0:{
                _nameField = tf;
                [cell addSubview:_nameField];
                break;
            }
            case 1:{
                _phoneNumberField = tf;
                [cell addSubview:_phoneNumberField];
                break;
            }
            case 2:{
                _objectBorrowedField = tf;
                [cell addSubview:_objectBorrowedField];
                break;
            }
            case 3:{
                _returnTimeField = tf;
                [cell addSubview:_returnTimeField];
                break;
            }
        }
         */
    } else if(indexPath.section == 0){
            if (indexPath.row == 0) {
                //import contact cell
                cell.textLabel.text = _importContactLabel;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                _autocompleteSwitch = [[UISwitch alloc]init];
                [_autocompleteSwitch addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
#warning This CGRect is a hardcoded piece of shit. RIP layout on other devices besides iPhone 6. Needs fixing
                _autocompleteSwitch.frame = CGRectMake(250,6, _autocompleteSwitch.intrinsicContentSize.width, _autocompleteSwitch.intrinsicContentSize.height);
                if (_isAutocompleteEnabled) {
                    [_autocompleteSwitch setOn:YES];
                } else {
                    [_autocompleteSwitch setOn:NO];
                }
                [cell addSubview:_autocompleteSwitch];
            } else if (indexPath.row == 1) {
                cell.textLabel.text = @"Turn this on to allow autocomplete via contacts";
                cell.textLabel.textAlignment = NSTextAlignmentCenter;
                cell.textLabel.font = [UIFont systemFontOfSize:12];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
    } else {
        //mark returned cell
        cell.textLabel.text = _doneLabel;
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
    }
    // Configure the cell...
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 2) {
        //done cell clicked
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
        
        BorrowListing *toAdd = [[BorrowListing alloc]init];
        toAdd.name = self.name;
        toAdd.phoneNumber = self.phoneNumber;
        toAdd.objectBorrowed = self.object;
        toAdd.returnBy = self.returnBy;
        [self saveCustomObject:toAdd key:BorrowBugArrayName];
        [self performSegueWithIdentifier:@"doneAddButton" sender:self];
    } else if (indexPath.section == 1) {
        if ([self.tableView numberOfRowsInSection:1] > 4) {
            //if its not the first row, or the last 3, find the index within _autocomplete array to fill the name/phone field
            if (indexPath.row > 0 && indexPath.row < [self.tableView numberOfRowsInSection:1] - 3) {
                Contact* chosen = [_autocompleteArray objectAtIndex:indexPath.row - 1];
                NSLog(@"DEBUG: Row chosen: %@:",chosen.fullName);
                //
                _nameField.text = chosen.fullName;
                //default to first phone number
                if ([chosen.phone count] > 0) {
                    _phoneNumberField.text = [[chosen.phone objectAtIndex:0] stringValue];
                }
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
                [self endAutocomplete];
            }
        }
    }
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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


#pragma mark - text field methods

- (void)setTextFieldValues{
    self.name = self.nameField.text;
    self.phoneNumber = self.phoneNumberField.text;
    self.object = self.objectBorrowedField.text;
    self.returnBy = self.returnTimeField.text;
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

//hide keyboard when return is pressed
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - helper methods

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

-(void)saveCustomObject:(BorrowListing *)object key:(NSString *)key {
    NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:object];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSMutableArray *borrows = [[NSMutableArray alloc]initWithArray:[prefs objectForKey:key]];
    [borrows addObject:encodedObject];
    [prefs setObject:borrows forKey:key];
    [prefs synchronize];
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [[event allTouches] anyObject];
    if ([_nameField isFirstResponder] && [touch view] != _nameField) {
        [_nameField resignFirstResponder];
    } else if ([_phoneNumberField isFirstResponder] && [touch view] != _phoneNumberField) {
        [_phoneNumberField resignFirstResponder];
    } else if ([_objectBorrowedField isFirstResponder] && [touch view] != _objectBorrowedField) {
        [_objectBorrowedField resignFirstResponder];
    } else if ([_returnTimeField isFirstResponder] && [touch view] != _returnTimeField) {
        [_returnTimeField resignFirstResponder];
    }
}

-(void)getAllContact
{
    if([CNContactStore class])
    {
        //iOS 9 or later
        NSError* contactError;
        CNContactStore* addressBook = [[CNContactStore alloc]init];
        [addressBook containersMatchingPredicate:[CNContainer predicateForContainersWithIdentifiers: @[addressBook.defaultContainerIdentifier]] error:&contactError];
        NSArray * keysToFetch =@[CNContactEmailAddressesKey, CNContactPhoneNumbersKey, CNContactFamilyNameKey, CNContactGivenNameKey, CNContactPostalAddressesKey];
        CNContactFetchRequest * request = [[CNContactFetchRequest alloc]initWithKeysToFetch:keysToFetch];
        BOOL success = [addressBook enumerateContactsWithFetchRequest:request error:&contactError usingBlock:^(CNContact * __nonnull contact, BOOL * __nonnull stop){
            [self parseContactWithContact:contact];
        }];
    }
}

- (void)parseContactWithContact :(CNContact* )contact {
    Contact* toAdd = [[Contact alloc]init];
    toAdd.firstName = contact.givenName;
    toAdd.lastName = contact.familyName;
    toAdd.phone = [contact.phoneNumbers valueForKey:@"value"];
    toAdd.email = [contact.emailAddresses valueForKey:@"value"];
    toAdd.fullName = [NSString stringWithFormat:@"%@ %@",toAdd.firstName, toAdd.lastName];
    [_contactList addObject:toAdd];
}

#pragma Autocomplete methods 
- (NSArray *)possibleCompletionsForString:(NSString *)string {
    NSMutableArray* returnValues = [[NSMutableArray alloc]init];
    for (Contact* cons in _contactList) {
        if ([[cons.fullName lowercaseString] containsString:[string lowercaseString]]) {
            [returnValues addObject:cons];
        }
    }
    
    return returnValues;
}

- (void)textFieldDidChange:(UITextField *)textField{
    if (textField.tag == 10) {
        //check if empty string (no longer need autocomplete) or less than 2 letters (saves computing)
        if (_autocompleteSwitch.isOn) {
            _isAutocompleteNeeded = YES;
        } else  {
            _isAutocompleteNeeded = NO;
        }
        if ((!([textField.text isEqualToString:@""] || [textField.text length] < 2)) && _isAutocompleteNeeded) {
            _currentString = textField.text;
            NSLog(@"DEBUG: Text entered into name field: %@", textField.text);
            _autocompleteArray = [[NSMutableArray alloc]initWithArray:[self possibleCompletionsForString:_currentString]];
            NSArray* indexes = [self createArrayOfIndexPaths:(int)_autocompleteArray.count];
            [self.tableView beginUpdates];
            if ([self.tableView numberOfRowsInSection:1] > 4) {
                NSLog(@"DEBUG: Deleting %ld old autocomplete rows", _lastIndexPaths.count);
                [self.tableView deleteRowsAtIndexPaths:_lastIndexPaths withRowAnimation:UITableViewRowAnimationNone];
            }
            NSLog(@"DEBUG: Inserting %ld new autocomplete rows", indexes.count);
            [self.tableView insertRowsAtIndexPaths:indexes withRowAnimation:UITableViewRowAnimationNone];
            [self.tableView endUpdates];
            _lastIndexPaths = indexes;
        } else {
            if ([self.tableView numberOfRowsInSection:1] > 4) {
                _autocompleteArray = nil;
                NSLog(@"DEBUG: Deleting old autocomplete rows");
                [self.tableView deleteRowsAtIndexPaths:_lastIndexPaths withRowAnimation:UITableViewRowAnimationNone];
            }
            _lastIndexPaths = nil;
        }
    }
    
}

- (void)switchChanged:(UISwitch *)sw {
    if (sw.isOn) {
        //turn on autocomplete
        NSLog(@"DEBUG: Use contact switch turned on");
        _isAutocompleteNeeded = YES;
        _isAutocompleteEnabled = YES;
    } else {
        //turn off autocomplete
        NSLog(@"DEBUG: Use contact switch turned off");
        [self endAutocomplete];
        _isAutocompleteEnabled = NO;

    }
}
                                       
- (void)endAutocomplete {
    _autocompleteArray = [[NSMutableArray alloc]init];
    NSLog(@"DEBUG: Deleting old autocomplete rows");
    [self.tableView deleteRowsAtIndexPaths:_lastIndexPaths withRowAnimation:UITableViewRowAnimationNone];
    _lastIndexPaths = [[NSMutableArray alloc]init];
    _isAutocompleteNeeded = NO;
}

- (NSArray *)createArrayOfIndexPaths:(int)sizeOfArray{
    NSMutableArray *toReturn = [[NSMutableArray alloc]init];
    for (int i=0; i < sizeOfArray; i++) {
        NSIndexPath *toAdd = [NSIndexPath indexPathForRow:i+1 inSection:1];
        [toReturn addObject:toAdd];
    }
    NSArray *array = [toReturn copy];
    return array;
}

@end

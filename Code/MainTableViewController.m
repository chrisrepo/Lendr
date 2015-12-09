//
//  MainTableViewController.m
//  Lendr
//
//  Created by Chris on 11/8/15.
//  Copyright © 2015 Chris Repanich. All rights reserved.
//

/*
    TODO:
    - Make Custom cell look better
    - Figure out color scheme
 */

#import "MainTableViewController.h"
#import "AddRowTableViewController.h"
#import "BorrowDetailTableViewController.h"
#import "Constants.h"
#import "BorrowListing.h"
#import "BorrowTableViewCell.h"
//custom static method to get UI color from a hex value
#define UIColorFromHex(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface MainTableViewController () {
    BorrowListing* _editBorrow;
    NSInteger _editIndex;
}

@end

@implementation MainTableViewController

- (void)viewWillAppear:(BOOL)animated {
    //load user defaults to get borrow array when view reappears (in case changes were made in detailView)
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];  //load NSUserDefaults
    if ([prefs objectForKey:BorrowBugArrayName] == nil) {
        NSLog(@"DEBUG: Borrow array in userDefaults is nil");
        [prefs setObject:_borrowArray forKey:BorrowBugArrayName];
        NSLog(@"DEBUG: Empty array placed in user defaults under key:%@", BorrowBugArrayName);
    } else {
        NSLog(@"DEBUG: Borrow array in userDefaults is NOT nil");
        NSLog(@"DEBUG: Copying array in userDefaults to local variable _borrowArray");
        _borrowArray = [self loadCustomObjectWithKey:BorrowBugArrayName];
    }
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //set back button to regular "back" text. As opposed to full root title
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
    //customize nav bar
    self.title = @"Lendr";
    
    //customize background
    self.view.backgroundColor = UIColorFromHex(0xF7F7F7);
    //register tableview cell nib
    [self.tableView registerNib:[UINib nibWithNibName:@"BorrowCell" bundle:nil]
         forCellReuseIdentifier:@"CustomCell"];
    
    //initialize local borrow array
    _borrowArray = [[NSMutableArray alloc]init];
    
    //load user defaults to get borrow array
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];  //load NSUserDefaults
    if ([prefs objectForKey:BorrowBugArrayName] == nil) {
        NSLog(@"DEBUG: Borrow array in userDefaults is nil");
        [prefs setObject:_borrowArray forKey:BorrowBugArrayName];
        NSLog(@"DEBUG: Empty array placed in user defaults under key:%@", BorrowBugArrayName);
    } else {
        NSLog(@"DEBUG: Borrow array in userDefaults is NOT nil");
        NSLog(@"DEBUG: Copying array in userDefaults to local variable _borrowArray");
        _borrowArray = [self loadCustomObjectWithKey:BorrowBugArrayName];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma data retrieval
//load object from nsuserdefaults
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
//delete object at index in nsuserdefaults array
- (void)deleteCustomObjectAtIndex:(NSInteger)index {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSMutableArray *borrows = [[NSMutableArray alloc]initWithArray:[prefs objectForKey:BorrowBugArrayName]];
    [borrows removeObjectAtIndex:index];
    [prefs setObject:borrows forKey:BorrowBugArrayName];
    [prefs synchronize];
}

#pragma mark - Table view data source
//default 1 section
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

//default 2 if array is empty, else its size of array
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //Set row count to number of objects in the borrow array
    if (_borrowArray.count < 1) {
        return 2;
    }
    return _borrowArray.count;
}

//Create cells
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //If borrowArray is empty, add the two filler cells
    if (_borrowArray.count < 1) {
        if (indexPath.row == 0) {
            UITableViewCell*  cell = [[UITableViewCell alloc] init];
            cell.textLabel.text = @"Tap \"Add New\" to create a listing";
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        } else if (indexPath.row == 1) {
            UITableViewCell*  cell = [[UITableViewCell alloc] init];
            cell.textLabel.text = @"Tap the gear icon to edit the reminder message";
            cell.textLabel.font = [UIFont systemFontOfSize:12];
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        } else {
            return nil;//error
        }
    } else { //borrow array not empty, add the listings
    BorrowTableViewCell *cell = (BorrowTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"CustomCell"];
    if (cell == nil) {
        cell = [[BorrowTableViewCell alloc] init];
    }
    // Configure the cell...
    BorrowListing *borrowed = [_borrowArray objectAtIndex:indexPath.row];
    cell.object = borrowed;
    NSLog(@"DEBUG: Configuring cell: %@",borrowed.name);
    cell.backgroundColor = UIColorFromHex(0xF7F7F7);
    
    cell.nameLabel.text = borrowed.name;
    cell.itemLabel.text = borrowed.objectBorrowed;
    cell.reminderButton.tag = indexPath.row;
    [cell.reminderButton addTarget:self action:@selector(sendReminderClicked:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
    }
}
//set hight for cells (default 80)
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

//handle cell selection
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_borrowArray.count < 1) {
        //do nothing if its the filler cell
        return;
    }
    _editBorrow = [_borrowArray objectAtIndex:indexPath.row];
    _editIndex = indexPath.row;
    [self performSegueWithIdentifier:@"editBorrow" sender:self];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    if (_borrowArray.count < 1) {
        return NO;//only filler cell
    }
    return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [self.borrowArray removeObjectAtIndex:indexPath.row];
        // Delete listing from NSUserDefaults
        [self deleteCustomObjectAtIndex:indexPath.row];
        [tableView reloadData];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}


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

#pragma mark - Helper Methods
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
                                    //Handle your yes please button action here
                                    [alert dismissViewControllerAnimated:YES completion:nil];
                                    
                                }];
    
    [alert addAction:yesButton];
    
    [self presentViewController:alert animated:YES completion:nil];
    
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"addBorrowTable"]) {
        AddRowTableViewController *dest = [segue destinationViewController];
        dest.navigationItem.leftBarButtonItem.title = @"Back";
    } else if ([segue.identifier isEqualToString:@"editBorrow"]) {
        BorrowDetailTableViewController *dest = [segue destinationViewController];
        dest.name = _editBorrow.name;
        dest.phoneNumber = _editBorrow.phoneNumber;
        dest.object = _editBorrow.objectBorrowed;
        dest.returnBy = _editBorrow.returnBy;
        dest.objectIndex = (int)_editIndex;
    }
    
}

#pragma mark message events
- (void)sendReminderClicked:(UIButton*)sender {
    NSLog(@"DEBUG: Send Reminder button pressed");
    //get listing of row where button was pressed using the sender tag
    BorrowListing *borrowed = [_borrowArray objectAtIndex:sender.tag];
    NSLog(@"DEBUG: Sending reminder to: %@", borrowed.name);
    
    if ([MFMessageComposeViewController canSendText])
        // The device can send email.
    {
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];  //load NSUserDefaults
        MFMessageComposeViewController *control = [[MFMessageComposeViewController alloc]init];
        
        //check prefs for custom message. if nil, create it
        if ([prefs objectForKey:SmsReminderName] == nil) {
            NSString* reminder = @"Hi, I just wanted to remind to you return the [item] you borrowed when you get a chance. Thank you!";
            [prefs setObject:reminder forKey:SmsReminderName];
        }
        NSString* textReminder = [prefs objectForKey:SmsReminderName];
        textReminder = [textReminder stringByReplacingOccurrencesOfString:@"[item]" withString:borrowed.objectBorrowed];
        control.body = textReminder;
        control.recipients = @[borrowed.phoneNumber];
        control.messageComposeDelegate = self;
        
        [self presentViewController:control animated:NO completion:NULL];
    }
    else
        // The device can not send messages.
    {
        NSLog(@"ERROR: Device Cannot send text");
        [self displayErrorMessage:@"Error" withMessage:@"Cannot send text\nPlease check service and try again" withButtonText:@"Ok"];
    }
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    switch (result) {
        case MessageComposeResultCancelled:
            NSLog(@"Message was cancelled");
            [self dismissViewControllerAnimated:YES completion:NULL];             break;
        case MessageComposeResultFailed:
            NSLog(@"Message failed");
            [self dismissViewControllerAnimated:YES completion:NULL];             break;
        case MessageComposeResultSent:
            NSLog(@"Message was sent");
            [self dismissViewControllerAnimated:YES completion:NULL];             break;
        default:             
            break;     
    } 
}

@end

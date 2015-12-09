//
//  SettingsTableViewController.m
//  BorrowBug
//
//  Created by Chris on 11/9/15.
//  Copyright © 2015 Chris Repanich. All rights reserved.
//

#import "SettingsTableViewController.h"
#import "Constants.h"

#define UIColorFromHex(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface SettingsTableViewController ()

@end

@implementation SettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //set title of view
    self.title = @"Settings";
    //set variables
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma cell helper methods

-(UITextView*) makeTextView{
    UITextView* tv = [[UITextView alloc]init];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];  //load NSUserDefaults
    if ([prefs objectForKey:SmsReminderName] == nil) {
        NSString* reminder = @"Hi, I just wanted to remind to you return the [item] you borrowed when you get a chance. Thank you!";
        [prefs setObject:reminder forKey:SmsReminderName];
    }
    _smsTextString = [prefs objectForKey:SmsReminderName];
    NSString* smsReminder = [prefs objectForKey:SmsReminderName];
   
    tv.text = smsReminder;
    
    tv.frame = CGRectMake(0, 0,self.view.frame.size.width, c_settingsTextAreaSize);
    [tv setFont:[UIFont systemFontOfSize:20]];
    return tv;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 2) {
        //done cell clicked
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];  //load NSUserDefaults
        [prefs setObject:_smsTextView.text forKey:SmsReminderName];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Incomplete implementation, return the number of sections
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
                //text area row
                 return c_settingsTextAreaSize;
                break;
            case 1:
                return 20;
            case 2:
                return 40;
            default:
                break;
        }
    }
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"settingsCell" forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]init];
    }
    // Configure the cell...
    if (indexPath.section == 0) {
        switch (indexPath.row)
        {
            case 0: {
                _smsTextView = [self makeTextView];
                [cell addSubview:_smsTextView];
                break;
            }
            case 1:{
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.textLabel.font = [UIFont systemFontOfSize:10];
                cell.textLabel.text = @"[item] will be replaced by the item borrowed in the text";
                break;
            }
            case 2: {
                cell.textLabel.text = @"Save";
                cell.textLabel.textAlignment = NSTextAlignmentCenter;
                break;
            }
        }
    }
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionName;
    switch (section)
    {
        case 0:
            sectionName = @"SMS Text Default Message";
            break;
    }
    return sectionName;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    if (indexPath.section == 0 && indexPath.row == 1) {
        return NO;
    }
    return YES;
}


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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

//
//  MainTableViewController.h
//  BorrowBug
//
//  Created by Chris on 11/8/15.
//  Copyright © 2015 Chris Repanich. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
@interface MainTableViewController : UITableViewController <MFMessageComposeViewControllerDelegate>
@property (strong,nonatomic) NSMutableArray* borrowArray;

@end

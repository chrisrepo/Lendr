//
//  Contact.h
//  BorrowBug
//
//  Created by Chris on 11/25/15.
//  Copyright © 2015 Chris Repanich. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Contact : NSObject
@property (strong, nonatomic) NSString* firstName;
@property (strong, nonatomic) NSString* lastName;
@property (strong, nonatomic) NSString* fullName;
@property (strong, nonatomic) NSArray* phone;
@property (strong, nonatomic) NSArray* email;
@end

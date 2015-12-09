//
//  BorrowListing.h
//  BorrowBug
//
//  Created by Chris on 11/8/15.
//  Copyright © 2015 Chris Repanich. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BorrowListing : NSObject
@property (strong, nonatomic) NSString* name;
@property (strong, nonatomic) NSString* phoneNumber;
@property (strong, nonatomic) NSString* objectBorrowed;
@property (strong, nonatomic) NSString* timeBorrowed;
@property (strong, nonatomic) NSString* returnBy;
@property (nonatomic) BOOL isReturned;

- (void)encodeWithCoder:(NSCoder *)encoder;
- (id)initWithCoder:(NSCoder *)decoder;
@end

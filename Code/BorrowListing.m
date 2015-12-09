//
//  BorrowListing.m
//  BorrowBug
//
//  Created by Chris on 11/8/15.
//  Copyright © 2015 Chris Repanich. All rights reserved.
//

#import "BorrowListing.h"
/* name, phoneNumber, objectBorrowed, timeBorrowed, returnBy*/
@implementation BorrowListing
- (void)encodeWithCoder:(NSCoder *)encoder {
    //Encode properties, other class variables, etc
    [encoder encodeObject:self.name forKey:@"name"];
    [encoder encodeObject:self.phoneNumber forKey:@"phoneNumber"];
    [encoder encodeObject:self.objectBorrowed forKey:@"objectBorrowed"];
    [encoder encodeObject:self.timeBorrowed forKey:@"timeBorrowed"];
    [encoder encodeObject:self.returnBy forKey:@"returnBy"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        //decode properties, other class vars
        self.name = [decoder decodeObjectForKey:@"name"];
        self.phoneNumber = [decoder decodeObjectForKey:@"phoneNumber"];
        self.objectBorrowed = [decoder decodeObjectForKey:@"objectBorrowed"];
        self.timeBorrowed = [decoder decodeObjectForKey:@"timeBorrowed"];
        self.returnBy = [decoder decodeObjectForKey:@"returnBy"];
    }
    return self;
}
@end

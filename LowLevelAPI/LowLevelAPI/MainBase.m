//
//  MainBase.m
//  Networking_n_Bonjore_Demo
//
//  Created by Global Logic on 12/03/13.
//  Copyright (c) 2013 Globallogic. All rights reserved.
//

#import "MainBase.h"

@implementation MainBase
@synthesize quitNow = quitNow_;

- (void)run
{
    NSLog(@"in");
    while ( ! self.quitNow ) {
        BOOL    didRun;
        
        didRun = [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        //assert(didRun);
    }

NSLog(@"out");
}

- (void)quit
{
    self.quitNow = YES;
}

- (NSString*) Quote:(NSString *) str
// Returns a quoted form of the string.  This isn't intended to be super-clever,
// for example, it doesn't escape any single quotes in the string.
{
    return [NSString stringWithFormat:@"'%@'", (str == nil) ? @"" : str];
}
@end

//
//  MainBase.h
//  Networking_n_Bonjore_Demo
//
//  Created by Global Logic on 12/03/13.
//  Copyright (c) 2013 Globallogic. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MainBase : NSObject
@property (nonatomic, assign, readwrite) BOOL quitNow;
- (void)run;
- (void)quit;
- (NSString*) Quote:(NSString *) str;
@end

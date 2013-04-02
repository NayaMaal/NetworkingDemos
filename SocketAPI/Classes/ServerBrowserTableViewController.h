//
//  ServerBrowser.h
//  NetworkingTesting
//
//  Created by Bill Dudney on 2/21/09.
//  Copyright 2009 Gala Factory Software LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Server.h"

@interface ServerBrowserTableViewController : UITableViewController {
    Server *_server;
	NSMutableArray *_services;
}

@property(nonatomic, retain) Server *server;

- (void)addService:(NSNetService *)service moreComing:(BOOL)moreComing;
- (void)removeService:(NSNetService *)service moreComing:(BOOL)moreComing;

@end

//
//  NetworkingTestingAppDelegate.h
//  NetworkingTesting
//
//  Created by Bill Dudney on 2/20/09.
//  Copyright Gala Factory Software LLC 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Server.h"

@class ServerRunningViewController;
@class ServerBrowserTableViewController;

@interface NetworkingTestingAppDelegate : NSObject <UIApplicationDelegate, ServerDelegate> {
    Server *_server;
    UIWindow *window;
    UINavigationController *navigationController;
    IBOutlet ServerBrowserTableViewController *serverBrowserVC;
    IBOutlet ServerRunningViewController *serverRunningVC;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

@end


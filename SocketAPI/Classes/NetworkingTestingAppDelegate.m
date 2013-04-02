//
//  NetworkingTestingAppDelegate.m
//  NetworkingTesting
//
//  Created by Bill Dudney on 2/20/09.
//  Copyright Gala Factory Software LLC 2009. All rights reserved.
//

#import "NetworkingTestingAppDelegate.h"
#import "ServerBrowserTableViewController.h"
#import "ServerRunningViewController.h"

@implementation NetworkingTestingAppDelegate

@synthesize window;
@synthesize navigationController;

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	
    NSString *type = @"TestingProtocol";
    _server = [[Server alloc] initWithProtocol:type];
    _server.delegate = self;
    NSError *error = nil;
    if(![_server start:&error]) {
        NSLog(@"error = %@", error);
    }
    serverBrowserVC.server = _server;
	// Configure and show the window
	[window addSubview:[navigationController view]];
	[window makeKeyAndVisible];
}

#pragma mark Server Delegate Methods

- (void)serverRemoteConnectionComplete:(Server *)server {
    NSLog(@"Server Started");
    // this is called when the remote side finishes joining with the socket as
    // notification that the other side has made its connection with this side
    serverRunningVC.server = server;
    [self.navigationController pushViewController:serverRunningVC animated:YES];
}

- (void)serverStopped:(Server *)server {
    NSLog(@"Server stopped");
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)server:(Server *)server didNotStart:(NSDictionary *)errorDict {
    NSLog(@"Server did not start %@", errorDict);
}

- (void)server:(Server *)server didAcceptData:(NSData *)data {
    NSLog(@"Server did accept data %@", data);
    NSString *message = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
    if(nil != message || [message length] > 0) {
        serverRunningVC.message = message;
    } else {
        serverRunningVC.message = @"no data received";
    }
}

- (void)server:(Server *)server lostConnection:(NSDictionary *)errorDict {
    NSLog(@"Server lost connection %@", errorDict);
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)serviceAdded:(NSNetService *)service moreComing:(BOOL)more {
    [serverBrowserVC addService:service moreComing:more];
}

- (void)serviceRemoved:(NSNetService *)service moreComing:(BOOL)more {
    [serverBrowserVC removeService:service moreComing:more];
}

#pragma mark -

- (void)applicationWillTerminate:(UIApplication *)application {
    [_server stop];
    [_server stopBrowser];
}

- (void)dealloc {
	self.navigationController = nil;
    self.window = nil;
    [serverRunningVC release];
    serverRunningVC = nil;
    [serverBrowserVC release];
    serverBrowserVC = nil;
    [_server release];
    _server = nil;
	[super dealloc];
}

@end

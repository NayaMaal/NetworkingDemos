//
//  ServerRunningViewController.m
//  NetworkingTesting
//
//  Created by Bill Dudney on 2/20/09.
//  Copyright 2009 Gala Factory Software LLC. All rights reserved.
//

#import "ServerRunningViewController.h"
#import "Server.h"

@implementation ServerRunningViewController

@synthesize message = _message;
@synthesize server = _server;

- (void)setMessage:(NSString *)message {
  messageLabel.text = message;
}

- (BOOL)textFieldShouldReturn:(UITextField *)tf {
  [tf resignFirstResponder];
  return YES;
}

- (IBAction)send {
  NSData *data = [newMessageText.text dataUsingEncoding:NSUTF8StringEncoding];
  NSError *error = nil;
  [self.server sendData:data error:&error];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

- (void)dealloc {
    [super dealloc];
}


@end

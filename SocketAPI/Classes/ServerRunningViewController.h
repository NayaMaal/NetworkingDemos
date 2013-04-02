//
//  ServerRunningViewController.h
//  NetworkingTesting
//
//  Created by Bill Dudney on 2/20/09.
//  Copyright 2009 Gala Factory Software LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Server;

@interface ServerRunningViewController : UIViewController <UITextFieldDelegate> {
  IBOutlet UILabel *messageLabel;
  IBOutlet UITextField *newMessageText;
  NSString *_message;
  Server *_server;
}

@property(nonatomic, retain) NSString *message;
@property(nonatomic, retain) Server *server;

- (IBAction)send;

@end

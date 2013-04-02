//
//  GLChatViewController.h
//  LowLevelAPI
//
//  Created by Global Logic on 01/04/13.
//  Copyright (c) 2013 Globallogic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GLNetworkController.h"

@interface GLChatViewController : UIViewController
@property (strong, nonatomic) IBOutlet UITextView *messageView;
@property (strong, nonatomic) IBOutlet UITextField *composeField;

- (IBAction)postMessage:(id)sender;
@property (strong, nonatomic) GLNetworkController *netController;

- (void)receiveData:(NSData *)data;
@end

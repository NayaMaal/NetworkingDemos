//
//  GLViewController.h
//  LowLevelAPI
//
//  Created by Global Logic on 01/04/13.
//  Copyright (c) 2013 Globallogic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GLNetworkController.h"
#import "GLChatViewController.h"
@interface GLViewController : UITableViewController<GLNetworkControllerDelegate>
@property (strong, nonatomic) NSMutableArray *serviceArray;
@property (weak, nonatomic) GLChatViewController *chatController;
@end

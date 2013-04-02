//
//  GLChatViewController.m
//  LowLevelAPI
//
//  Created by Global Logic on 01/04/13.
//  Copyright (c) 2013 Globallogic. All rights reserved.
//

#import "GLChatViewController.h"

@interface GLChatViewController ()

@end

@implementation GLChatViewController
@synthesize netController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)addTextToView:(NSString *)str
{
    NSString *full_message = [NSString stringWithFormat:@"%@\n%@",self.messageView.text,str];
    self.messageView.text = full_message;
    [self.messageView scrollRangeToVisible:NSMakeRange([self.messageView.text length], 0)];
}

- (void)receiveData:(NSData *)data {
    NSString *str = [[NSString alloc] initWithBytes:[data bytes] length:[data length] encoding:NSUTF8StringEncoding];
    [self addTextToView:str];
}
- (IBAction)postMessage:(id)sender {
    [self addTextToView:self.composeField.text];
    [self.netController sendData:[self.composeField.text dataUsingEncoding:NSUTF8StringEncoding]];
    self.composeField.text = @"";
}
@end

//
//  GLViewController.m
//  LowLevelAPI
//
//  Created by Global Logic on 01/04/13.
//  Copyright (c) 2013 Globallogic. All rights reserved.
//

#import "GLViewController.h"
#import "GLChatViewController.h"

@interface GLViewController ()
@property GLNetworkController *network;
@end

@implementation GLViewController
@synthesize serviceArray = _serviceArray;
@synthesize network = _network;
@synthesize chatController = _chatController;
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
       
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
     _serviceArray = [NSMutableArray arrayWithCapacity:1];
    NSString *type = @"TestingProtocol";
    self.network = [[GLNetworkController alloc] initWithProtocol:type];
    self.network.delegate = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        NSError *error;
        [self.network start:&error];
    });
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.serviceArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reuseIdentifier = @"myCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    }
    cell.textLabel.text = [[self.serviceArray objectAtIndex:indexPath.row] name];
    
    return cell;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //[self.network connectToRemoteService:[self.serviceArray objectAtIndex:indexPath.row]];
   //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        DNSSDService * service = [self.serviceArray objectAtIndex:indexPath.row];
        [self.network resolveName:service.name ofType:service.type forDomain:service.domain];
    //});
}

#pragma mark - GLNetworkControllerDelegate
// sent when both sides of the connection are ready to go
- (void)serverRemoteConnectionComplete:(GLNetworkController *)server {
    if (self.chatController == nil) {
        [self performSegueWithIdentifier:@"ChatController" sender:self];
    }

}
// called when the server is finished stopping
- (void)serverStopped:(GLNetworkController *)server {
    
}
// called when something goes wrong in the starup
- (void)server:(GLNetworkController *)server didNotStart:(NSDictionary *)errorDict {
    
}
// called when data gets here from the remote side of the server
- (void)server:(GLNetworkController *)server didAcceptData:(NSData *)data {
    [self.chatController receiveData:data];
}
// called when the connection to the remote side is lost
- (void)server:(GLNetworkController *)server lostConnection:(NSDictionary *)errorDict {
    [self.navigationController popViewControllerAnimated:YES];
}
// called when a new service comes on line
- (void)serviceAdded:(DNSSDService *)service moreComing:(BOOL)more {
    [self.serviceArray addObject:service];
    if (!more) {
        [self.tableView reloadData];
    }
}
// called when a service goes off line
- (void)serviceRemoved:(DNSSDService *)service moreComing:(BOOL)more {
    [self.serviceArray removeObject:service];
    if (!more) {
        [self.tableView reloadData];
    }
}
-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    GLChatViewController *afc = (GLChatViewController*) segue.destinationViewController;
    self.chatController = afc;
    self.chatController.netController = self.network;
}
@end
//
//  ServerBrowser.m
//  NetworkingTesting
//
//  Created by Bill Dudney on 2/21/09.
//  Copyright 2009 Gala Factory Software LLC. All rights reserved.
//

#import "ServerBrowserTableViewController.h"

@interface ServerBrowserTableViewController()
@property(nonatomic, retain) NSMutableArray *services;
@end

@implementation ServerBrowserTableViewController

@synthesize services = _services;
@synthesize server = _server;

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    self.title = @"Service Browser";
    self.services = nil;
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.services = nil;
}

- (NSMutableArray *)services {
    if(nil == _services) {
        self.services = [NSMutableArray array];
    }
    return _services;
}

- (void)addService:(NSNetService *)service moreComing:(BOOL)more {
    [self.services addObject:service];
    if(!more) {
        [self.tableView reloadData];
    }
}

- (void)removeService:(NSNetService *)service moreComing:(BOOL)more {
    [self.services removeObject:service];
    if(!more) {
        [self.tableView reloadData];
    }
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Connection Choices";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.services.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
    }
    
    cell.text = [[self.services objectAtIndex:indexPath.row] name];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.server connectToRemoteService:[self.services objectAtIndex:indexPath.row]];
}

#pragma mark -

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

- (void)dealloc {
    self.services = nil;
    self.server = nil;
    [super dealloc];
}

@end

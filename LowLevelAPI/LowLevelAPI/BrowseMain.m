//
//  BrowseMain.m
//  Networking_n_Bonjore_Demo
//
//  Created by Global Logic on 11/03/13.
//  Copyright (c) 2013 Globallogic. All rights reserved.
//

#import "BrowseMain.h"

#pragma mark * BrowseMain
// BrowseMain implements the "-b" command using the DNSSDBrowser object.
@implementation BrowseMain

@synthesize type = type_;
@synthesize browser = browser_;
@synthesize deleage = _deleage;

- (void)dealloc
{
    [self->browser_ stop];
    /*[self->browser_ release];
    [self->type_ release];
    [super dealloc];*/
}

- (void)run
{
    assert(self.browser == nil);
    assert(self.type != nil);
    
    self.browser = [[DNSSDBrowser alloc] initWithDomain:nil type:self.type];
    assert(self.browser != nil);
    
    self.browser.delegate = self;
    
    [self.browser startBrowse];
    
    [super run];
}

- (void)dnssdBrowserWillBrowse:(DNSSDBrowser *)browser
{
    assert(browser == self.browser);
    [self.deleage dnssdBrowserWillBrowse:browser];
    NSLog(@"will browse %@ / %@", [self Quote:self.browser.type], [self Quote:self.browser.domain]);
}

- (void)dnssdBrowser:(DNSSDBrowser *)browser didAddService:(DNSSDService *)service moreComing:(BOOL)moreComing
{
    assert(browser == self.browser);
    [self.deleage dnssdBrowser:browser didAddService:service moreComing:moreComing];
    
    NSLog(@"   add service %@ / %@ / %@%s", [self Quote:service.name], [self Quote:service.type], [self Quote:service.domain], moreComing ? " ..." : "");
}

- (void)dnssdBrowser:(DNSSDBrowser *)browser didRemoveService:(DNSSDService *)service moreComing:(BOOL)moreComing
{
    assert(browser == self.browser);
    [self.deleage dnssdBrowser:browser didRemoveService:service moreComing:moreComing];
    
    NSLog(@"remove service %@ / %@ / %@%s", [self Quote:service.name], [self Quote:service.type], [self Quote:service.domain], moreComing ? " ..." : "");
}

- (void)dnssdBrowser:(DNSSDBrowser *)browser didNotBrowse:(NSError *)error
{
    assert(browser == self.browser);
    [self.deleage dnssdBrowser:browser didNotBrowse:error];
    assert(error != nil);
    
    NSLog(@"did not browse (%@ / %zd)", [error domain], (ssize_t) [error code]);
    [self quit];
}

- (void)dnssdBrowserDidStopBrowse:(DNSSDBrowser *)browser
{
    assert(browser == self.browser);
    [self.deleage dnssdBrowserDidStopBrowse:browser];
    NSLog(@"stopped");
}

@end
//
//  ResolveMain.m
//  Networking_n_Bonjore_Demo
//
//  Created by Global Logic on 11/03/13.
//  Copyright (c) 2013 Globallogic. All rights reserved.
//

#import "ResolveMain.h"

#pragma mark * ResolveMain
// ResolveMain implements the "-l" command using the DNSSDService object.
@implementation ResolveMain

@synthesize name   = name_;
@synthesize type   = type_;
@synthesize domain = domain_;

@synthesize service = service_;
@synthesize delegate;

- (void)dealloc
{
    /*[self->name_ release];
    [self->type_ release];
    [self->domain_ release];
    [super dealloc];*/
}

- (void)run
{
    assert(self.service == nil);
    assert(self.type != nil);
    
    self.service = [[DNSSDService alloc] initWithDomain:self.domain type:self.type name:self.name];
    assert(self.service != nil);
    
    self.service.delegate = self;
    
    [self.service startResolve];
    
    [super run];
}

- (void)dnssdServiceWillResolve:(DNSSDService *)service
{
    assert(service == self.service);
#pragma unused(service)
    
    NSLog(@"will resove %@ / %@ / %@", [self Quote:self.service.name], [self Quote:self.service.type], [self Quote:self.service.domain]);
    [self.delegate dnssdServiceWillResolve:service];
}

- (void)dnssdServiceDidResolveAddress:(DNSSDService *)service
{
    assert(service == self.service);
#pragma unused(service)
    NSLog(@"did resolve to %@:%zu", service.resolvedHost, (size_t) service.resolvedPort);
    [self quit];
    [self.delegate dnssdServiceDidResolveAddress:service];
    
}

- (void)dnssdService:(DNSSDService *)service didNotResolve:(NSError *)error
{
    assert(service == self.service);
#pragma unused(service)
    NSLog(@"did not resolve (%@ / %zd)", [error domain], (ssize_t) [error code]);
    [self.delegate dnssdService:service didNotResolve:error];
    [self quit];
}

- (void)dnssdServiceDidStop:(DNSSDService *)service
{
    assert(service == self.service);
#pragma unused(service)
    [self.delegate dnssdServiceDidStop:service];
    NSLog(@"stopped");
}

@end

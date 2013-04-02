//
//  RegisterMain.m
//  Networking_n_Bonjore_Demo
//
//  Created by Global Logic on 11/03/13.
//  Copyright (c) 2013 Globallogic. All rights reserved.
//

#import "RegisterMain.h"

@implementation RegisterMain

@synthesize type = type_;
@synthesize port = port_;
@synthesize registration = registration_;
@synthesize deleage = _deleage;

- (void)dealloc
{
    [self->registration_ stop];
    
    /*[self->registration_ release];
    [self->type_ release];
    [super dealloc];*/
}

- (void)run
{
    assert(self.type != nil);
    assert(self.registration == nil);
    
    self.registration = [[DNSSDRegistration alloc] initWithDomain:nil type:self.type name:nil port:self.port];
    assert(self.registration != nil);
    
    self.registration.delegate = self;
    
    [self.registration start];
    
    [super run];
}

- (void)dnssdRegistrationWillRegister:(DNSSDRegistration *)sender
{
    assert(sender == self.registration);
    [self.deleage dnssdRegistrationWillRegister:sender];
    NSLog(@"will register %@ / %@ / %@", [self Quote:self.registration.name], [self Quote:self.registration.type], [self Quote:self.registration.domain]);
}

- (void)dnssdRegistrationDidRegister:(DNSSDRegistration *)sender
{
    assert(sender == self.registration);
    
    [self.deleage dnssdRegistrationDidRegister:sender];
    NSLog(@"registered as %@ / %@ / %@", [self Quote:self.registration.name], [self Quote:self.registration.type], [self Quote:self.registration.domain]);
}

- (void)dnssdRegistration:(DNSSDRegistration *)sender didNotRegister:(NSError *)error
{
    assert(sender == self.registration);
    [self.deleage dnssdRegistration:sender didNotRegister:error];
    assert(error != nil);
    
    NSLog(@"did not register (%@ / %zd)", [error domain], (ssize_t) [error code]);
    [self quit];
}

- (void)dnssdRegistrationDidStop:(DNSSDRegistration *)sender
{
    assert(sender == self.registration);
    [self.deleage dnssdRegistrationDidStop:sender];
    
    NSLog(@"stopped");
}

@end
//
//  RegisterMain.h
//  Networking_n_Bonjore_Demo
//
//  Created by Global Logic on 11/03/13.
//  Copyright (c) 2013 Globallogic. All rights reserved.
//

#import "MainBase.h"
#import "DNSSDRegistration.h"

@interface RegisterMain : MainBase <DNSSDRegistrationDelegate>
@property (nonatomic, copy,   readwrite) NSString *     type;
@property (nonatomic, assign, readwrite) NSUInteger     port;

@property (nonatomic, retain, readwrite) DNSSDRegistration *  registration;
@property (nonatomic, weak) id <DNSSDRegistrationDelegate> deleage;
@end
//
//  ResolveMain.h
//  Networking_n_Bonjore_Demo
//
//  Created by Global Logic on 11/03/13.
//  Copyright (c) 2013 Globallogic. All rights reserved.
//

#import "MainBase.h"
#import "DNSSDService.h"

@interface ResolveMain : MainBase <DNSSDServiceDelegate>
@property (nonatomic, copy,   readwrite) NSString *     name;
@property (nonatomic, copy,   readwrite) NSString *     type;
@property (nonatomic, copy,   readwrite) NSString *     domain;

@property (nonatomic, retain, readwrite) DNSSDService *  service;
@property (nonatomic, weak) id <DNSSDServiceDelegate> delegate;
@end

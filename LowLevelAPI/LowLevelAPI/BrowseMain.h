//
//  BrowseMain.h
//  Networking_n_Bonjore_Demo
//
//  Created by Global Logic on 11/03/13.
//  Copyright (c) 2013 Globallogic. All rights reserved.
//

#import "MainBase.h"
#import "DNSSDBrowser.h"

@interface BrowseMain : MainBase <DNSSDBrowserDelegate>
@property (nonatomic, copy,   readwrite) NSString *                 type;

@property (nonatomic, retain, readwrite) DNSSDBrowser *       browser;
@property (nonatomic, weak) id <DNSSDBrowserDelegate> deleage;
@end


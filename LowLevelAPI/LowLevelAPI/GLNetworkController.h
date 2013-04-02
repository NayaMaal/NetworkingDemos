//
//  GLNetworkController.h
//  Networking_n_Bonjore_Demo
//
//  Created by Global Logic on 07/03/13.
//  Copyright (c) 2013 Globallogic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RegisterMain.h"
#import "BrowseMain.h"

typedef enum {
    kServerCouldNotBindToIPv4Address = 1,
    kServerCouldNotBindToIPv6Address = 2,
    kServerNoSocketsAvailable = 3,
    kServerNoSpaceOnOutputStream = 4,
    kServerOutputStreamReachedCapacity = 5 // should be able to try again 'later'
} ServerErrorCode;
@protocol GLNetworkControllerDelegate;

@interface GLNetworkController : NSObject  <NSStreamDelegate>
{
    @private
    CFSocketRef _socket4;
    CFSocketRef _socket6;
    
    BrowseMain *    browseObj;
    RegisterMain *  registerObj;
}

- (id)initWithProtocol:(NSString *)protocol;
- (id)initWithDomainName:(NSString *)domain
                protocol:(NSString *)protocol
                    name:(NSString *)name;
//- (BOOL)start:(NSError **)error;
- (BOOL)start:(NSError **)error;
- (void)browse:(NSError **)error;
- (void)connectToRemoteServer:(NSString *)server on:(uint16_t)port;
- (void)connectToRemoteService:(NSNetService *)selectedService;

- (void) sendData:(NSData*)data;

@property (nonatomic, weak) id <GLNetworkControllerDelegate> delegate;

@end


#import "ResolveMain.h"

@interface GLNetworkController(DNS_SD_API) <DNSSDBrowserDelegate,DNSSDRegistrationDelegate,DNSSDServiceDelegate>
- (void) resolveName:(NSString*)name ofType:(NSString*)type forDomain:(NSString*)domain;
- (void) browseType:(NSString *)type;
- (void) registerType:(NSString *)type onPort:(NSUInteger)port;
@end

@protocol GLNetworkControllerDelegate <NSObject>

// sent when both sides of the connection are ready to go
- (void)serverRemoteConnectionComplete:(GLNetworkController *)server;
// called when the server is finished stopping
- (void)serverStopped:(GLNetworkController *)server;
// called when something goes wrong in the starup
- (void)server:(GLNetworkController *)server didNotStart:(NSDictionary *)errorDict;
// called when data gets here from the remote side of the server
- (void)server:(GLNetworkController *)server didAcceptData:(NSData *)data;
// called when the connection to the remote side is lost
- (void)server:(GLNetworkController *)server lostConnection:(NSDictionary *)errorDict;
// called when a new service comes on line
- (void)serviceAdded:(DNSSDService *)service moreComing:(BOOL)more;
// called when a service goes off line
- (void)serviceRemoved:(DNSSDService *)service moreComing:(BOOL)more;

@end

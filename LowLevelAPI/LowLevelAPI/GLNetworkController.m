//
//  GLNetworkController.m
//  Networking_n_Bonjore_Demo
//
//  Created by Global Logic on 07/03/13.
//  Copyright (c) 2013 Globallogic. All rights reserved.
//

#import "GLNetworkController.h"
#include <netinet/in.h>
#import <CFNetwork/CFSocketStream.h>
#import <Foundation/Foundation.h>



NSString * const ServerErrorDomain = @"ServerErrorDomain";
NSString *const ServiceType = @"_TestingProtocol._tcp.";

@interface GLNetworkController()
@property(nonatomic, copy) NSString *domain;
@property(nonatomic, copy) NSString *protocol;
@property(nonatomic, copy) NSString *name;
@property (nonatomic, assign)uint8_t payloadSize;
@property (nonatomic, assign)uint16_t port;

//Stream
@property (nonatomic, strong) NSInputStream *inputStream;
@property (nonatomic, strong) NSOutputStream *outputStream;
@property(nonatomic, assign) BOOL inputStreamReady;
@property(nonatomic, assign) BOOL outputStreamReady;
@property(nonatomic, assign) BOOL outputStreamHasSpace;

//Services
@property (nonatomic, strong) NSNetService  *netService,
                                            *localService,
                                            *currentlyResolvingService;
@property (nonatomic, strong) NSNetServiceBrowser *browser;

// now start looking for others
- (void)remoteServiceResolved:(NSNetService*)service;
- (void)connectedToInputStream:(NSInputStream *)inputStream
                   outputStream:(NSOutputStream *)outputStream;
@end


@implementation GLNetworkController
@synthesize domain = _domain;
@synthesize delegate;
@synthesize protocol = _protocol;
@synthesize name = _name;
@synthesize payloadSize = _payloadSize, port = _port;
@synthesize netService = _netService;
@synthesize currentlyResolvingService = _currentlyResolvingService;
@synthesize inputStream = _inputStream, outputStream = _outputStream;
@synthesize inputStreamReady, outputStreamHasSpace,outputStreamReady;

- (id)initWithDomainName:(NSString *)domain
                protocol:(NSString *)protocol
                    name:(NSString *)name {
    self = [super init];
    if(nil != self) {
        self.domain = domain;
        self.protocol = protocol;
        self.name = name;
        //self.outputStreamHasSpace = NO;
        self.payloadSize = 128;
    }
    return self;
}
- (id)initWithProtocol:(NSString *)protocol {
    if (protocol == nil) {
        protocol = ServiceType;
    }
         return [self initWithDomainName:@""
                        protocol:[NSString stringWithFormat:@"_%@._tcp.", protocol]
                            name:@""];
}

- (id)init {
        return [self initWithDomainName:@""
                        protocol:@"_Server._tcp."
                            name:@""];
}

- (void)stop {
    if(nil != self.netService) {
        [self stopNetService];
    }
    if(NULL != _socket4) {
        CFSocketInvalidate(_socket4);
        CFRelease(_socket4);
        _socket4 = NULL;
    }
    [self stopStreams];
    //[self.delegate serverStopped:self];
}
- (void)browse:(NSError **)error {
    [self browseType:self.protocol];
}
- (BOOL)start:(NSError **)error {
    BOOL successful = YES;
    CFSocketContext socketCtxt = {0, (__bridge void *)(self), NULL, NULL, NULL};
    _socket4 = CFSocketCreate(kCFAllocatorDefault,
                              PF_INET,
                              SOCK_STREAM,
                             IPPROTO_TCP,
                             kCFSocketAcceptCallBack,
                             (CFSocketCallBack)&SocketAcceptedConnectionCallBack,
                             &socketCtxt);
    
    _socket6 = CFSocketCreate(
                                              kCFAllocatorDefault,
                                              PF_INET6,
                                              SOCK_STREAM,
                                              IPPROTO_TCP,
                                              kCFSocketAcceptCallBack, (CFSocketCallBack)SocketAcceptedConnectionCallBack, NULL);
	
    if (NULL == _socket4) {
        if (nil != error) {
            *error = [[NSError alloc]
                      initWithDomain:ServerErrorDomain
                      code:kServerNoSocketsAvailable
                      userInfo:nil];
        }
        successful = NO;
    }
	
    if(YES == successful && _socket4 != NULL) {
        // enable address reuse
        int yes = 1;
        setsockopt(CFSocketGetNative(_socket4),
                   SOL_SOCKET, SO_REUSEADDR,
                   (void *)&yes, sizeof(yes));
        // set the packet size for send and receive
        // cuts down on latency and such when sending
        // small packets
        uint8_t packetSize = self.payloadSize;
        setsockopt(CFSocketGetNative(_socket4),
                   SOL_SOCKET, SO_SNDBUF,
                   (void *)&packetSize, sizeof(packetSize));
        setsockopt(CFSocketGetNative(_socket4),
                   SOL_SOCKET, SO_RCVBUF,
                   (void *)&packetSize, sizeof(packetSize));
        
        // set up the IPv4 endpoint; use port 0, so the kernel will choose an arbitrary port for us, which will be
        struct sockaddr_in addr4;
        memset(&addr4, 0, sizeof(addr4));
        addr4.sin_len = sizeof(addr4);
        addr4.sin_family = AF_INET;
        addr4.sin_port = htons(12345); // since we set it to zero the kernel will assign one for us
        addr4.sin_addr.s_addr = htonl(INADDR_ANY);
        NSData *address4 = [NSData dataWithBytes:&addr4 length:sizeof(addr4)];
        
        if (kCFSocketSuccess != CFSocketSetAddress(_socket4, (__bridge CFDataRef)address4)) {
            if (error) *error = [[NSError alloc]
                                 initWithDomain:ServerErrorDomain
                                 code:kServerCouldNotBindToIPv4Address
                                 userInfo:nil];
            if (_socket4) {
                CFSocketInvalidate(_socket4);
                CFRelease(_socket4);
                _socket4 = NULL;
            }
            successful = NO;
        } else {
            // now that the binding was successful, we get the port number
            NSData *addr = (__bridge NSData *)CFSocketCopyAddress(_socket4);
            memcpy(&addr4, [addr bytes], [addr length]);
            self.port = ntohs(addr4.sin_port);
            
            // set up the run loop sources for the sockets
            CFRunLoopRef cfrl = CFRunLoopGetCurrent();
            CFRunLoopSourceRef source4 = CFSocketCreateRunLoopSource(kCFAllocatorDefault, _socket4, 0);
            CFRunLoopAddSource(cfrl, source4, kCFRunLoopCommonModes);
            CFRelease(source4);
            
            //Start with registration
            [self registerType:self.protocol onPort:12345];
        }
	}
    return successful;
}

- (void)stopNetService {
    [self.netService stop];
    [self.netService removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    self.netService = nil;
}

//! Get callback when connection accepted from client.
static void SocketAcceptedConnectionCallBack (CFSocketRef s, CFSocketCallBackType type, CFDataRef address, const void *data, void *info) {
    // the server's socket has accepted a connection request
    // this function is called because it was registered in the
    // socket create method
    if (kCFSocketAcceptCallBack == type) {
        GLNetworkController *server = (__bridge GLNetworkController *)info;
        // on an accept the data is the native socket handle
        CFSocketNativeHandle nativeSocketHandle = *(CFSocketNativeHandle *)data;
        // create the read and write streams for the connection to the other process
        CFReadStreamRef readStream = NULL;
		CFWriteStreamRef writeStream = NULL;
        CFStreamCreatePairWithSocket(kCFAllocatorDefault, nativeSocketHandle,
                                     &readStream, &writeStream);
        if(NULL != readStream && NULL != writeStream) {

            CFReadStreamSetProperty(readStream,
                                    kCFStreamPropertyShouldCloseNativeSocket,
                                    kCFBooleanTrue);
            CFWriteStreamSetProperty(writeStream,
                                     kCFStreamPropertyShouldCloseNativeSocket,
                                     kCFBooleanTrue);

            [server connectedToInputStream:(__bridge NSInputStream *)readStream
                               outputStream:(__bridge NSOutputStream *)writeStream];
            [server->browseObj quit];
            //[server->registerObj quit];
        } else {
            // on any failure, need to destroy the CFSocketNativeHandle
            // since we are not going to use it any more
            close(nativeSocketHandle);
        }
        if (readStream) CFRelease(readStream);
        if (writeStream) CFRelease(writeStream);
    }
}


#pragma mark Stream Control
- (void)stopStreams {
    if(nil != self.inputStream) {
        [self.inputStream close];
        [self.inputStream removeFromRunLoop:[NSRunLoop currentRunLoop]
                                    forMode:NSRunLoopCommonModes];
        self.inputStream = nil;
        self.inputStreamReady = NO;
    }
    if(nil != self.outputStream) {
        [self.outputStream close];
        [self.outputStream removeFromRunLoop:[NSRunLoop currentRunLoop]
                                     forMode:NSRunLoopCommonModes];
        self.outputStream = nil;
        self.outputStreamReady = NO;
    }
}


- (void)connectedToInputStream:(NSInputStream *)inputStream
                   outputStream:(NSOutputStream *)outputStream {
    // need to close existing streams
    [self stopStreams];
    
    self.inputStream = inputStream;
    self.inputStream.delegate = self;
    [self.inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop]
                                forMode:NSDefaultRunLoopMode];
    [self.inputStream open];
    
    self.outputStream = outputStream;
    self.outputStream.delegate = self;
    [self.outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop]
                                 forMode:NSDefaultRunLoopMode];
    [self.outputStream open];
}
- (void) stream:(NSStream*)stream handleEvent:(NSStreamEvent)eventCode {
    switch (eventCode) {
        case NSStreamEventOpenCompleted: {
            [self streamCompletedOpening:stream];
            break;
        }
        case NSStreamEventHasBytesAvailable: {
            [self streamHasBytes:stream];
            break;
        }
        case NSStreamEventHasSpaceAvailable: {
            [self streamHasSpace:stream];
            break;
        }
        case NSStreamEventEndEncountered: {
            [self streamEncounteredEnd:stream];
            break;
        }
        case NSStreamEventErrorOccurred: {
            [self streamEncounteredError:stream];
            break;
        }
        default:
            break;
    }
}

- (void)streamCompletedOpening:(NSStream *)stream {
    if(stream == self.inputStream) {
        self.inputStreamReady = YES;
    }
    if(stream == self.outputStream) {
        self.outputStreamReady = YES;
    }
    
    if(YES == self.inputStreamReady && YES == self.outputStreamReady) {
        dispatch_async(dispatch_get_main_queue(), ^(void){
        [self.delegate serverRemoteConnectionComplete:self];
        });
        //[self stopNetService];
    }
}

- (void)streamHasBytes:(NSStream *)stream {
    NSMutableData *data = [NSMutableData data];
    uint8_t *buf = calloc(self.payloadSize, sizeof(uint8_t));
    NSUInteger len = 0;
    while([(NSInputStream*)stream hasBytesAvailable]) {
        len = [self.inputStream read:buf maxLength:self.payloadSize];
        if(len > 0) {
            [data appendBytes:buf length:len];
        }
    }
    free(buf);
    dispatch_async(dispatch_get_main_queue(), ^(void){
        [self.delegate server:self didAcceptData:data];
    });
}

- (void)streamHasSpace:(NSStream *)stream {
    self.outputStreamHasSpace = YES;
}

- (void)streamEncounteredEnd:(NSStream *)stream {
    // remote side died, tell the delegate then restart my local
    // service looking for some other server to connect to
    [self.delegate server:self lostConnection:nil];
    [self stopStreams];
}

- (void)streamEncounteredError:(NSStream *)stream {
    //[self.delegate server:self lostConnection:[[stream streamError] userInfo]];
    [self stop];
}

- (void) connectToRemoteDNSSDService:(DNSSDService *)service {
    CFReadStreamRef readStream = NULL;
    CFWriteStreamRef writeStream = NULL;
    
    CFHostRef hostRef = CFHostCreateWithName(kCFAllocatorDefault, (__bridge CFStringRef)(service.resolvedHost));
    
    CFStreamCreatePairWithSocketToCFHost(kCFAllocatorDefault, hostRef, service.resolvedPort, &readStream, &writeStream);
    
    if(NULL != readStream && NULL != writeStream) {
        CFReadStreamSetProperty(readStream,
                                kCFStreamPropertyShouldCloseNativeSocket,
                                kCFBooleanTrue);
        CFWriteStreamSetProperty(writeStream,
                                 kCFStreamPropertyShouldCloseNativeSocket,
                                 kCFBooleanTrue);
        [self stop];
        [browseObj quit];
        [registerObj quit];
        [self connectedToInputStream:(__bridge NSInputStream*)readStream outputStream:(__bridge NSOutputStream*)writeStream];
    }
    CFRelease(readStream);
    CFRelease(writeStream);
    CFRelease(hostRef);
}
- (void) sendData:(NSData*)data {
    [self.outputStream write:[data bytes] maxLength:[data length]];
}
@end

#pragma mark - DNS SD API
@implementation GLNetworkController (DNS_SD_API)

- (void) registerType:(NSString *)type onPort:(NSUInteger)port {
    MainBase *          mainObj;
    
    
    registerObj = [[RegisterMain alloc] init];
    registerObj.deleage = self;
    assert(registerObj != nil);
    
    registerObj.type = type;
    registerObj.port = port;
    if ( (registerObj.type != nil) && ([registerObj.type length] != 0) && ! [registerObj.type hasPrefix:@"."] &&
        (registerObj.port != 0) && (registerObj.port < 65536) ) {
        mainObj = registerObj;
        [mainObj run];
        NSLog(@"Register init success");
    }
}

- (void) browseType:(NSString *)type {
    MainBase *      mainObj;
        
    browseObj = [[BrowseMain alloc] init];
    browseObj.deleage = self;
    assert(browseObj != nil);
    
    browseObj.type = type;
    if ( (browseObj.type != nil) && ([browseObj.type length] != 0) && ! [browseObj.type hasPrefix:@"."] ) {
        mainObj = browseObj;
        [mainObj run];
        NSLog(@"Browse init success");
    }
}

- (void) resolveName:(NSString*)name ofType:(NSString*)type forDomain:(NSString*)domain {
    MainBase *      mainObj;
    ResolveMain *   resolveObj;
    
    resolveObj = [[ResolveMain alloc] init];
    resolveObj.delegate = self;
    assert(resolveObj != nil);
    
    resolveObj.name   = name;
    resolveObj.type   = type;
    resolveObj.domain = domain;
    if ( (resolveObj.name   != nil) && ([resolveObj.name   length] != 0) &&
        (resolveObj.type   != nil) && ([resolveObj.type   length] != 0) && ! [resolveObj.type   hasPrefix:@"."] &&
        (resolveObj.domain != nil) && ([resolveObj.domain length] != 0) && ! [resolveObj.domain hasPrefix:@"."] ) {
        mainObj = resolveObj;
        [mainObj run];
        NSLog(@"Resolve init success");
    }
}

#pragma mark DNSSD Registration Delegate
// All delegate methods are called on the main thread.
- (void)dnssdRegistrationWillRegister:(DNSSDRegistration *)sender {
// Called before the registration process starts.
}

- (void)dnssdRegistrationDidRegister:(DNSSDRegistration *)sender {
// Called when the service is successfully registered.  At this point
// registeredName and registeredDomain are valid.
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
           [self browseType:sender.type];
    });
    
}

- (void)dnssdRegistration:(DNSSDRegistration *)sender didNotRegister:(NSError *)error {
// Called when the service can't be registered.  The registration will be stopped
// immediately after this delegate method returns.
    [self.delegate server:self didNotStart:@{error:@"error"}];
}

- (void)dnssdRegistrationDidStop:(DNSSDRegistration *)sender {
// Called when the registration stops (except if you call -stop on it).
    
}
#pragma mark DNSSD Service Delegate
- (void)dnssdServiceWillResolve:(DNSSDService *)service {
// Called before the service starts resolving.
}

- (void)dnssdServiceDidResolveAddress:(DNSSDService *)service {
// Called when the service successfully resolves.  The resolve will be stopped
// immediately after this delegate method returns.
    [self stop];
    [browseObj quit];
    [registerObj quit];
    
    [self connectToRemoteDNSSDService:service];

}

- (void)dnssdService:(DNSSDService *)service didNotResolve:(NSError *)error {
// Called when the service fails to resolve.  The resolve will be stopped
// immediately after this delegate method returns.
}

- (void)dnssdServiceDidStop:(DNSSDService *)service {
// Called when a resolve stops (except if you call -stop on it).
}
#pragma mark DNSSD Browse Delegate
// All delegate methods are called on the main thread.
- (void)dnssdBrowserWillBrowse:(DNSSDBrowser *)browser {
// Called before the browser starts browsing.
}

- (void)dnssdBrowserDidStopBrowse:(DNSSDBrowser *)browser {
// Called when a browser stops browsing (except if you call -stop on it).
}

- (void)dnssdBrowser:(DNSSDBrowser *)browser didNotBrowse:(NSError *)error {
// Called when the browser fails to start browsing.  The browser will be stopped
// immediately after this delegate method returns.
}

- (void)dnssdBrowser:(DNSSDBrowser *)browser didAddService:(DNSSDService *)service
          moreComing:(BOOL)moreComing {
// Called when the browser finds a new service.

    [self.delegate serviceAdded:service moreComing:moreComing];
    
}

- (void)dnssdBrowser:(DNSSDBrowser *)browser didRemoveService:(DNSSDService *)service
          moreComing:(BOOL)moreComing {
// Called when the browser sees an existing service go away.
    
    [self.delegate serviceRemoved:service moreComing:moreComing];
}
@end

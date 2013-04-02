
#import <Foundation/Foundation.h>

// forward declarations

@protocol DNSSDServiceDelegate;

#pragma mark * DNSSDService

// DNSSDService represents a service discovered on the network.  You can use it to 
// resolve that service, and get a DNS name and port to connect to.

@interface DNSSDService : NSObject <NSCopying>

- (id)initWithDomain:(NSString *)domain type:(NSString *)type name:(NSString *)name;
    // In most cases you don't need to construct a DNSSDService object because you get it 
    // back from a DNSSDBrowser.  However, if you do need to construct one, it's fine to 
    // do so by calling this method.
    //
    // domain, type and name must not be nil or the empty string.  type must be of the 
    // form "_foo._tcp." or "_foo._udp." (possibly without the trailing dot, see below).
    // 
    // domain and type should include the trailing dot; if they don't, one is added 
    // and that change is reflected in the domain and type properties.
    // 
    // domain and type must not include a leading dot.

// DNSSDService implements -isEqual: based on a comparison of the domain, type and name, and  
// it implements -hash correspondingly.  This allows you to use DNSSDService objects in sets, 
// as dictionary keys, and so on.
//
// IMPORTANT: This uses case-sensitive comparison.  In general DNS is case insensitive. 
// DNS-SD will always pass you services with a consistent case, so using case sensitive 
// comparison here is not a problem.  You might run into problems, however, if you do 
// odd things like manually create a DNSSDService with the domain set to "LOCAL." instead 
// of "local.".
// 
// DNSSDService also implements NSCopying.  When you copy a service, the copy has the same 
// domain, type and name as the original.  However, the copy does not bring across any of 
// the resolution state.  Specifically:
//
// o If the original was resolving, the copy is not.
//
// o If the original had successfully resolved (and thus has resolvedHost and resolvedPort set), 
//   these results are not present in the copy.
//
// However, because the domain, type and name are copied, and these are the only things 
// considered by -isEqual: and -hash, DNSSDService can be used as a dictionary key.

// properties that are set up by the init method

@property (copy,   readonly ) NSString * domain;
@property (copy,   readonly ) NSString * type;
@property (copy,   readonly ) NSString * name;

// properties that you can change any time

@property (assign, readwrite) id<DNSSDServiceDelegate> delegate;

- (void)startResolve;
    // Starts a resolve.  Starting a resolve on a service that is currently resolving 
    // is a no-op.  If the resolve does not complete within 30 seconds, it will fail 
    // with a time out.

- (void)stop;
    // Stops a resolve.  Stopping a resolve on a service that is not resolving is a no-op.

// properties that are set up once the resolve completes

@property (copy,   readonly ) NSString * resolvedHost;
@property (assign, readonly ) NSUInteger resolvedPort;

@end

@protocol DNSSDServiceDelegate <NSObject>

// All delegate methods are called on the main thread.

@optional

- (void)dnssdServiceWillResolve:(DNSSDService *)service;
    // Called before the service starts resolving.

- (void)dnssdServiceDidResolveAddress:(DNSSDService *)service;
    // Called when the service successfully resolves.  The resolve will be stopped 
    // immediately after this delegate method returns.

- (void)dnssdService:(DNSSDService *)service didNotResolve:(NSError *)error;
    // Called when the service fails to resolve.  The resolve will be stopped 
    // immediately after this delegate method returns.

- (void)dnssdServiceDidStop:(DNSSDService *)service;
    // Called when a resolve stops (except if you call -stop on it).

@end

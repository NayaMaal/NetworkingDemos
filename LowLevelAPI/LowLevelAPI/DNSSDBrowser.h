
#import <Foundation/Foundation.h>

#import "DNSSDService.h"

// forward declarations

@protocol DNSSDBrowserDelegate;

#pragma mark * DNSSDBrowser

// DNSSDBrowser allows you to browse for services on the network, and be informed 
// of their coming and going.

@interface DNSSDBrowser : NSObject

- (id)initWithDomain:(NSString *)domain type:(NSString *)type;
    // domain may be nil or the empty string, to specify browsing in all default 
    // browsing domains.
    //
    // type must be of the form "_foo._tcp." or "_foo._udp." (possibly without the 
    // trailing dot, see below).
    // 
    // domain and type should include the trailing dot; if they don't, one is added 
    // and that change is reflected in the domain and type properties.
    // 
    // domain and type must not include a leading dot.

// properties that are set up by the init method

@property (copy,   readonly ) NSString * domain;
@property (copy,   readonly ) NSString * type;

// properties that you can change any time

@property (assign, readwrite) id <DNSSDBrowserDelegate> delegate;

- (void)startBrowse;
    // Starts a browse.  Starting a browse on a browser that is currently browsing 
    // is a no-op.

- (void)stop;
    // Stops a browse.  Stopping a browse on a browser that is not browsing is a no-op.

@end

@protocol DNSSDBrowserDelegate <NSObject>

// All delegate methods are called on the main thread.

@optional

- (void)dnssdBrowserWillBrowse:(DNSSDBrowser *)browser;
    // Called before the browser starts browsing.

- (void)dnssdBrowserDidStopBrowse:(DNSSDBrowser *)browser;
    // Called when a browser stops browsing (except if you call -stop on it).

- (void)dnssdBrowser:(DNSSDBrowser *)browser didNotBrowse:(NSError *)error;
    // Called when the browser fails to start browsing.  The browser will be stopped 
    // immediately after this delegate method returns.

- (void)dnssdBrowser:(DNSSDBrowser *)browser didAddService:(DNSSDService *)service moreComing:(BOOL)moreComing;
    // Called when the browser finds a new service.

- (void)dnssdBrowser:(DNSSDBrowser *)browser didRemoveService:(DNSSDService *)service moreComing:(BOOL)moreComing;
    // Called when the browser sees an existing service go away.

@end

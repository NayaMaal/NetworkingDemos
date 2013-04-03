
#import "DNSSDBrowser.h"

#include <dns_sd.h>

#pragma mark * DNSSDBrowser

@interface DNSSDBrowser ()

// private properties

@property (assign, readwrite) DNSServiceRef      sdRef;

// forward declarations

- (void)stopWithError:(NSError *)error notify:(BOOL)notify;

@end

@implementation DNSSDBrowser

@synthesize domain = domain_;
@synthesize type = type_;

@synthesize delegate = delegate_;

@synthesize sdRef = sdRef_;

- (id)initWithDomain:(NSString *)domain type:(NSString *)type
    // See comment in header.
{
    // domain may be nil or empty
    assert( ! [domain hasPrefix:@"."] );
    assert(type != nil);
    assert([type length] != 0);
    assert( ! [type hasPrefix:@"."] );
    self = [super init];
    if (self != nil) {
        if ( ([domain length] != 0) && ! [domain hasSuffix:@"."] ) {
            domain = [domain stringByAppendingString:@"."];
        }
        if ( ! [type hasSuffix:@"."] ) {
            type = [type stringByAppendingString:@"."];
        }
        self->domain_ = [domain copy];
        self->type_ = [type copy];
    }
    return self;
}

- (void)dealloc
{
    if (self->sdRef_ != NULL) {
        DNSServiceRefDeallocate(self->sdRef_);
    }
    /*[self->domain_ release];
    [self->type_ release];
    [super dealloc];*/
}

- (void)browseReplyWithFlags:(DNSServiceFlags)flags domain:(NSString *)domain type:(NSString *)type name:(NSString *)name
    // Called when DNS-SD tells us that a service has been discovered or lost.
{
    BOOL            moreComing;
    DNSSDService *   service;
    
    assert(domain != nil);
    assert(type   != nil);
    assert(name   != nil);
    
    moreComing = (flags & kDNSServiceFlagsMoreComing) != 0;
    
    service = [[DNSSDService alloc] initWithDomain:domain type:type name:name];
    assert(service != nil);
    
    if (flags & kDNSServiceFlagsAdd) {
        if ([self.delegate respondsToSelector:@selector(dnssdBrowser:didAddService:moreComing:)]) {
            [self.delegate dnssdBrowser:self didAddService:service moreComing:moreComing];
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(dnssdBrowser:didRemoveService:moreComing:)]) {
            [self.delegate dnssdBrowser:self didRemoveService:service moreComing:moreComing];
        }
    }
}

static void BrowseReplyCallback(
    DNSServiceRef                       sdRef,
    DNSServiceFlags                     flags,
    uint32_t                            interfaceIndex,
    DNSServiceErrorType                 errorCode,
    const char                          *serviceName,
    const char                          *regtype,
    const char                          *replyDomain,
    void                                *context
)
    // Called by DNS-SD when something happens with the browse operation.
{
    DNSSDBrowser *    obj;
    #pragma unused(interfaceIndex)

    assert([NSThread isMainThread]);        // because sdRef dispatches to the main queue
    
    obj = (__bridge DNSSDBrowser *) context;
    assert([obj isKindOfClass:[DNSSDBrowser class]]);
    assert(sdRef == obj->sdRef_);
    #pragma unused(sdRef)
    
    if (errorCode == kDNSServiceErr_NoError) {
        [obj browseReplyWithFlags:flags domain:[NSString stringWithUTF8String:replyDomain] type:[NSString stringWithUTF8String:regtype] name:[NSString stringWithUTF8String:serviceName]];
    } else {
        [obj stopWithError:[NSError errorWithDomain:NSNetServicesErrorDomain code:errorCode userInfo:nil] notify:YES];
    }
}

- (void)startBrowse
    // See comment in header.
{
    NSString *              domain;
    DNSServiceErrorType     errorCode;
    
    if (self.sdRef == NULL) {
        domain = self.domain;
        if (domain == nil) {
            domain = @"";
        }
        
        errorCode = DNSServiceBrowse(&self->sdRef_, 0, kDNSServiceInterfaceIndexP2P, [self.type UTF8String], [domain UTF8String], BrowseReplyCallback, (__bridge void *)(self));
        if (errorCode == kDNSServiceErr_NoError) {
            errorCode = DNSServiceSetDispatchQueue(self.sdRef, dispatch_get_main_queue());
        }
        if (errorCode == kDNSServiceErr_NoError) {
            if ([self.delegate respondsToSelector:@selector(dnssdBrowserWillBrowse:)]) {
                [self.delegate dnssdBrowserWillBrowse:self];
            }
        } else {
            [self stopWithError:[NSError errorWithDomain:NSNetServicesErrorDomain code:errorCode userInfo:nil] notify:YES];
        }
    }
}

- (void)stopWithError:(NSError *)error notify:(BOOL)notify
    // An internal bottleneck for shutting down the object.
{
    if (notify) {
        if (error != nil) {
            if ([self.delegate respondsToSelector:@selector(dnssdBrowser:didNotBrowse:)]) {
                [self.delegate dnssdBrowser:self didNotBrowse:error];
            }
        }
    }
    if (self.sdRef != NULL) {
        DNSServiceRefDeallocate(self.sdRef);
        self.sdRef = NULL;
    }
    if (notify) {
        if ([self.delegate respondsToSelector:@selector(dnssdBrowserDidStopBrowse:)]) {
            [self.delegate dnssdBrowserDidStopBrowse:self];
        }
    }
}

- (void)stop
    // See comment in header.
{
    [self stopWithError:nil notify:NO];
}

@end

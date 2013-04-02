#import <Foundation/Foundation.h>
@protocol DNSSDRegistrationDelegate;

@interface DNSSDRegistration : NSObject

- (id)initWithDomain:(NSString *)domain type:(NSString *)type name:(NSString *)name port:(NSUInteger)port;
    // domain and name can be nil or the empty string to get default behaviour.
    //
    // type must be of the form "_foo._tcp." or "_foo._udp." (possibly without the 
    // trailing dot, see below).
    //
    // port must be in the range 1..65535.
    // 
    // domain and type should include the trailing dot; if they don't, one is added 
    // and that change is reflected in the domain and type properties.
    // 
    // domain and type must not include a leading dot.

// properties that are set up by the init method

@property (copy,   readonly ) NSString * domain;
@property (copy,   readonly ) NSString * type;
@property (copy,   readonly ) NSString * name;
@property (assign, readonly ) NSUInteger port;

// properties that you can change any time

@property (assign, readwrite) id<DNSSDRegistrationDelegate> delegate;

- (void)start;
    // Starts the registration process.  Does nothing if the registration is currently started.

- (void)stop;
    // Stops a registration, deregistering the service from the network.  Does nothing if the 
    // registration is not started.

// properties that are set up once the registration is in place

@property (copy,   readonly ) NSString * registeredDomain;
@property (copy,   readonly ) NSString * registeredName;

@end

@protocol DNSSDRegistrationDelegate <NSObject>

// All delegate methods are called on the main thread.

@optional

- (void)dnssdRegistrationWillRegister:(DNSSDRegistration *)sender;
    // Called before the registration process starts.

- (void)dnssdRegistrationDidRegister:(DNSSDRegistration *)sender;
    // Called when the service is successfully registered.  At this point 
    // registeredName and registeredDomain are valid.

- (void)dnssdRegistration:(DNSSDRegistration *)sender didNotRegister:(NSError *)error;
    // Called when the service can't be registered.  The registration will be stopped 
    // immediately after this delegate method returns.

- (void)dnssdRegistrationDidStop:(DNSSDRegistration *)sender;
    // Called when the registration stops (except if you call -stop on it).

@end

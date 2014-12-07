//
//  SocketHelper.h
//  ChatRom
//
//  Created by sumeng on 12/6/14.
//  Copyright (c) 2014 sumeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SocketPacket.h"

@protocol SocketHelperDelegate;

@interface HostInfo : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *host;
@property (nonatomic, assign) uint16_t port;

@end

@interface SocketHelper : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) id<SocketHelperDelegate> delegate;

+ (SocketHelper *)shared;

- (BOOL)accept;
- (BOOL)connectToHost:(NSString *)host port:(uint16_t)port;
- (void)send:(NSData *)data;
- (void)send:(NSData *)data toHost:(HostInfo *)host;
- (void)send:(NSData *)data toHosts:(NSArray *)hosts;
- (void)close;

- (BOOL)isServer;
- (NSArray *)clientHosts;
- (HostInfo *)serverHost;

@end

@protocol SocketHelperDelegate <NSObject>

@optional
- (void)socketHelper:(SocketHelper *)helper acceptHost:(HostInfo *)host;
- (void)socketHelper:(SocketHelper *)helper connectToHost:(HostInfo *)host;
- (void)socketHelper:(SocketHelper *)helper recievePacket:(SocketPacket *)packet host:(HostInfo *)host;
- (void)socketHelper:(SocketHelper *)helper disconnect:(HostInfo *)host;

@end

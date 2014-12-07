//
//  SocketHelper.m
//  ChatRom
//
//  Created by sumeng on 12/6/14.
//  Copyright (c) 2014 sumeng. All rights reserved.
//

#import "SocketHelper.h"
#import "GCDAsyncSocket.h"
#import "SocketFinder.h"

#define SOCKET_TIMEOUT_AUTH 2

typedef enum _SocketTag {
    SocketTagHeader = 1,
    SocketTagBody,
    
    SocketTagTotal
}SocketTag;

@interface HostInfo ()

@property (nonatomic, strong) GCDAsyncSocket* socket;
@property (nonatomic, assign) BOOL isAuth;

@end

@implementation HostInfo

- (id)init {
    self = [super init];
    if (self) {
        _socket = nil;
        _name = @"";
        _host = @"";
        _isAuth = NO;
    }
    return self;
}

@end

@interface SocketHelper () <GCDAsyncSocketDelegate>

@property (nonatomic, strong) GCDAsyncSocket *socket;
@property (nonatomic, strong) HostInfo *server;
@property (nonatomic, strong) NSMutableArray *clients;
@property (nonatomic, assign) BOOL isServer;
@property (nonatomic, strong) SocketFinder* finder;

@property (nonatomic, strong) NSMutableDictionary *cachePacketDict;

@end

@implementation SocketHelper

+ (SocketHelper *)shared {
    static SocketHelper *obj = nil;
    if (obj == nil) {
        obj = [[SocketHelper alloc] init];
    }
    return obj;
}

- (id)init {
    self  = [super init];
    if (self) {
        _server = nil;
        _clients = [[NSMutableArray alloc] init];
        _cachePacketDict = [[NSMutableDictionary alloc] init];
        _name = @"";
    }
    return self;
}

- (void)open {
    [self close];
    self.socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
}

- (void)close {
    if (_socket) {
        [_socket disconnect];
        self.socket = nil;
    }
    [_clients removeAllObjects];
    self.server = nil;
    if (_finder) {
        [_finder close];
        self.finder = nil;
    }
}

- (BOOL)accept {
    [self open];
    NSError *err = nil;
    if (![_socket acceptOnPort:SERVER_PORT error:&err]) {
        NSLog(@"socket accept() err:%@", err);
        return NO;
    }
    self.finder = [[SocketFinder alloc] init];
    _finder.name = _name;
    if (![_finder bind]) {
        NSLog(@"socket finder bind err");
    }
    _isServer = YES;
    return YES;
}

- (BOOL)connectToHost:(NSString *)host port:(uint16_t)port {
    if (host && host.length > 0 && port > 0) {
        [self open];
        NSError *err = nil;
        if (![_socket connectToHost:host onPort:port withTimeout:1 error:&err]) {
            NSLog(@"socket connectToHost() err:%@", err);
            return NO;
        }
        _isServer = NO;
        return YES;
    }
    return NO;
}

- (void)send:(NSData *)data {
    if (_isServer) {
        [self send:data toHosts:[self clientHosts]];
    }
    else {
        [self send:data toHost:[self serverHost]];
    }
}

- (void)send:(NSData *)data toHost:(HostInfo *)host; {
    [host.socket writeData:data withTimeout:-1 tag:1];
}

- (void)send:(NSData *)data toHosts:(NSArray *)hosts {
    for (HostInfo *host in hosts) {
        [self send:data toHost:host];
    }
}

- (BOOL)isServer {
    return _isServer;
}

- (NSArray *)clientHosts {
    return _clients;
}

- (HostInfo *)serverHost {
    return _server;
}

- (HostInfo *)hostInfo:(GCDAsyncSocket *)socket {
    if (_isServer) {
        for (HostInfo *host in _clients) {
            if (host.socket == socket) {
                return host;
            }
        }
    }
    else {
        if (_server.socket == socket) {
            return _server;
        }
    }
    return nil;
}

- (BOOL)auth:(HostInfo *)host packet:(SocketPacket *)packet {
    if (((_isServer && packet.type == SocketPacketTypeAuthReq) ||
        (!_isServer && packet.type == SocketPacketTypeAuthRsp)) &&
        [(SocketPacketAuth *)packet auth]) {
        SocketPacketAuth *packetAuth = (SocketPacketAuth *)packet;
        host.name = packetAuth.name;
        [self authSucceed:host];
        return YES;
    }
    else {
        [self authFailed:host];
        return NO;
    }
    
}

- (void)authSucceed:(HostInfo *)host {
    host.isAuth = YES;
    if (_isServer) {
        if (_delegate && [_delegate respondsToSelector:@selector(socketHelper:acceptHost:)]) {
            [_delegate socketHelper:self acceptHost:host];
        }
        SocketPacketAuth *packet = [[SocketPacketAuth alloc] initWithRsp];
        packet.name = _name;
        [self send:[packet data] toHost:host];
    }
    else {
        if (_delegate && [_delegate respondsToSelector:@selector(socketHelper:connectToHost:)]) {
            [_delegate socketHelper:self connectToHost:host];
        }
    }
}

- (void)authFailed:(HostInfo *)host {
    [host.socket disconnect];
}

- (void)read:(NSData *)data tag:(long)tag host:(HostInfo *)host {
    switch (tag) {
        case SocketTagHeader: {
            SocketPacket *cachePacket = [SocketPacket parseHeader:data];
            if (cachePacket && cachePacket.len > 0) {
                NSLog(@"socket recieve header:%d, %d", cachePacket.len, cachePacket.type);
                [self cachePacketAdd:cachePacket host:host];
                [host.socket readDataToLength:cachePacket.len withTimeout:(host.isAuth ? -1 : SOCKET_TIMEOUT_AUTH) tag:SocketTagBody];
            }
            else {
                if (host.isAuth) {
                    [host.socket readDataToLength:[SocketPacket lenOfHeader] withTimeout:-1 tag:SocketTagHeader];
                }
                else {
                    [self authFailed:host];
                }
            }
            break;
        }
        case SocketTagBody: {
            NSLog(@"socket recieve body:%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            SocketPacket *cachePacket = [self cachePacketFind:host];
            if (cachePacket) {
                [cachePacket parseBody:data];
                if (host.isAuth) {
                    if (_delegate && [_delegate respondsToSelector:@selector(socketHelper:recievePacket:host:)]) {
                        [_delegate socketHelper:self recievePacket:cachePacket host:host];
                    }
                }
                else {
                    [self auth:host packet:cachePacket];
                }
                [self cachePacketRemove:host];
            }
            [host.socket readDataToLength:[SocketPacket lenOfHeader] withTimeout:-1 tag:SocketTagHeader];
            break;
        }
        default:
            break;
    }
}

- (void)cachePacketAdd:(SocketPacket *)packet host:(HostInfo *)host {
    [_cachePacketDict setObject:packet forKey:[NSString stringWithFormat:@"%@:%d", host.host, host.port]];
}

- (SocketPacket *)cachePacketFind:(HostInfo *)host {
    return [_cachePacketDict objectForKey:[NSString stringWithFormat:@"%@:%d", host.host, host.port]];
}

- (void)cachePacketRemove:(HostInfo *)host {
    [_cachePacketDict removeObjectForKey:[NSString stringWithFormat:@"%@:%d", host.host, host.port]];
}

#pragma mark - GCDAsyncSocketDelegate

- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket{
    HostInfo *host = [[HostInfo alloc] init];
    host.socket = newSocket;
    host.host = newSocket.connectedHost;
    host.port = newSocket.connectedPort;
    [_clients addObject:host];
    [newSocket readDataToLength:[SocketPacket lenOfHeader] withTimeout:SOCKET_TIMEOUT_AUTH tag:SocketTagHeader];
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    self.server = [[HostInfo alloc] init];
    _server.socket = sock;
    _server.host = host;
    _server.port = port;
    SocketPacketAuth *packet = [[SocketPacketAuth alloc] initWithReq];
    packet.name = _name;
    [self send:[packet data] toHost:_server];
    [sock readDataToLength:[SocketPacket lenOfHeader] withTimeout:SOCKET_TIMEOUT_AUTH tag:SocketTagHeader];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    switch (tag) {
        case SocketTagHeader:
            [self read:data tag:tag host:[self hostInfo:sock]];
            break;
        case SocketTagBody:
            [self read:data tag:tag host:[self hostInfo:sock]];
            break;
        default:
            break;
    }
}

- (void)socket:(GCDAsyncSocket *)sock didReadPartialDataOfLength:(NSUInteger)partialLength tag:(long)tag {

}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {

}

- (NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutReadWithTag:(long)tag
                 elapsed:(NSTimeInterval)elapsed
               bytesDone:(NSUInteger)length {
    [self authFailed:[self hostInfo:sock]];
    return 0;
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    if (_delegate && [_delegate respondsToSelector:@selector(socketHelper:disconnect:)]) {
        [_delegate socketHelper:self disconnect:[self hostInfo:sock]];
    }
    if (sock) {
        if (sock == _socket) {
            [self close];
        }
        else {
            [_clients removeObject:[self hostInfo:sock]];
        }
    }
}

@end

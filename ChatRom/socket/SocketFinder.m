//
//  SocketFinder.m
//  ChatRom
//
//  Created by sumeng on 12/6/14.
//  Copyright (c) 2014 sumeng. All rights reserved.
//

#import "SocketFinder.h"
#import "GCDAsyncUdpSocket.h"

@interface SocketFinder () <SocketHelperDelegate>

@property (nonatomic, strong) GCDAsyncUdpSocket *socket;
@property (nonatomic, assign) BOOL isServer;

@end

@implementation SocketFinder

- (id)init {
    self = [super init];
    if (self) {
        _isServer = NO;
    }
    return self;
}

- (void)open {
    [self close];
    self.socket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
}

- (void)close {
    [_socket close];
    self.socket = nil;
}

- (BOOL)find {
    [self open];
    
    NSError *err = nil;
    [_socket enableBroadcast:YES error:&err];
    if (err) {
        NSLog(@"SocketFinder enableBroadcast err:%@", err);
        return NO;
    }
    
    SocketPacketAuth *packet = [[SocketPacketAuth alloc] initWithReq];
    packet.name = @"finder";
    [_socket sendData:[packet data] toHost:@"255.255.255.255" port:SERVER_PORT withTimeout:-1 tag:0];
    
    [_socket receiveOnce:&err];
    if (err) {
        NSLog(@"SocketFinder receive err:%@", err);
        return NO;
    }
    _isServer = NO;
    return YES;
}

- (BOOL)bind {
    [self open];

    NSError *err = nil;
    if (![_socket bindToPort:SERVER_PORT error:&err]) {
        NSLog(@"SocketFinder bind err:%@", err);
        return NO;
    }

    [_socket receiveOnce:&err];
    if (err) {
        NSLog(@"SocketFinder receive err:%@", err);
        return NO;
    }
    _isServer = YES;
    return YES;
}

#pragma mark - GCDAsyncUdpSocketDelegate

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data
                                               fromAddress:(NSData *)address
                                         withFilterContext:(id)filterContext {
    SocketPacket *packet = [SocketPacket parse:data];
    if (((_isServer && packet.type == SocketPacketTypeAuthReq) ||
         (!_isServer && packet.type == SocketPacketTypeAuthRsp)) &&
        [(SocketPacketAuth *)packet auth]) {
        SocketPacketAuth *packetAuth = (SocketPacketAuth *)packet;
        if (_isServer) {
            SocketPacketAuth *packetRsp = [[SocketPacketAuth alloc] initWithRsp];
            packetRsp.name = _name;
            [sock sendData:[packetRsp data] toAddress:address withTimeout:-1 tag:0];
        }
        else {
            if (_delegate && [_delegate respondsToSelector:@selector(socketFinder:find:)]) {
                HostInfo *host = [[HostInfo alloc] init];
                host.name = packetAuth.name;
                host.host = [GCDAsyncUdpSocket hostFromAddress:address];
                host.port = [GCDAsyncUdpSocket portFromAddress:address];
                [_delegate socketFinder:self find:host];
            }
        }
    }
    NSError *err = nil;
    [_socket receiveOnce:&err];
    if (err) {
        NSLog(@"SocketFinder receive err:%@", err);
    }
}

@end
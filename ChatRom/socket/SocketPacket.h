//
//  SocketPacket.h
//  ChatRom
//
//  Created by sumeng on 12/6/14.
//  Copyright (c) 2014 sumeng. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum _SocketPacketType {
    SocketPacketTypeErr = 0,
    SocketPacketTypeAuthReq = 1,
    SocketPacketTypeAuthRsp,
    SocketPacketTypeContent,
    SocketPacketTypeRsp,
    
    SocketPacketTypeTotal
}SocketPacketType;

@interface SocketPacket : NSObject

@property (nonatomic, assign) uint32_t len;
@property (nonatomic, assign) Byte type;

@property (nonatomic, assign) int packetId;

- (void)parseBody:(NSData *)data;
- (NSData *)data;

+ (int)lenOfHeader;
+ (SocketPacket *)parse:(NSData *)data;
+ (SocketPacket *)parseHeader:(NSData *)data;

@end

@interface SocketPacketAuth : SocketPacket

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *key;

- (id)initWithReq;
- (id)initWithRsp;
- (BOOL)auth;

@end

@interface SocketPacketContent : SocketPacket

@property (nonatomic, strong) NSString *content;

@end

@interface SocketPacketRsp : SocketPacket

@property (nonatomic, assign) int errCode;
@property (nonatomic, strong) NSString *errMsg;

@end

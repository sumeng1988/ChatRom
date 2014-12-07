//
//  SocketPacket.m
//  ChatRom
//
//  Created by sumeng on 12/6/14.
//  Copyright (c) 2014 sumeng. All rights reserved.
//

#import "SocketPacket.h"

static Byte sHeaderSep[] = {13, 10};
static int sPacketId = 1;

@implementation SocketPacket

- (id)init {
    self = [super init];
    if (self) {
        _len = 0;
        _type = SocketPacketTypeErr;
    }
    return self;
}

- (void)parseBody:(NSData *)data {
    
}

- (NSData *)data {
    return [self data:nil];
}

- (NSMutableData *)dataOfHeader {
    NSMutableData* data = [[NSMutableData alloc] init];
    [data appendInt:htonl(_len)];
    [data appendByte:_type];
    [data appendBytes:sHeaderSep length:sizeof(sHeaderSep)];
    return data;
}

- (NSData *)data:(NSMutableDictionary *)bodyDict {
    if (self.packetId == 0) {
        self.packetId = sPacketId++;
    }
    if (bodyDict == nil) {
        bodyDict = [NSMutableDictionary dictionary];
    }
    [bodyDict setObject:[NSNumber numberWithInt:self.packetId] forKey:@"I"];
    if ([NSJSONSerialization isValidJSONObject:bodyDict]) {
        NSError *err = nil;
        NSData *body = [NSJSONSerialization dataWithJSONObject:bodyDict options:NSJSONWritingPrettyPrinted error:&err];
        if (!err) {
            _len = (uint32_t)body.length;
            NSMutableData *data = [self dataOfHeader];
            [data appendData:body];
            return data;
        }
        else {
            NSLog(@"err:%@", err);
        }
    }
    return nil;
}

- (id)readJson:(NSData *)data {
    NSError *err = nil;
    id jsonObj = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&err];
    if (err == nil) {
        return jsonObj;
    }
    else {
        NSLog(@"err:%@", err);
        return nil;
    }
}

+ (int)lenOfHeader {
    return sizeof(uint32_t)+sizeof(Byte)+sizeof(sHeaderSep);
}

+ (SocketPacket *)parse:(NSData *)data {
    SocketPacket *packet = [SocketPacket parseHeader:data];
    if (packet && packet.type != SocketPacketTypeErr) {
        NSData *body = [data subdataWithRange:NSMakeRange([SocketPacket lenOfHeader], packet.len)];
        [packet parseBody:body];
    }
    return packet;
}

+ (SocketPacket *)parseHeader:(NSData *)data {
    SocketPacket *packet = nil;
    if (data && data.length >= [SocketPacket lenOfHeader]) {
        Byte *sep = (Byte *)(data.bytes + [SocketPacket lenOfHeader] - sizeof(sHeaderSep));
        if (sep[0] == sHeaderSep[0] && sep[1] == sHeaderSep[1]) {
            int offset = 0;
            uint32_t len = ntohl([data readInt:offset]);
            offset += sizeof(int);
            Byte type = [data readByte:offset];
            
            switch (type) {
                case SocketPacketTypeAuthReq:
                    packet = [[SocketPacketAuth alloc] initWithReq];
                    break;
                case SocketPacketTypeAuthRsp:
                    packet = [[SocketPacketAuth alloc] initWithRsp];
                    break;
                case SocketPacketTypeContent:
                    packet = [[SocketPacketContent alloc] init];
                    break;
                case SocketPacketTypeRsp:
                    packet = [[SocketPacketRsp alloc] init];
                    break;
                default:
                    break;
            }
            if (packet) {
                packet.len = len;
            }
        }
    }
    return packet;
}

@end

@implementation SocketPacketAuth

- (id)initWithType:(SocketPacketType)type {
    self = [super init];
    if (self) {
        if (type == SocketPacketTypeAuthReq) {
            self.type = type;
            self.key = @"auth req";
        }
        else if (type == SocketPacketTypeAuthRsp) {
            self.type = type;
            self.key = @"auth rsp";
        }
    }
    return self;
}

- (id)initWithReq {
    return [self initWithType:SocketPacketTypeAuthReq];
}

- (id)initWithRsp {
    return [self initWithType:SocketPacketTypeAuthRsp];
}

- (BOOL)auth {
    if (self.type == SocketPacketTypeAuthReq) {
        return [@"auth req" isEqualToString:self.key];
    }
    else if (self.type == SocketPacketTypeAuthRsp) {
        return [@"auth rsp" isEqualToString:self.key];
    }
    return NO;
}

- (void)parseBody:(NSData *)data {
    NSDictionary *jsonDict = [self readJson:data];
    if (jsonDict != nil) {
        self.packetId = [jsonDict intForKey:@"I"];
        self.name = [jsonDict stringForKey:@"N"];
        self.key = [jsonDict stringForKey:@"K"];
    }
}

- (NSData *)data {
    NSMutableDictionary *bodyDict = [[NSMutableDictionary alloc] init];
    [bodyDict setObject:self.name forKey:@"N"];
    [bodyDict setObject:self.key forKey:@"K"];
    return [self data:bodyDict];
}

@end

@implementation SocketPacketContent

- (id)init {
    self = [super init];
    if (self) {
        self.type = SocketPacketTypeContent;
    }
    return self;
}

- (void)parseBody:(NSData *)data {
    NSDictionary *jsonDict = [self readJson:data];
    if (jsonDict != nil) {
        self.packetId = [jsonDict intForKey:@"I"];
        self.content = [jsonDict stringForKey:@"C"];
    }
}

- (NSData *)data {
    NSMutableDictionary *bodyDict = [[NSMutableDictionary alloc] init];
    [bodyDict setObject:self.content forKey:@"C"];
    return [self data:bodyDict];
}

@end

@implementation SocketPacketRsp

- (id)init {
    self = [super init];
    if (self) {
        self.type = SocketPacketTypeRsp;
        self.errCode = 0;
    }
    return self;
}

- (void)parseBody:(NSData *)data {
    NSDictionary *jsonDict = [self readJson:data];
    if (jsonDict != nil) {
        self.packetId = [jsonDict intForKey:@"I"];
        self.errCode = [jsonDict intForKey:@"EC"];
        self.errMsg = [jsonDict stringForKey:@"EM"];
    }
}

- (NSData *)data {
    NSMutableDictionary *bodyDict = [[NSMutableDictionary alloc] init];
    [bodyDict setObject:[NSNumber numberWithInt:self.errCode] forKey:@"EC"];
    [bodyDict setObject:self.errMsg forKey:@"EM"];
    return [self data:bodyDict];
}

- (void)setErrCode:(int)errCode {
    _errCode = errCode;
    switch (_errCode) {
        case 0:
            self.errMsg = @"操作成功";
            break;
        default:
            break;
    }
}

@end

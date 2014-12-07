//
//  SocketFinder.h
//  ChatRom
//
//  Created by sumeng on 12/6/14.
//  Copyright (c) 2014 sumeng. All rights reserved.
//
//

#import <Foundation/Foundation.h>
#import "SocketHelper.h"

@protocol SocketFinderDelegate;

@interface SocketFinder : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) id<SocketFinderDelegate> delegate;

- (BOOL)find;
- (BOOL)bind;
- (void)close;

@end

@protocol SocketFinderDelegate <NSObject>

@optional
- (void)socketFinder:(SocketFinder *)finder find:(HostInfo *)host;

@end
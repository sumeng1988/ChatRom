//
//  ChatVC.h
//  ChatRom
//
//  Created by sumeng on 12/7/14.
//  Copyright (c) 2014 sumeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatVC : UIViewController

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *host;
@property (nonatomic, assign) uint16_t port;
@property (nonatomic, assign) BOOL isServer;

@end

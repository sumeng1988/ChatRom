//
//  ChatVC.m
//  ChatRom
//
//  Created by sumeng on 12/7/14.
//  Copyright (c) 2014 sumeng. All rights reserved.
//

#import "ChatVC.h"
#import "UIInputBar.h"
#import "SocketHelper.h"

@interface ChatVC () <UIInputBarDelegate, SocketHelperDelegate>

@property (weak, nonatomic) IBOutlet UIInputBar *inputBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inputBarHeightContraint;

@property (nonatomic, strong) SocketHelper *socketHelper;
@property (nonatomic, strong) NSMutableArray *dataList;

@end

@implementation ChatVC

- (void)viewDidLoad {
    [super viewDidLoad];
    _dataList = [[NSMutableArray alloc] init];
    _inputBar.delegate = self;
    [self.view bringSubviewToFront:_inputBar];
    
    _socketHelper = [[SocketHelper alloc] init];
    _socketHelper.name = _name;
    _socketHelper.delegate = self;
    if (_isServer) {
        [_socketHelper accept];
    }
    else {
        [_socketHelper connectToHost:_host port:_port];
    }
}

- (void)dealloc {
    _socketHelper.delegate = nil;
    [_socketHelper close];
}

#pragma mark - Native

- (void)insertData:(NSString *)item {
    if (_dataList.count > 0) {
        [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_dataList.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    [_dataList addObject:item];
    [_tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:_dataList.count-1 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)recieveContent:(SocketPacketContent *)packetContent host:(HostInfo *)host {
    NSString *item = [NSString stringWithFormat:@"%@:%@", host.name, packetContent.content];
    [self insertData:item];
    
    SocketPacketRsp *packet = [[SocketPacketRsp alloc] init];
    packet.packetId = packetContent.packetId;
    [_socketHelper send:[packet data] toHost:host];
    
    if (_isServer) {
        NSMutableArray *hosts = [[NSMutableArray alloc] initWithArray:[_socketHelper clientHosts]];
        [hosts removeObject:host];
        if (hosts.count > 0) {
            [_socketHelper send:[packetContent data] toHosts:hosts];
        }
    }
}

- (void)recieveRsp:(SocketPacketRsp *)packetRsp host:(HostInfo *)host {
    NSLog(@"socket recieve SocketPacketRsp id:%d code:%d msg:%@",packetRsp.packetId, packetRsp.errCode, packetRsp.errMsg);
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    NSString *item = [_dataList objectAtIndex:indexPath.row];
    cell.textLabel.text = item;
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UIInputBarDelegate

- (void)inputBar:(UIInputBar *)bar send:(NSString *)text {
    SocketPacketContent *packet = [[SocketPacketContent alloc] init];
    packet.content = text;
    [_socketHelper send:[packet data]];
    
    NSString *item = [NSString stringWithFormat:@"我：%@", text];
    [self insertData:item];
    _inputBar.text = @"";
}

- (void)inputBar:(UIInputBar *)bar willChangeHeight:(CGFloat)height {
    _inputBarHeightContraint.constant = height;
}

#pragma mark - SocketHelperDelegate

- (void)socketHelper:(SocketHelper *)helper acceptHost:(HostInfo *)host {
    NSString *item = [NSString stringWithFormat:@"%@ accept", host.name];
    [self insertData:item];
}

- (void)socketHelper:(SocketHelper *)helper connectToHost:(HostInfo *)host {
    NSString *item = [NSString stringWithFormat:@"connect to %@", host.name];
    [self insertData:item];
}

- (void)socketHelper:(SocketHelper *)helper recievePacket:(SocketPacket *)packet host:(HostInfo *)host {
    switch (packet.type) {
        case SocketPacketTypeContent:
            [self recieveContent:(SocketPacketContent *)packet host:host];
            break;
        case SocketPacketTypeRsp:
            [self recieveRsp:(SocketPacketRsp *)packet host:host];
            break;
        default:
            break;
    }
}

- (void)socketHelper:(SocketHelper *)helper disconnect:(HostInfo *)host {
    NSString *item = @"disconnect";
    [self insertData:item];
}

@end

//
//  ChatRomListVC.m
//  ChatRom
//
//  Created by sumeng on 12/6/14.
//  Copyright (c) 2014 sumeng. All rights reserved.
//

#import "ChatRomListVC.h"
#import "SocketFinder.h"
#import "ChatVC.h"

@interface ChatRomListVC () <SocketFinderDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) SocketFinder *finder;
@property (nonatomic, strong) NSMutableArray *dataList;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) HostInfo *host;
@property (nonatomic, assign) BOOL isServer;

@end

@implementation ChatRomListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _dataList = [[NSMutableArray alloc] init];
    _finder = [[SocketFinder alloc] init];
    _finder.delegate = self;
}

- (void)dealloc {
    _finder.delegate = nil;
    [_finder close];
}

#pragma mark - Navigation

- (void)refreshData {
    [_dataList removeAllObjects];
    [_finder find];
    [self.tableView reloadData];
}

- (IBAction)onCreate:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Create"
                                                    message:@"Type in rom's name"
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Done", nil];
    alert.tag = 1;
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}

- (IBAction)onRefresh:(id)sender {
    [self refreshData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ChatSegue"]) {
        ChatVC *vc = [segue destinationViewController];
        vc.isServer = _isServer;
        vc.name = _name;
        if (!_isServer) {
            vc.host = _host.host;
            vc.port = _host.port;
        }
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"RomListCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    HostInfo *item = [_dataList objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@(%@)", item.name, item.host];
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    _host = [_dataList objectAtIndex:indexPath.row];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Join"
                                                    message:@"Type in name"
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Done", nil];
    alert.tag = 2;
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}

#pragma mark - SocketHelperDelegate

- (void)socketFinder:(SocketFinder *)finder find:(HostInfo *)host {
    [_dataList addObject:host];
    [self.tableView reloadData];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != alertView.cancelButtonIndex) {
        if (alertView.tag == 1) {
            _isServer = true;
            _name = [alertView textFieldAtIndex:0].text;
            [self performSegueWithIdentifier:@"ChatSegue" sender:self];
        }
        else if (alertView.tag == 2) {
            _isServer = false;
            _name = [alertView textFieldAtIndex:0].text;
            [self performSegueWithIdentifier:@"ChatSegue" sender:self];
        }
    }
}

@end

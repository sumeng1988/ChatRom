//
//  UIInputBar.h
//  ChatRom
//
//  Created by sumeng on 12/7/14.
//  Copyright (c) 2014 sumeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UIInputBarDelegate;

@interface UIInputBar : UIView

@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSString *placeholder;
@property (nonatomic, assign) BOOL isOpen;
@property (nonatomic, assign) BOOL enable;
@property (nonatomic, weak) id<UIInputBarDelegate> delegate;

@end

@protocol UIInputBarDelegate <NSObject>

@optional
- (void)inputBar:(UIInputBar *)bar send:(NSString *)text;
- (void)inputBar:(UIInputBar *)bar willChangeHeight:(CGFloat)height;
- (void)inputBar:(UIInputBar *)bar didChangeHeight:(CGFloat)height;

@end
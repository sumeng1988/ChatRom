//
//  UIInputBar.m
//  ChatRom
//
//  Created by sumeng on 12/7/14.
//  Copyright (c) 2014 sumeng. All rights reserved.
//

#import "UIInputBar.h"
#import "HPGrowingTextView.h"

#define KInputBarHeight 44
#define KInputViewMinHeight 34
#define KInputViewMaxHeight 80

@interface UIInputBar () <HPGrowingTextViewDelegate>

@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) HPGrowingTextView *inputView;
@property (nonatomic, strong) UIImageView *inputBgView;

@end

@implementation UIInputBar

- (id)init {
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self initView];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initView];
    }
    return self;
}

- (void)initView {
    self.backgroundColor = [UIColor colorWithRed:0.97f green:0.97f blue:0.97f alpha:1];
    self.clipsToBounds = YES;
    _isOpen = NO;
    
    _topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
    [self addSubview:_topView];
    
    _inputBgView = [[UIImageView alloc] initWithImage:[UIImage stretchImage:@"bg_tape"]];
    [_topView addSubview:_inputBgView];
    
    _inputView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(0, 0, _topView.width-20, KInputViewMinHeight)];
    _inputView.translatesAutoresizingMaskIntoConstraints = YES;
    _inputView.backgroundColor = [UIColor clearColor];
    _inputView.center = CGPointMake(_topView.width/2, _topView.height/2);
    _inputView.delegate = self;
    _inputView.font = [UIFont font:15];
    _inputView.returnKeyType = UIReturnKeySend;
    _inputView.minHeight = KInputViewMinHeight;
    _inputView.maxHeight = KInputViewMaxHeight;
    [_topView addSubview:_inputView];
    
    _inputBgView.frame = _inputView.frame;
    
    _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, _topView.y+_topView.height, self.width, 0)];
    [self addSubview:_contentView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)layoutSubviews {
    _topView.width = self.width;
    _contentView.width = self.width;

    _inputView.width = _topView.width-20;
    _inputView.center = CGPointMake(_topView.width/2, _topView.height/2);
    _inputBgView.frame = _inputView.frame;
}

#pragma mark - Native

- (void)setEnable:(BOOL)enable {
    _enable = enable;
    _inputView.editable = enable;
}

- (void)setText:(NSString *)text {
    _inputView.text = text;
}

- (NSString *)text {
    return _inputView.text;
}

- (void)setPlaceholder:(NSString *)placeholder {
    _inputView.placeholder = placeholder;
}

- (NSString *)placeholder {
    return _inputView.placeholder;
}

- (BOOL)becomeFirstResponder {
    return [_inputView becomeFirstResponder];
}

- (BOOL)resignFirstResponder {
    return [_inputView resignFirstResponder];
}

- (void)onKeyboardWillShow:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    _contentView.height = keyboardRect.size.height;
    self.height = _topView.height + _contentView.height;
    _isOpen = YES;
    if (_delegate && [_delegate respondsToSelector:@selector(inputBar:willChangeHeight:)]) {
        [_delegate inputBar:self willChangeHeight:self.height];
    }
    if (_delegate && [_delegate respondsToSelector:@selector(inputBar:didChangeHeight:)]) {
        [_delegate inputBar:self didChangeHeight:self.height];
    }
}

- (void)onKeyboardWillHide:(NSNotification *)notification {
    _contentView.height = 0;
    self.height = _topView.height + _contentView.height;
    _isOpen = NO;
    if (_delegate && [_delegate respondsToSelector:@selector(inputBar:willChangeHeight:)]) {
        [_delegate inputBar:self willChangeHeight:self.height];
    }
    if (_delegate && [_delegate respondsToSelector:@selector(inputBar:didChangeHeight:)]) {
        [_delegate inputBar:self didChangeHeight:self.height];
    }
}

- (void)onSendClicked:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(inputBar:send:)]) {
        [_delegate inputBar:self send:_inputView.text];
    }
}

#pragma mark - HPGrowingTextViewDelegate

- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height {
    _inputBgView.height = height;
    _topView.height = height + (KInputBarHeight-KInputViewMinHeight);
    _contentView.y = _topView.height;
    self.height = _topView.height+_contentView.height;
    if (_delegate && [_delegate respondsToSelector:@selector(inputBar:willChangeHeight:)]) {
        [_delegate inputBar:self willChangeHeight:self.height];
    }
}

- (BOOL)growingTextView:(HPGrowingTextView *)growingTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [self onSendClicked:nil];
        return NO;
    }
    return YES;
}

@end

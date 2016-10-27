//
//  HQAlertViewController.m
//  Hq100yyApp
//
//  Created by lidebo on 2016/10/25.
//  Copyright © 2016年 edu24ol. All rights reserved.
//

#import "HQAlertViewController.h"
#import <Masonry.h>
#import <POP.h>

//弱引用/强引用
#define kWeakSelf(type)   __weak typeof(type) weak##type = type;
#define kStrongSelf(type) __strong typeof(type) type = weak##type;

#define ScreenWidth  [[UIScreen mainScreen] bounds].size.width
#define ScreenHeight [[UIScreen mainScreen] bounds].size.height
#define OnePixel     (1./[UIScreen mainScreen].scale)
#define ButtonHeight 45
#define animateTime  0.35f
#define UIColorFromHEX(hexValue, alphaValue) \
[UIColor colorWithRed:((float)((hexValue & 0xFF0000) >> 16))/255.0 \
green:((float)((hexValue & 0x00FF00) >> 8))/255.0 \
blue:((float)(hexValue & 0x0000FF))/255.0 \
alpha:alphaValue]

@interface HQAlertViewController ()<UITextFieldDelegate>
@property (nonatomic, assign) BOOL notifiKeyboardHide;

@property (nonatomic, strong) UITextField * inputTextField;  //输入框
@property (nonatomic, strong) UIView * alertView; //弹窗视图

@property (nonatomic, strong) UIButton * reloadImageBtn;

@property (nonatomic, copy) ConfirmBlock confirmBlock;
@property (nonatomic, copy) CancelBlock cancelBlock;
@property (nonatomic, copy) TextFieldConfigurationHandler configurationHandler;
@property (nonatomic, copy) InputTextCheckHandler checkHandler;
@property (nonatomic, strong) NSString *titleText;
@property (nonatomic, strong) NSString *messageText;
@end

@implementation HQAlertViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = UIColorFromHEX(0x000000, 0.5);
    [self initAlertView];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.inputTextField) {
        [self willToShow:self.alertView];
    } else {
        [self shakeToShow:self.alertView];
    }
}

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message ConfirmAction:(ConfirmBlock)confirmBlock andCancelAction:(CancelBlock)cancelBlcok
{
    if (self = [super init]) {
        self.titleText = title;
        self.messageText = message;
        self.confirmBlock = confirmBlock;
        self.cancelBlock = cancelBlcok;
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        self.modalPresentationStyle = UIModalPresentationOverFullScreen;
    }
    return self;
}

- (void)addTextFieldConfigurationHanlder:(TextFieldConfigurationHandler)configurationHandler {
    self.configurationHandler = configurationHandler;
}

- (void)addInputTextCheckHandler:(InputTextCheckHandler)checkHandler {
    self.checkHandler = checkHandler;
}

#pragma mark - 创建UI
- (void)initAlertView
{
    _notifiKeyboardHide = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
     //弹窗
    _alertView = [[UIView alloc] init];
    _alertView.center = CGPointMake(ScreenWidth/2., ScreenHeight/2.);
    _alertView.bounds = CGRectMake(0, 0, 300, 190);
    _alertView.backgroundColor = [UIColor whiteColor];
    _alertView.layer.cornerRadius = 6;
    _alertView.clipsToBounds = YES;
    [self.view addSubview:_alertView];
    
    //title
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = self.titleText;
    titleLabel.adjustsFontSizeToFitWidth = YES;
    [titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    titleLabel.textColor = UIColorFromHEX(0x333333, 1);
    kWeakSelf(self);
    [_alertView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakself.alertView).offset(15);
        make.right.equalTo(weakself.alertView).offset(-15);
        make.top.equalTo(weakself.alertView).offset(20);
        make.height.equalTo(@20);
    }];
    
    UILabel *messageLabel = [[UILabel alloc] init];
    messageLabel.text = self.messageText;
    titleLabel.adjustsFontSizeToFitWidth = YES;
    [messageLabel setFont:[UIFont systemFontOfSize:12]];
    [messageLabel setTextAlignment:NSTextAlignmentCenter];
    messageLabel.textColor = UIColorFromHEX(0x333333, 1);
    [_alertView addSubview:messageLabel];
    [messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakself.alertView).offset(15);
        make.right.equalTo(weakself.alertView).offset(-15);
        make.top.equalTo(titleLabel.mas_bottom).offset(8);
        make.height.equalTo(@15);
    }];
    
     //按钮
    UIButton * cancelBtn = [self createButtonWithFrame:CGRectMake(0, CGRectGetHeight(_alertView.frame) - ButtonHeight, _alertView.frame.size.width/2., ButtonHeight) title:@"取消" andAction:@selector(cancelAction:)];
    [cancelBtn setTitleColor:UIColorFromHEX(0x666666, 1) forState:UIControlStateNormal];
    
    UIButton * confirmBtn = [self createButtonWithFrame:CGRectMake(_alertView.frame.size.width/2., CGRectGetHeight(_alertView.frame) - ButtonHeight, _alertView.frame.size.width/2., ButtonHeight) title:@"确认" andAction:@selector(confirmAction:)];
    [confirmBtn setTitleColor:UIColorFromHEX(0xf26631, 1) forState:UIControlStateNormal];
    
    //分割线
    UILabel * horLine = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(_alertView.frame) - ButtonHeight - OnePixel, _alertView.frame.size.width, OnePixel)];
    horLine.backgroundColor = UIColorFromHEX(0xcccccc, 1);
    [_alertView addSubview:horLine];
    UILabel * verLine = [[UILabel alloc] initWithFrame:CGRectMake(_alertView.frame.size.width/2. - OnePixel/2., CGRectGetHeight(_alertView.frame) - ButtonHeight - OnePixel, OnePixel, ButtonHeight)];
    verLine.backgroundColor = UIColorFromHEX(0xcccccc, 1);
    [_alertView addSubview:verLine];
    
    
    //输入框背景
    UIView * inputBkView = [[UIView alloc] init];
    inputBkView.layer.borderColor = UIColorFromHEX(0xcccccc, 1).CGColor;
    inputBkView.layer.borderWidth = 1;
    [_alertView addSubview:inputBkView];
    [inputBkView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakself.alertView).offset(15);
        make.right.equalTo(weakself.alertView).offset(-15);
        make.top.equalTo(messageLabel.mas_bottom).offset(20);
        make.height.equalTo(@35);
    }];
    
    //输入框
    _inputTextField = [[UITextField alloc] init];
    [inputBkView addSubview:_inputTextField];
    [_inputTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(inputBkView).offset(5);
        make.right.equalTo(inputBkView);
        make.centerY.equalTo(inputBkView);
    }];
    
    _inputTextField.delegate = self;
    if (self.configurationHandler) {
        self.configurationHandler(self.inputTextField);
    } else {
        _inputTextField.keyboardType = UIKeyboardTypeDefault;
        _inputTextField.returnKeyType = UIReturnKeyDone;
        _inputTextField.font = [UIFont systemFontOfSize:16];
        _inputTextField.placeholder = @"";
        _inputTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    }
    
    [_inputTextField becomeFirstResponder];
    
}

#pragma mark - 移除视图
- (void)removeAlertView
{
    if ([_inputTextField isFirstResponder]) {
        [_inputTextField resignFirstResponder];
    }
    
    kWeakSelf(self);
    [UIView animateWithDuration:0.15 animations:^{
        weakself.alertView.alpha = 0;
        weakself.alertView.transform = CGAffineTransformMakeScale(0.1, 0.1);
    } completion:^(BOOL finished) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
        if (weakself.notifiKeyboardHide) {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
        }
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

#pragma mark - 创建按钮
- (UIButton *)createButtonWithFrame:(CGRect)frame title:(NSString *)title andAction:(SEL)action
{
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeSystem];
    btn.frame = frame;
    [btn setTitle:title forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [_alertView addSubview:btn];
    
    return btn;
}
- (void)confirmAction:(UIButton *)sender
{
    if (self.confirmBlock) {
        self.confirmBlock(_inputTextField.text);
    }
    
    BOOL isRemove = YES;
    if (self.checkHandler) {
        isRemove = self.checkHandler(_inputTextField.text);
    }
    
    if (isRemove) {
        [self removeAlertView];
    }
}
- (void)cancelAction:(UIButton *)sender
{
    if (self.cancelBlock) {
        self.cancelBlock();
    }
    
    [self removeAlertView];
}

#pragma mark - 监听键盘弹起，操作框动画
///键盘弹起，页面动画，监听
- (void)keyboardWillShow:(NSNotification *)notification
{
    // 键盘的frame
    CGRect keyboardRect = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyboardHeight = keyboardRect.size.height;
    
    CGFloat keyboardOriginY = ScreenHeight - keyboardHeight;
    CGFloat operateMaxY = ScreenHeight/2. + _alertView.bounds.size.height/2. + 16;

    kWeakSelf(self);
    if (operateMaxY >= keyboardOriginY) {
        CGFloat centerY = (self.view.bounds.size.height - keyboardHeight) / 2.0;
        CGFloat centerX =  weakself.alertView.center.x;
        CGPoint center = CGPointMake(centerX, centerY);
        POPSpringAnimation *springAnimationCenter = [POPSpringAnimation animationWithPropertyNamed:kPOPViewCenter];
        springAnimationCenter.springSpeed      = 0;
        springAnimationCenter.springBounciness = 0.8;
        springAnimationCenter.dynamicsFriction = 10;
        springAnimationCenter.toValue = [NSValue valueWithCGPoint:center];
        [self.alertView pop_addAnimation:springAnimationCenter forKey:nil];
        
//        [UIView animateWithDuration:0.25 animations:^{
//            CGFloat centerY = (self.view.bounds.size.height - keyboardHeight) / 2.0;
//            CGFloat centerX =  weakself.alertView.center.x;
//            CGPoint center = CGPointMake(centerX, centerY);
//            weakself.alertView.center = center;
//        } completion:^(BOOL finished) {
//            [self shakeToShow:weakself.alertView];
//        }];
        _notifiKeyboardHide = YES;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillHide:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];
    }
    else {
        _notifiKeyboardHide = NO;
    }
}
///键盘收起，页面动画，监听
- (void)keyboardWillHide:(NSNotification *)notification
{
    kWeakSelf(self);
    [UIView animateWithDuration:0.25 animations:^{
        CGRect rect = weakself.alertView.frame;
        rect.origin.y = (ScreenHeight - rect.size.height)/2.;
        weakself.alertView.frame = rect;
    } completion:^(BOOL finished) {
        
    }];
}

#pragma mark - 输入框代理
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

#pragma mark - 颜色转换为图片
- (UIImage *)imageWithColor:(UIColor *)color andSize:(CGSize)aSize
{
    CGRect rect = CGRectMake(0.0f, 0.0f, aSize.width, aSize.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}


#pragma mark - 弹性震颤动画
- (void)shakeToShow:(UIView *)aView
{
    CAKeyframeAnimation * popAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    popAnimation.duration = 0.35;
    popAnimation.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.01f, 0.01f, 1.0f)],
                            [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.05f, 1.05f, 1.0f)],
                            [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9f, 0.9f, 1.0f)],
                            [NSValue valueWithCATransform3D:CATransform3DIdentity]];
    popAnimation.keyTimes = @[@0.0f, @0.5f, @0.75f, @0.8f];
    popAnimation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [aView.layer addAnimation:popAnimation forKey:nil];
}

- (void)willToShow:(UIView *)aView
{
    CAKeyframeAnimation * popAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    popAnimation.duration = 0.2;
    popAnimation.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.01f, 0.01f, 1.0f)],
                            [NSValue valueWithCATransform3D:CATransform3DIdentity]];
    popAnimation.keyTimes = @[@0.0f, @0.5f];
    popAnimation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [aView.layer addAnimation:popAnimation forKey:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    NSLog(@"<HQAlertViewController>------dealloc");
}

@end

//
//  HQAlertViewController.h
//  Hq100yyApp
//
//  Created by lidebo on 2016/10/25.
//  Copyright © 2016年 edu24ol. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^ConfirmBlock)(NSString *inputText);
typedef void(^CancelBlock)();
typedef void (^TextFieldConfigurationHandler)(UITextField *textField);
typedef BOOL (^InputTextCheckHandler)(NSString *inputText);

@interface HQAlertViewController : UIViewController
//创建并初始化弹窗带一个文本框、title、message、取消按钮、确定按钮的弹窗
- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message ConfirmAction:(ConfirmBlock)confirmBlock andCancelAction:(CancelBlock)cancelBlcok;

//配置TextField相关属性
- (void)addTextFieldWithConfigurationHandler:(TextFieldConfigurationHandler)configurationHandler;

//配置TextField文本合法性校验规则，如果合法，点击确定按钮后弹窗会自动消失，反之则不会消失
- (void)addInputTextWithCheckHandler:(InputTextCheckHandler)checkHandler;
@end

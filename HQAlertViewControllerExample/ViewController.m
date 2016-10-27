//
//  ViewController.m
//  HQAlertViewControllerExample
//
//  Created by lidebo on 2016/10/27.
//  Copyright © 2016年 lidebo. All rights reserved.
//

#import "ViewController.h"
#import "HQAlertViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)showAlertView:(UIButton *)sender {
    
    switch (sender.tag) {
        case 0:
        {
            //初始化
            HQAlertViewController * alertVC = [[HQAlertViewController alloc] initWithTitle:@"Title" message:@"message" ConfirmAction:^(NSString *inputText) {
                
                //点击确定按钮
                
            } andCancelAction:^{
                
                //点击取消按钮
                
            }];
            
            //配置文本框
            [alertVC addTextFieldConfigurationHanlder:^(UITextField *textField) {
                textField.keyboardType = UIKeyboardTypeDefault;
                textField.returnKeyType = UIReturnKeyDone;
                textField.font = [UIFont systemFontOfSize:16];
                textField.placeholder = @"例如：王雪";
                textField.clearButtonMode = UITextFieldViewModeWhileEditing;
            }];
            
            //配置文本框文本校验规则并返回校验结果
            [alertVC addInputTextCheckHandler:^BOOL(NSString *inputText) {
                return NO;
            }];
            
            [self presentViewController:alertVC animated:YES completion:nil];
        }
            
            break;
        
        case 1:
            
            break;
            
        case 2:
            
            break;
            
            
        default:
            break;
    }
    
}

@end

//
//  MFFeedbackViewController.m
//  MyAudios
//
//  Created by chang on 2017/11/8.
//  Copyright © 2017年 chang. All rights reserved.
//

#import "MFFeedbackViewController.h"
#import "MFStringUtil.h"
#import "Notify.h"
#import "GHWEmailManager.h"
#import <QiniuSDK.h>
#import "MFQiNiuUtil.h"
#import "SVProgressHUD.h"
#import "Notify.h"

@interface MFFeedbackViewController ()<UITextViewDelegate,UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextView *feedbackTxtView;// 意见反馈文本
@property (weak, nonatomic) IBOutlet UITextField *contactInfoTxtField;// 您的联系方式：手机号或者邮箱
@property (weak, nonatomic) IBOutlet UITextField *yourNameTxtField;// 您的称呼
@property (weak, nonatomic) IBOutlet UIScrollView *myScrollView;

@property(strong,nonatomic) UITextField * currentTxtField;// 当前焦点

@end

@implementation MFFeedbackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 添加单击取消键盘响应事件
    self.view.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleSingleTap:)];
    singleTapGesture.numberOfTapsRequired =1;
    singleTapGesture.numberOfTouchesRequired  =1;
    [self.view addGestureRecognizer:singleTapGesture];

    //  监听键盘的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [self setupSubviewShows];
    
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    // 取消监听通知
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - 设置子视图样式
-(void)setupSubviewShows {
    
    self.title = @"意见反馈";
    
    // 设置 self.myScrollView 样式
    self.myScrollView.frame = self.view.bounds;
    self.myScrollView.contentSize = CGSizeMake(mainScreenWidth, mainScreenHeight-44);
    self.myScrollView.showsHorizontalScrollIndicator = NO;
    self.myScrollView.showsVerticalScrollIndicator = NO;
    self.myScrollView.scrollEnabled = NO;
    
    // 设置 txtView 样式
    self.feedbackTxtView.textColor=[UIColor lightGrayColor];//设置提示内容颜色
    self.feedbackTxtView.text=@"请输入反馈，我们将不断为您改进";//提示语
    self.feedbackTxtView.selectedRange=NSMakeRange(0,0) ;//光标起始位置
    self.feedbackTxtView.delegate=self;// 代理
    
    // 设置发送反馈信息按钮
    UIButton *rightButton = [[UIButton alloc]initWithFrame:CGRectMake(0,0,30,30)];
    [rightButton setTitle:@"提交" forState:UIControlStateNormal];
    [rightButton setTintColor:[UIColor whiteColor]];
    [rightButton.titleLabel setFont:[UIFont systemFontOfSize:16.0]];
    [rightButton addTarget:self action:@selector(sendFeedBackBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem*rightItem = [[UIBarButtonItem alloc]initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem= rightItem;
    
}

#pragma mark - UITextFieldDelegate Methods
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField.tag==0) {
        [self.contactInfoTxtField resignFirstResponder];
        [self.yourNameTxtField becomeFirstResponder];
    }else{
        [self.view endEditing:YES];
    }
    return YES;
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    self.currentTxtField = textField;
    return YES;
}


#pragma mark - UITextViewDelegate Methods
- (void)textViewDidChangeSelection:(UITextView *)textView
{
    // 如果是提示内容，光标放置开始位置
    if (textView.textColor==[UIColor lightGrayColor]
        &&[@"请输入反馈，我们将不断为您改进" isEqualToString:textView.text]){
        NSRange range;
        range.location = 0;
        range.length = 0;
        textView.selectedRange = range;
    }else if(textView.textColor==[UIColor lightGrayColor]) {
        NSString *placeholder = @"请输入反馈，我们将不断为您改进";
        textView.textColor = [UIColor blackColor];
        textView.text = [textView.text substringWithRange:NSMakeRange(0, textView.text.length- placeholder.length)];
    }
    
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString*)text
{
    if (![@"" isEqualToString:text]&&textView.textColor==[UIColor lightGrayColor])//如果不是delete响应,当前是提示信息，修改其属性
    {
        textView.text=@"";//置空
        textView.textColor=[UIColor blackColor];
    }
    
    if ([text isEqualToString:@"\n"])//回车事件
    {
        if ([textView.text isEqualToString:@""])//如果直接回车，显示提示内容
        {
            textView.textColor = [UIColor lightGrayColor];
            textView.text = @"请输入反馈，我们将不断为您改进";
        }
        [textView resignFirstResponder];//隐藏键盘
        return NO;
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""])
    {
        textView.textColor=[UIColor lightGrayColor];
        textView.text = @"请输入反馈，我们将不断为您改进";
    }
}


#pragma mark- 键盘遮挡问题解决
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSLog(@"%@", NSStringFromCGPoint(self.myScrollView.contentOffset));
}

- (void)keyboardWillShow:(NSNotification *)notification {
    
    NSDictionary *info = [notification userInfo];
    CGSize keyboardSize = [info[UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    CGFloat keyboardHeight = keyboardSize.height;
    
    [self reSeatOffset];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:[info[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    [UIView setAnimationCurve:[info[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    CGRect currentTxtFieldRect = self.currentTxtField.frame;
    CGFloat yPosition = currentTxtFieldRect.origin.y + currentTxtFieldRect.size.height;
    CGFloat totalHight = yPosition+keyboardHeight+kNavigationHeight+kToolBarHeight;
    CGFloat offset = 0.0;
    if (totalHight>mainScreenHeight) {
        offset = keyboardHeight-(mainScreenHeight-yPosition-kNavigationHeight)+30;
    }
    
    UIEdgeInsets insets = UIEdgeInsetsMake(self.myScrollView.contentInset.top, 0, offset, 0);
    self.myScrollView.contentInset = insets;
    self.myScrollView.scrollIndicatorInsets = insets;
    self.myScrollView.contentOffset = CGPointMake(self.myScrollView.contentOffset.x, self.myScrollView.contentOffset.y + offset);
    
    [UIView commitAnimations];
    
}

- (void)keyboardWillHide:(NSNotification *)notification {
    
    NSDictionary *info = [notification userInfo];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:[info[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    [UIView setAnimationCurve:[info[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    [self reSeatOffset];
    
    [UIView commitAnimations];
    
}

#pragma mark - 复原 myScrollView.contentOffset
-(void)reSeatOffset {
    UIEdgeInsets insets = UIEdgeInsetsMake(self.myScrollView.contentInset.top, 0, 0, 0);
    self.myScrollView.contentInset = insets;
    self.myScrollView.scrollIndicatorInsets = insets;
    self.myScrollView.contentOffset = CGPointMake(self.myScrollView.contentOffset.x,-kNavigationHeight);
}


#pragma mark - 自定义方法
-(void)sendFeedBackBtnClicked:(id)sender {
    
    [self.view endEditing:YES];
    NSString * feedbackStr = self.feedbackTxtView.text;
    NSString * contactStr = self.contactInfoTxtField.text;
    NSString * nameStr = self.yourNameTxtField.text;
    
    if ([MFStringUtil isEmpty:feedbackStr]||[@"请输入反馈，我们将不断为您改进" isEqualToString:feedbackStr]) {
        [Notify showAlertDialog:nil messageString:@"请输入反馈信息..."];
        return;
    }
    
    NSString *feedbackInfo = [NSString stringWithFormat:@"\n\n\n=============反馈内容：=============\n%@\n联系方式:\n%@\n联系人:\n%@\n" ,feedbackStr,contactStr,nameStr];
    // [[GHWEmailManager shareInstance] sendEmail:feedbackInfo];
    
    NSString *token = [MFQiNiuUtil makeToken:kQiNiuAccessKey secretKey:kQiNiuSecretKey];
    QNUploadManager *upManager = [[QNUploadManager alloc] init];
    NSData *data = [feedbackInfo dataUsingEncoding : NSUTF8StringEncoding];
    
    [self setStarted];
    [upManager putData:data key:[NSString stringWithFormat:@"%@.txt",feedbackStr] token:token
              complete: ^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
                  NSLog(@"%@", info);
                  NSLog(@"%@", resp);
                  [self setFinished];
                  
                  self.feedbackTxtView.text = @"";
                  self.contactInfoTxtField.text = @"";
                  self.yourNameTxtField.text = @"";
                  
                  [Notify showAlert:nil titleString:@"提示" messageString:@"您的反馈已经收到，我们会认真考虑，谢谢来信..." actionStr:@"确定"];
                  
              } option:nil];
    
}



#pragma mark- 单击事件
-(void)handleSingleTap:(UIGestureRecognizer *)sender{
    [self.view endEditing:YES];
}

#pragma mark - 开始loading
- (void)setStarted {
    [SVProgressHUD showWithStatus:@"正在提交..."];
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleLight];
}

#pragma mark - 结束loading
- (void)setFinished {
    [SVProgressHUD dismiss];
}


@end

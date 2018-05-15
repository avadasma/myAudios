//
//  MFSettingViewController.m
//  MyAdios
//
//  Created by chang on 2017/7/15.
//  Copyright © 2017年 chang. All rights reserved.
//

#import "MFSettingViewController.h"
#import "MFDownloadedViewController.h"
#import "MFAboutViewController.h"
#import "COShareView.h"
#import "Notify.h"
#import "MFWiFiShareViewController.h"
#import "MFFeedbackViewController.h"
#import "MFiTunesShareViewController.h"

#define ROWHEIGHT 56.0
#define HEADERHEIGHT 20.0
#define NUMBEROFSECTION 4



@interface MFSettingViewController ()<MFMailComposeViewControllerDelegate,UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (nonatomic,strong)NSMutableArray *dataArray;// 数据库

@end

@implementation MFSettingViewController

#pragma mark - UIView LifeCycle Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置数据源
    [self initDataArray];
    self.navigationItem.title = @"设置";
    // 删除多余的分割线
    [self.myTableView setTableFooterView:[[UIView alloc]initWithFrame:CGRectZero]];
    self.myTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.myTableView.backgroundColor = COLOR(239.0, 239.0, 244.0, 1.0);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if (section==3 && row==0) {
        if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
            [cell setLayoutMargins:UIEdgeInsetsZero];
        }
        if ([cell respondsToSelector:@selector(setSeparatorInset:)]){
            [cell setSeparatorInset:UIEdgeInsetsZero];
        }
    }
}

#pragma mark - UITableView DataSource

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *MyIdentifier = @"MyIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:MyIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor whiteColor];
    }
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    if (section==0 || section==1) {
        NSMutableArray * arr = [[self dataArray] objectAtIndex:section];
        if (row < arr.count) {
            cell.textLabel.text = [arr objectAtIndex:row];
        }
    }else{
        
        NSString * name = [[self dataArray] objectAtIndex:section];
        cell.textLabel.text = name;
        
        /*
        if ([@"通过 WiFi 分享" isEqualToString:name]) {
            cell.accessoryType = UITableViewCellAccessoryNone;
            
            UISwitch * shareSwitch = [cell viewWithTag:999];
            if (!shareSwitch) {
                shareSwitch = [[UISwitch alloc] init];
                shareSwitch.tag = 999;
                shareSwitch.frame = CGRectMake(mainScreenWidth-66, 12.5, 51, 31);
                [cell addSubview:shareSwitch];
                
                [shareSwitch addTarget:self action:@selector(shareSwitchValueChang:) forControlEvents:UIControlEventValueChanged];
            }
            
        }*/
        
    }
    return cell;
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return NUMBEROFSECTION;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSInteger count = 1;
    if (section==0) {
        count = 2;
    }
    if (section==1) {
        NSArray * dataArr = [self.dataArray objectAtIndex:1];
        count = [dataArr count];
    }
    return count;
}

#pragma  mark tableView delegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return ROWHEIGHT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
 
    return HEADERHEIGHT;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger section = indexPath.section;
    NSInteger row  = indexPath.row;
    
   
    if(section==0){
        if (row==0) {
            if (self.navigationController.topViewController == self) {
                MFWiFiShareViewController *wifiVC = [[MFWiFiShareViewController alloc] init];
                [self.navigationController pushViewController:wifiVC animated:YES];
            }
        }else if (row==1){
            if (self.navigationController.topViewController == self) {
                MFiTunesShareViewController *iTunesShareVC = [[MFiTunesShareViewController alloc] init];
                [self.navigationController pushViewController:iTunesShareVC animated:YES];
            }
        }
        
    }else if (section==1) {
        if (row==0) {
            NSString *content = @"请输入您的意见，我们会认真考虑：";
            [self shareAppleMail:content];
        }else if (row==1){// 分享给好友
            [self share];
        }else if (row==2){// 给软件打分
            [self jumpTo:[NSString stringWithFormat:@"%@",setting_IOS7_Up_Grade]];
        }
    }else if (section==2 && row==0) {
        if (self.navigationController.topViewController == self) {
            MFDownloadedViewController *listPlayerVC = [[MFDownloadedViewController alloc] init];
            listPlayerVC.isPlayList = YES;
            [self.navigationController pushViewController:listPlayerVC animated:YES];
        }
    }else if (section==3 && row==0){
    
        MFAboutViewController *aboutMeVC = [[MFAboutViewController alloc] init];
        [self.navigationController pushViewController:aboutMeVC animated:YES];
    }
    
    
}

#pragma mark - 前往 AppStore 去评分
-(void)jumpTo:(NSString *)urlString{
    if (urlString.length > 0) {
        NSURL *url = [NSURL URLWithString:urlString];
        if (url) {
            if (IS_IOS10) {
                [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
                    NSLog(@"open url with success");
                }];
            }else {
                [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
                }];
                
            }
        }
    }
}


#pragma mark - Custom Methods
// 设置数据
-(void)initDataArray {
    
    if (!self.dataArray) {
        self.dataArray = [[NSMutableArray alloc] init];
    }

    // section 0
    NSArray * section0 = [NSMutableArray arrayWithObjects:@"通过 WiFi 传输文件",@"通过 iTunes 传输文件",nil];
    [self.dataArray addObject:section0];
    
    // section 1
    NSArray * array = [NSMutableArray arrayWithObjects:@"帮助与反馈",@"分享给好友",@"给软件打分",nil];
    [self.dataArray addObject:array];
  
    // section 2
    [self.dataArray addObject:@"播放列表"];
    
    // section 3
    [self.dataArray addObject:@"关于我们"];
    
}

#pragma mark - wifi 共享 开关
-(void)shareSwitchValueChang:(id)sender {

    UISwitch * shareSwitch = (UISwitch *)sender;
    UITableViewCell *cell = (UITableViewCell *)[shareSwitch superview];
    if (shareSwitch.isOn) {
#warning 待完善
        cell.detailTextLabel.text = @"http://192.168.23.13";
    }else{
        cell.detailTextLabel.text = @"";
    }
    
}

#pragma mark - 分享沐风影音
-(void)share{
    NSString * shareContent = NSLocalizedStringWithInternational(@"SettingViewController_00001", @"我刚刚在使用沐风影音，感觉非常好用，赶紧去下载一个吧！客户端下载地址：%@");
    
    NSString * appShareUrl = [[NSUserDefaults standardUserDefaults] objectForKey:kAppShareUrl];
    NSString *shareStr;
    if (appShareUrl.length>0) {
        shareStr = [[NSString alloc]initWithFormat:shareContent,appShareUrl];
    }else{
        shareStr = [[NSString alloc]initWithFormat:shareContent,setting_IOS7_Up_Grade];
    }
    [COShareView showShareViewContent:shareStr];

}

#pragma mark - 帮助与反馈
- (void)shareAppleMail:(NSString*)content{
    
    
    MFFeedbackViewController *feedbackVC = [[MFFeedbackViewController alloc] init];
    [self.navigationController pushViewController:feedbackVC animated:YES];
    
//    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
//    if (mailClass != nil) {
//        if ([mailClass canSendMail]) {
//            [self displayMailComposerSheet:content];
//        } else {
//            [Notify showAlertDialog:self messageString:NSLocalizedStringWithInternational(@"MFAboutViewController_01012",@"设备不支持邮件功能或者邮件未配置")];
//        }
//    }
}

- (void)displayMailComposerSheet:(NSString*)content{
    
    MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
    controller.mailComposeDelegate = self;
    NSString *bodyMess=content;
    [controller setSubject:@""];
    [controller setToRecipients:[NSArray arrayWithObject:@"changyou_dev@163.com"]];
    [controller setSubject:@"意见反馈"];
    [controller setMessageBody:bodyMess isHTML:NO];

    [self presentViewController:controller animated:YES completion:^{}];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(nullable NSError *)error{

    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

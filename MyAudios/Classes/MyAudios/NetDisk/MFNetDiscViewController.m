//
//  MFNetDiscViewController.m
//  MyAdios
//
//  Created by chang on 2017/7/15.
//  Copyright © 2017年 chang. All rights reserved.
//

#import "MFNetDiscViewController.h"
#import "PhotoViewController.h"
#import "MFNetDiscObject.h"
#import "MFNetDiscTableViewCell.h"
#import <ObjectiveDropboxOfficial/ObjectiveDropboxOfficial.h>
#import "MFDropBoxViewController.h"
#import "MFGoogleDriveViewController.h"
#import "MFBoxViewController.h"
#import "BOXSampleFolderViewController.h"
#import "MFOneDriveViewController.h"
#import <OneDriveSDK/OneDriveSDK.h>

@import BoxContentSDK;

#define CellHeight 56.0


@interface MFNetDiscViewController ()<UITableViewDelegate,UITableViewDataSource>

@property(weak, nonatomic) IBOutlet UIButton *linkDropboxButton;
@property(weak, nonatomic) IBOutlet UIButton *unlinkDropboxButton;
@property(nonatomic) UIBarButtonItem *oldButton;

@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property(nonatomic,strong) NSMutableArray * dataArray;

@end

@implementation MFNetDiscViewController

#pragma mark - UIView LifeCycle Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"云服务";
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor]}];
 
    // 删除多余的分割线
    [self.myTableView setTableFooterView:[[UIView alloc]initWithFrame:CGRectZero]];
}

-(void)viewWillAppear:(BOOL)animated{

    [super viewWillAppear:animated];
    
    // 判断 dropbox 是否已登录
    [self checkIsLogin];
    // 判断 googleDrive 是否已登录
    // [self checkGoogleDriveIsLogin];
    // 判断 box 是否已登录
    [self checkBoxIsLogin];
    // 判断 oneDrive 是否已登录
    [self checkOneDriveIsLogin];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidLoad];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableView DataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  self.dataArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
 
    static NSString *simpleTableIdentifier = @"MFNetDiscTableViewCell";
    MFNetDiscTableViewCell *cell = (MFNetDiscTableViewCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"MFNetDiscTableViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    NSInteger row = indexPath.row;
    MFNetDiscObject * netDisc = [self.dataArray objectAtIndex:row];
    [cell setupCell:netDisc];
    
    
    return cell;
}
#pragma  mark tableView delegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return CellHeight;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger row = indexPath.row;
    
    if (row==0) {
        MFDropBoxViewController *dropboxVC = [[MFDropBoxViewController alloc] init];
        dropboxVC.searchPath = @"";
        dropboxVC.title = @"DropBox";
        [self.navigationController pushViewController:dropboxVC animated:YES];
        
    }
    /*
    else if (row==1){
        MFGoogleDriveViewController * googleDriveVC = [[MFGoogleDriveViewController alloc] init];
        [self.navigationController pushViewController:googleDriveVC animated:YES];
    }*/
    
    else if (row==1){
        
        BOXUserMini * loginedUser = [[BOXContentClient defaultClient] user];
        if (loginedUser) {// 已经登录，直接跳转
            [[BOXContentClient defaultClient] authenticateWithCompletionBlock:^(BOXUser *user, NSError *error) {
                if (error == nil) {
                    
                    BOXContentClient *client = [BOXContentClient clientForUser:user];
                    BOXSampleFolderViewController *folderListingController = [[BOXSampleFolderViewController alloc] initWithClient:client folderID:BOXAPIFolderIDRoot];
                    [self.navigationController pushViewController:folderListingController animated:YES];
                    
                }
            }];
        }else{
            MFBoxViewController * boxViewController = [[MFBoxViewController alloc] init];
            [self.navigationController pushViewController:boxViewController animated:YES];
        }
    }else if (row==2){// OneDrive
        MFOneDriveViewController *oneDriveVC = [[MFOneDriveViewController alloc] init];
         [self.navigationController pushViewController:oneDriveVC animated:YES];
    }else{
        
    }
}



#pragma mark- 懒加载数据数组
-(NSMutableArray *)dataArray{
    if (!_dataArray) {
        NSMutableArray * dataArr = [self setupDataArray];
        _dataArray = [NSMutableArray arrayWithArray:dataArr];
    }
    return _dataArray;
}

#pragma mark - 初始化数据源
-(NSMutableArray *)setupDataArray {

    MFNetDiscObject * dropBox = [[MFNetDiscObject alloc] init];
    dropBox.netDiscName = @"DropBox";
    dropBox.iconName = @"dropbox-CellIcon";
    dropBox.isLogined = NO;
    
    /*
    MFNetDiscObject * iCloudDrive = [[MFNetDiscObject alloc] init];
    iCloudDrive.netDiscName = @"iCloud Drive";
    iCloudDrive.iconName = @"iCloud-CellIcon";
    iCloudDrive.isLogined = NO;
    
    MFNetDiscObject * googleDirve = [[MFNetDiscObject alloc] init];
    googleDirve.netDiscName = @"Google Dirve";
    googleDirve.iconName = @"googledrive-CellIcon";
    googleDirve.isLogined = NO;*/
    
    MFNetDiscObject * box = [[MFNetDiscObject alloc] init];
    box.netDiscName = @"Box";
    box.iconName = @"box--CellIcon";
    box.isLogined = NO;
    
    MFNetDiscObject * oneDrive = [[MFNetDiscObject alloc] init];
    oneDrive.netDiscName = @"OneDrive";
    oneDrive.iconName = @"onedrive-CellIcon";
    oneDrive.isLogined = NO;
    
    
    NSMutableArray * dataArr = [NSMutableArray arrayWithObjects:dropBox,box,oneDrive,nil];
    
    return dataArr;
}

#pragma mark - 判断是否已登录
- (void)checkIsLogin {
    
    MFNetDiscObject * dropBox = [self.dataArray objectAtIndex:0];
    if ([DBClientsManager authorizedClient] || [DBClientsManager authorizedTeamClient]) {
        dropBox.isLogined = YES;
    }else{
        dropBox.isLogined = NO;
    }
    
    [self.myTableView reloadData];
}

//#pragma mark - 判断 GoogleDrive 是否已登录
//- (void)checkGoogleDriveIsLogin {
//
//    MFNetDiscObject * dropBox = [self.dataArray objectAtIndex:1];
//    GIDGoogleUser *user = [[GIDSignIn sharedInstance] currentUser];
//    if (user!=nil) {
//        dropBox.isLogined = YES;
//    }else{
//        dropBox.isLogined = NO;
//    }
//
//    [self.myTableView reloadData];
//}

// 退出 GoogleDrive 登录
- (IBAction)didTapSignOut:(id)sender {
   [[GIDSignIn sharedInstance] signOut];
}

#pragma mark - 判断box是否已经登录
- (void)checkBoxIsLogin {
    
    MFNetDiscObject * box = [self.dataArray objectAtIndex:1];
    BOXUserMini * loginedUser = [[BOXContentClient defaultClient] user];
    if (loginedUser) {
        box.isLogined = YES;
    }else{
        box.isLogined = NO;
    }
    [self.myTableView reloadData];
}

#pragma mark - 判断oneDrive是否已经登录
- (void)checkOneDriveIsLogin {

    MFNetDiscObject * box = [self.dataArray objectAtIndex:2];

    ODClient *client = [ODClient loadCurrentClient];
    if (client) {
        box.isLogined = YES;
    }else{
        box.isLogined = NO;
    }
    [self.myTableView reloadData];
}


@end

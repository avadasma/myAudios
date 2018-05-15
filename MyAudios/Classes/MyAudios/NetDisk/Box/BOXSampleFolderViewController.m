//
//  FolderListingViewController.m
//  BoxContentSDKSampleApp
//
//  Created on 1/6/15.
//  Copyright (c) 2015 Box. All rights reserved.
//

#import "BOXSampleFolderViewController.h"
#import "BOXSampleItemCell.h"
#import <Photos/Photos.h>
#import "MFStringUtil.h"
#import "Notify.h"
#import "BOXSampleAppSessionManager.h"
#import "SVProgressHUD.h"

#define TABLEVIEWCELLHEIGHT 56 // cell行高

@interface BOXSampleFolderViewController () <UIAlertViewDelegate,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, readwrite, strong) NSArray *items;
@property (nonatomic, readwrite, strong) NSString *folderID;
@property (nonatomic, readwrite, strong) BOXFolder *folder;
@property (nonatomic, readwrite, strong) BOXContentClient *client;
@property (nonatomic, readwrite, strong) BOXRequest *request;
@property (nonatomic, readwrite, strong) BOXRequest *nonBackgroundUploadRequest;

@property (nonatomic, strong) UITableView * tableView;// chang
@property (nonatomic) BOOL isFirstComing;// 第一次进入本页面
@end

@implementation BOXSampleFolderViewController

- (instancetype)initWithClient:(BOXContentClient *)client folderID:(NSString *)folderID
{
    if (self = [super init]) {
        _client = client;
        _folderID = folderID;
    }
    return self;
}

#pragma mark - 初始化tableView
-(void)customTableView {
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.refreshControl = [[UIRefreshControl alloc] init];
    [self.tableView.refreshControl addTarget:self action:@selector(retrieveItems) forControlEvents:UIControlEventValueChanged];
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.isFirstComing = YES;
    
    // 设置 tableView
    [self customTableView];
    
    // Get the current folder's informations
    BOXFolderRequest *folderRequest = [self.client folderInfoRequestWithID:self.folderID];
    [folderRequest performRequestWithCompletion:^(BOXFolder *folder, NSError *error) {
        self.folder = folder;
        self.cutomTitleLbl.text = folder.name;
    }];
    
    // 加载数据
    [self retrieveItems];
    
    // 退出Box登录 按钮
    [self creatLogoutBtn];
    
}

#pragma mark - 添加退出box 按钮
-(void)creatLogoutBtn {
    
    UIBarButtonItem * logoutButton = nil ;
    UIButton * rightButton = [[UIButton alloc] init];
    rightButton.frame=CGRectMake(0, 0, 52, 20);
    [rightButton setTitle:@"退出登录" forState:UIControlStateNormal];
    [[rightButton titleLabel] setFont:[UIFont systemFontOfSize:16.0]];
    [rightButton setBackgroundColor:[UIColor clearColor]];
    [rightButton addTarget:self action:@selector(logoutButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    rightButton.exclusiveTouch=YES;
    logoutButton = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    [self.navigationItem setRightBarButtonItem:logoutButton];
}
#pragma mark - 退出Box登录事件
-(void)logoutButtonClicked:(id)sender {
    
    [[BOXContentClient defaultClient] logOut];
    [self.navigationController popToRootViewControllerAnimated:YES];
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    // 设置title
    self.cutomTitleLbl.text = self.folder.name;
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.request cancel];
    self.request = nil;
    [self.nonBackgroundUploadRequest cancel];
    self.nonBackgroundUploadRequest = nil;
}

- (void)retrieveItems
{
    // 开始 loading
    [self startLoading];
    
    // 第一次进来不刷新页面
    if (self.isFirstComing == YES) {
        self.isFirstComing = NO;
    }else{
        [self.tableView.refreshControl beginRefreshing];
    }
    // Retrieve all items from the folder.
    BOXFolderItemsRequest *itemsRequest = [self.client folderItemsRequestWithID:self.folderID];
    itemsRequest.requestAllItemFields = YES;
    [itemsRequest performRequestWithCompletion:^(NSArray *items, NSError *error) {
        // 结束 loading
        [self endLoading];
        
        if (error == nil) {
            self.items = items;
            [self.tableView reloadData];
        } else {
            if ([self.navigationController.topViewController isKindOfClass:[self class]]) {
                // NSString *errorMsg = [NSString stringWithFormat:@"Failed to retrieve items %@", error];// 官方demo提示
                NSString *errorMsg = [NSString stringWithFormat:@"获取信息失败，请重试..."];
                [Notify showAlert:self titleString:@"" messageString:errorMsg actionStr:@"取消"];
            }
        }
        [self.tableView.refreshControl endRefreshing];
    }];
    
    self.request = itemsRequest;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static NSString *UserTableViewCellIdentifier = @"UserTableViewCellIdentifier";
    BOXSampleItemCell *cell = [tableView dequeueReusableCellWithIdentifier:UserTableViewCellIdentifier];
    
    if (cell == nil) {
        cell = [[BOXSampleItemCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:UserTableViewCellIdentifier];
        cell.client = self.client;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    BOXItem *item = self.items[indexPath.row];
    cell.item = item;
    
    __weak BOXSampleItemCell *wCell = cell;
    __weak BOXSampleFolderViewController *weakSelf = self;
    cell.downloadBtnClickedBlock = ^{
        // 在block的执行过程中,使用强对象对弱对象进行引用
        // BOXSampleItemCell *sCell = wCell;
        // [weakSelf downloadCurrentCellItem:cell];
        [weakSelf downloadCellItem:wCell completion:^(NSError *error) {
            
        }];
    };
    
    
    if ([item isKindOfClass:[BOXFolder class]]) {// 文件夹
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }else{// 文件item
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

#pragma mark - UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    BOXItem *entry = [self.items objectAtIndex:indexPath.row];
    NSString * name = entry.name;
    CGFloat cellHeight = [MFStringUtil heightForString:name andWidth:mainScreenWidth-106.0];
    return cellHeight;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOXItem *item = self.items[indexPath.row];
    UIViewController *controller = nil;
    
    if ([item isKindOfClass:[BOXFolder class]]) {
        controller = [[BOXSampleFolderViewController alloc] initWithClient:self.client folderID:((BOXFolder *)item).modelID];
    } else {
    }
    [self.navigationController pushViewController:controller animated:YES];
}

//- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return YES;
//}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath 
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        BOXItem *item = self.items[indexPath.row];
        NSString *message = [NSString stringWithFormat:@"This will delete \n%@\nAre you sure you wish to continue ?", item.name];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
                                                                                 message:message
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"Delete"
                                                               style:UIAlertActionStyleDestructive
                                                             handler:^(UIAlertAction * _Nonnull action) {
                                                                 BOXItem *item = self.items[indexPath.row];

                                                                 BOXErrorBlock errorBlock = ^void(NSError *error) {
                                                                     if (error) {
                                                                         [self dismissViewControllerAnimated:YES
                                                                                                  completion:^{
                                                                                                      UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
                                                                                                                                                                               message:@"Could not delete this item."
                                                                                                                                                                        preferredStyle:UIAlertControllerStyleAlert];
                                                                                                      UIAlertAction *OKAction = [UIAlertAction actionWithTitle:@"OK"
                                                                                                                                                         style:UIAlertActionStyleDefault
                                                                                                                                                       handler:^(UIAlertAction * _Nonnull action) {
                                                                                                                                                           [self dismissViewControllerAnimated:YES
                                                                                                                                                                                    completion:nil];
                                                                                                                                                       }];
                                                                                                      [alertController addAction:OKAction];
                                                                                                      [self presentViewController:alertController
                                                                                                                         animated:YES
                                                                                                                       completion:nil];
                                                                                                  }];
                                                                     } else {
                                                                         NSMutableArray *array = [NSMutableArray arrayWithArray:self.items];
                                                                         [array removeObject:item];
                                                                         self.items = [array copy];
                                                                         [self.tableView reloadData];
                                                                         [self dismissViewControllerAnimated:YES
                                                                                                  completion:nil];
                                                                     }
                                                                 };
                                                                 
                                                                 if ([item isKindOfClass:[BOXFolder class]]) {
                                                                     BOXFolderDeleteRequest *request = [self.client folderDeleteRequestWithID:item.modelID];
                                                                     [request performRequestWithCompletion:^(NSError *error) {
                                                                         errorBlock (error);
                                                                     }];
                                                                 } else if ([item isKindOfClass:[BOXFile class]]) {
                                                                     BOXFileDeleteRequest *request = [self.client fileDeleteRequestWithID:item.modelID];
                                                                     [request performRequestWithCompletion:^(NSError *error) {
                                                                         errorBlock (error);
                                                                     }];
                                                                 } else if ([item isKindOfClass:[BOXBookmark class]]) {
                                                                     BOXBookmarkDeleteRequest *request = [self.client bookmarkDeleteRequestWithID:item.modelID];
                                                                     [request performRequestWithCompletion:^(NSError *error) {
                                                                         errorBlock (error);
                                                                     }];
                                                                 } else {
                                                                     [self dismissViewControllerAnimated:YES
                                                                                              completion:nil];
                                                                 }
                                                             }];
        [alertController addAction:deleteAction];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                             [self dismissViewControllerAnimated:YES
                                                                                      completion:nil];
                                                         }];
        [alertController addAction:cancelAction];
        [self presentViewController:alertController
                           animated:YES
                         completion:nil];
    }
}


#pragma mark - Private Helpers

- (void)updateDataSourceWithNewFile:(BOXFile *)file atIndex:(NSInteger)index
{    
    NSMutableArray *newItems = [NSMutableArray arrayWithArray:self.items];
    if (index == NSNotFound) {
        [newItems addObject:file];
    } else {
        [newItems replaceObjectAtIndex:index withObject:file];
    }
    self.items = newItems;
}

#pragma mark - 开始loading
- (void)startLoading {
    [SVProgressHUD showWithStatus:@"加载中..."];
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleLight];
}
#pragma mark - 结束loading
- (void)endLoading {
    [SVProgressHUD dismiss];
}

#pragma mark - Private Helpers
#pragma mark - 下载事件
-(void)downloadCellItem:(BOXSampleItemCell *)cell completion:(BOXErrorBlock)completionBlock{
    
    BOXContentClient *contentClient = [BOXContentClient defaultClient];
    NSString* ceches = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString* localFilePath = [ceches stringByAppendingPathComponent:((BOXFile *)cell.item).name];
    BOXFileDownloadRequest *boxRequest = [contentClient fileDownloadRequestWithID:cell.item.modelID toLocalFilePath:localFilePath];
    [boxRequest performRequestWithProgress:^(long long totalBytesTransferred, long long totalBytesExpectedToTransfer) {
        cell.downloadBtn.hidden = YES;
        float progress = (float)totalBytesTransferred / (float)totalBytesExpectedToTransfer;
        [cell setProgress:progress];
    } completion:^(NSError *error) {
        NSString *message = [NSString stringWithFormat:@"Your file %@ in the documents directory.", error == nil ? @"was downloaded" : @"failed to download"];
        if (error) {
            cell.downloadBtn.hidden = NO;
            // 弹框提示
            [Notify showAlert:self titleString:nil messageString:message actionStr:@"确定"];
        }else{
            // 延迟 1s 执行加载完全
            dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC));
            dispatch_after(delayTime, dispatch_get_main_queue(), ^{
                [cell setProgress:1.0];
                // 下载完，更新 cell 显示状态
                NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
                [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationFade];
            });
        }
        if (completionBlock != nil) {
            completionBlock(error);
        }
    }];
}

#pragma mark - 以下为 demo 中方法，测试未通过
- (void)downloadCurrentCellItem:(BOXSampleItemCell *)cell
{
    NSString *associateId = [BOXSampleAppSessionManager generateRandomStringWithLength:32];
    [self downloadCurrentItemWithAssociateId:associateId andCell:cell completion:nil];
}

- (BOXFileDownloadRequest *)downloadCurrentItemWithAssociateId:(NSString *)associateId andCell:(BOXSampleItemCell *)cell completion:(BOXErrorBlock)completionBlock
{
    // Setup our download path (the download can alternatively be done via a NSOutputStream using fileDownloadRequestWithFileID:toOutputStream:
    // 文件路径
    NSString* ceches = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString* finalPath = [ceches stringByAppendingPathComponent:((BOXFile *)cell.item).name];
    
    
    // save information about this background download to allow reconnection to it upon app restarts
    NSString *userId = self.client.user.modelID;
    BOXSampleAppSessionManager *appSessionManager = [BOXSampleAppSessionManager defaultManager];
    BOXSampleAppSessionInfo *info = [BOXSampleAppSessionInfo new];
    info.fileID = cell.item.modelID;//self.itemID;
    info.folderID = self.folderID;
    info.destinationPath = finalPath;
    [appSessionManager saveUserId:userId associateId:associateId withInfo:info];
    
    // Setup some UI to track our download progress
    BOXFileDownloadRequest *request = [self.client fileDownloadRequestWithID:cell.item.modelID
                                                             toLocalFilePath:finalPath
                                                                 associateId:associateId];
    [self performRequest:request associateId:associateId andCell:cell completion:completionBlock];
    return request;
}

- (void)performRequest:(BOXFileDownloadRequest *)request associateId:(NSString *)associateId andCell:(BOXSampleItemCell *)cell completion:(BOXErrorBlock)completionBlock
{
    NSString *userId = self.client.user.modelID;
    
    [request performRequestWithProgress:^(long long totalBytesTransferred, long long totalBytesExpectedToTransfer) {
        float progress = (float)totalBytesTransferred / (float)totalBytesExpectedToTransfer;
        [cell setProgress:progress];
    } completion:^(NSError *error) {
        [[BOXSampleAppSessionManager defaultManager] removeUserId:userId associateId:associateId];
        self.tableView.tableHeaderView = nil;
        NSString *message = [NSString stringWithFormat:@"Your file %@ in the documents directory.", error == nil ? @"was downloaded" : @"failed to download"];
        // 弹框提示
        [Notify showAlert:self titleString:nil messageString:message actionStr:@"确定"];
        if (completionBlock != nil) {
            completionBlock(error);
        }
    }];
}

@end

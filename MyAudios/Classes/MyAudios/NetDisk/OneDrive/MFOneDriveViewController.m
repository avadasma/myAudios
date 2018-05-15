//
//  MFOneDriveViewController.m
//  MyAudios
//
//  Created by chang on 2017/12/11.
//  Copyright © 2017年 chang. All rights reserved.
//

#import "MFOneDriveViewController.h"
#import "AuthenticationManager.h"
#import <OneDriveSDK/OneDriveSDK.h>
#import "ODXProgressViewController.h"
#import "MFOneDriveTableViewCell.h"
#import "MFStringUtil.h"
#import "SVProgressHUD.h"

typedef void (^MFOneDriveErrorBlock)(NSError *error);

@interface MFOneDriveViewController ()<NSURLSessionDelegate>

@property(nonatomic,strong) NSArray * kScopes;
@property(nonatomic,strong) MSALPublicClientApplication *applicationContext;
@property(nonatomic,strong) NSString * accessToken;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (weak, nonatomic) NSArray *scopes;
@property (nonatomic, strong) MSALPublicClientApplication *msalClient;
@property (nonatomic, strong) MSALUser *user;
@property (nonatomic, strong) ODClient *odClient;

// 以下来自官方demo chang
@property NSMutableDictionary *items;
@property NSMutableArray *itemsLookup;
@property (strong, nonatomic) ODClient *client;
@property ODItem *currentItem;

@property NSMutableDictionary *thumbnails;
@property BOOL selection;
//@property NSMutableArray *selectedItems;
@property UIRefreshControl *refreshControl;
@property UIBarButtonItem *actions;
@property ODXProgressViewController *progressController;

@property UIBarButtonItem *signOut;

@end

@implementation MFOneDriveViewController
@synthesize odClient;


#pragma mark - UIView LifeCycle Methods
- (void)viewDidLoad {
    
    [super viewDidLoad];
    // 初始化 OneDrive 配置所需 scopes
//    self.kScopes = [NSArray arrayWithObject:@"https://graph.microsoft.com/user.read"];

    self.items = [NSMutableDictionary dictionary];
    self.itemsLookup = [NSMutableArray array];
    self.thumbnails = [NSMutableDictionary dictionary];
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.progressController = [[ODXProgressViewController alloc] initWithParentViewController:self];
    
    [self.myTableView addSubview:self.refreshControl];
    [self.refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    self.myTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    // 退出登录按钮
    self.signOut = [[UIBarButtonItem alloc] initWithTitle:@"退出登录" style:UIBarButtonItemStylePlain target:self action:@selector(signOutAction:)];
    self.signOut.tintColor = [UIColor whiteColor];
    
    if (!self.client){
        self.client = [ODClient loadCurrentClient];
    }
    if (!self.currentItem){
        self.title = @"OneDrive";
    }
    
    if (self.client){
        self.connectButton.hidden = YES;
        [self loadChildren];
    }else{
        self.connectButton.hidden = NO;
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if (!self.accessToken) {
        // signoutButton.isEnabled = false;
    }
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    // 隐藏旋转框
    [self setFinished];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Delegate Methods
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
    static NSString *UserTableViewCellIdentifier = @"MFOneDriveTableViewCell";
    MFOneDriveTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:UserTableViewCellIdentifier];
    
    if (cell == nil) {
        cell = [[MFOneDriveTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:UserTableViewCellIdentifier];
        cell.client = self.client;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
   
    ODItem *item = [self itemForIndex:indexPath];
    cell.item = item;
    [cell.downloadBtn addTarget:self action:@selector(downLoadData:) forControlEvents:UIControlEventTouchUpInside];
    if ([@"本机照片" isEqualToString:self.title]) {
        cell.downloadBtn.hidden = YES;
    }

    return cell;
}

// 下载事件
- (void)downLoadData:(id)sender {
    
    UIButton * downloadBtn = (UIButton *)sender;
    MFOneDriveTableViewCell *cell = (MFOneDriveTableViewCell *)downloadBtn.superview;
    downloadBtn.hidden = YES;
    [cell setProgress:0.05];// 开始时先有个默认显示
    ODURLSessionDownloadTask *task = [[[[self.client drive] items:cell.item.id] contentRequest] downloadWithCompletion:^(NSURL *filePath, NSURLResponse *response, NSError *error){
        
        if (!error) {
            if ([cell.item.file.mimeType isEqualToString:@"audio/mpeg"]) {// 音频
                NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
                NSString *newFilePath = [documentPath stringByAppendingPathComponent:cell.item.name];
                [[NSFileManager defaultManager] moveItemAtURL:filePath toURL:[NSURL fileURLWithPath:newFilePath] error:nil];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                NSIndexPath *indexPath = [self.myTableView indexPathForCell:cell];
                [self.myTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]  withRowAnimation:UITableViewRowAnimationNone];
            });
            
        }else{
            downloadBtn.hidden = NO;
            [self showErrorAlert:error];
            // [self.selectedItems removeObject:cell.item];
        }
    }];
    task.progress.totalUnitCount = cell.item.size;
    
    cell.task = task;
    
  
}

#pragma mark - UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    ODItem *entry = [self itemForIndex:indexPath];
    NSString * name = entry.name;
    CGFloat cellHeight = [MFStringUtil heightForString:name andWidth:mainScreenWidth-106.0];
    return cellHeight;
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    ODItem *item = [self itemForIndex:indexPath];
    MFOneDriveViewController *controller = nil;
    
    if (item.folder!=nil) {
        controller = [[MFOneDriveViewController alloc] init];
        controller.currentItem = item;
        controller.client = self.client;
        controller.title = item.name;
    } else {
    }
    
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        ODItem *item = [self itemForIndex:indexPath];
        NSString *message = [NSString stringWithFormat:@"This will delete \n%@\nAre you sure you wish to continue ?", item.name];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
                                                                                 message:message
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"Delete"
                                                               style:UIAlertActionStyleDestructive
                                                             handler:^(UIAlertAction * _Nonnull action) {
                                                                 ODItem *item = [self itemForIndex:indexPath];
                                                                 
                                                                 MFOneDriveErrorBlock errorBlock = ^void(NSError *error) {
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
                                                                         // NSMutableArray *array = [NSMutableArray arrayWithArray:self.items];
                                                                         // [array removeObject:item];
                                                                         
                                                                         NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:self.items];
                                                                         [dic removeObjectForKey:item.id];
                                                                         
                                                                         self.items = [dic copy];
                                                                         [self.myTableView reloadData];
                                                                         [self dismissViewControllerAnimated:YES
                                                                                                  completion:nil];
                                                                     }
                                                                 };
                                                                 
                                                                 /*
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
                                                                 }*/
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



#pragma mark - Third Mathods
- (void)refresh
{
    [self loadChildren];
}



- (IBAction)signInAction:(id)sender {
    
    [self setStarted];
    [ODClient authenticatedClientWithCompletion:^(ODClient *client, NSError *error){
        if (!error){
            self.client = client;
            [ODClient setCurrentClient:client];
            [self loadChildren];
        }
        else{
            [self showErrorAlert:error];
        }
        [self setFinished];
    }];
}
- (IBAction)signOutAction:(id)sender {
    [self setStarted];
    [self.client signOutWithCompletion:^(NSError *signOutError){
        self.items = nil;
        self.items = [NSMutableDictionary dictionary];
        self.itemsLookup = nil;
        self.itemsLookup = [NSMutableArray array];
        self.client = nil;
        self.currentItem = nil;
        self.title = @"OneDrive";
        dispatch_async(dispatch_get_main_queue(), ^(){
            [self.myTableView reloadData];
            self.myTableView.hidden = YES;
            self.connectButton.hidden = NO;
            self.navigationItem.rightBarButtonItem = nil;
            [self setFinished];
        });
    }];
}


- (void)loadChildren
{
    NSString *itemId = (self.currentItem) ? self.currentItem.id : @"root";
    ODChildrenCollectionRequest *childrenRequest = [[[[self.client drive] items:itemId] children] request];
    if (![self.client serviceFlags][@"NoThumbnails"]){
        [childrenRequest expand:@"thumbnails"];
    }
    [self loadChildrenWithRequest:childrenRequest];
}


- (void)onLoadedChildren:(NSArray *)children
{

    dispatch_async(dispatch_get_main_queue(), ^(){
        if (self.refreshControl.isRefreshing){
            [self.refreshControl endRefreshing];
        }
        
        if (children.count>0) {
            self.myTableView.hidden = NO;
             self.navigationItem.rightBarButtonItem = self.signOut;
        }else{
            self.myTableView.hidden = YES;
            self.navigationItem.rightBarButtonItem = nil;
        }
        self.connectButton.hidden = YES;
    });
   
    [children enumerateObjectsUsingBlock:^(ODItem *item, NSUInteger index, BOOL *stop){
        if (![self.itemsLookup containsObject:item.id]){
            [self.itemsLookup addObject:item.id];
        }
        self.items[item.id] = item;
    }];
    [self loadThumbnails:children];
    dispatch_async(dispatch_get_main_queue(), ^(){
        
        [self.myTableView reloadData];
    });
}

- (void)loadThumbnails:(NSArray *)items{
    for (ODItem *item in items){
        if ([item thumbnails:0]){
            [[[[[[self.client drive] items:item.id] thumbnails:@"0"] small] contentRequest] downloadWithCompletion:^(NSURL *location, NSURLResponse *response, NSError *error) {
                if (!error){
                    self.thumbnails[item.id] = [UIImage imageWithData:[NSData dataWithContentsOfURL:location]];
                    dispatch_async(dispatch_get_main_queue(), ^(){
                        [self.myTableView reloadData];
                    });
                }
            }];
        }
    }
}

- (void)loadChildrenWithRequest:(ODChildrenCollectionRequest*)childrenRequests
{
    [childrenRequests getWithCompletion:^(ODCollection *response, ODChildrenCollectionRequest *nextRequest, NSError *error){
        if (!error){
            if (response.value){
                [self onLoadedChildren:response.value];
            }
            if (nextRequest){
                [self loadChildrenWithRequest:nextRequest];
            }
        }
        else if ([error isAuthenticationError]){
            [self showErrorAlert:error];
            [self onLoadedChildren:@[]];
        }
    }];
}

- (ODItem *)itemForIndex:(NSIndexPath *)indexPath
{
    NSString *itemId = self.itemsLookup[indexPath.row];
    return self.items[itemId];
}

- (void)showErrorAlert:(NSError*)error
{
    NSString *errorMsg;
    if ([error isAuthCanceledError]) {
        errorMsg = @"Sign-in was canceled!";
    }
    else if ([error isAuthenticationError]) {
        errorMsg = @"There was an error in the sign-in flow!";
    }
    else if ([error isClientError]) {
        errorMsg = @"Oops, we sent a bad request!";
    }
    else {
        errorMsg = @"Uh oh, an error occurred!";
    }
    UIAlertController *errorAlert = [UIAlertController alertControllerWithTitle:errorMsg
                                                                        message:[NSString stringWithFormat:@"%@", error.description]
                                                                 preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){}];
    [errorAlert addAction:ok];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:errorAlert animated:YES completion:nil];
    });
    
}

#pragma mark - 开始loading
- (void)setStarted {
    
    [SVProgressHUD showWithStatus:@"加载中..."];
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleLight];
    
}

#pragma mark - 结束loading
- (void)setFinished {
    
    [SVProgressHUD dismiss];
}


@end

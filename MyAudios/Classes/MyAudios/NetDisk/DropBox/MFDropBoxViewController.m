//
//  MFDropBoxViewController.m
//  MyAdios
//
//  Created by chang on 2017/7/16.
//  Copyright © 2017年 chang. All rights reserved.
//

#import "MFDropBoxViewController.h"
#import <ObjectiveDropboxOfficial/ObjectiveDropboxOfficial.h>
#import "MFDropBoxTableViewCell.h"
#import <objc/runtime.h>
#import "SVProgressHUD.h"
#import "MFFileTypeJudgmentUtil.h"
#import "MFStringUtil.h"

@interface MFDropBoxViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (weak, nonatomic) IBOutlet UIButton *dropboxLoginBtn;
@property (weak, nonatomic) IBOutlet UIImageView *dropboxUnLoginImgview;

@property UIBarButtonItem *signOut;

@end

@implementation MFDropBoxViewController


#pragma mark - UIView LifeCycle Methods

-(void)viewWillAppear:(BOOL)animated{

    [super viewWillAppear:animated];
    
    [self checkIsLogin];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dataArray = [[NSMutableArray alloc] init];
    // 查询dropBox数据
    [self setupDropboxSearch:self.searchPath];
    
    [self customSubviewShow];
  
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self setFinished];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

#pragma mark - 设置子视图
-(void)customSubviewShow {
    // 退出登录按钮
    self.signOut = [[UIBarButtonItem alloc] initWithTitle:@"退出登录" style:UIBarButtonItemStylePlain target:self action:@selector(signOutAction:)];
    self.signOut.tintColor = [UIColor whiteColor];
    
    // 删除多余的分割线
    [self.myTableView setTableFooterView:[[UIView alloc]initWithFrame:CGRectZero]];
    self.myTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
}


#pragma mark - UITableView DataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  self.dataArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    static NSString *simpleTableIdentifier = @"MFDropBoxTableViewCell";
    MFDropBoxTableViewCell *cell = (MFDropBoxTableViewCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"MFDropBoxTableViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    NSInteger row = indexPath.row;
    DBFILESMetadata *entry = [self.dataArray objectAtIndex:row];
    [cell setupCellWithModel:entry];

     __weak MFDropBoxTableViewCell *wCell = cell;
    cell.downloadBtnClickedBlock = ^{
        // 在block的执行过程中,使用强对象对弱对象进行引用
        MFDropBoxTableViewCell *sCell = wCell;
        [self downloadImage:entry.pathDisplay andCell:sCell];
    };
    
    cell.downloadBtn.showsTouchWhenHighlighted = YES;
    cell.downloadBtn.showsTouchWhenHighlighted = YES;

    
    return cell;
}
#pragma  mark tableView delegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    DBFILESMetadata *entry = [self.dataArray objectAtIndex:indexPath.row];
    CGFloat cellHeight = [MFStringUtil heightForString:entry.name andWidth:mainScreenWidth-84];

    return cellHeight;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger row = indexPath.row;
    DBFILESMetadata *entry = [self.dataArray objectAtIndex:row];
    
    BOOL isImageType = [MFFileTypeJudgmentUtil isImageType:entry.name];
    BOOL isAudioType = [MFFileTypeJudgmentUtil isAudioType:entry.name];
    
    if (isImageType||isAudioType||[MFFileTypeJudgmentUtil isFileType:entry.name]) {
        return;
    }
    if ([MFFileTypeJudgmentUtil isFileType:entry.name]&&!isAudioType&&!isImageType) {
        return;
    }
    
    MFDropBoxViewController *dropboxVC = [[MFDropBoxViewController alloc] init];
    dropboxVC.searchPath = entry.pathLower;
    dropboxVC.title = entry.name;
    
    
    
    [self.navigationController pushViewController:dropboxVC animated:YES];
}



#pragma mark - Custom Methods

- (BOOL)isImageType:(NSString *)itemName {
    NSRange range = [itemName rangeOfString:@"\\.jpeg|\\.jpg|\\.JPEG|\\.JPG|\\.png" options:NSRegularExpressionSearch];
    return range.location != NSNotFound;
}

// 判断是否是img格式
- (BOOL)isAudioType:(NSString *)itemName {
    NSRange range = [itemName rangeOfString:@"\\.mp3|\\.mp4|\\.aac|\\.AIFF|\\.CAF|\\.WAVE" options:NSRegularExpressionSearch];
    return range.location != NSNotFound;
}


- (IBAction)linkDropboxButtonPressed:(id)sender {
    
    [DBClientsManager authorizeFromController:[UIApplication sharedApplication]
                                   controller:self
                                      openURL:^(NSURL * url) {
                                          NSDictionary *options = [[NSDictionary alloc] initWithObjectsAndKeys:@"testValue",@"testKey",nil];
                                          [[UIApplication sharedApplication] openURL:url options:options completionHandler:^(BOOL success) {
                                          }];
                                      }
                                  browserAuth:YES];
}



#pragma mark - 判断是否已登录
- (void)checkIsLogin {
    
    if ([DBClientsManager authorizedClient] || [DBClientsManager authorizedTeamClient]) {
        self.myTableView.hidden = NO;
        self.dropboxLoginBtn.hidden = YES;
        self.dropboxUnLoginImgview.hidden = YES;
        self.navigationItem.rightBarButtonItem = self.signOut;
    }else{
        self.myTableView.hidden = YES;
        self.dropboxLoginBtn.hidden = NO;
        self.dropboxUnLoginImgview.hidden = NO;
        self.navigationItem.rightBarButtonItem = nil;
    }
    
}


#pragma mark - 查询 dropbox 信息
-(void)setupDropboxSearch:(NSString *)searchPath {

    if (!searchPath) {
        return;
    }
    
    if ([DBClientsManager authorizedClient] || [DBClientsManager authorizedTeamClient]) {
        // loading
        [self setStarted];
    }
    
    DBUserClient *client = [DBClientsManager authorizedClient];
    
    // list folder metadata contents (folder will be root "/" Dropbox folder if app has permission
    // "Full Dropbox" or "/Apps/<APP_NAME>/" if app has permission "App Folder").
    [[client.filesRoutes listFolder:searchPath]
     setResponseBlock:^(DBFILESListFolderResult *result, DBFILESListFolderError *routeError, DBRequestError *error) {
         
         // end loading
         [self setFinished];
         
         if (result) {
             
             self.dataArray = [NSMutableArray arrayWithArray:result.entries];
             [self.myTableView reloadData];
             
             // [self displayPhotos:result.entries];
         } else {
             NSString *title = @"";
             NSString *message = @"";
             if (routeError) {
                 // Route-specific request error
                 title = @"Route-specific error";
                 if ([routeError isPath]) {
                     message = [NSString stringWithFormat:@"Invalid path: %@", routeError.path];
                 }
             } else {
                 // Generic request error
                 title = @"Generic request error";
                 if ([error isInternalServerError]) {
                     DBRequestInternalServerError *internalServerError = [error asInternalServerError];
                     message = [NSString stringWithFormat:@"%@", internalServerError];
                 } else if ([error isBadInputError]) {
                     DBRequestBadInputError *badInputError = [error asBadInputError];
                     message = [NSString stringWithFormat:@"%@", badInputError];
                 } else if ([error isAuthError]) {
                     DBRequestAuthError *authError = [error asAuthError];
                     message = [NSString stringWithFormat:@"%@", authError];
                 } else if ([error isRateLimitError]) {
                     DBRequestRateLimitError *rateLimitError = [error asRateLimitError];
                     message = [NSString stringWithFormat:@"%@", rateLimitError];
                 } else if ([error isHttpError]) {
                     DBRequestHttpError *genericHttpError = [error asHttpError];
                     message = [NSString stringWithFormat:@"%@", genericHttpError];
                 } else if ([error isClientError]) {
                     DBRequestClientError *genericLocalError = [error asClientError];
                     message = [NSString stringWithFormat:@"%@", genericLocalError];
                 }
                 message = @"网络连接异常，请确认网络是否正常后再重试...";
             }
             
             UIAlertController *alertController =
             [UIAlertController alertControllerWithTitle:title
                                                 message:message
                                          preferredStyle:(UIAlertControllerStyle)UIAlertControllerStyleAlert];
             [alertController addAction:[UIAlertAction actionWithTitle:@"OK"
                                                                 style:(UIAlertActionStyle)UIAlertActionStyleCancel
                                                               handler:nil]];
             [self presentViewController:alertController animated:YES completion:nil];
             
             [self setFinished];
         }
     }];
}


#pragma mark - 处理图片
- (void)displayPhotos:(NSArray<DBFILESMetadata *> *)folderEntries {
    NSMutableArray<NSString *> *imagePaths = [NSMutableArray new];
    for (DBFILESMetadata *entry in folderEntries) {
        NSString *itemName = entry.name;
        if ([self isImageType:itemName]) {
            [imagePaths addObject:entry.pathDisplay];
        }
    }
    
    if ([imagePaths count] > 0) {
        NSString *imagePathToDownload = imagePaths[arc4random_uniform((int)[imagePaths count] - 1)];
        [self downloadImage:imagePathToDownload andCell:nil];
    } else {
        NSString *title = @"No images found";
        NSString *message = @"There are currently no valid image files in the specified search path in your Dropbox. "
        @"Please add some images and try again.";
        UIAlertController *alertController =
        [UIAlertController alertControllerWithTitle:title
                                            message:message
                                     preferredStyle:(UIAlertControllerStyle)UIAlertControllerStyleAlert];
        [alertController
         addAction:[UIAlertAction actionWithTitle:@"OK" style:(UIAlertActionStyle)UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
        [self setFinished];
    }
}



#pragma mark - 下载
- (void)downloadImage:(NSString *)imagePath andCell:(MFDropBoxTableViewCell *)cell{
    DBUserClient *client = [DBClientsManager authorizedClient];
    
    cell.downloadBtn.hidden = YES;
    [[[client.filesRoutes downloadData:imagePath]
     setResponseBlock:^(DBFILESFileMetadata *result, DBFILESDownloadError *routeError, DBRequestError *error, NSData *fileData) {
         if (result) {
             
             [self saveData:result with:fileData];
             [self setFinished];
             
             // 延迟 1s 执行加载完全
             dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC));
             dispatch_after(delayTime, dispatch_get_main_queue(), ^{
                [cell setProgress:1.0];
                
                // 下载完，更新 cell 显示状态
                NSIndexPath *indexPath = [self.myTableView indexPathForCell:cell];
                [self.myTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationFade];
                 
             });
             
             
         } else {
            
             cell.downloadBtn.hidden = NO;
             NSString *title = @"";
             NSString *message = @"";
             if (routeError) {
                 // Route-specific request error
                 title = @"Route-specific error";
                 if ([routeError isPath]) {
                     message = [NSString stringWithFormat:@"Invalid path: %@", routeError.path];
                 } else if ([routeError isOther]) {
                     message = [NSString stringWithFormat:@"Unknown error: %@", routeError];
                 }
             } else {
                 // Generic request error
                 title = @"Generic request error";
                 if ([error isInternalServerError]) {
                     DBRequestInternalServerError *internalServerError = [error asInternalServerError];
                     message = [NSString stringWithFormat:@"%@", internalServerError];
                 } else if ([error isBadInputError]) {
                     DBRequestBadInputError *badInputError = [error asBadInputError];
                     message = [NSString stringWithFormat:@"%@", badInputError];
                 } else if ([error isAuthError]) {
                     DBRequestAuthError *authError = [error asAuthError];
                     message = [NSString stringWithFormat:@"%@", authError];
                 } else if ([error isRateLimitError]) {
                     DBRequestRateLimitError *rateLimitError = [error asRateLimitError];
                     message = [NSString stringWithFormat:@"%@", rateLimitError];
                 } else if ([error isHttpError]) {
                     DBRequestHttpError *genericHttpError = [error asHttpError];
                     message = [NSString stringWithFormat:@"%@", genericHttpError];
                 } else if ([error isClientError]) {
                     DBRequestClientError *genericLocalError = [error asClientError];
                     message = [NSString stringWithFormat:@"%@", genericLocalError];
                 }
             }
             
             UIAlertController *alertController =
             [UIAlertController alertControllerWithTitle:title
                                                 message:message
                                          preferredStyle:(UIAlertControllerStyle)UIAlertControllerStyleAlert];
             [alertController addAction:[UIAlertAction actionWithTitle:@"OK"
                                                                 style:(UIAlertActionStyle)UIAlertActionStyleCancel
                                                               handler:nil]];
             [self presentViewController:alertController animated:YES completion:nil];
             
             [self setFinished];
         }
     } ]
     setProgressBlock:^(int64_t bytesDownloaded, int64_t totalBytesDownloaded, int64_t totalBytesExpectedToDownload) {
         float progress = (float)totalBytesDownloaded/totalBytesExpectedToDownload;
         NSLog(@"progress === %.2f",progress);
         [cell setProgress:progress];
         NSLog(@"bytesDownloaded == %lld\n totalBytesDownloaded == %lld\n totalBytesExpectedToDownload== %lld\n", bytesDownloaded, totalBytesDownloaded, totalBytesExpectedToDownload);
        
         
     }];
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


#pragma mark - 保存文件到本地
- (void)saveData:(DBFILESFileMetadata *)result with:(NSData *)fileData
{

    // 文件路径
    NSString* ceches = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString* filepath = [ceches stringByAppendingPathComponent:result.name];
    
    // 创建一个空的文件到沙盒中
    // NSFileManager* mgr = [NSFileManager defaultManager];
    // BOOL isSuccess = [mgr createFileAtPath:filepath contents:fileData attributes:nil];
    
    //创建数据缓冲
    NSMutableData *writer = [[NSMutableData alloc] init];
    //将字符串添加到缓冲中
    //[writer appendData:[fileData dataUsingEncoding:NSUTF8StringEncoding]];
    [writer appendData:fileData];
    //将其他数据添加到缓冲中
    
    //将缓冲的数据写入到文件中
    BOOL isSuccess = [writer writeToFile:filepath atomically:YES];
    
    if (isSuccess) {
       NSLog(@"保存文件成功");
    }else{
       NSLog(@"保存文件失败");
    }
}

#pragma mark - 退出登录事件
- (IBAction)signOutAction:(id)sender {
    [DBClientsManager unlinkAndResetClients];
    [self checkIsLogin];
}

@end

//
//  MFDownloadedViewController.m
//  MyAdios
//
//  Created by chang on 2017/7/15.
//  Copyright © 2017年 chang. All rights reserved.
//

#import "MFDownloadedViewController.h"
#import "PhotoViewController.h"
#import "MFDownloadTableViewCell.h"
#import "AudiosPlayerViewController.h"
#import "MFFileManager.h"
#import "MFFileTypeJudgmentUtil.h"
#import "MFAudiosListPlayerViewController.h"
#import "CHAudioModel.h"
#import "Masonry.h"
#import "MFStringUtil.h"
#import "MFFolderViewController.h"
#import "CustomNavigationController.h"
#import "MFUserDefaultsCache.h"
#import "MusicPlayTools.h"

#define TOPBGVIEWHEIGHT 44.0 // 顶部背景视图高度
#define BOTTOMVIEWHEIGHT 44.0 // 底部全选、删除背景视图高度

@interface MFDownloadedViewController ()<UITableViewDelegate,UITableViewDataSource>


@property (nonatomic,strong) NSMutableArray * dataArray;
@property (nonatomic) BOOL isNeedRefresh;// 是否需要刷新加载数据
@property (weak, nonatomic) IBOutlet UIView *topBgView;// 顶部背景视图
@property (weak, nonatomic) IBOutlet UIButton *deleateAllBtn;// 批量删除按钮
@property (weak, nonatomic) IBOutlet UIButton *moveFileBtn;// 移动文件按钮
@property (weak, nonatomic) IBOutlet UIView *bottomView;// 底部视图
@property (weak, nonatomic) IBOutlet UIButton *deleteConfirmBtn;// 底部删除按钮
@property (weak, nonatomic) IBOutlet UIButton *selectAllBtn;// 全选按钮
@property (weak, nonatomic) IBOutlet UILabel *alreadySlectedLbl;// 已选择x条
@property (weak, nonatomic) IBOutlet UILabel *totalNumLbl;// 共计多少条

@property(nonatomic) BOOL ifMoveFile;// 标志是否是移动文件

@end

@implementation MFDownloadedViewController

#pragma mark - UIView LifeCycle Methods

-(void)viewWillAppear:(BOOL)animated{

    [super viewWillAppear:animated];
    
    // pop时候不需要刷新
    if (self.isNeedRefresh) {
        // 播放列表页面不显示图片
        [self loadDataArray];
        [self.myTableView reloadData];
        [self refreshShowCount];
    }else{
        self.isNeedRefresh = YES;
    }

    // 加载数据源
    [self loadDataArray];
    [self customViewShow];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.isNeedRefresh = YES;
    
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - 设置显示样式
-(void)customViewShow {
    
    if (!self.isPlayList) {
        if (self.title) {
            self.navigationItem.title = self.title;
            self.cutomTitleLbl.text = self.title;
        }else{
            self.navigationItem.title = @"下载听";
            self.cutomTitleLbl.text = @"下载听";
        }
    }else{
        self.navigationItem.title = @"播放列表";
        self.cutomTitleLbl.text = @"播放列表";
    }
    
    [self showOrHideTitleEditBtns];
    
    // 删除多余的分割线
    [self.myTableView setTableFooterView:[[UIView alloc]initWithFrame:CGRectZero]];
    self.myTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.myTableView.allowsMultipleSelectionDuringEditing = YES;
    
    if ([MusicPlayTools shareMusicPlay].player.rate==1) {// 正在播放
        UIButton *playBtn = [self createPlayingBtn:nil];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:playBtn];
    }else{
        // 设置右边按钮(新建文件夹)
        self.navigationItem.rightBarButtonItem =
        [[UIBarButtonItem alloc]
         initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
         target:self
         action:@selector(newFolderBtnClicked:)];
        // 设置按钮背景颜色
        self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
    }
    
    // 如果iOS的系统是11.0，会有这样一个宏定义“#define __IPHONE_11_0  110000”；如果系统版本低于11.0则没有这个宏定义
#ifdef __IPHONE_11_0
    if ([self.myTableView respondsToSelector:@selector(setContentInsetAdjustmentBehavior:)]) {
        if (@available(iOS 11.0, *)) {
            [self.myTableView setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentNever];
        } else {
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
    }
    
#endif
    
    // 设置控件高度
    float screenH = mainScreenHeight;
    float topBgViewH = TOPBGVIEWHEIGHT;
    float navH = MFNavBarHeight;
    float tabH = MFTabBarHeight;
    self.topBgView.frame = CGRectMake(0, navH, mainScreenWidth, topBgViewH);
    float height = screenH - navH - tabH - topBgViewH;
    self.myTableView.frame = CGRectMake(0, navH + topBgViewH, mainScreenWidth, height);
    self.bottomView.frame = CGRectMake(0, mainScreenHeight, mainScreenWidth, BOTTOMVIEWHEIGHT);
   
}



#pragma mark - 加载数据源
-(void)loadDataArray {
    NSMutableArray * filesArr = [MFFileManager readDownloadedFiles:self.parentfolderName];
    self.dataArray = [[NSMutableArray alloc] init];
    if (!self.isPlayList) {
        for (NSString *name in filesArr) {
            CHAudioModel * audio = [[CHAudioModel alloc] init];
            audio.fileName = name;
            audio.ifSelected = NO;// 默认未选中 选中删除
            audio.parentfolderName = self.parentfolderName;
            [self.dataArray addObject:audio];
        }
    }else{
        NSMutableArray *temArr = [MFFileManager readDownloadedFiles:self.parentfolderName];
        for (NSString *name in filesArr) {
            if ([MFFileTypeJudgmentUtil isImageType:name]) {
                [temArr removeObject:name];
            }
        }
        for (NSString *name in filesArr) {
            CHAudioModel * audio = [[CHAudioModel alloc] init];
            audio.fileName = name;
            audio.ifSelected = NO;// 默认未选中 选中删除
            audio.parentfolderName = self.parentfolderName;
            [self.dataArray addObject:audio];
        }
    }
}


#pragma mark - UITableView DataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  self.dataArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString * simpleTableIdentifier = [NSString stringWithFormat:@"MFDownloadTableViewCell%li%li",(long)indexPath.section,indexPath.row];
    MFDownloadTableViewCell *cell = (MFDownloadTableViewCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"MFDownloadTableViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.layoutMargins = UIEdgeInsetsZero;
    cell.separatorInset = UIEdgeInsetsMake(0, 15, 0, 0);
    
    NSInteger row = indexPath.row;
    if ([self dataArray].count>row) {
        CHAudioModel *audio = [[self dataArray] objectAtIndex:row];
        NSString * name = audio.fileName;
        [cell setupCellWithModel:name];
        
        // 如果已经播放完毕，设置文本颜色变浅
        NSUserDefaults* defs = [NSUserDefaults standardUserDefaults];
        BOOL isPlayed = [defs boolForKey:name];
        if (isPlayed) {
            cell.nameLabel.textColor = [UIColor colorWithRed:181.0/255.0 green:181.0/255.0 blue:181.0/255.0 alpha:1.0];
        }else{
            cell.nameLabel.textColor = [UIColor blackColor];
        }
    }
    return cell;
}

#pragma  mark tableView delegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    MFDownloadTableViewCell *cell = (MFDownloadTableViewCell*)[self tableView:tableView cellForRowAtIndexPath:indexPath];
    CHAudioModel *audio = [[self dataArray] objectAtIndex:indexPath.row];
    NSString *name = audio.fileName;
    CGFloat cellHeight = [cell heightForString:name andWidth:mainScreenWidth-84];
    
    return cellHeight;
}
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self showSelectedCount];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CHAudioModel *audio = [[self dataArray] objectAtIndex:indexPath.row];
    NSString *name = audio.fileName;
    
    if (self.myTableView.isEditing) {// 当前处于编辑状态，进行选中
        [self showSelectedCount];
        return;
        
    }else{
        [self pushToViewControllerByName:name];
    }
}

#pragma mark - 根据文件名判断文件类型，进行特定跳转
-(void)pushToViewControllerByName:(NSString *)name {
    if ([MFFileTypeJudgmentUtil isImageType:name]) {
        
        PhotoViewController * photoViewController = [[PhotoViewController alloc] init];
        if (![MFStringUtil isEmpty:self.parentfolderName]) {
            name = [self.parentfolderName stringByAppendingString:[NSString stringWithFormat:@"/%@",name]];
        }
        NSString * filePath = [MFFileManager readFilePath:name];
        NSData *newData = [NSData dataWithContentsOfFile:filePath];
        UIImage *showImage = [[UIImage alloc] initWithData:newData];
        
        photoViewController.currentImage = showImage;
        photoViewController.title = name;
        
        [self.navigationController pushViewController:photoViewController animated:YES];
        
    }else if ([MFFileTypeJudgmentUtil isAudioType:name]){
        
        if (!self.isPlayList) {
            AudiosPlayerViewController * audiosPlayerVC = [[AudiosPlayerViewController alloc] init];
            audiosPlayerVC.parentfolderName = self.parentfolderName;
            audiosPlayerVC.fileName = name;
            audiosPlayerVC.title = name;
            [self.navigationController pushViewController:audiosPlayerVC animated:YES];
        }else{
            MFAudiosListPlayerViewController * audiosListVC = [[MFAudiosListPlayerViewController alloc] init];
            audiosListVC.fileName = name;
            audiosListVC.parentfolderName = self.parentfolderName;
            audiosListVC.title = name;
            [self.navigationController pushViewController:audiosListVC animated:YES];
        }
        
    }else {// if ([MFFileTypeJudgmentUtil isFolderType:name])
        
        MFDownloadedViewController *downloadedVC = [[MFDownloadedViewController alloc] init];
        
        NSString *folderName = name;
        if (![MFStringUtil isEmpty:self.parentfolderName]) {
            folderName = [NSString stringWithFormat:@"%@/%@",self.parentfolderName,name];
        }
        downloadedVC.parentfolderName = folderName;
        // downloadedVC.folderName = folderName;
        downloadedVC.title = name;
        downloadedVC.isPlayList = self.isPlayList;
        [self.navigationController pushViewController:downloadedVC animated:YES];
        
    }
}



// 请求数据源提交的插入或删除指定行接收者。
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (editingStyle ==UITableViewCellEditingStyleDelete) {
        
        if (indexPath.row<[self.dataArray count]) {
            
            // 删除本地文件
            CHAudioModel *audio = [[self dataArray] objectAtIndex:indexPath.row];
            NSString *name = audio.fileName;
            if (![MFStringUtil isEmpty:self.parentfolderName]) {
                name = [NSString stringWithFormat:@"%@/%@",self.parentfolderName,name];
            }
            BOOL isSuccess = [MFFileManager deleteFileWithPath:name];
            if (isSuccess) {
                NSLog(@"删除成功...");
            }else{
                NSLog(@"删除失败...");
            }
            // 清空播放完毕缓存
            [MFUserDefaultsCache clearPlayEndSetting:self.fileName];
            // 移除数据源的数据
            [self.dataArray removeObjectAtIndex:indexPath.row];
            
            // 移除tableView中的数据
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
          
        }
    }
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCellEditingStyle result = UITableViewCellEditingStyleNone;//默认没有编辑风格
    if ([tableView isEqual:self.myTableView]) {
        result = UITableViewCellEditingStyleDelete;//设置编辑风格为删除风格
    }
    return result;
}

#pragma mark - 以下自定义方法
#pragma mark - 创建播放中动画按钮
-(UIButton *)createPlayingBtn:(id)sender {
    
    UIButton *playBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    NSMutableArray *images = [NSMutableArray new];
    
    for (NSInteger i = 0; i < 4; i++) {
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"cm2_list_icn_loading%ld", i + 1]];
        [images addObject:image];
    }
    
    for (NSInteger i = 4; i > 0; i--) {
        NSString *imageName = [NSString stringWithFormat:@"cm2_list_icn_loading%ld", (long)i];
        [images addObject:[UIImage imageNamed:imageName]];
    }
    [playBtn setImage:[UIImage imageNamed:@"cm2_list_icn_loading1"] forState:UIControlStateNormal];
    [playBtn.imageView setAnimationImages:[images copy]];
    [playBtn.imageView setAnimationDuration:0.85];
    playBtn.imageView.animationRepeatCount = 0;//设置动画次数 0 表示无限
    [playBtn.imageView startAnimating];
    playBtn.backgroundColor = [UIColor darkGrayColor];
    [playBtn addTarget:self action:@selector(palyingBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    return playBtn;
}



#pragma mark- 设置是否显示一个可编辑视图的视图控制器。
-(void)setEditing:(BOOL)editing animated:(BOOL)animated{
    
    [super setEditing:editing animated:animated];
    // 切换接收者的进入和退出编辑模式。
    [self.myTableView setEditing:editing animated:animated];
    // 提示显示已选中多少个
    [self showSelectedCount];
}


#pragma mark - 播放中按钮点击事件
-(void)palyingBtnClicked:(id)sender {
    
    MusicInfoModel *musicModel = [[MusicPlayTools shareMusicPlay] model];
    NSString * fileName = musicModel.name;
    NSArray *strArr = [fileName componentsSeparatedByString:@"/"];
    if (strArr.count>1) {
        fileName = [strArr lastObject];
    }
    [self pushToViewControllerByName:fileName];
}

#pragma mark - 移动文件夹事件
- (IBAction)moveFilesBtnClicked:(id)sender {
    
    UIButton *btn = (UIButton *)sender;
    
    if ([@"移动文件" isEqualToString:btn.titleLabel.text]) {
        if (self.dataArray.count == 0) {
            return;
        }
        self.ifMoveFile = YES;
        btn.titleLabel.text = @"取 消";
        [btn setTitle:@"取 消" forState:UIControlStateNormal];
        [self.myTableView setEditing:YES animated:YES];
        [self showEitingView:YES];
        
    }else{
        self.ifMoveFile = NO;
        [btn setTitle:@"移动文件" forState:UIControlStateNormal];
        [self.myTableView setEditing:NO animated:YES];
        [self showEitingView:NO];
    }
}


#pragma mark - 批量删除事件
-(IBAction)deleateAllBtnClicked:(id)sender {
    UIButton *btn = (UIButton *)sender;
    if ([@"批量删除" isEqualToString:btn.titleLabel.text]) {
        if (self.dataArray.count == 0) {
            return;
        }
        btn.titleLabel.text = @"取 消";
        [btn setTitle:@"取 消" forState:UIControlStateNormal];
        [self.myTableView setEditing:YES animated:YES];
        [self showEitingView:YES];
    }else{
        [btn setTitle:@"批量删除" forState:UIControlStateNormal];
        [self.myTableView setEditing:NO animated:YES];
        [self showEitingView:NO];
    }
}

#pragma mark - 取消选择
- (IBAction)cancellSelectedCells:(id)sender {
    [self.myTableView setEditing:NO animated:YES];
    [self.myTableView reloadData];
}

#pragma mark - 全选
- (IBAction)selectAllCells:(id)sender {
    [self.dataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.myTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
    }];
}

#pragma mark - 删除已选中cell
- (IBAction)confirmBtnClicked:(id)sender {
    
    NSMutableIndexSet *insets = [[NSMutableIndexSet alloc] init];
    if (self.ifMoveFile) {// 如果是移动文件，弹出模态视图
        
        [[self.myTableView indexPathsForSelectedRows] enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [insets addIndex:obj.row];
        }];
        
        NSArray *moveItemsArr = [self.dataArray objectsAtIndexes:insets];
        
        MFFolderViewController *folderVC = [[MFFolderViewController alloc] init];
        CustomNavigationController * customNav = [[CustomNavigationController alloc] initWithRootViewController:folderVC];
        folderVC.moveItems = moveItemsArr;
        [self presentViewController:customNav animated:YES completion:^{
            
        }];
        return;
    }
    
    [[self.myTableView indexPathsForSelectedRows] enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [insets addIndex:obj.row];
        CHAudioModel *audio = [self.dataArray objectAtIndex:obj.row];
        [MFFileManager deleteFileWithPath:audio.fileName];
    }];

    [self.dataArray removeObjectsAtIndexes:insets];
    [self.myTableView deleteRowsAtIndexPaths:[self.myTableView indexPathsForSelectedRows] withRowAnimation:UITableViewRowAnimationFade];
    
    // 清空已选中个数显示
    [self showSelectedCount];
    
    /** 数据清空情况下取消编辑状态*/
    if (self.dataArray.count == 0) {
        [self closeEditStyle];
    }

}

#pragma mark- 全选、全反选事件
- (IBAction)selectedAllBtnClicked:(id)sender {
    
    UIButton * selectAllBtn = (UIButton *)sender;
    selectAllBtn.selected = !selectAllBtn.selected;
    [selectAllBtn setImage:[UIImage imageNamed:@"selectBtn"] forState:UIControlStateNormal];
    [selectAllBtn setImage:[UIImage imageNamed:@"selectedBgImg"] forState:UIControlStateSelected];
    if (selectAllBtn.selected) {
        [self.dataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self.myTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
        }];
    }else{
        [[self.myTableView indexPathsForSelectedRows] enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self.myTableView deselectRowAtIndexPath:obj animated:NO];
        }];
    }
    // 提示显示已选中多少个
    [self showSelectedCount];
}

#pragma Mark- 提示显示已选中多少个
-(void)showSelectedCount {
    NSArray *selectedIndexArr = self.myTableView.indexPathsForSelectedRows;
    NSInteger count = selectedIndexArr.count;
    if (count<=0) {
        count = 0;
    }
    NSString * notifyStr = [NSString stringWithFormat:@"已选择%ld条",(long)count];
    self.alreadySlectedLbl.text = notifyStr;
}

#pragma mark - 显示、隐藏底部删除视图
- (void)showEitingView:(BOOL)isShow{
    [self.bottomView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).offset(isShow?0:45);
    }];
    if (isShow) {
        [self.myTableView setContentInset:UIEdgeInsetsMake(0, 0, 45, 0)];
        // 底部视图布局
        [self.bottomView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view.mas_left).offset(0);
            make.bottom.equalTo(self.view.mas_bottom).offset(0);
            make.right.equalTo(self.view.mas_right).offset(0);
            make.height.equalTo(@44);
        }];
        
        // 全选按钮
        [self.selectAllBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.bottomView.mas_left).offset(0);
            make.bottom.equalTo(self.bottomView.mas_bottom).offset(0);
            make.width.equalTo(@80);
            make.height.equalTo(@44);
        }];
        // 提示删除几个lbl
        [self.alreadySlectedLbl mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.bottomView.mas_left).offset(82);
            make.bottom.equalTo(self.bottomView.mas_bottom).offset(-9);
            make.width.equalTo(@107);
            make.height.equalTo(@25);
        }];
        // 删除确认按钮
        [self.deleteConfirmBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.bottomView.mas_right).offset(0);
            make.bottom.equalTo(self.bottomView.mas_bottom).offset(0);
            make.width.equalTo(@90);
            make.height.equalTo(@44);
        }];
        
        // 判断是移动文件还是批量删除
        if (self.ifMoveFile) {
            [self.deleteConfirmBtn setTitle:@"移动" forState:UIControlStateNormal];
            self.deleateAllBtn.enabled = NO;
        }else{
            [self.deleteConfirmBtn setTitle:@"删除" forState:UIControlStateNormal];
            self.moveFileBtn.enabled = NO;
        }
    }else{
        [self.myTableView setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
        self.deleateAllBtn.enabled = YES;
        self.moveFileBtn.enabled = YES;
    }
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
    }];
}




#pragma mark - 重载返回事件
- (IBAction)backPrePage:(id)sender{
    if (self.navigationController.topViewController != self) {
        return;
    }
    self.isNeedRefresh = NO;
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 关闭tableView编辑模式
-(void)closeEditStyle {
    
    [self.myTableView setEditing:NO animated:YES];
    [self showEitingView:NO];
    [self.deleateAllBtn  setTitle:@"批量删除" forState:UIControlStateNormal];
}

#pragma mark - 新建文件夹
-(void)newFolderBtnClicked:(id)sender {
    
    // 首先关闭编辑模式
    [self closeEditStyle];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"新建文件夹" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField){
        textField.placeholder = @"新建文件夹";
        [textField setMarkedText:@"新建文件夹" selectedRange:[self selectedRange:textField]];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
                                                         
                                                     }];
    UIAlertAction *OKAction = [UIAlertAction actionWithTitle:@"确定"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
                                                         if (alertController.textFields.count>0) {
                                                             UITextField *nameTxtField = [alertController.textFields objectAtIndex:0];
                                                             NSString * folderName = nameTxtField.text;
                                                             if (self.parentfolderName) {
                                                                  folderName = [self.parentfolderName  stringByAppendingString:[NSString stringWithFormat:@"/%@",folderName]];
                                                             }
                                                             [self refreshDataArray:folderName];
                                                         }
                                                         
                                                         
                                                     }];
    [alertController addAction:cancelAction];
    [alertController addAction:OKAction];
    [self presentViewController:alertController
                          animated:YES
                        completion:nil];
}


// 获取文本选中区间
-(NSRange)selectedRange:(UITextField *)txtFiled{
    NSInteger location = [txtFiled offsetFromPosition:txtFiled.beginningOfDocument toPosition:txtFiled.selectedTextRange.start];
    NSInteger length = [txtFiled offsetFromPosition:txtFiled.selectedTextRange.start toPosition:txtFiled.selectedTextRange.end];
    return NSMakeRange(location, length);
}


#pragma mark - 创建文件后刷新数据源
-(void)refreshDataArray:(NSString *) folderName{
    
    if (folderName.length>0 && folderName!=nil) {
        BOOL isCreatSuccess = [MFFileManager creatNewFolder:folderName];
        NSLog(@"创建新文件夹是否成功:%d",isCreatSuccess);
        if (isCreatSuccess) {
            [self loadDataArray];
            [self.myTableView reloadData];
            [self showOrHideTitleEditBtns];
        }
    }
    
}

#pragma mark - 刷新显示个数
-(void)refreshShowCount {
    // 刷新显示数据
    self.totalNumLbl.text = [NSString stringWithFormat:@"共%lu条",(unsigned long)[self.dataArray count]];
    [self showSelectedCount];
}

#pragma mark - 隐藏或者显示头部编辑视图
-(void)showOrHideTitleEditBtns {
    
    if (self.dataArray.count <= 0) {
        self.totalNumLbl.hidden = YES;
        self.moveFileBtn.hidden = YES;
        self.deleateAllBtn.hidden = YES;
    }else{
        self.totalNumLbl.hidden = NO;
        self.moveFileBtn.hidden = NO;
        self.deleateAllBtn.hidden = NO;
    }
    self.totalNumLbl.text = [NSString stringWithFormat:@"共%lu条",(unsigned long)[self.dataArray count]];
}


-(void)dealloc{
    NSLog(@"控制器销毁了...")
}


@end

//
//  MFFolderViewController.m
//  MyAudios
//
//  Created by chang on 2018/1/30.
//  Copyright © 2018年 chang. All rights reserved.
//

#import "MFFolderViewController.h"
#import "ArrayDataSource.h"
#import "MFFolder.h"
#import "MFFolderTableViewCell.h"
#import "MFFileManager.h"
#import "MFFileTypeJudgmentUtil.h"
#import "MFStringUtil.h"
#import "CHAudioModel.h"
#import "Notify.h"

static NSString * const FolderCellIdentifier = @"FolderCell";
#define CustomCellHight 56.0

@interface MFFolderViewController ()

@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (nonatomic, strong) ArrayDataSource * foldersArrayDataSource;
@property (nonatomic, strong) NSMutableArray *folders;// 当前页面含有的文件夹数组

@property (weak, nonatomic) IBOutlet UIButton *creatFolderBtn;// 新建文件夹按钮
@property (weak, nonatomic) IBOutlet UIButton *moveFileBtn;// 移动文件按钮

@end

@implementation MFFolderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置 self.view 子视图样式
    [self setupSubViews];
    
    // 初始化数据源
    [self loadDataArray];
    // 设置tableView
    [self setupTableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

// 设置 self.view 子视图样式
- (void)setupSubViews {
    
    self.title = @"移动文件";
    
    // 右上方播放列表按钮
    UIBarButtonItem * rightItem = [[UIBarButtonItem alloc] initWithTitle:@"取 消" style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonClicked:)];
    self.navigationItem.rightBarButtonItem= rightItem;
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
    
    // 删除多余的分割线
    [self.myTableView setTableFooterView:[[UIView alloc]initWithFrame:CGRectZero]];
    self.myTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.myTableView.allowsMultipleSelectionDuringEditing = YES;
    
    // 设置按钮圆角
    self.creatFolderBtn.layer.cornerRadius = 3.0;
    self.creatFolderBtn.layer.masksToBounds = YES;
    self.moveFileBtn.layer.cornerRadius = 3.0;
    self.moveFileBtn.layer.masksToBounds = YES;
}



#pragma mark - 取消模态视图
-(void)cancelButtonClicked:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

// 设置tableView
- (void)setupTableView
{
    TableViewCellConfigureBlock configureCell = ^(MFFolderTableViewCell *cell, MFFolder *folder) {
        [cell configureForFolder:folder];
    };
    NSArray *items = [self.folders copy];
    
    // 对比指针地址
    NSLog(@"items== %p",items);
    NSLog(@"self.folders== %p",self.folders);
    
    self.foldersArrayDataSource = [[ArrayDataSource alloc] initWithItems:items
                                                         cellIdentifier:FolderCellIdentifier
                                                     configureCellBlock:configureCell];
    self.myTableView.dataSource = self.foldersArrayDataSource;
    // 如果使用 registerClass，需要在cell的实现文件中重写initWithStyle并加载自己的nib
    // [self.myTableView registerClass:[MFFolderTableViewCell class] forCellReuseIdentifier:FolderCellIdentifier];
    [self.myTableView registerNib:[UINib nibWithNibName:@"MFFolderTableViewCell" bundle:nil] forCellReuseIdentifier:FolderCellIdentifier];
}


#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MFFolderViewController * folderVC = [[MFFolderViewController alloc] init];
    folderVC.moveItems = self.moveItems;
    MFFolder *folder = [self.folders objectAtIndex:indexPath.row];
    if (![MFStringUtil isEmpty:self.parentfolderName]) {
         folderVC.parentfolderName = [NSString stringWithFormat:@"%@/%@",self.parentfolderName,folder.name];
    }else{
         folderVC.parentfolderName = folder.name;
    }
    [self.navigationController pushViewController:folderVC animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return CustomCellHight;
}

#pragma mark - Custom Methods
#pragma mark - 加载数据源
-(void)loadDataArray {
    
    NSString *parentFolderStr = self.parentfolderName==nil?@"":self.parentfolderName;
    NSMutableArray * filesArr = [MFFileManager readDownloadedFiles:parentFolderStr];
    self.folders = [[NSMutableArray alloc] init];
    
    for (NSString *name in filesArr) {
        NSString * path = name;
        if (![MFStringUtil isEmpty:self.parentfolderName]) {
            path = [NSString stringWithFormat:@"%@/%@",self.parentfolderName,name];
        }
        if ([MFFileTypeJudgmentUtil isFolderType:path]) {
        
            MFFolder *folder = [[MFFolder alloc] init];
            folder.name = name;
            folder.imgName = @"cellThumbnailFolder";
        
            [self.folders addObject:folder];
        }
    }
    
}


#pragma mark 新建文件夹事件
- (IBAction)newFolderBtnClicked:(id)sender {
    
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
                                                                 folderName =    [self.parentfolderName  stringByAppendingString:[NSString stringWithFormat:@"/%@",folderName]];
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

#pragma mark 移动文件事件
- (IBAction)moveBtnClicked:(id)sender {
    
    if (self.moveItems.count<=0) {
        return;
    }
    
    /*
    if ([MFStringUtil isEmpty:self.parentfolderName]) {
        [Notify showAlertDialog:nil messageString:@"请选择不同的文件夹!"];
        return;
    }*/
    
    for (CHAudioModel *audio in self.moveItems) {
        NSString * fromPath = audio.fileName;
        if (![MFStringUtil isEmpty:audio.parentfolderName]) {
            fromPath = [audio.parentfolderName stringByAppendingString:[NSString stringWithFormat:@"/%@",audio.fileName]];
        }
        NSString * toPath = @"";
        if (![MFStringUtil isEmpty:self.parentfolderName]) {
            toPath = [self.parentfolderName stringByAppendingString:[NSString stringWithFormat:@"/%@",audio.fileName]];
        }
        if ([fromPath isEqualToString:toPath]) {
            [Notify showAlertDialog:nil messageString:@"请选择不同的文件夹!"];
            return;
        }
        if ([@"" isEqualToString:toPath]) {// 如果没有选择新文件夹，并不执行移动操作，继续下一个循环
            continue;
        }
        BOOL isSuccess = [MFFileManager moveItemAtPath:fromPath toPath:toPath];
        NSLog(@"移动文件记录: fromPath:%@ toPath:%@ result:%i",fromPath,toPath,isSuccess);
    }

    // 取消当前模态视图
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}


#pragma mark - 关闭tableView编辑模式
-(void)closeEditStyle {
    
    [self.myTableView setEditing:NO animated:YES];
    
}
// 获取文本选中区间
-(NSRange)selectedRange:(UITextField *)txtFiled{
    NSInteger location = [txtFiled offsetFromPosition:txtFiled.beginningOfDocument toPosition:txtFiled.selectedTextRange.start];
    NSInteger length = [txtFiled offsetFromPosition:txtFiled.selectedTextRange.start toPosition:txtFiled.selectedTextRange.end];
    return NSMakeRange(location, length);
}

#pragma mark - 创建文件后刷新数据源
-(void)refreshDataArray:(NSString *) folderName{
    if (folderName.length>0) {
        BOOL isCreatSuccess = [MFFileManager creatNewFolder:folderName];
        NSLog(@"创建新文件夹是否成功:%d",isCreatSuccess);
        if (isCreatSuccess) {
            [self loadDataArray];
            [self setupTableView];
            [self.myTableView reloadData];
            
        }
    }
    
}


@end

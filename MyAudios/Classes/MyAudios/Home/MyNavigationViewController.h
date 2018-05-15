//
//  MyNavigationViewController.h
//  MyNavi
//
//  Created by juuman on 14-1-15.
//  Copyright (c) 2014年 Joeychang.me. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MyNavigationViewController : UIViewController<UINavigationControllerDelegate, UITextFieldDelegate> {

}
@property (nonatomic,strong) NSMutableArray *cancalHttpArr;
@property (nonatomic,strong) UIButton *lButton;
@property (nonatomic,assign) BOOL animating;
@property (nonatomic,assign)BOOL backRootViewController;

@property(nonatomic,strong) UILabel *cutomTitleLbl;// 自定义头部title
@property(nonatomic,strong) UIView *navTitleView;// 自定义titleView

#pragma mark - 返回上一页
- (IBAction)backPrePage:(id)sender;

#pragma mark - 返回首页
- (IBAction)toRootPage:(id)sender;


#pragma mark - 添加返回取消URL
-(void)addCancalHttpArrWithURLString:(NSString*) string andParams:(NSDictionary *)paramDict;

#pragma mark - 取消URL
//-(void)cancalHttp;

@end

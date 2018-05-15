//
//  GoogleDriveViewController.h
//  MyAudios
//
//  Created by chang on 2017/10/25.
//  Copyright © 2017年 chang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Google/SignIn.h>
#import <GTLRDrive.h>

@interface MFGoogleDriveViewController : MyNavigationViewController<GIDSignInDelegate, GIDSignInUIDelegate>

@property (nonatomic, strong) IBOutlet GIDSignInButton *signInButton;
@property (nonatomic, strong) UITextView *output;
@property (nonatomic, strong) GTLRDriveService *service;


@end

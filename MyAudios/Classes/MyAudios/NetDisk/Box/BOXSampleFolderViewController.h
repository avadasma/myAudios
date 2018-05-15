//
//  FolderListingViewController.h
//  BoxContentSDKSampleApp
//
//  Created on 1/6/15.
//  Copyright (c) 2015 Box. All rights reserved.
//

#import <UIKit/UIKit.h>

@import BoxContentSDK;


@interface BOXSampleFolderViewController : MyNavigationViewController



- (instancetype)initWithClient:(BOXContentClient *)client folderID:(NSString *)folderID;

@end

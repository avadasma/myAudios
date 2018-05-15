//
//  Notify.m
//  Spring
//
//  Created by MeMac.cn on 11-7-13.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Notify.h"

@implementation Notify

#pragma mark - 新版弹框提示
+(void)showAlert:(UIViewController *)context titleString:(NSString *)titleString messageString:(NSString *)messageString actionStr:(NSString *)actionTitle{
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:titleString
                                                                             message:messageString
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *OKAction = [UIAlertAction actionWithTitle:actionTitle
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
                                                         [context dismissViewControllerAnimated:YES
                                                                                  completion:nil];
                                                     }];
    [alertController addAction:OKAction];
    [context presentViewController:alertController
                       animated:YES
                     completion:nil];
    
}



+ (void)showAlertDialog:(id)context titleString:(NSString *)titleString messageString:(NSString *)messageString {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *myAlert = [[UIAlertView alloc] initWithTitle:titleString
                                                          message:messageString
                                                         delegate:context
                                                cancelButtonTitle:NSLocalizedStringWithInternational(@"trip_common_util_notify_003", @"确定")
                                                otherButtonTitles:nil];
        [myAlert show];
    });
}

+ (void)showAlertDialog:(id)context messageString:(NSString *)messageString {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *myAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringWithInternational(@"trip_common_util_notify_001", @"提示")
                                                          message:messageString
                                                         delegate:context
                                                cancelButtonTitle:NSLocalizedStringWithInternational(@"trip_common_util_notify_003", @"确定")
                                                otherButtonTitles:nil];
        [myAlert show];
        
    });
}

@end

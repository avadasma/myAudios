//
//  Notify.h
//  Spring
//
//  Created by MeMac.cn on 11-7-13.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Notify : NSObject {

}

#pragma mark - 新版弹框提示
+(void)showAlert:(UIViewController *)context titleString:(NSString *)titleString messageString:(NSString *)messageString actionStr:(NSString *)actionTitle;
+ (void)showAlertDialog:(id)context titleString:(NSString *)titleString messageString:(NSString *)messageString;
#pragma mark -
#pragma mark - xuHui 2011-07-25
+ (void)showAlertDialog:(id)context messageString:(NSString *)messageString;

@end

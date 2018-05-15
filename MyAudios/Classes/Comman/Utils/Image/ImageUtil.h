//
//  ImageUtil.h
//  Spring
//
//  Created by MeMac.cn on 11-6-21.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ImageUtil : NSObject {

}
/*
 * 将指定的图片按比例缩放,
 * image:需要缩放的原始图片
 * scaleSize:一个浮点数,大于1时表示放大,小于1时表示缩小,当小于等于0时表示不改变图片大小,通常使用一位小数,没有测试更多小数的情况,理论上没事
 * 返回对象:UIImage为缩放后的图片对象
 */
+ (UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize;

+ (UIImage *)scaleImage:(UIImage *)image setWidth:(float)width setHeight:(float)height ;

+ (UIImage *)scaleImage:(UIImage *)image toSizeMake:(CGSize)sizeMake ;

//createImageWithColor
+(UIImage *)createImageWithColor:(UIColor *)color;

/*
 *根据图片名称，获取本地路径下面图片
 *使用该方法原因：大图片在使用过一次以后会缓存在内存中，不会释放
 *imageName需要传不带后缀的图片名称
 */
+(UIImage *)getJPGImageFromResource:(NSString *)imageName;

/*
 *注意:imageName需要传不带后缀的图片名称
 */
+(UIImage *)getPNGImageFromResource:(NSString *)imageName;

/*
 *注意:imageName需要传不带后缀的图片名称
 *     type需要传入图片类型
 */
+(UIImage *)getImageFromResource:(NSString *)imageName type:(NSString *)type;

/**
 将view截图成UIImage

 @param fram 要截图的view的大小

 @return uiimage
 */
+ (UIImage *)newImageFromViewWithFrame:(CGSize)frame WithView:(UIView *)view;

/**
 拼接两张UIImage

 @param image1 UIImage
 @param image2 UIImage

 @return UIImage
 */
+ (UIImage *)addImage:(UIImage *)image1 toImage:(UIImage *)image2;

/**
 压缩图片

 @param image 要压缩的图片

 @return 压缩后的data
 */
+ (NSData *)zipImageWithImage:(UIImage *)image;

@end

//
//  ImageUtil.m
//  Spring
//
//  Created by MeMac.cn on 11-6-21.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ImageUtil.h"


@implementation ImageUtil

+ (UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize {
	if(image==nil){
		return nil;
	}
	if(scaleSize<=0){
		scaleSize = 1.0f;
	}
	UIGraphicsBeginImageContext(CGSizeMake(image.size.width * scaleSize, image.size.height * scaleSize));
	[image drawInRect:CGRectMake(0, 0, image.size.width * scaleSize, image.size.height * scaleSize)];
	UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();	
	return scaledImage;	
}

+ (UIImage *)scaleImage:(UIImage *)image setWidth:(float)width setHeight:(float)height {
	if(image==nil){
		return nil;
	}
	if(width<=0){
		width = image.size.width;
	}
	if(height<=0){
		height = image.size.height;
	}
	UIGraphicsBeginImageContext(CGSizeMake(width, height));
	[image drawInRect:CGRectMake(0, 0, width, height)];
	UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return scaledImage;	
}

+ (UIImage *)scaleImage:(UIImage *)image toSizeMake:(CGSize)sizeMake {
	if(image==nil){
		return nil;
	}	
	UIGraphicsBeginImageContext(sizeMake);
	[image drawInRect:CGRectMake(0, 0, sizeMake.width, sizeMake.height)];
	UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();	
	return scaledImage;	
}


+(UIImage *)createImageWithColor:(UIColor *)color{
    CGRect rect=CGRectMake(0.0f, 0.0f, 320.0f, 80.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context=UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage=UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return  theImage;
}

/*
 *根据图片名称，获取本地路径下面图片
 *使用该方法原因：大图片在使用过一次以后会缓存在内存中，不会释放
 *注意:imageName需要传不带后缀的图片名称
 */
+(UIImage *)getJPGImageFromResource:(NSString *)imageName{
    if (imageName == nil) {
        return nil;
    }
    if ([imageName hasSuffix:@".jpg"]) {
        imageName = [imageName substringToIndex:imageName.length - 4];
    }
    NSString *imagePath = [[NSBundle mainBundle]pathForResource:imageName ofType:@"jpg"];
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    return image;
}

/*
 *注意:imageName需要传不带后缀的图片名称
 */
+(UIImage *)getPNGImageFromResource:(NSString *)imageName{
    if ([imageName hasSuffix:@".png"]) {
        imageName = [imageName substringToIndex:imageName.length - 4];
    }
    if ([imageName rangeOfString:@"@3x"].location == NSNotFound && [imageName rangeOfString:@"@2x"].location == NSNotFound) {
        if(mainScreenWidth > 400){
            imageName = [NSString stringWithFormat:@"%@@3x",imageName];
        }else{
            imageName = [NSString stringWithFormat:@"%@@2x",imageName];
        }
    }
    
    NSString *imagePath = [[NSBundle mainBundle]pathForResource:imageName ofType:@"png"];
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    return image;
}

/*
 *注意:imageName需要传不带后缀的图片名称
 *     type需要传入图片类型
 */
+(UIImage *)getImageFromResource:(NSString *)imageName type:(NSString *)type{
    NSString *imagePath = [[NSBundle mainBundle]pathForResource:imageName ofType:type];
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    return image;
}

+ (UIImage *)newImageFromViewWithFrame:(CGSize)frame WithView:(UIView *)view{

  UIGraphicsBeginImageContextWithOptions(CGSizeMake(frame.width, frame.height), NO, 0.0);
  //设置截屏大小
  [[view layer] renderInContext:UIGraphicsGetCurrentContext()];
    
  UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
    return viewImage;
}

+(UIImage *)addImage:(UIImage *)image1 toImage:(UIImage *)image2{
    
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(image1.size.width, image1.size.height + image2.size.height), NO, 0.0);
    
        // Draw image1
        [image1 drawInRect:CGRectMake(0, 0, image1.size.width, image1.size.height)];
    
        // Draw image2
        [image2 drawInRect:CGRectMake((mainScreenWidth - image2.size.width)/2, image1.size.height, image2.size.width, image2.size.height)];
    
        UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return resultingImage;
}

+ (NSData *)zipImageWithImage:(UIImage *)image
{
    if (!image) {
        return nil;
    }
    CGFloat maxFileSize = 32*1024;
    CGFloat compression = 0.9f;
    
    UIImage *img = [[self class]compressImage:image newWidth:image.size.width*compression];
    NSData *compressedData = UIImageJPEGRepresentation(img, compression);
    
    while ([compressedData length] > maxFileSize) {
        compression *= 0.9;
        compressedData = UIImageJPEGRepresentation(img, compression);
    }
    return compressedData;
}

/**
 *  等比缩放本图片大小
 *
 *  @param newImageWidth 缩放后图片宽度，像素为单位
 *
 *  @return self-->(image)
 */
+ (UIImage *)compressImage:(UIImage *)image newWidth:(CGFloat)newImageWidth
{
    if (!image) return nil;
    float imageWidth = image.size.width;
    float imageHeight = image.size.height;
    float width = newImageWidth;
    float height = image.size.height/(image.size.width/width);
    
    float widthScale = imageWidth /width;
    float heightScale = imageHeight /height;
    
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(CGSizeMake(width, height));
    
    if (widthScale > heightScale) {
        [image drawInRect:CGRectMake(0, 0, imageWidth /heightScale , height)];
    }
    else {
        [image drawInRect:CGRectMake(0, 0, width , imageHeight /widthScale)];
    }
    
    // 从当前context中创建一个改变大小后的图片
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    
    return newImage;
    
}
@end

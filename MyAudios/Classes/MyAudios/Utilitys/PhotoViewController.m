//
//  PhotoViewController.m
//  DBRoulette
//
//  Copyright © 2016 Dropbox. All rights reserved.
//

#import <ObjectiveDropboxOfficial/ObjectiveDropboxOfficial.h>
#import "PhotoViewController.h"
#import <EvernoteSDK/EvernoteSDK.h>

@interface PhotoViewController ()<UIScrollViewDelegate>{
    
    float currentScale;// 当前缩放比例
    float maxScale;// 最大缩放比例
    float minScale;// 最小缩放比例
    
}

@property(weak, nonatomic) IBOutlet UIButton *randomPhotoButton;
@property(weak, nonatomic) IBOutlet UIActivityIndicatorView *indicatorView;

@property (weak, nonatomic) IBOutlet UIScrollView *myScrollView;
@property (weak, nonatomic) IBOutlet UIImageView *myImageView;
@property (weak, nonatomic) IBOutlet UIWebView *myWebView;

@property(nonatomic) UIImageView *currentImageView;
@property(nonatomic,strong) UIScrollView *scrollView;// 滚动视图

@end

@implementation PhotoViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    _indicatorView.hidden = YES;
    
    
    self.myScrollView.backgroundColor = [UIColor whiteColor];
    
    float width = self.currentImage.size.width/2.0;
    float height = self.currentImage.size.height/2.0;
    
    self.myScrollView.frame = CGRectMake(0, 0, mainScreenWidth, mainScreenHeight-44.0);
    self.myScrollView.contentSize = CGSizeMake(width, height);
    self.myScrollView.delegate = self;
    maxScale = 4.0;
    minScale = 0.3;
    currentScale = 1.0;
    self.myScrollView.maximumZoomScale = maxScale;
    self.myScrollView.minimumZoomScale = minScale;
    self.myScrollView.zoomScale = 1.0;
    self.myScrollView.showsHorizontalScrollIndicator = YES;
    self.myScrollView.showsVerticalScrollIndicator = YES;
    self.myScrollView.backgroundColor = [UIColor blackColor];
    
    self.myImageView.frame = self.myScrollView.bounds;
    
    [self.myImageView setContentScaleFactor:[[UIScreen mainScreen] scale]];
    // self.myImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    // 图片大于或小于显示区域
    self.myImageView.clipsToBounds  = YES;
    
    // 打开image,重新布局
    [self openImage:self.currentImage];
    
    
    // 双击手势
    UITapGestureRecognizer *doubelGesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleGesture:)];
    doubelGesture.numberOfTapsRequired=2;
    [self.myImageView addGestureRecognizer:doubelGesture];
    self.myImageView.userInteractionEnabled = YES;
    
    // 右上方播放列表按钮
    /*
    UIBarButtonItem * rightItem = [[UIBarButtonItem alloc] initWithTitle:@"分享" style:UIBarButtonItemStylePlain target:self action:@selector(shareButtonClicked:)];
    self.navigationItem.rightBarButtonItem= rightItem;
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
    */
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}


- (void)openImage:(UIImage *)image {
    
    // 重置UIImageView的Frame，让图片居中显示
    self.myImageView.frame = CGRectMake(0, 0, self.myScrollView.frame.size.width, self.myScrollView.frame.size.width * image.size.height/image.size.width);
    //设置scrollView的缩小比例
    CGSize maxSize = self.myScrollView.frame.size;
    CGFloat widthRatio = maxSize.width/self.currentImage.size.width;
    CGFloat heightRatio = maxSize.height/self.currentImage.size.height;
    CGFloat initialZoom = (widthRatio > heightRatio) ? heightRatio : widthRatio;
    self.myScrollView.minimumZoomScale = initialZoom;
    
    self.myImageView.image = self.currentImage;
    [self.myScrollView setZoomScale:currentScale animated:YES];
    [self scrollViewDidZoom:self.myScrollView];
}

// 设置UIScrollView中要缩放的视图
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.myImageView;
}

// 让UIImageView在UIScrollView缩放后居中显示
- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    self.myImageView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                          scrollView.contentSize.height * 0.5 + offsetY);// 44.0为底部状态栏高度,34.0为微调
}

-(void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    currentScale=scale;
}

#pragma mark -DoubleGesture Action
-(void)doubleGesture:(UIGestureRecognizer *)sender
{
    
    if (currentScale==0){
        currentScale = maxScale;
        [self.myScrollView setZoomScale:currentScale animated:YES];
        return;
    }
    
    // 当前倍数等于最大放大倍数
    // 双击默认为缩小到原图
    if (currentScale==maxScale) {
        currentScale=minScale;
        [self.myScrollView setZoomScale:currentScale animated:YES];
        return;
    }
    //当前等于最小放大倍数
    //双击默认为放大到最大倍数
    if (currentScale==minScale) {
        currentScale=maxScale/2;
        [self.myScrollView setZoomScale:currentScale animated:YES];
        return;
    }
    
    CGFloat aveScale =minScale+(maxScale-minScale)/2.0;//中间倍数
    
    //当前倍数大于平均倍数
    // 双击默认为放大最大倍数
    if (currentScale>=aveScale) {
        currentScale=maxScale;
        [self.myScrollView setZoomScale:currentScale animated:YES];
        return;
    }
    
    // 当前倍数小于平均倍数
    // 双击默认为放大到最小倍数
    if (currentScale<aveScale) {
        currentScale=minScale;
        [self.myScrollView setZoomScale:currentScale animated:YES];
        return;
    }
    // 居中布局
    [self scrollViewDidZoom:self.myScrollView];
}

#pragma mark- Custom methods 
-(void)shareButtonClicked:(id)sender {

    [[ENSession sharedSession] authenticateWithViewController:self preferRegistration:NO completion:^(NSError *authenticateError) {
        
        NSLog(@"印象笔记认证");
        ENNote * note = [[ENNote alloc] init];
        note.content = [ENNoteContent noteContentWithString:@"Check out this awesome picture!"];
        note.title = @"My Image Note";
        ENResource * resource = [[ENResource alloc] initWithImage:self.currentImage];
        [note addResource:resource];
        [[ENSession sharedSession] uploadNote:note notebook:nil completion:^(ENNoteRef * noteRef, NSError * uploadNoteError) {
            
            NSLog(@"上传完毕");
            
        }];
    }];
    
    
   
}


#pragma mark - 改变图片大小
-(UIImage *)resizeImage:(UIImage *)sourceImage newWidth:(CGFloat)newWidth {
    
    CGFloat targetWidth = newWidth;
    float scale = newWidth/sourceImage.size.width;
    CGFloat targetHeight = scale*sourceImage.size.height;
    
    CGImageRef imageRef = [sourceImage CGImage];
    CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
    CGColorSpaceRef colorSpaceInfo = CGImageGetColorSpace(imageRef);
    
    if (bitmapInfo == kCGImageAlphaNone) {
        // bitmapInfo = kCGImageAlphaNoneSkipLast;
    }
    
    CGContextRef bitmap;
    
    if (sourceImage.imageOrientation == UIImageOrientationUp || sourceImage.imageOrientation == UIImageOrientationDown) {
        bitmap = CGBitmapContextCreate(NULL, targetWidth, targetHeight, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo, bitmapInfo);
        
    } else {
        bitmap = CGBitmapContextCreate(NULL, targetHeight, targetWidth, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo, bitmapInfo);
        
    }
    
    if (sourceImage.imageOrientation == UIImageOrientationLeft) {
        CGContextRotateCTM (bitmap, M_PI_2); // + 90 degrees
        CGContextTranslateCTM (bitmap, 0, -targetHeight);
        
    } else if (sourceImage.imageOrientation == UIImageOrientationRight) {
        CGContextRotateCTM (bitmap, -M_PI_2); // - 90 degrees
        CGContextTranslateCTM (bitmap, -targetWidth, 0);
        
    } else if (sourceImage.imageOrientation == UIImageOrientationUp) {
        // NOTHING
    } else if (sourceImage.imageOrientation == UIImageOrientationDown) {
        CGContextTranslateCTM (bitmap, targetWidth, targetHeight);
        CGContextRotateCTM (bitmap, -M_PI); // - 180 degrees
    }
    
    CGContextDrawImage(bitmap, CGRectMake(0, 0, targetWidth, targetHeight), imageRef);
    CGImageRef ref = CGBitmapContextCreateImage(bitmap);
    UIImage* newImage = [UIImage imageWithCGImage:ref];
    
    CGContextRelease(bitmap);
    CGImageRelease(ref);
    
    return newImage;

}





- (IBAction)randomPhotoButtonPressed:(id)sender {
  [self setStarted];
  
  if (_currentImageView) {
    [_currentImageView removeFromSuperview];
  }

  DBUserClient *client = [DBClientsManager authorizedClient];

  NSString *searchPath = @"";

  // list folder metadata contents (folder will be root "/" Dropbox folder if app has permission
  // "Full Dropbox" or "/Apps/<APP_NAME>/" if app has permission "App Folder").
  [[client.filesRoutes listFolder:searchPath]
      setResponseBlock:^(DBFILESListFolderResult *result, DBFILESListFolderError *routeError, DBRequestError *error) {
        if (result) {
          [self displayPhotos:result.entries];
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
    [self downloadImage:imagePathToDownload];
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

- (BOOL)isImageType:(NSString *)itemName {
  NSRange range = [itemName rangeOfString:@"\\.jpeg|\\.jpg|\\.JPEG|\\.JPG|\\.png" options:NSRegularExpressionSearch];
  return range.location != NSNotFound;
}

- (void)downloadImage:(NSString *)imagePath {
  DBUserClient *client = [DBClientsManager authorizedClient];
  [[client.filesRoutes downloadData:imagePath]
      setResponseBlock:^(DBFILESFileMetadata *result, DBFILESDownloadError *routeError, DBRequestError *error, NSData *fileData) {
        if (result) {
          UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageWithData:fileData]];
          // imageView.frame = CGRectMake(100, 100, 300, 300);
          imageView.frame = CGRectMake(0, 0, mainScreenWidth, mainScreenHeight);
          [imageView setCenter:CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2)];
          _currentImageView = imageView;
          [self setFinished];
        } else {
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
      }];
}

- (void)setStarted {
  [_indicatorView startAnimating];
  _indicatorView.hidden = NO;
}

- (void)setFinished {
  [_indicatorView stopAnimating];
  _indicatorView.hidden = YES;
}


- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

@end

//
//  ViewController.m
//  DQSample
//
//  Created by weichao on 16/4/23.
//  Copyright © 2016年 FatGragon. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self getDQData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getDQData {
    UIImage *saxs1Image = [UIImage imageNamed:@"saxs-1.jpg"];
    UIImage *saxs2Image = [UIImage imageNamed:@"saxs-2.jpg"];
    UIImage *saxs3Image = [UIImage imageNamed:@"saxs-3.jpg"];
    UIImage *saxs4Image = [UIImage imageNamed:@"saxs-4.jpg"];
    NSLog(@"saxs-1.jpg");
    NSString *content1 = [self obtaintPixelColorWithImage:saxs1Image];
    [self saveFile:@"saxs-1Color.txt" content:content1];
    NSLog(@"saxs-2.jpg");
    NSString *content2 = [self obtaintPixelColorWithImage:saxs2Image];
    [self saveFile:@"saxs-2Color.txt" content:content2];
    NSLog(@"saxs-3.jpg");
    NSString *content3 = [self obtaintPixelColorWithImage:saxs3Image];
    [self saveFile:@"saxs-3Color.txt" content:content3];
    NSLog(@"saxs-4.jpg");
    NSString *content4 = [self obtaintPixelColorWithImage:saxs4Image];
    [self saveFile:@"saxs-4Color.txt" content:content4];
}

- (NSString *)obtaintPixelColorWithImage:(UIImage *)inImage {
    NSMutableString *content = [[NSMutableString alloc] init];
    size_t wMax = CGImageGetWidth(inImage.CGImage);
    size_t hMax = CGImageGetHeight(inImage.CGImage);

    CGImageRef inCGImage = inImage.CGImage;
    // Create off screen bitmap context to draw the image into. Format ARGB is 4 bytes for each pixel: Alpa, Red, Green, Blue
    CGContextRef cgctx = [self createARGBBitmapContextFromImage:inCGImage];
    if (cgctx == NULL) { return nil; /* error */ }
    
    size_t w = CGImageGetWidth(inCGImage);
    size_t h = CGImageGetHeight(inCGImage);
    CGRect rect = {{0,0},{w,h}};
    
    // Draw the image to the bitmap context. Once we draw, the memory
    // allocated for the context for rendering will then contain the
    // raw image data in the specified color space.
    CGContextDrawImage(cgctx, rect, inCGImage);
    
    // Now we can get a pointer to the image data associated with the bitmap
    // context.
    unsigned char* data = CGBitmapContextGetData (cgctx);
    if (data != NULL) {
        for (CGFloat x = 0; x < wMax; x++) {
            for (CGFloat y = 0; y < hMax; y ++) {
                CGPoint point= CGPointMake(x, y);
                //offset locates the pixel in the data from x,y.
                //4 for 4 bytes of data per pixel, w is width of one row of data.
                int offset = 4*((w*round(point.y))+round(point.x));     // 4 base
                int alpha =  data[offset];
                int red = data[offset+1];
                int green = data[offset+2];
                int blue = data[offset+3];
                if(red!=255 && green!=255 && blue!=255){
                    [content appendFormat:@"x:%f;y:%f;colors: RGB A %i %i %i  %i\n",x,y,red,green,blue,alpha];
                }
            }
            NSLog(@"%f",x);
        }
//        color = [UIColor colorWithRed:(red/255.0f) green:(green/255.0f) blue:(blue/255.0f) alpha:(alpha/255.0f)];
    }
    
    // When finished, release the context
    CGContextRelease(cgctx);
    // Free image data memory for the context
    if (data) { free(data); }
    
    return content;
}

- (CGContextRef)createARGBBitmapContextFromImage:(CGImageRef)inCGImage {
    
    CGContextRef    context = NULL;
    CGColorSpaceRef colorSpace;
    void *          bitmapData;
    unsigned long int             bitmapByteCount;
    unsigned long int             bitmapBytesPerRow;
    
    // Get image width, height. We'll use the entire image.
    size_t pixelsWide = CGImageGetWidth(inCGImage);
    size_t pixelsHigh = CGImageGetHeight(inCGImage);
    
    // Declare the number of bytes per row. Each pixel in the bitmap in this
    // example is represented by 4 bytes; 8 bits each of red, green, blue, and
    // alpha.
    bitmapBytesPerRow   = (pixelsWide * 4);
    bitmapByteCount     = (bitmapBytesPerRow * pixelsHigh);
    
    // Use the generic RGB color space.
    colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
    if (colorSpace == NULL)
    {
        fprintf(stderr, "Error allocating color space\n");
        return NULL;
    }
    
    // Allocate memory for image data. This is the destination in memory
    // where any drawing to the bitmap context will be rendered.
    bitmapData = malloc( bitmapByteCount );
    if (bitmapData == NULL)
    {
        fprintf (stderr, "Memory not allocated!");
        CGColorSpaceRelease( colorSpace );
        return NULL;
    }
    
    // Create the bitmap context. We want pre-multiplied ARGB, 8-bits
    // per component. Regardless of what the source image format is
    // (CMYK, Grayscale, and so on) it will be converted over to the format
    // specified here by CGBitmapContextCreate.
    context = CGBitmapContextCreate (bitmapData,
                                     pixelsWide,
                                     pixelsHigh,
                                     8,      // bits per component
                                     bitmapBytesPerRow,
                                     colorSpace,
                                     kCGImageAlphaPremultipliedFirst);
    if (context == NULL)
    {
        free (bitmapData);
        fprintf (stderr, "Context not created!");
    }
    
    // Make sure and release colorspace before returning
    CGColorSpaceRelease( colorSpace );
    
    return context;
}

- (void)saveFile:(NSString *)fileName content:(NSString *)content {
    NSString *sandboxPath = NSHomeDirectory();
    NSString *documentPath = [sandboxPath stringByAppendingPathComponent:@"Documents"];
    NSString *filePath=[documentPath stringByAppendingPathComponent:fileName];
    [content writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

@end

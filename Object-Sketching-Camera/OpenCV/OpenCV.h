//
//  OpenCV.h
//  Object-Sketching-Camera
//
//  Created by jiahaol on 7/27/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface OpenCV : NSObject

+ (UIImage *)cvtColorBGR2GRAY:(UIImage *)image;

+ (void) getColorPosition:(UIImage **)image r:(int)r g:(int)g b:(int)b x:(int *)x y:(int *)y size:(int *)size;

+ (void) getMarkersPositions:(UIImage **)image num:(int *)num x:(int *)x y:(int *)y;

@end

NS_ASSUME_NONNULL_END

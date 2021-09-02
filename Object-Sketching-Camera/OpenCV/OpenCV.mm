//
//  OpenCV.mm
//  Object-Sketching-Camera
//
//  Created by jiahaol on 7/27/21.
//
#import <opencv2/opencv.hpp>
#import <opencv2/core.hpp>
#import <opencv2/imgproc.hpp>
#import <opencv2/imgcodecs/ios.h>


#import "OpenCV.h"

@implementation OpenCV
using namespace cv;
using namespace std;

+ (UIImage *)cvtColorBGR2GRAY:(UIImage *)image {
    Mat mat;
    UIImageToMat(image, mat);
    
    Mat gray;
    cvtColor(mat, gray, COLOR_BGR2GRAY);
    
    cvtColor(gray, gray, COLOR_RGB2BGR);
    UIImage *resultImage = MatToUIImage(gray);
    return resultImage;
}

+ (void) getColorPosition:(UIImage **)image r:(int)r g:(int)g b:(int)b x:(int *)x y:(int *)y size:(int *)size {
    Mat src;
    UIImageToMat(*image, src);
    cvtColor(src, src, COLOR_RGB2BGR);
    
    Mat mask;
    Mat dst;
    
    Scalar lower = Scalar(b-20, g-20, r-20, 0);
    Scalar upper = Scalar(b+20, g+20, r+20, 255);
    
    inRange(src, lower, upper, mask);
    bitwise_and(src, src, dst, mask=mask);
    
    vector<vector<cv::Point>> contours;
    vector<Vec4i> hierarchy;
    vector<cv::Point> maxContourPoly;
    cv::Rect rect;
    cv::Point2f center;
    float radius;
    
    findContours(mask, contours, hierarchy, RETR_TREE, CHAIN_APPROX_SIMPLE);

    vector<vector<cv::Point>> contoursPoly(contours.size());
    Mat res = src;
    
    if (contours.size() > 0) {
        int maxId = 0;
        vector<cv::Point> maxContour = contours[0];
        for (int i = 0; i < contours.size(); i++) {
            cv::approxPolyDP(contours[i], contoursPoly[i], 3, true);
            if (contourArea(maxContour) < contourArea(contours[i])) {
                maxContour = contours[i];
                maxId = i;
            }
        }
        
        cv::approxPolyDP(maxContour, maxContourPoly, 3, true);
        rect = cv::boundingRect(maxContourPoly);
        cv::minEnclosingCircle(maxContourPoly, center, radius);
        
        Moments mu = moments(maxContour, false);
        *x = int(mu.m10/mu.m00);
        *y = int(mu.m01/mu.m00);
        *size = int(radius);
        
        cv::Scalar color = cv::Scalar(255, 255, 255);
        cv::drawContours(res, contoursPoly, maxId, color, 10);
    }
    
//    cvtColor(dst, dst, COLOR_BGR2RGB);
//    UIImage *resultImage = MatToUIImage(dst);
    cvtColor(res, res, COLOR_BGR2RGB);
    UIImage *resultImage = MatToUIImage(res);

    *image = resultImage;
}

+ (void) getMarkersPositions:(UIImage **)image num:(int *)num x:(int *)x y:(int *)y{
    Mat src;
    UIImageToMat(*image, src);
    cv::resize(src, src, cv::Size(1366, 1024));
    cv::cvtColor(src, src, COLOR_RGB2BGR);
//    cvtColor(src, src, COLOR_BGR2HSV);
    
    Mat mask;
    Mat dst;
    
    Scalar lower = Scalar(0, 160, 0, 0);
    Scalar upper = Scalar(140, 255, 180, 255);
    
    inRange(src, lower, upper, mask);
    bitwise_and(src, src, dst, mask=mask);
    blur(mask, mask, cv::Size(10, 10));
    cv::threshold(mask, mask, 120, 255, THRESH_BINARY);
    
    vector<vector<cv::Point>> contours;
    vector<Vec4i> hierarchy;
    vector<cv::Point> maxContourPoly;
    cv::Point2f center;
    float radius;
    
    findContours(mask, contours, hierarchy, RETR_TREE, CHAIN_APPROX_SIMPLE);
    
    vector<vector<cv::Point>> contoursValid(0);
    
    if (contours.size() > 0) {
        for (int i = 0; i < contours.size(); i++) {
            if (contourArea(contours[i]) > 60) {
                contoursValid.push_back(contours[i]);
            }
        }
//        cout << "valid number" << contoursValid.size() << endl;
        
        vector<vector<cv::Point>> contoursValidPoly(contoursValid.size());
        
        for (int i = 0; i < contoursValid.size(); i++) {
            cv::approxPolyDP(contoursValid[i], contoursValidPoly[i], 3, true);
            cv::minEnclosingCircle(contoursValidPoly[i], center, radius);
            
            Moments mu = moments(contoursValid[i]);
            int xx = int(mu.m10/mu.m00);
            int yy = int(mu.m01/mu.m00);
            
            x[i] = xx;
            y[i] = yy;
        }
    }
    
    
    
    *num = contoursValid.size();
    
    
    
}


@end

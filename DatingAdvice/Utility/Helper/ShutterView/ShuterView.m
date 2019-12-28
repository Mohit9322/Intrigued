//
//  ShuterView.m
//  tuurnt
//
//  Created by micheladrion on 9/18/15.
//  Copyright (c) 2015 fabricemishiki. All rights reserved.
//

#import "ShuterView.h"

#define PI 3.14159265358979323846

#define CAPTURING_IMAGE_TIME 0.3f
#define PROGRESS_WIDTH 4.5f

@implementation ShuterView{

    NSDate *startShuttingTime;
    NSDate *currentShuttingTime;
    NSTimer *timer;
    
    BOOL is_recording;
    int mode_transaction;

}

static inline float radians(double degrees) { return degrees * PI / 180; }

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    
    self.shuttingLength = 20.0f;
    
    is_recording = false;
    mode_transaction = 0;
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self startRecord];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSTimeInterval shuttingLength = [self getCurrentShuttingLength];
    if(shuttingLength < CAPTURING_IMAGE_TIME)
    {
        [self cancelRecord];
    }
    else
    {
        [self endRecord];
    }
    
    mode_transaction = 0;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
//    UITouch *aTouch = [touches anyObject];
//    CGPoint point = [aTouch locationInView:self];
//    // point.x and point.y have the coordinates of the touch
//    NSLog(@"%lf %lf", point.x, point.y);
//    
//    UIView *view = self;
//    NSLog(@"%lf %lf",view.frame.size.width,view.frame.size.height);
    
//    float viewWidth = view.frame.size.width;
//    float pointX = point.x;
    
//    if ((fabsf(view.frame.size.width) < fabsf(point.x)) || (fabsf(view.frame.size.width) < fabsf(point.y))) {
//        NSLog(@"Sumit - touches Cancelled");
//        return;
//    }

//    if (((int)(view.frame.size.width) < (int)(point.x)) || ((int)(view.frame.size.width) < (int)(point.y))) {
//        NSLog(@"Sumit - touches Cancelled");
//        return;
//    }

//    if ((int)(view.frame.size.width) <= (int)(point.x)) {
//        NSLog(@"Sumit - touches Cancelled condition true");
//     }
//    else {
//        NSLog(@"Sumit - touches Cancelled");
//        return;
//    }
    [self cancelRecord];
    mode_transaction = 0;
 }

- (NSTimeInterval) getCurrentShuttingLength
{
    if(startShuttingTime == nil || currentShuttingTime == nil) return 0;
    
    return [currentShuttingTime timeIntervalSinceDate:startShuttingTime];
}

- (double) getCurrentProgress
{
    NSTimeInterval shuttingLength = [self getCurrentShuttingLength] - CAPTURING_IMAGE_TIME;
    if(shuttingLength < 0) shuttingLength = 0;
    
    float alpha = -90 + 360 * shuttingLength / (self.shuttingLength  - CAPTURING_IMAGE_TIME) ;
    
    return alpha;
}

- (BOOL) isExpiredShutting
{
    NSTimeInterval shuttingLength = [self getCurrentShuttingLength] - 0.25f;
    
    return shuttingLength > self.shuttingLength;
}

- (BOOL) isRecordingVideo
{
    double progressAlpha = [self getCurrentProgress];
    
    return progressAlpha > -90;
}

- (void) updateShutter
{
    if(self.shuttingLength < 1) return ;
    
    NSDate *fireDate = timer.fireDate;
    if(startShuttingTime == nil)
    {
        startShuttingTime = fireDate;
    }
    currentShuttingTime = fireDate;
    
    if([self isExpiredShutting])
    {
        [self endRecord];
    }
    
    [self setNeedsDisplay];
}

- (void)startRecord{
    
    mode_transaction = 1;
    
    [self initialize];
    
    if ( timer ) {
        [timer invalidate];
    }
    
    timer = [NSTimer scheduledTimerWithTimeInterval:0.01f target:self selector:@selector(updateShutter) userInfo:nil repeats:YES];
}

- (void)cancelRecord{
    if ( [self isRecordingVideo] ) {
        is_recording = false;
        mode_transaction = 2;
        [self.delegate stopRecordingVideo];
        [self recordVideo];
    }else{
        if (mode_transaction == 1 ) {
            [self captureImage ];
        }
    }
    [self initialize];
    
}

- (void)endRecord{
    if ( [self isRecordingVideo] ) {
        is_recording = false;
        mode_transaction = 2;
        [self.delegate stopRecordingVideo];
        [self recordVideo];
    }else{
        if (mode_transaction == 1 ) {
            [self captureImage ];
        }
    }
    [self initialize];
}

- (void)captureImage{
    [self.delegate captureImage];
}

- (void)recordVideo{
    [self.delegate captureVideo];
    
}

- (void) initialize
{
    startShuttingTime = nil;
    currentShuttingTime = nil;
    
    if(timer != nil)
    {
        [timer invalidate];
    }
    timer = nil;
    
    [self setNeedsDisplay];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    
    CGRect bounds = self.bounds;
    CGFloat x = CGRectGetWidth(bounds) / 2;
    CGFloat y = CGRectGetHeight(bounds) / 2;
    
    CGPoint center = CGPointMake(x, y);
    
    // Get the graphics context and clear it
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextClearRect(ctx, rect);
    
    if ( [self isRecordingVideo] ) {
        if (!is_recording) {
            is_recording = true;
            mode_transaction = 2;
            [self.delegate startRecordingVideo];
        }
        [self drawRecordingStateButton:ctx center:center];
    }else{
        [self drawDefaultStateButton:ctx center:center];
    }
    
}

- (float) getShutterRadius
{
    return self.bounds.size.width/2.0f;
}


- (void) drawBackground:(CGContextRef)ctx center:(CGPoint)center
{
    //float innerRadius = [self getShutterRadius];
    float innerRadius = 34.0f;
    
    CGContextSetRGBFillColor(ctx, 0.0f, 0.0f, 0.0f, 0.26f);
    CGContextMoveToPoint(ctx, center.x, center.y);
    CGContextAddArc(ctx, center.x, center.y, innerRadius,  radians(0), radians(360), 0);
    CGContextClosePath(ctx);
    CGContextFillPath(ctx);
}

- (void) drawDefaultStateButton:(CGContextRef)ctx center:(CGPoint)center
{
    [self drawBackground:ctx center:center];
    [self drawMediumBackgroundForDefault:ctx center:center];
    [self drawCenterBackgroundForDefaultState:ctx center:center];
}

- (void) drawMediumBackgroundForDefault:(CGContextRef)ctx center:(CGPoint)center
{
    float innerRadius = [self getShutterRadius] - 17.0f; //sumit 24 Nov. earlier -17
    
    
    CGContextSetRGBFillColor(ctx, 255.f/255.f, 255.f/255.f, 255.f/255.f, 1.0f);
    CGContextMoveToPoint(ctx, center.x, center.y);
    CGContextAddArc(ctx, center.x, center.y, innerRadius,  radians(0), radians(360), 0);
    CGContextClosePath(ctx);
    CGContextFillPath(ctx);
}

- (void) drawCenterBackgroundForDefaultState:(CGContextRef)ctx center:(CGPoint)center
{
    float innerRadius = 8.0f; //sumit 24 Nov. 8.0f
    
    CGContextSetRGBFillColor(ctx, 68.f/255.f, 127.f/255.f, 193.f/255.f, 1.0f);//ravi 01Jun
    //CGContextSetRGBFillColor(ctx, 237.0f/255.f, 28.0f/255.f, 50.0f/255.f, 1.0f);
    CGContextMoveToPoint(ctx, center.x, center.y);
    CGContextAddArc(ctx, center.x, center.y, innerRadius,  radians(0), radians(360), 0);
    CGContextClosePath(ctx);
    CGContextFillPath(ctx);
}

- (void) drawRecordingStateButton:(CGContextRef)ctx center:(CGPoint)center
{
    
    [self drawMediumBackgroundForRecording:ctx center:center];
    [self drawCenterBackgroundForRecording:ctx center:center];
    
    [self drawProgressBackground:ctx center:center];
    [self drawProgress:ctx center:center];
}

- (void) drawMediumBackgroundForRecording:(CGContextRef)ctx center:(CGPoint)center
{
    float innerRadius = 24.0f;
    
    CGContextSetRGBFillColor(ctx, 68.f/255.f, 127.f/255.f, 193.f/255.f, 1.0f);//ravi 01Jun
   // CGContextSetRGBFillColor(ctx, 227.f/255.f, 27.f/255.f, 45.f/255.f, 1.0f);
    CGContextMoveToPoint(ctx, center.x, center.y);
    CGContextAddArc(ctx, center.x, center.y, innerRadius,  radians(0), radians(360), 0);
    CGContextClosePath(ctx);
    CGContextFillPath(ctx);
}

- (void) drawCenterBackgroundForRecording:(CGContextRef)ctx center:(CGPoint)center
{
    float innerRadius = 20.0f;
    
    CGContextSetRGBFillColor(ctx, 68.f/255.f, 127.f/255.f, 193.f/255.f, 1.0f);//ravi 01Jun
    //CGContextSetRGBFillColor(ctx, 182.f/255.f, 19.f/255.f, 12.f/255.f, 1.0f);
    CGContextMoveToPoint(ctx, center.x, center.y);
    CGContextAddArc(ctx, center.x, center.y, innerRadius,  radians(0), radians(360), 0);
    CGContextClosePath(ctx);
    CGContextFillPath(ctx);
}

- (void) drawProgressBackground:(CGContextRef)ctx center:(CGPoint)center
{
    CGContextSetRGBStrokeColor(ctx, 255/255.f, 255/255.f, 255/255.f, 0.36f);
    CGContextSetLineWidth(ctx, PROGRESS_WIDTH);
    
    float shutterRadius = [self getShutterRadius];
    float borderRadius = shutterRadius - PROGRESS_WIDTH;
    
    CGContextAddArc(ctx, center.x, center.y, borderRadius,  radians(0), 360.f, 0);
    CGContextDrawPath(ctx, kCGPathStroke);
}

- (void) drawProgress:(CGContextRef)ctx center:(CGPoint)center
{

    CGContextSetRGBStrokeColor(ctx, 221.f/255.f, 32.f/255.f, 44.f/255.f, 1.0f);//ravi 01Jun
    CGContextSetLineWidth(ctx, PROGRESS_WIDTH);
    
    float shutterRadius = [self getShutterRadius];
    float borderRadius = shutterRadius - PROGRESS_WIDTH;
    
    double alpha = [self getCurrentProgress];
    
    CGContextAddArc(ctx, center.x, center.y, borderRadius,  radians(- 90), radians(alpha), 0);
    CGContextDrawPath(ctx, kCGPathStroke);
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    gestureRecognizer.cancelsTouchesInView = NO; //ravi 20Dec
    return NO;
}

@end

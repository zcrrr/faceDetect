//
//  CanvasView.m
//  Created by sluin on 15/7/1.
//  Copyright (c) 2015年 SunLin. All rights reserved.
//

#import "CanvasView.h"
#import <math.h>
#define radians(degrees) (degrees * M_PI/180)
@interface CanvasView()
@property (strong, nonatomic) CALayer *bgLayer;

@property (strong, nonatomic) CALayer *glassesLayer;
@property (strong, nonatomic) CALayer *hairLayer;
@end

@implementation CanvasView
{
    CGContextRef context ;
}
int startIndex = 0;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.bgLayer = [[CALayer alloc]init];
        self.bgLayer.position = CGPointMake(235, 579);
        self.bgLayer.bounds = CGRectMake(0, 0, 220, 114);
        UIImage *imagebg = [UIImage imageNamed:@"title.png"];
        self.bgLayer.contents = (__bridge id _Nullable)([imagebg CGImage]);
        [self.layer addSublayer:self.bgLayer];
        
        
        NSDictionary *actions = @{@"bounds":[NSNull null],@"position":[NSNull null],@"transform":[NSNull null]};
        self.glassesLayer = [[CALayer alloc]init];
        self.glassesLayer.position = CGPointZero;
        self.glassesLayer.bounds = CGRectMake(0, 0, 295, 90);
        UIImage *imageEye = [UIImage imageNamed:@"eye.png"];
        self.glassesLayer.contents = (__bridge id _Nullable)([imageEye CGImage]);
        [self.layer addSublayer:self.glassesLayer];
        self.glassesLayer.actions = actions;
        
        self.hairLayer = [[CALayer alloc]init];
        self.hairLayer.position = CGPointZero;
        self.hairLayer.bounds = CGRectMake(0, 0, 525, 459);
        UIImage *imageHair = [UIImage imageNamed:@"hair.png"];
        self.hairLayer.contents = (__bridge id _Nullable)([imageHair CGImage]);
        [self.layer addSublayer:self.hairLayer];
        self.hairLayer.actions = actions;
    }
    return self;
}
- (void)drawRect:(CGRect)rect {
    [self drawPointWithPoints:self.arrPersons] ;
}

-(void)drawPointWithPoints:(NSArray *)arrPersons
{
    if (context) {
        CGContextClearRect(context, self.bounds) ;
    }
    context = UIGraphicsGetCurrentContext();
    
    
    for (NSDictionary *dicPerson in self.arrPersons) {
//        if ([dicPerson objectForKey:POINTS_KEY]) {
//            for (NSString *strPoints in [dicPerson objectForKey:POINTS_KEY]) {
//                CGPoint p = CGPointFromString(strPoints) ;
//                CGContextAddEllipseInRect(context, CGRectMake(p.x - 1 , p.y - 1 , 2 , 2));
//            }
//        }
//        if ([dicPerson objectForKey:RECT_KEY]) {
//            CGContextAddRect(context, CGRectFromString([dicPerson objectForKey:RECT_KEY])) ;
//        }
        int roll = [[dicPerson objectForKey:@"roll"]intValue];
        if(roll < 0){
            roll = roll + 90;
        }else if(roll ){
            roll = roll - 90;
        }
        CGPoint point0 = CGPointFromString([dicPerson objectForKey:POINTS_KEY][0]);
        CGPoint point32 = CGPointFromString([dicPerson objectForKey:POINTS_KEY][32]);
        CGPoint point55 = CGPointFromString([dicPerson objectForKey:POINTS_KEY][55]);
        CGPoint point58 = CGPointFromString([dicPerson objectForKey:POINTS_KEY][58]);
        CGPoint point67 = CGPointFromString([dicPerson objectForKey:POINTS_KEY][67]);
        CGPoint point68 = CGPointFromString([dicPerson objectForKey:POINTS_KEY][68]);
        float x1 = point0.x;
        float y1 = point0.y;
        float x2 = point32.x;
        float y2 = point32.y;
        float distance = sqrtf((x1-x2)*(x1-x2)+(y1-y2)*(y1-y2));
        float scale = distance / 285.0;
//        NSLog(@"scale is %f",scale);
//        NSLog(@"distance is %f",distance);
        float width_eye = 295.0*scale;
        float height_eye = 90.0 * scale;
        float centerx_eye = (point55.x + point58.x)/2 - (-24) * sinf(radians(roll)) * scale;
        float centery_eye = (point55.y + point58.y)/2 +  (-24) * cosf(radians(roll)) * scale;
        
        float width_hair = 525.0*scale;
        float height_hair = 459.0 * scale;
        float centerx_hair = (point67.x + point68.x)/2 - (-180) * sinf(radians(roll)) * scale;
        float centery_hair = (point67.y + point68.y)/2 + (-180) * cosf(radians(roll)) * scale;
        NSLog(@"roll:%i",roll);
        NSLog(@"ox:%f",(point67.x + point68.x)/2);
        NSLog(@"oy:%f",(point67.y + point68.y)/2);
        NSLog(@"centerx_hair:%f",centerx_hair);
        NSLog(@"centery_hair:%f",centery_hair);
//        NSLog(@"centerx,y:%f,%f",centerx_hair,centery_hair);
//        NSString *imgkey = [NSString stringWithFormat:@"eyes_big_%03d",startIndex];
//        NSDictionary *imginfo = [self.imgDic objectForKey:imgkey];
//        float imgx = [[imginfo objectForKey:@"x"]floatValue];
//        float imgy = [[imginfo objectForKey:@"y"]floatValue];
//        float imgw = [[imginfo objectForKey:@"w"]floatValue];
//        float imgh = [[imginfo objectForKey:@"h"]floatValue];
//        CGRect rectimg = CGRectMake(imgx, imgy, imgw, imgh);
//        CGRect rect1 = CGRectMake(originx, originy, width, height);
        
//        CGImageRef imageRef = CGImageCreateWithImageInRect([self.bgimage CGImage], rectimg);
//        drawFollowImage(context, imageRef,rect1,roll);
        
        
        self.glassesLayer.position = CGPointMake(centerx_eye, centery_eye);
        self.glassesLayer.bounds = CGRectMake(0, 0, width_eye, height_eye);
        self.glassesLayer.transform = CATransform3DMakeRotation(radians(roll), 0, 0, 1);
        
        self.hairLayer.position = CGPointMake(centerx_hair, centery_hair);
        self.hairLayer.bounds = CGRectMake(0, 0, width_hair, height_hair);
        self.hairLayer.transform = CATransform3DMakeRotation(radians(roll), 0, 0, 1);
//        self.glassesLayer.contents = (__bridge id)imageRef;
        
        
        
        
        
        
//        CGImageRelease(imageRef);
    }

    [[UIColor greenColor] set];
    CGContextSetLineWidth(context, 2);
    CGContextStrokePath(context);
    startIndex++;
    if(startIndex == 39){
        startIndex = 0;
    }
//    UIImage *bgImage = [UIImage imageNamed:[NSString stringWithFormat:@"bg_%03d.png",startIndex]];
//    self.bgLayer.contents = (id)bgImage.CGImage;
}
void drawFollowImage(CGContextRef context, CGImageRef image , CGRect rect,int rotation){
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, rect.origin.x+rect.size.width/2, rect.origin.y+rect.size.height/2);//先把左上角移动到rect中心点
    CGContextScaleCTM(context, 1.0, -1.0);//是因为之后如果绘图drawImage，正好绘制成正的。
    if(rotation < 0){
        rotation = rotation + 90;
    }else if(rotation ){
        rotation = rotation - 90;
    }
    CGContextRotateCTM(context, radians(-rotation));//然后旋转角度，这个旋转相对于画布的左上角。
    CGContextTranslateCTM(context, -rect.size.width/2, -rect.size.height/2);//然后再让rect的中心点和原来重合，注意此时已经是旋转后的坐标系统了。所以很简单，不用计算三角函数。
    CGContextDrawImage(context, CGRectMake(0, 0, rect.size.width,rect.size.height), image);
    CGContextRestoreGState(context);
}
void drawFixedImage(CGContextRef context, CGImageRef image , CGRect rect){
    CGContextSaveGState(context);
    CGContextScaleCTM(context, 1.0, -1.0);//是因为之后如果绘图drawImage，正好绘制成正的。
    CGContextTranslateCTM(context, 0, -(2*rect.origin.y+rect.size.height));
    CGContextDrawImage(context, rect, image);
    CGContextRestoreGState(context);
}

@end

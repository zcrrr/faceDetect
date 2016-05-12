//
//  StickerView.m
//  sample_face_track106
//
//  Created by babytree-ios on 16/5/4.
//  Copyright © 2016年 sensetime. All rights reserved.
//  贴纸层
//  贴纸类型：0-位置不动、内容不变；1-位置不动、内容变化；2-位置跟随、内容不变；3-位置跟随、内容变化。
//

#import "StickerView.h"
#import "HMSticker.h"
#import "SBJson.h"
#define radians(degrees) (degrees * M_PI/180)
static const float kMessageDisplayDuring = 2.0f;
#define screenScale ([UIScreen mainScreen].bounds.size.width / 480.0)

@interface StickerView()

@property (strong, nonatomic) NSMutableDictionary *m_DataSource;
@property (assign, nonatomic) BOOL m_isDataPrepared;
@property (strong, nonatomic) UILabel *m_MessageLabel;
// 类型为0的贴纸数组
@property (strong, nonatomic) NSMutableArray *m_StickersType0;
// 类型为1的贴纸数组
@property (strong, nonatomic) NSMutableArray *m_StickersType1;
// 类型为23的贴纸数组,一起处理
@property (strong, nonatomic) NSMutableArray *m_StickersType23;

@end

@implementation StickerView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.m_MessageLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetHeight(frame)/2 - 30, CGRectGetWidth(frame), 60)];
        self.m_MessageLabel.textColor = [UIColor blackColor];
        self.m_MessageLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.m_MessageLabel];
    }
    return self;
}
- (void)initData{
    self.m_DataSource = [[NSMutableDictionary alloc]init];
    self.m_StickersType0 = [[NSMutableArray alloc]init];
    self.m_StickersType1 = [[NSMutableArray alloc]init];
    self.m_StickersType23 = [[NSMutableArray alloc]init];
    //类型2，3是根据脸有多少张，就有多少份的存在，这里先初始化一张脸的内存空间。
    NSMutableArray *face1 = [[NSMutableArray alloc]init];
    [self.m_StickersType23 addObject:face1];
    self.m_MessageLabel.text = @"";
    self.m_isDataPrepared = NO;
}
- (void)hideMessage{
    [UIView animateWithDuration:1 animations:^{
        self.m_MessageLabel.alpha = 0;
    }];
}
- (NSString*)pathByName:(NSString*)name suffix:(NSString*)suffix catagory:(NSString*)catagory isDefault:(BOOL)isDefault{
    if(isDefault){
        return [[NSBundle mainBundle] pathForResource:name ofType:suffix];
    }else{
        NSArray *patharray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *path = [patharray[0] stringByAppendingString:[NSString stringWithFormat:@"/%@/%@.%@",catagory,name,suffix]];
        NSLog(@"path:%@",path);
        return path;
    }
}
- (void)prepareData:(NSString*)name catagory:(NSString*)catagory isDefault:(BOOL)isDefault{
    [self initData];
    // 显示一下message
    //    self.m_MessageLabel.alpha = 1;
    //    self.m_MessageLabel.text = @"张开嘴";
    //    [self performSelector:@selector(hideMessage) withObject:nil afterDelay:kMessageDisplayDuring];
    
    // 按照m_StickerName找到手机路径下的资源包
    NSString *infoTxt = [self pathByName:name suffix:@"txt" catagory:catagory isDefault:isDefault];
    NSString*str=[[NSString alloc] initWithContentsOfFile:infoTxt encoding:NSUTF8StringEncoding error:nil];
    SBJsonParser *jsonParser = [[SBJsonParser alloc]init];
    NSDictionary *infoDic = [jsonParser objectWithString:str];
    self.m_DataSource = [[NSMutableDictionary alloc]init];
    for(NSDictionary *item in infoDic[@"itemList"]){
        //对于每个item干两件事：创建对应的layer并加入到相应的容器，把需要的资源加载到m_DataSource
        NSString *resourceName = item[@"resourceName"];
        //把对应的png图片放入m_DataSource。（每个元素必须有个png，这里和类型没关系，无非png是一张图还是多张图拼的）
        NSString *path = [self pathByName:resourceName suffix:@"png" catagory:catagory isDefault:isDefault];
        UIImage *image = [UIImage imageWithContentsOfFile:path];
        NSString *imgkey = [NSString stringWithFormat:@"%@_img",resourceName];
        HMSticker *sticker = [[HMSticker alloc]init];
        sticker.m_Info = item;
        sticker.m_CurrentFrame = 0;
        // 按照json的顺序加入，保证了元素的上下层的关系
        [self.layer addSublayer:sticker];
        int type = [item[@"type"]intValue];
        switch (type) {
            case StickerTypePositionFixContentFix:
            {
                [self.m_StickersType0 addObject:sticker];
                self.m_DataSource[imgkey] = image;
                break;
            }
            case StickerTypePositionFixContentChange:
            {
                //如果内容变化，会有一个json文件对应
                NSString *path = [self pathByName:resourceName suffix:@"json" catagory:catagory isDefault:isDefault];
                NSString*str=[[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
                NSDictionary *itemjson = [jsonParser objectWithString:str];
                //每一帧对应的图片数据的数组
                NSMutableArray *frameImgs = [[NSMutableArray alloc]init];
                //所有图片数据的dic，个数会<=frameImgs的个数，因为有不同帧使用相同图片的情况
                NSMutableDictionary *allImages = [[NSMutableDictionary alloc]init];
                int frameCount = [item[@"frames"]intValue];
                for(int i = 0;i < frameCount;i++){
                    NSString *frameKey = [NSString stringWithFormat:@"%@_%03d",resourceName,i];
                    NSDictionary *thisFrameInfo = itemjson[@"frames"][frameKey];
                    int x = [thisFrameInfo[@"x"]intValue];
                    int y = [thisFrameInfo[@"y"]intValue];
                    NSString *imgKey = [NSString stringWithFormat:@"%i_%i",x,y];
                    if([[allImages allKeys]containsObject:imgkey]){
                        NSData *imgData = allImages[imgKey];
                        [frameImgs addObject:imgData];
                    }else{
                        @autoreleasepool {
                            NSData *imgData = [self generateImgFromBigImg:image byInfo:thisFrameInfo];
                            allImages[imgKey] = imgData;
                            [frameImgs addObject:imgData];
                        }
                    }
                }
                self.m_DataSource[imgkey] = frameImgs;
                [self.m_StickersType1 addObject:sticker];
                break;
            }
            case StickerTypePositionFollowContentFix:
            {
                [self.m_StickersType23[0] addObject:sticker];
                self.m_DataSource[imgkey] = image;
                break;
            }
            case StickerTypePositionFollowContentChange:
            {
                //如果内容变化，会有一个json文件对应
                NSString *path = [self pathByName:resourceName suffix:@"json" catagory:catagory isDefault:isDefault];
                NSString*str=[[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
                NSDictionary *itemjson = [jsonParser objectWithString:str];
                
                //每一帧对应的图片数据的数组
                NSMutableArray *frameImgs = [[NSMutableArray alloc]init];
                //所有图片数据的dic，个数会<=frameImgs的个数，因为有不同帧使用相同图片的情况
                NSMutableDictionary *allImages = [[NSMutableDictionary alloc]init];
                int frameCount = [item[@"frames"]intValue];
                for(int i = 0;i < frameCount;i++){
                    NSString *frameKey = [NSString stringWithFormat:@"%@_%03d",resourceName,i];
                    NSDictionary *thisFrameInfo = itemjson[@"frames"][frameKey];
                    int x = [thisFrameInfo[@"x"]intValue];
                    int y = [thisFrameInfo[@"y"]intValue];
                    NSString *imgKey = [NSString stringWithFormat:@"%i_%i",x,y];
                    if([[allImages allKeys]containsObject:imgkey]){
                        NSData *imgData = allImages[imgKey];
                        [frameImgs addObject:imgData];
                    }else{
                        @autoreleasepool {
                            NSData *imgData = [self generateImgFromBigImg:image byInfo:thisFrameInfo];
                            allImages[imgKey] = imgData;
                            [frameImgs addObject:imgData];
                        }
                    }
                }
                self.m_DataSource[imgkey] = frameImgs;
                [self.m_StickersType23[0] addObject:sticker];
                break;
            }
            default:
                break;
        }
    }
}
// 设置贴纸数据源
- (void)displayStickerByName:(NSString*)name catagory:(NSString*)catagory isDefault:(BOOL)isDefault{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        self.m_isDataPrepared = NO;
        [self prepareData:name catagory:catagory isDefault:isDefault];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.m_isDataPrepared = YES;
            [self drawStickerOnlyOnce];
        });
    });
//    NSLog(@"m_DataSource:%@",self.m_DataSource);
//    NSLog(@"m_StickersType0:%@",self.m_StickersType0);
//    NSLog(@"m_StickersType1:%@",self.m_StickersType1);
//    NSLog(@"m_StickersType23:%@",self.m_StickersType23);
}


- (void)refreshFaceData:(NSMutableArray*)persons{
    // 先判断数据源是否解析完毕，否则return
    if(!self.m_isDataPrepared)return;
    if([[self.m_DataSource allKeys] count] == 0)return;
    int faceCount = (int)[persons count];
    if(faceCount == 0){
        self.hidden = YES;
        return;
    }
    // 如果有小提示，说明有触发行为，则只支持一张脸
    if(![self.m_MessageLabel.text isEqualToString:@""]){
        faceCount = 1;
    }
    [self changeStickerType1Content];
    int alreadyHasFaces = (int)[self.m_StickersType23 count];
    //如果脸不够用，则动态创建新脸。
    for(int i = 0 ; i < faceCount - alreadyHasFaces; i++){
        NSMutableArray *face1 = self.m_StickersType23[0];
        NSMutableArray *faceNew = [[NSMutableArray alloc]init];
        for(HMSticker *sticker in face1){
            HMSticker *stickerOfNewFace = [sticker completeCopy];
            [faceNew addObject:stickerOfNewFace];
            [self.layer addSublayer:stickerOfNewFace];
        }
        [self.m_StickersType23 addObject:faceNew];
    }
    // 目前内存中的脸，必大于等于faceCount
    int hasFacesNow = (int)[self.m_StickersType23 count];
    // 开始渲染
    for(int i = 0 ; i < hasFacesNow; i++){
        if(i >= faceCount){
            NSMutableArray *stickers = self.m_StickersType23[i];
            for(HMSticker *sticker in stickers){
                sticker.contents = nil;
            }
            continue;
        }
        NSDictionary *dicPerson = persons[i];
        int roll = [[dicPerson objectForKey:@"roll"]intValue];
        NSMutableArray *stickers = self.m_StickersType23[i];
        for (HMSticker *sticker in stickers) {
            //算宽高
            int leftIndex = [sticker.m_Info[@"leftIndex"]intValue];
            int rightIndex = [sticker.m_Info[@"rightIndex"]intValue];
            int scaleWidth = [sticker.m_Info[@"scaleWidth"]intValue];
            NSMutableArray *pointList = [dicPerson objectForKey:@"POINTS_KEY"];
            int x1 = (CGPointFromString(pointList[leftIndex])).x;
            int y1 = (CGPointFromString(pointList[leftIndex])).y;
            int x2 = (CGPointFromString(pointList[rightIndex])).x;
            int y2 = (CGPointFromString(pointList[rightIndex])).y;
            
            float distance = sqrtf((float)((x1-x2)*(x1-x2)+(y1-y2)*(y1-y2)));
            float scale = distance / scaleWidth;
            float width = [sticker.m_Info[@"width"]floatValue]*scale;
            float height = [sticker.m_Info[@"height"]floatValue]*scale;
            //算位置
            int followx;
            int followy;
            NSArray *alignIndexList = sticker.m_Info[@"alignIndexList"];
            if([alignIndexList count] == 1){
                int alignIndex = [alignIndexList[0]intValue];
                followx = (CGPointFromString(pointList[alignIndex])).x;
                followy = (CGPointFromString(pointList[alignIndex])).y;
            }else if([alignIndexList count] == 2){
                int alignIndex1 = [alignIndexList[0]intValue];
                int alignIndex2 = [alignIndexList[1]intValue];
                CGPoint point1 = CGPointFromString(pointList[alignIndex1]);
                CGPoint point2 = CGPointFromString(pointList[alignIndex2]);
                followx = (point1.x + point2.x)/2;
                followy = (point1.y + point2.y)/2;
            }
            int alignX = [sticker.m_Info[@"alignX"]intValue];
            int alignY = [sticker.m_Info[@"alignY"]intValue];
            int targetX = followx + alignX * cosf(radians(roll)) * scale - alignY * sinf(radians(roll)) * scale;
            int targetY = followy + alignX * sinf(radians(roll)) * scale + alignY * cosf(radians(roll)) * scale;
            // 设置角度、位置、大小、贴图
            CGPoint stickerCenter = CGPointMake(targetX * screenScale, targetY * screenScale);
            if(sticker.m_LastRoll != roll){
                [self rotateStricker:roll :sticker];
                sticker.m_LastRoll = roll;
            }
            sticker.position = stickerCenter;
            sticker.bounds = CGRectMake(0, 0, width * screenScale, height * screenScale);
            
            [self changeStickerContent:sticker];
        }
    }
}
- (void)rotateStricker:(int)roll :(HMSticker*)sticker{
    sticker.transform = CATransform3DMakeRotation(radians(roll), 0, 0, 1);
}
// 执行一次就不用再改变的绘制：包括type0的全部绘制，以及type1的位置绘制。
- (void)drawStickerOnlyOnce{
    //type0的贴纸直接全部绘制出来
    for (HMSticker *sticker in self.m_StickersType0) {
        [self.layer addSublayer:sticker];
        float originx = [sticker.m_Info[@"x"] floatValue];
        float originy = [sticker.m_Info[@"y"] floatValue];
        float width = [sticker.m_Info[@"width"] floatValue];
        float height = [sticker.m_Info[@"height"] floatValue];
        
        NSString *imagekey = [NSString stringWithFormat:@"%@_img",sticker.m_Info[@"resourceName"]];
        UIImage *content = self.m_DataSource[imagekey];
        sticker.position = CGPointMake((originx + width/2) * screenScale, (originy + height/2) * screenScale);
        sticker.bounds = CGRectMake(0, 0, width * screenScale, height * screenScale);
        CGImageRef imgref = [content CGImage];
        sticker.contents = (__bridge id _Nullable)imgref;
    }
    //type1的贴纸可以先把轮廓绘制出来，稍后每帧改变内容。
    for (HMSticker *sticker in self.m_StickersType1) {
        [self.layer addSublayer:sticker];
        float originx = [sticker.m_Info[@"x"] floatValue];
        float originy = [sticker.m_Info[@"y"] floatValue];
        float width = [sticker.m_Info[@"width"] floatValue];
        float height = [sticker.m_Info[@"height"] floatValue];
        sticker.position = CGPointMake((originx + width/2) * screenScale, (originy + height/2) * screenScale);
        sticker.bounds = CGRectMake(0, 0, width * screenScale, height * screenScale);
    }
    for (HMSticker *sticker in self.m_StickersType23[0]) {
        [self.layer addSublayer:sticker];
    }
}
/// type为1的贴纸的内容改变，每帧一次
- (void)changeStickerType1Content{
    for (HMSticker *sticker in self.m_StickersType1) {
        [self changeStickerContent:sticker];
    }
}
- (void)changeStickerContent:(HMSticker*)sticker{
    //图片再也不用更新了，可能原因：1.循环一次就结束的sticer。2.type为2，设置过一次图片的sticer。
    if(sticker.m_TheEnd)return;
    // 元素名
    NSString *resourceName = sticker.m_Info[@"resourceName"];
    NSString *imageContent = [NSString stringWithFormat:@"%@_img",resourceName];
    if([sticker.m_Info[@"type"]intValue] == StickerTypePositionFollowContentFix){
        UIImage *staticImg = self.m_DataSource[imageContent];
        sticker.contents = (__bridge id _Nullable)([staticImg CGImage]);
        sticker.m_TheEnd = YES;
        return;
    }
    NSMutableArray *frameImgs = self.m_DataSource[imageContent];
    NSData *imgData = frameImgs[sticker.m_CurrentFrame];
    sticker.contents = (__bridge id _Nullable)([[UIImage imageWithData:imgData]CGImage]);
    sticker.m_CurrentFrame ++ ;
}
- (NSData*)generateImgFromBigImg:(UIImage*)bigImage byInfo:(NSDictionary*)jsonDic{
    int x = [jsonDic[@"x"]intValue];
    int y = [jsonDic[@"y"]intValue];
    int w = [jsonDic[@"w"]intValue];
    int h = [jsonDic[@"h"]intValue];
    int offX = [jsonDic[@"offX"]intValue];
    int offY = [jsonDic[@"offY"]intValue];
    int sourceW = [jsonDic[@"sourceW"]intValue];
    int sourceH = [jsonDic[@"sourceH"]intValue];
    CGRect rectimg = CGRectMake(x, y, w, h);
    CGImageRef imageRef = CGImageCreateWithImageInRect([bigImage CGImage], rectimg);
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(sourceW, sourceH),NO,1.0);
    [[UIImage imageWithCGImage:imageRef] drawInRect:CGRectMake(offX, offY, w, h)];
    UIImage *resultImage=UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CGImageRelease(imageRef);
    NSData *imgData = UIImagePNGRepresentation(resultImage);
    return imgData;
}
- (void)cvtest{
    self.m_DataSource = nil;
}


@end

//
//  ViewController.m
//  sample_face_track106
//
//  Created by huoqiuliang on 16/2/17.
//  Copyright © 2016年 sensetime. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "cv_face.h"
#import "CanvasView.h"
#import "SBJson.h"
#import "StickerView.h"
@interface ViewController () <AVCaptureVideoDataOutputSampleBufferDelegate>{
    int _screenWidth;
    int _screenHeight;
}

@property (nonatomic , strong) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer ;

@property (nonatomic) cv_handle_t hTracker;

@property (nonatomic , strong) CanvasView *viewCanvas ;
@property (nonatomic, strong) AVCaptureDevice *device;
@property (nonatomic, strong) NSDictionary *result;
@property (nonatomic, strong) UIImageView *iv;
@property (nonatomic, strong) StickerView *sv;

@end

int bgIndex = 0;

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor blackColor] ;
    self.hTracker = cv_face_create_tracker_106(NULL, CV_FACE_SKIP_BELOW_THRESHOLD|CV_TRACK_MULTI_TRACKING_106|CV_FACE_RESIZE_IMG_320W);
    cv_face_track_106_set_detect_face_cnt_limit(self.hTracker, 5);
    
    NSString*filePath=[[NSBundle mainBundle] pathForResource:@"glassEye"ofType:@"json"];
    
    NSString*str=[[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    NSLog(@"%@",str);
    
    SBJsonParser *jsonParser = [[SBJsonParser alloc]init];
    self.result = [jsonParser objectWithString:str];
    
    
}


- (void)didReceiveMemoryWarning { 
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    cv_face_destroy_tracker_106(self.hTracker);
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSLog(@"self.view:%f,%f",self.view.frame.size.width,self.view.frame.size.height);
    
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    // Added by tony
    session.sessionPreset = AVCaptureSessionPreset640x480;
    if (session.sessionPreset == AVCaptureSessionPreset1280x720) {
        _screenWidth = 720;
        _screenHeight = 1280;
    } else if (session.sessionPreset == AVCaptureSessionPreset640x480) {
        _screenWidth = 480;
        _screenHeight = 640;
    } else if (session.sessionPreset == AVCaptureSessionPreset352x288) {
        _screenWidth = 288;
        _screenWidth = 352;
    } else {
        _screenWidth = 480;
        _screenHeight = 640;
    }
    // to here, get the frame size.
    self.captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
    self.captureVideoPreviewLayer.frame = CGRectMake( 0, 0, 480, 640 ) ;
    self.captureVideoPreviewLayer.position = self.view.center;
    [self.captureVideoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [self.view.layer addSublayer:self.captureVideoPreviewLayer];
    
//    self.iv = [[UIImageView alloc]initWithFrame:self.captureVideoPreviewLayer.frame];
//    [self.view addSubview:self.iv];
    
    
    
//    self.viewCanvas = [[CanvasView alloc] initWithFrame:self.captureVideoPreviewLayer.frame] ;
//    [self.view addSubview:self.viewCanvas] ;
//    self.viewCanvas.backgroundColor = [UIColor clearColor] ;
//    self.viewCanvas.imgDic = [self.result objectForKey:@"frames"];
//    self.viewCanvas.bgimage = [UIImage imageNamed:@"glassEye.png"];
    
    self.sv = [[StickerView alloc]initWithFrame:self.captureVideoPreviewLayer.frame];
    [self.sv displayStickerByName:@"glassEye" type:@"" isDefault:YES];
    [self.view addSubview:self.sv];
//
//    UIView* myview = [[UIView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height - 80, self.view.frame.size.width, 80)];
//    myview.backgroundColor = [UIColor yellowColor];
//    [self.view addSubview:myview];
    
    AVCaptureDevice *deviceFront ;
    
    NSArray *devices = [AVCaptureDevice devices];
    for (AVCaptureDevice *device in devices) {
        if ([device hasMediaType:AVMediaTypeVideo]) {
            
            if ([device position] == AVCaptureDevicePositionFront) {
                deviceFront = device;
            }
        }
    }
    self.device = deviceFront;
    
    
    
    
    
    
    NSError *error = nil;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:deviceFront error:&error];
    if (!input) {
        // Handle the error appropriately.
        NSLog(@"ERROR: trying to open camera: %@", error);
    }
    AVCaptureVideoDataOutput * dataOutput = [[AVCaptureVideoDataOutput alloc] init];
    [dataOutput setAlwaysDiscardsLateVideoFrames:YES];
    [dataOutput setVideoSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange] forKey:(id)kCVPixelBufferPixelFormatTypeKey]];
    
    [dataOutput setSampleBufferDelegate:self queue:dispatch_queue_create("createDataOutputQueue", NULL)];
    
    
    [session beginConfiguration];
    if ([session canAddInput:input]) {
        [session addInput:input];
        UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
        self.captureVideoPreviewLayer.connection.videoOrientation = (AVCaptureVideoOrientation)deviceOrientation;
    }
    if ([session canAddOutput:dataOutput]) {
        [session addOutput:dataOutput];
    }
    //下面这段代码可以设置output频率但是其他相关设置也得对应上。
//    for(AVCaptureDeviceFormat *vFormat in [self.device formats])
//    {
//        CMFormatDescriptionRef description= vFormat.formatDescription;
//        float maxrate=((AVFrameRateRange*)[vFormat.videoSupportedFrameRateRanges objectAtIndex:0]).maxFrameRate;
//        NSLog(@"maxrate is %f",maxrate);
//        if(maxrate>59 && CMFormatDescriptionGetMediaSubType(description)==kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)
//        {
//            if ( YES == [self.device lockForConfiguration:NULL] )
//            {
//                self.device.activeFormat = vFormat;
//                [self.device setActiveVideoMinFrameDuration:CMTimeMake(1,15)];
//                [self.device setActiveVideoMaxFrameDuration:CMTimeMake(1,15)];
//                [self.device unlockForConfiguration];
//                NSLog(@"formats  %@ %@ %@",vFormat.mediaType,vFormat.formatDescription,vFormat.videoSupportedFrameRateRanges);
//            }
//        }
//    }
    [session commitConfiguration];
    
    [session startRunning];
}

-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
//    NSLog(@"frame is %i",frame++);
    CVPixelBufferRef pixelBuffer = (CVPixelBufferRef)CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    // For BGRA(aka kCVPixelFormatType_32BGRA)
    //    uint8_t *baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer);
    // For NV12(aka kCVPixelFormatType_420YpCbCr8BiPlanarFullRange) compat with kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange
    uint8_t *baseAddress = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0);
    
    cv_face_106_t *pFaceRectID = NULL;
    int iCount = 0;
    
    int iWidth  = (int)CVPixelBufferGetWidth(pixelBuffer);
    int iHeight = (int)CVPixelBufferGetHeight(pixelBuffer);

    cv_result_t iRet = CV_OK;
    
    UIDeviceOrientation iDeviceOrientation = [[UIDevice currentDevice]orientation];
    
    cv_face_orientation face_orientation;
    
    switch (iDeviceOrientation) {
        case UIDeviceOrientationPortrait:
            face_orientation = CV_FACE_LEFT;
//            NSLog(@"left");
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            face_orientation = CV_FACE_RIGHT;
//            NSLog(@"right");
            break;
        case UIDeviceOrientationLandscapeLeft:
            face_orientation = CV_FACE_DOWN;
//            NSLog(@"down");
            break;
        case UIDeviceOrientationLandscapeRight:
            face_orientation = CV_FACE_UP;
//            NSLog(@"up");
            break;
        default:
            face_orientation = CV_FACE_LEFT;
            break;
    }
    iRet = cv_face_track_106(self.hTracker, baseAddress, CV_PIX_FMT_NV12, iWidth, iHeight, iWidth * 4, face_orientation, &pFaceRectID, &iCount);
    
    BOOL mirror = NO;
    if (self.device.position == AVCaptureDevicePositionFront) {
        mirror = YES;
    }
    if ( iRet == CV_OK && iCount > 0 ) {
        
        NSMutableArray *arrPersons = [NSMutableArray array] ;
        for (int i = 0; i < iCount ; i ++) {
            
            cv_face_106_t rectIDMain = pFaceRectID[i] ;
            
            NSMutableArray *arrStrPoints = [NSMutableArray array] ;
//            NSLog(@"rotation is %i",rectIDMain.roll);
            CGRect rectFace = CGRectZero;
            
            cv_pointf_t *facialPoints = rectIDMain.points_array;
            // Modified by tony
            for(int i = 0; i < rectIDMain.points_count; i ++) {
                if (mirror) {
                    [arrStrPoints addObject:NSStringFromCGPoint(CGPointMake(facialPoints[i].y, facialPoints[i].x))] ;
                } else {
                    [arrStrPoints addObject:NSStringFromCGPoint(CGPointMake(_screenWidth - facialPoints[i].y, facialPoints[i].x))] ;
                }
            }
            
            cv_rect_t rect = rectIDMain.rect ;
            if (mirror) {
                rectFace = CGRectMake(rect.top, rect.left, rect.right - rect.left, rect.bottom - rect.top);
            } else {
                rectFace = CGRectMake(_screenWidth - rect.top - (rect.right - rect.left) , rect.left , rect.right - rect.left, rect.bottom - rect.top);
            }
            // To decide whether mirror the rect or not.
            NSMutableDictionary *dicPerson = [NSMutableDictionary dictionary] ;
            [dicPerson setObject:arrStrPoints forKey:POINTS_KEY];
            [dicPerson setObject:NSStringFromCGRect(rectFace) forKey:RECT_KEY];
            [dicPerson setObject:[NSNumber numberWithInt:rectIDMain.roll] forKey:@"roll"];
            
            [arrPersons addObject:dicPerson] ;
        }
//        NSLog(@"y:%f",pFaceRectID[0].points_array[0].y);
//        NSLog(@"count:%i",pFaceRectID[0].points_count);
        dispatch_async(dispatch_get_main_queue(), ^{
//            NSLog(@"y:%f",pFaceRectID[0].points_array[0].y);
//            NSLog(@"count:%i",pFaceRectID[0].points_count);
//            [self showFaceLandmarksAndFaceRectWithPersonsArray:arrPersons];
            [self.sv refreshFaceData:arrPersons];
            
            
            if (self.sv.hidden) {
                self.sv.hidden = NO ;
            }

        } ) ;
        
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideFace];
        } ) ;
    }
    cv_face_release_tracker_106_result(pFaceRectID, iCount);
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
}
- (void)prepareDate4StickerView{//改变sticerview的数据源，一般都是点击某个贴纸buttong后调用一次。
//    self.viewCanvas.imgDic = [self.result objectForKey:@"frames"];
//    self.viewCanvas.bgimage = [UIImage imageNamed:@"glassEye.png"];
}

- (void) showFaceLandmarksAndFaceRectWithPersonsArray:(NSMutableArray *)arrPersons
{
    self.viewCanvas.hidden = YES;
//    if (self.viewCanvas.hidden) {
//        self.viewCanvas.hidden = NO ;
//    }
//    self.viewCanvas.arrPersons = arrPersons ;
//    [self.viewCanvas setNeedsDisplay] ;
    
    
}
- (void) hideFace {
    if (!self.viewCanvas.hidden) {
        self.viewCanvas.hidden = YES ;
    }
    if (!self.sv.hidden) {
        self.sv.hidden = YES ;
    }
}

@end

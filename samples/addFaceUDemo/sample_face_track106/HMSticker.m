//
//  HMSticker.m
//  sample_face_track106
//
//  Created by babytree-ios on 16/5/5.
//  Copyright © 2016年 sensetime. All rights reserved.
//

#import "HMSticker.h"

@implementation HMSticker




- (instancetype)init{
    self = [super init];
    if (self) {
        NSLog(@"create layer");
        NSDictionary *actions = @{@"bounds":[NSNull null],@"position":[NSNull null],@"transform":[NSNull null],@"contents":[NSNull null]};
        self.actions = actions;
    }
    return self;
}
- (void)setM_CurrentFrame:(int)m_CurrentFrame{
    _m_CurrentFrame = m_CurrentFrame;
    int frames = [self.m_Info[@"frames"] intValue];
    //一个循环
    if(m_CurrentFrame == frames){
        _m_CurrentFrame = 0;
        int looping = [self.m_Info[@"looping"] intValue];
        if(looping == 0){
            self.m_TheEnd = YES;
            if([[self.m_Info allKeys]containsObject:@"showUtilFinish"]){
                int showUtilFinish = [self.m_Info[@"showUtilFinish"] intValue];
                if(showUtilFinish == 0){
                    self.contents = nil;
                }
            }
        }
    }
}
- (HMSticker*)completeCopy{
    HMSticker *sticker = [[HMSticker alloc]init];
    // 这里是地址复制，浅拷贝，因为m_info不需要更改，第一次赋值之后是只读的。而且还有节省内存的好处。
    sticker.m_Info = self.m_Info;
    return sticker;
}

@end

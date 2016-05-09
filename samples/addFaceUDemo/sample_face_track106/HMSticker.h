//
//  HMSticker.h
//  sample_face_track106
//
//  Created by babytree-ios on 16/5/5.
//  Copyright © 2016年 sensetime. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface HMSticker : CALayer

@property (assign, nonatomic) int m_CurrentFrame;
@property (strong, nonatomic) NSDictionary *m_Info;

@property (assign, nonatomic) int m_LastX;
@property (assign, nonatomic) int m_LastY;
@property (assign, nonatomic) int m_LastRoll;

@property (assign, nonatomic) BOOL m_TheEnd;

- (HMSticker*)completeCopy;




@end

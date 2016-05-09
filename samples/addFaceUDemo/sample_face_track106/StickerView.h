//
//  StickerView.h
//  sample_face_track106
//
//  Created by babytree-ios on 16/5/4.
//  Copyright © 2016年 sensetime. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, STICKERTYPE)
{
    StickerTypePositionFixContentFix = 0,
    StickerTypePositionFixContentChange,
    StickerTypePositionFollowContentFix,
    StickerTypePositionFollowContentChange
};
@interface StickerView : UIView

/// 点击某个贴纸,name:贴纸名  type:大类  isDefault:是否安装时自带
- (void)displayStickerByName:(NSString*)name type:(NSString*)type isDefault:(BOOL)isDefault;

/// 人脸识别数据结果
- (void)refreshFaceData:(NSMutableArray*)persons;



@end

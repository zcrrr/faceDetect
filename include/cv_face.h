
#ifndef INCLUDE_CVFACE_API_CV_FACE_H_
#define INCLUDE_CVFACE_API_CV_FACE_H_

#include "cv_common.h"

/// @defgroup cvface_common cvface common
/// @brief Common definitions for cvface
/// @{

/// @brief 人脸信息结构体
typedef struct cv_face_t {
	cv_rect_t rect;			///< 代表面部的矩形区域
	float score;			///< 置信度，用于筛除负例，与人脸照片质量无关，值越高表示置信度越高。
	cv_pointf_t points_array[21];	///< 人脸21关键点的数组
	int points_count;		///< 人脸21关键点数组的长度，如果没有计算关键点，则为0
	int yaw;			///< 水平转角，真实度量的左负右正
	int pitch;			///< 俯仰角，真实度量的上负下正
	int roll;			///< 旋转角，真实度量的左负右正
	int eye_dist;			///< 两眼间距
	int ID;				///< faceID，用于表示在实时人脸跟踪中的相同人脸在不同帧多次出现，在人脸检测的结果中无实际意义
} cv_face_t;

/// common config flags, 0x------00 ~ 0x------FF
#define CV_FACE_DEFAULT_CONFIG		0x00000000  ///< 默认选项，不设置任何开关
#define CV_FACE_SKIP_BELOW_THRESHOLD	0x00000001  ///< 检测阈值开关，开启时会将置信度低于阈值的人脸过滤掉，相应误检少，漏检多；关闭则会输出所有检测到的脸，误检多，漏检少，需要自行过滤
#define CV_FACE_RESIZE_IMG_320W		0x00000002  ///< resize图像为长边320的图像
#define CV_FACE_RESIZE_IMG_640W		0x00000004  ///< resize图像为长边640的图像
#define CV_FACE_RESIZE_IMG_1280W	0x00000008  ///< resize图像为长边1280的图像

/// @brief  人脸朝向
typedef enum {
	CV_FACE_UP = 0,		///< 人脸向上，即人脸朝向正常
	CV_FACE_LEFT = 1,	///< 人脸向左，即人脸被逆时针旋转了90度
	CV_FACE_DOWN = 2,	///< 人脸向下，即人脸被逆时针旋转了180度
	CV_FACE_RIGHT = 3	///< 人脸向右，即人脸被逆时针旋转了270度
} cv_face_orientation;

/// @brief  输出当前SDK所支持的算法及内置模型信息
CV_SDK_API
void
cv_face_algorithm_info();

/// @}


/// @defgroup cvface_track cvface 106 points track
/// @brief face 106 points tracking interfaces
///
/// This set of interfaces processing face 106 points tracking routines
///
/// @{

#define CV_TRACK_MULTI_TRACKING_106	0x00010000  ///< 多人脸跟踪选项，开启跟踪所有检测到的人脸，关闭只跟踪检测到的人脸中最大的一张脸

/// @brief 供106点track使用
typedef struct cv_face_106_t {
	cv_rect_t rect;			///< 代表面部的矩形区域
	float score;			///< 置信度，用于筛除负例，与人脸照片质量无关，值越高表示置信度越高。
	cv_pointf_t points_array[106];	///< 人脸106关键点的数组
	int points_count;		///< 人脸106关键点数组的长度，如果没有计算关键点，则为0
	int yaw;			///< 水平转角，真实度量的左负右正
	int pitch;			///< 俯仰角，真实度量的上负下正
	int roll;			///< 旋转角，真实度量的左负右正
	int eye_dist;			///< 两眼间距
	int ID;				///< faceID，用于表示在实时人脸跟踪中的相同人脸在不同帧多次出现，在人脸检测的结果中无实际意义
} cv_face_106_t;

/// @brief 创建实时人脸106关键点跟踪句柄
/// @param model_path 模型文件的绝对路径或相对路径，若不指定模型可为NULL
/// @param config 配置选项，推荐使用 CV_FACE_SKIP_BELOW_THRESHOLD | CV_TRACK_MULTI_TRACKING
/// @return 成功返回人脸跟踪句柄，失败返回NULL
CV_SDK_API
cv_handle_t
cv_face_create_tracker_106(
	const char *model_path,
	unsigned int config
);

/// @brief 销毁已初始化的实时人脸106关键点跟踪句柄
/// @param tracker_handle 已初始化的实时人脸跟踪句柄
CV_SDK_API
void
cv_face_destroy_tracker_106(
	cv_handle_t tracker_handle
);

/// @brief 对连续视频帧进行实时快速人脸106关键点跟踪
/// @param tracker_handle 已初始化的实时人脸跟踪句柄
/// @param image 用于检测的图像数据
/// @param piexl_format 用于检测的图像数据的像素格式
/// @param image_width 用于检测的图像的宽度(以像素为单位)
/// @param image_height 用于检测的图像的高度(以像素为单位)
/// @param image_stride 用于检测的图像中每一行的跨度(以像素为单位)
/// @param orientation 视频中人脸的方向
/// @param p_faces_array 检测到的人脸信息数组，api负责分配内存，需要调用cv_facesdk_release_tracker_result函数释放
/// @param p_faces_count 检测到的人脸数量
/// @return 成功返回CV_OK，否则返回错误类型
CV_SDK_API
cv_result_t
cv_face_track_106(
	cv_handle_t tracker_handle,
	const unsigned char *image,
	cv_pixel_format pixel_format,
	int image_width,
	int image_height,
	int image_stride,
	cv_face_orientation orientation,
	cv_face_106_t **p_faces_array,
	int *p_faces_count
);

/// @brief 重置人脸106关键点跟踪
/// @param tracker_handle 已初始化的实时人脸跟踪句柄
CV_SDK_API
void
cv_face_reset_tracker_106(
	cv_handle_t tracker_handle
);

/// @brief 释放实时人脸106关键点跟踪返回结果时分配的空间
/// @param faces_array 检测到的人脸信息数组
/// @param faces_count 检测到的人脸数量
CV_SDK_API
void
cv_face_release_tracker_106_result(
	cv_face_106_t *faces_array,
	int faces_count
);

/// @brief 设置检测到的最大人脸数目N，持续track已检测到的N个人脸直到人脸数小于N再继续做detect
/// @param tracker_handle 已初始化的实时人脸跟踪句柄
/// @param detect_face_cnt_limit 最大人脸数目N，-1表示不设上限
/// @return 成功返回CV_OK，否则返回错误类型
CV_SDK_API
cv_result_t
cv_face_track_106_set_detect_face_cnt_limit(
	cv_handle_t tracker_handle,
	int detect_face_cnt_limit
);

/// @}


#endif  // INCLUDE_CVFACE_API_CV_FACE_H_
